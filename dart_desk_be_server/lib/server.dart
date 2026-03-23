import 'dart:developer' as developer;
import 'dart:io';

import 'package:dart_desk_be_server/src/web/routes/root.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';
import 'package:serverpod_auth_idp_server/providers/email.dart';
import 'package:serverpod_auth_idp_server/providers/google.dart';

import 'src/auth/dart_desk_auth.dart';
import 'src/generated/endpoints.dart';
import 'src/generated/protocol.dart';
import 'src/plugin/dart_desk_plugin.dart';
import 'src/plugin/dart_desk_registry.dart';
import 'src/plugin/dart_desk_session.dart';
import 'src/services/document_crdt_service.dart';
import 'src/tenancy.dart';

void run(List<String> args, {List<DartDeskPlugin> plugins = const []}) async {
  // Create registry and let plugins register their contributions.
  final registry = DartDeskRegistry();
  for (final plugin in plugins) {
    plugin.register(registry);
  }

  // Bridge registry into auth and tenancy.
  DartDeskAuth.configure(
    externalStrategies: registry.authStrategies,
  );
  DartDeskTenancy.configure(resolver: registry.resolveTenantId);

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

  // For production cloud storage (S3, GCS, etc.), configure in your deployment overlay.

  // Start the server.
  await pod.start();

  // Run plugin startup hooks.
  for (final plugin in plugins) {
    await plugin.onStartup(pod);
  }
  await registry.runStartupHooks(pod);

  // Initialize external auth strategies (if any configured).
  await DartDeskAuth.initialize();

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

    // Ensure User record exists (single-tenant: clientId = null)
    final existingUser = await User.db.findFirstRow(
      session,
      where: (t) => t.serverpodUserId.equals(authUserId.toString()),
    );
    if (existingUser == null) {
      await User.db.insertRow(session, User(
        clientId: null,
        email: email,
        name: 'Admin',
        role: 'admin',
        isActive: true,
        serverpodUserId: authUserId.toString(),
      ));
      developer.log('[Admin] Created User record for admin');
    }
  } catch (e) {
    developer.log('[Admin] Error seeding admin user: $e');
  } finally {
    await session.close();
  }
}
