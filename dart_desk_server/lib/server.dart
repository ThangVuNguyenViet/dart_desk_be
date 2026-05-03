import 'dart:io' show Directory;

import 'package:dart_desk_server/src/services/email_service.dart';
import 'package:dart_desk_server/src/web/configure_web_routes.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_cloud_storage_s3/serverpod_cloud_storage_s3.dart';
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart'
    hide Protocol, Endpoints;
import 'package:serverpod_auth_idp_server/core.dart';
import 'package:serverpod_auth_idp_server/providers/email.dart';
import 'package:serverpod_auth_idp_server/providers/google.dart';

import 'src/auth/api_key_validator.dart';
import 'src/auth/compound_token_parser.dart';
import 'src/generated/endpoints.dart';
import 'src/generated/protocol.dart';
import 'src/plugin/dart_desk_plugin.dart';
import 'src/plugin/dart_desk_registry.dart';
import 'src/plugin/dart_desk_session.dart';
import 'src/services/document_crdt_service.dart';
import 'src/services/purge_service.dart'; // ignore: unused_import — used by PurgeFutureCall (see TODO below)
import 'src/services/rate_limiter.dart';

/// This is the starting point of your Serverpod server. In most cases, you will
/// only need to make additions to this file if you add future calls, routes, or
/// extensions that require setup at startup.
void run(List<String> args, {List<DartDeskPlugin> plugins = const []}) async {
  final registry = DartDeskRegistry();

  // Load plugins
  for (final plugin in plugins) {
    plugin.register(registry);
  }

  // Make registry available to session extensions.
  DartDeskSession.setRegistry(registry);

  // Initialize Serverpod and connect it with your generated code.
  final pod = Serverpod(
    args,
    Protocol(),
    Endpoints(),
  );

  // Initialize email service from SMTP passwords.
  _emailService = _initEmailService(pod);

  // Initialize CRDT service with node ID from passwords.yaml
  final nodeId = pod.getPassword('crdtNodeId') ?? 'postgres-main';
  registry.documentCrdtService = DocumentCrdtService(nodeId);

  // Register S3 cloud storage for production/staging (skipped in development
  // where the passwords entry is absent — falls back to database storage).
  final s3Bucket = pod.getPassword('s3Bucket');
  final awsRegion = pod.getPassword('awsRegion');
  final s3PublicHost = pod.getPassword('s3PublicHost');
  if (s3Bucket != null && awsRegion != null) {
    pod.addCloudStorage(S3CloudStorage(
      serverpod: pod,
      storageId: 'public',
      public: true,
      region: awsRegion,
      bucket: s3Bucket,
      publicHost: s3PublicHost,
    ));
  }

  configureWebRoutes(
    pod.webServer.addRoute,
    setFallback: (route) => pod.webServer.fallbackRoute = route,
    studioDomain: pod.getPassword('studioDomain') ?? 'app.dartdesk.dev',
    publicStorageDir: Directory('storage/public'),
    staticDir: Directory('static'),
  );

  pod.initializeAuthServices(
    tokenManagerBuilders: [
      JwtConfigFromPasswords(),
    ],
    identityProviderBuilders: [
      GoogleIdpConfig(
        clientSecret: GoogleClientSecret.fromJsonString(
          pod.getPassword('googleClientSecret')!,
        ),
      ),
      EmailIdpConfigFromPasswords(
        sendRegistrationVerificationCode: _sendRegistrationCode,
        sendPasswordResetVerificationCode: _sendPasswordResetCode,
        maxPasswordResetAttempts: const RateLimit(
          timeframe: Duration(hours: 1),
          maxAttempts: 10,
        ),
      ),
    ],
  );

  // TODO(purge): Schedule daily purge of soft-deleted records using a
  // FutureCall. Requires defining a PurgeFutureCall class and running
  // `serverpod generate`. Retention period is configured via
  // `softDeleteRetentionDays` in passwords.yaml (default: 30 days).
  // Example: pod.futureCalls.callWithDelay(Duration(hours: 24)).purge.doWork()
  // See PurgeService for the purge logic.

  // Override the authentication handler to chain JWT auth + API key auth.
  // initializeAuthServices sets the default JWT handler; we wrap it to also
  // support project API keys passed as "jwtToken:apiKey" compound tokens.
  final cloudAdminKey = pod.getPassword('cloudAdminKey');
  final defaultHandler = pod.authenticationHandler;
  final authRateLimiter = RateLimiter(maxAttempts: 1000, windowDuration: Duration(minutes: 1));
  pod.authenticationHandler = (session, token) async {
      final tokenKey = token.length > 8 ? token.substring(0, 8) : token;
      if (!authRateLimiter.isAllowed(tokenKey)) {
        session.log('Rate limited auth attempt', level: LogLevel.warning);
        return null;
      }
    // Cloud admin: a single privileged key stored in passwords.yaml / env.
    if (cloudAdminKey != null &&
        cloudAdminKey.isNotEmpty &&
        token == cloudAdminKey) {
      return AuthenticationInfo(
        'cloud-admin',
        {
          Scope('admin'),
          Scope('project.read'),
          Scope('project.write'),
        },
        authId: 'cloud-admin',
      );
    }

    final parsed = CompoundTokenParser.parse(token);
    final authToken = parsed.jwtToken;
    final apiKey = parsed.apiKey;

    final scopes = <Scope>{};
    String? userIdentifier;
    String? authId;

    if (authToken != null && authToken.isNotEmpty && authToken != 'null') {
      try {
        final authInfo = await defaultHandler?.call(session, authToken);
        if (authInfo != null) {
          userIdentifier = authInfo.userIdentifier;
          authId = authInfo.authId;
          scopes.addAll(authInfo.scopes);
          // JWT tokens may carry no scopes; ensure authenticated users are
          // never rejected solely because the scope set is empty.
          if (authInfo.scopes.isEmpty) {
            scopes.add(Scope('user'));
          }
        }
      } catch (_) {
        // Ignore JWT errors and continue. The request may still authenticate
        // through a project API key.
      }
    }

    if (apiKey != null && apiKey.isNotEmpty && apiKey != 'null') {
      final tokenRow = await ApiKeyValidator.validate(session, apiKey);
      if (tokenRow != null) {
        final project = await Project.db.findById(session, tokenRow.projectId);
        if (project != null) {
          scopes.add(Scope('project:${project.id}'));
          scopes.add(Scope('project.read'));
          if (tokenRow.role == 'write' ||
              tokenRow.role == 'editor' ||
              tokenRow.role == 'admin') {
            scopes.add(Scope('project.write'));
          }
          scopes.add(Scope('client:${project.clientId}'));
          userIdentifier ??= 'api-token:${tokenRow.id}';
          authId ??= 'api-token:${tokenRow.id}';
        }
      }
    }

    if (userIdentifier == null || authId == null) {
      return null;
    }

    return AuthenticationInfo(
      userIdentifier,
      scopes,
      authId: authId,
    );
  };

  // Start the server.
  await pod.start();

  // Run plugin startup hooks.
  for (final plugin in plugins) {
    await plugin.onStartup(pod);
  }
  await registry.runStartupHooks(pod);
}

