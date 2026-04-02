import 'dart:io';

import 'package:dart_desk_server/src/web/routes/root.dart';
import 'package:mailer/mailer.dart' as mailer;
import 'package:mailer/smtp_server.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart'
    hide Protocol, Endpoints;
import 'package:serverpod_auth_idp_server/core.dart';
import 'package:serverpod_auth_idp_server/providers/email.dart';
import 'package:serverpod_auth_idp_server/providers/google.dart';

import 'src/auth/api_key_validator.dart';
import 'src/generated/endpoints.dart';
import 'src/generated/protocol.dart';
import 'src/plugin/dart_desk_plugin.dart';
import 'src/plugin/dart_desk_registry.dart';
import 'src/plugin/dart_desk_session.dart';
import 'src/services/document_crdt_service.dart';

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

  // Initialize CRDT service with node ID from passwords.yaml
  final nodeId = pod.getPassword('crdtNodeId') ?? 'postgres-main';
  registry.documentCrdtService = DocumentCrdtService(nodeId);

  // Setup a default page at the web root.
  pod.webServer.addRoute(RouteRoot(), '/');
  pod.webServer.addRoute(RouteRoot(), '/index.html');

  // Serve uploaded files from storage/public directory
  pod.webServer.addRoute(
    StaticRoute.directory(Directory('storage/public')),
    '/files/*',
  );

  // Serve all files in the /static directory.
  pod.webServer.addRoute(
    StaticRoute.directory(Directory('static')),
    '/*',
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
      ),
    ],
  );

  // Override the authentication handler to chain JWT auth + API key auth.
  // initializeAuthServices sets the default JWT handler; we wrap it to also
  // support project API keys passed as "jwtToken:apiKey" compound tokens.
  final cloudAdminKey = pod.getPassword('cloudAdminKey');
  final defaultHandler = pod.authenticationHandler;
  pod.authenticationHandler = (session, token) async {
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

    final parts = token.split(':');
    final hasCompound = parts.length > 1;
    final authToken = hasCompound ? parts[0] : token;
    final apiKey = hasCompound ? parts[1] : null;

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
          scopes.add(Scope('project:${project.id!}'));
          scopes.add(Scope('project.read'));
          if (tokenRow.role == 'write' ||
              tokenRow.role == 'editor' ||
              tokenRow.role == 'admin') {
            scopes.add(Scope('project.write'));
          }
          scopes.add(Scope('client:${project.clientId}'));
          userIdentifier ??= 'api-token:${tokenRow.id!}';
          authId ??= 'api-token:${tokenRow.id!}';
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

void _sendRegistrationCode(
  Session session, {
  required String email,
  required UuidValue accountRequestId,
  required String verificationCode,
  required Transaction? transaction,
}) {
  session.log('[EmailIdp] Registration code ($email): $verificationCode');
  stdout.writeln('[EmailIdp] Registration code ($email): $verificationCode');
  _sendSmtpEmail(
    session: session,
    to: email,
    subject: 'Your Dart Desk verification code',
    text: 'Your verification code is: $verificationCode',
    html:
        '<p>Your Dart Desk verification code is: <strong>$verificationCode</strong></p>',
  );
}

void _sendPasswordResetCode(
  Session session, {
  required String email,
  required UuidValue passwordResetRequestId,
  required String verificationCode,
  required Transaction? transaction,
}) {
  session.log('[EmailIdp] Password reset code ($email): $verificationCode');
  stdout.writeln('[EmailIdp] Password reset code ($email): $verificationCode');
  _sendSmtpEmail(
    session: session,
    to: email,
    subject: 'Your Dart Desk password reset code',
    text: 'Your password reset code is: $verificationCode',
    html:
        '<p>Your Dart Desk password reset code is: <strong>$verificationCode</strong></p>',
  );
}

Future<void> _sendSmtpEmail({
  required Session session,
  required String to,
  required String subject,
  required String text,
  required String html,
}) async {
  final pod = Serverpod.instance;
  final smtpHost = pod.getPassword('smtpHost');
  if (smtpHost == null || smtpHost.isEmpty) {
    session.log('[EmailIdp] smtpHost not configured — skipping SMTP send');
    return;
  }

  final smtpPort = int.tryParse(pod.getPassword('smtpPort') ?? '587') ?? 587;
  final smtpUsername = pod.getPassword('smtpUsername') ?? '';
  final smtpPassword = pod.getPassword('smtpPassword') ?? '';
  final fromAddress = pod.getPassword('emailFromAddress') ?? smtpUsername;
  final fromName = pod.getPassword('emailFromName') ?? 'Dart Desk';

  final smtpServer = SmtpServer(
    smtpHost,
    port: smtpPort,
    username: smtpUsername,
    password: smtpPassword,
  );

  final message = mailer.Message()
    ..from = mailer.Address(fromAddress, fromName)
    ..recipients.add(to)
    ..subject = subject
    ..text = text
    ..html = html;

  try {
    await mailer.send(message, smtpServer);
    session.log('[EmailIdp] Email sent to $to');
  } catch (e) {
    session.log('[EmailIdp] Failed to send email to $to: $e',
        level: LogLevel.error);
    stderr.writeln('[EmailIdp] Failed to send email to $to: $e');
  }
}
