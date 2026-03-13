import 'dart:io';

import 'package:flutter_cms_be_server/src/web/routes/root.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';
import 'package:serverpod_auth_idp_server/providers/google.dart';

import 'src/generated/endpoints.dart';
import 'src/generated/protocol.dart';
import 'src/services/document_crdt_service.dart';

// Global CRDT service instance
late DocumentCrdtService documentCrdtService;

// This is the starting point of your Serverpod server. In most cases, you will
// only need to make additions to this file if you add future calls,  are
// configuring Relic (Serverpod's web-server), or need custom setup work.

void run(List<String> args) async {
  // Initialize CRDT service with node ID
  final nodeId = Platform.environment['CRDT_NODE_ID'] ?? 'postgres-main';
  documentCrdtService = DocumentCrdtService(nodeId);

  // Initialize Serverpod and connect it with your generated code.
  final pod = Serverpod(
    args,
    Protocol(),
    Endpoints(),
  );

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
    ],
  );

  // Start the server.
  await pod.start();
}