EmailService? _emailService;

EmailService? _initEmailService(Serverpod pod) {
  final smtpHost = pod.getPassword('smtpHost');
  if (smtpHost == null || smtpHost.isEmpty) return null;

  return EmailService(SmtpConfig(
    host: smtpHost,
    port: int.tryParse(pod.getPassword('smtpPort') ?? '587') ?? 587,
    username: pod.getPassword('smtpUsername') ?? '',
    password: pod.getPassword('smtpPassword') ?? '',
    fromAddress:
        pod.getPassword('emailFromAddress') ?? pod.getPassword('smtpUsername') ?? '',
    fromName: pod.getPassword('emailFromName') ?? 'Dart Desk',
  ));
}

Future<void> _sendRegistrationCode(
  Session session, {
  required String email,
  required UuidValue accountRequestId,
  required String verificationCode,
  required Transaction? transaction,
}) async {
  session.log('Registration code ($email): $verificationCode', level: LogLevel.info);
  await _sendEmail(
    session: session,
    to: email,
    subject: 'Your Dart Desk verification code',
    text: 'Your verification code is: $verificationCode',
    html:
        '<p>Your Dart Desk verification code is: <strong>$verificationCode</strong></p>',
  );
}

Future<void> _sendPasswordResetCode(
  Session session, {
  required String email,
  required UuidValue passwordResetRequestId,
  required String verificationCode,
  required Transaction? transaction,
}) async {
  session.log('Password reset code ($email): $verificationCode', level: LogLevel.info);
  await _sendEmail(
    session: session,
    to: email,
    subject: 'Your Dart Desk password reset code',
    text: 'Your password reset code is: $verificationCode',
    html:
        '<p>Your Dart Desk password reset code is: <strong>$verificationCode</strong></p>',
  );
}

Future<void> _sendEmail({
  required Session session,
  required String to,
  required String subject,
  required String text,
  required String html,
}) async {
  final service = _emailService;
  if (service == null) {
    session.log('[EmailIdp] smtpHost not configured — skipping SMTP send', level: LogLevel.warning);
    return;
  }

  try {
    await service.send(to: to, subject: subject, text: text, html: html);
    session.log('[EmailIdp] Email sent to $to', level: LogLevel.info);
  } catch (e) {
    session.log('[EmailIdp] Failed to send email to $to: $e', level: LogLevel.error);
  }
}
