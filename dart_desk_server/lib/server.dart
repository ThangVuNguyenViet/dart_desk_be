import 'dart:io';

import 'package:dart_desk_server/src/web/routes/root.dart';
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
  final defaultHandler = pod.authenticationHandler;
  pod.authenticationHandler = (session, token) async {
    final parts = token.split(':');
    final authToken = parts[0];
    final apiKey = parts.length > 1 ? parts[1] : null;

    final scopes = <Scope>{};
    String? userIdentifier;
    String? authId;

    if (authToken.isNotEmpty && authToken != 'null') {
      try {
        final authInfo = await defaultHandler?.call(session, authToken);
        if (authInfo != null) {
          userIdentifier = authInfo.userIdentifier;
          authId = authInfo.authId;
          scopes.addAll(authInfo.scopes);
        }
      } catch (_) {
        // Ignore JWT errors and continue. The request may still authenticate
        // through a project API key.
      }
    }

    if (apiKey != null && apiKey.isNotEmpty && apiKey != 'null') {
      final tokenRow = await ApiKeyValidator.validate(session, apiKey);
      if (tokenRow != null) {
        final project =
            await Project.db.findById(session, tokenRow.projectId);
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

    if (scopes.isEmpty || userIdentifier == null || authId == null) {
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
}

void _sendPasswordResetCode(
  Session session, {
  required String email,
  required UuidValue passwordResetRequestId,
  required String verificationCode,
  required Transaction? transaction,
}) {
  session.log('[EmailIdp] Password reset code ($email): $verificationCode');
}
