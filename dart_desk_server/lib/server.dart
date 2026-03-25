import 'dart:io';

import 'package:dart_desk_server/src/web/routes/root.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';
import 'package:serverpod_auth_idp_server/providers/email.dart';
import 'package:serverpod_auth_idp_server/providers/google.dart';

import 'src/auth/api_key_validator.dart';
import 'src/auth/dart_desk_session.dart';
import 'src/generated/endpoints.dart';
import 'src/generated/protocol.dart';
import 'src/plugin/dart_desk_plugin.dart';
import 'src/plugin/dart_desk_registry.dart';
import 'src/plugin/dart_desk_session.dart';
import 'src/services/document_crdt_service.dart';

void run(List<String> args, {List<DartDeskPlugin> plugins = const []}) async {
  // Create registry and let plugins register their contributions.
  final registry = DartDeskRegistry();
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

  // Validate x-api-key on every RPC request before the endpoint runs.
  // Attaches ApiKeyContext to session.apiKey for endpoint access.
  pod.server.preEndpointHandlers.add((session, request) async {
    final apiKeyHeader = request.headers['x-api-key']?.first;
    if (apiKeyHeader == null) {
      return Response.unauthorized(
        body: Body.fromString(
          '{"error":"Missing x-api-key header"}',
          mimeType: MimeType.json,
        ),
      );
    }

    final apiKeyCtx = await ApiKeyValidator.validate(session, apiKeyHeader);
    if (apiKeyCtx == null) {
      return Response.unauthorized(
        body: Body.fromString(
          '{"error":"Invalid API key"}',
          mimeType: MimeType.json,
        ),
      );
    }

    session.apiKey = apiKeyCtx;
    return null; // continue to endpoint
  });

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

