import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter_cms_be_server/src/web/routes/root.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_admin_server/serverpod_admin_server.dart' as admin;
import 'package:serverpod_auth_idp_server/core.dart';
import 'package:serverpod_auth_idp_server/providers/email.dart';
import 'package:serverpod_auth_idp_server/providers/google.dart';

import 'src/generated/endpoints.dart';
import 'src/generated/protocol.dart';
import 'src/services/document_crdt_service.dart';

// Global CRDT service instance
late DocumentCrdtService documentCrdtService;

void run(List<String> args) async {
  // Initialize Serverpod and connect it with your generated code.
  final pod = Serverpod(
    args,
    Protocol(),
    Endpoints(),
  );

  // Initialize CRDT service with node ID from passwords.yaml
  final nodeId = pod.getPassword('crdtNodeId') ?? 'postgres-main';
  documentCrdtService = DocumentCrdtService(nodeId);

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

  // Start the server.
  await pod.start();

  // Register admin module with all CMS models.
  _registerAdminModule();

  // Seed admin user (idempotent — safe to call on every startup).
  await _seedAdminUser();
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

void _registerAdminModule() {
  admin.configureAdminModule((registry) {
    registry.register<CmsClient>();
    registry.register<CmsDocument>();
    registry.register<CmsDocumentData>();
    registry.register<CmsUser>();
    registry.register<DocumentVersion>();
    registry.register<MediaFile>();
    registry.register<DocumentCrdtOperation>();
    registry.register<DocumentCrdtSnapshot>();
    registry.register<CmsApiToken>();
    registry.register<CmsDeployment>();

    developer.log(
        '[Admin] Module registered with ${registry.registeredResourceMetadata.length} resources');
  });
}

/// Creates a default admin user if one doesn't already exist.
/// Uses environment variables or falls back to dev defaults.
Future<void> _seedAdminUser() async {
  final session = await Serverpod.instance.createSession();

  try {
    final emailAdmin = AuthServices.instance.emailIdp.admin;
    final email = Serverpod.instance.getPassword('adminEmail');
    final password = Serverpod.instance.getPassword('adminPassword');

    if (email == null || password == null) {
      developer.log(
          '[Admin] ADMIN_EMAIL and ADMIN_PASSWORD env vars not set, skipping admin seed');
      return;
    }

    // Check if the email account already exists
    final existingAccount = await emailAdmin.findAccount(
      session,
      email: email,
    );

    UuidValue authUserId;

    if (existingAccount == null) {
      // Create a new auth user and email authentication
      final authUser = await AuthServices.instance.authUsers.create(session);
      authUserId = authUser.id;

      await emailAdmin.createEmailAuthentication(
        session,
        authUserId: authUserId,
        email: email,
        password: password,
      );
      developer.log('[Admin] Created admin user: $email');
    } else {
      authUserId = existingAccount.authUserId;
      developer.log('[Admin] Admin user already exists: $email');
    }

    // Ensure admin scope is set
    await AuthServices.instance.authUsers.update(
      session,
      authUserId: authUserId,
      scopes: {Scope.admin},
    );
  } catch (e) {
    developer.log('[Admin] Error seeding admin user: $e');
  } finally {
    await session.close();
  }
}
