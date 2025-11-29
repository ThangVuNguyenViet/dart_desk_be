import 'dart:io';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_server/serverpod_auth_server.dart' as auth;

import 'package:flutter_cms_be_server/src/web/routes/root.dart';

import 'src/generated/protocol.dart';
import 'src/generated/endpoints.dart';
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
    authenticationHandler: auth.authenticationHandler,
  );

  // Setup a default page at the web root.
  pod.webServer.addRoute(RouteRoot(), '/');
  pod.webServer.addRoute(RouteRoot(), '/index.html');

  // Google Sign-In authentication route
  pod.webServer.addRoute(auth.RouteGoogleSignIn(), '/googlesignin');

  // Serve uploaded files from storage/public directory
  pod.webServer.addRoute(
    RouteStaticDirectory(serverDirectory: 'storage/public', basePath: '/'),
    '/files/*',
  );

  // Serve all files in the /static directory.
  pod.webServer.addRoute(
    RouteStaticDirectory(serverDirectory: 'static', basePath: '/'),
    '/*',
  );

  // Start the server.
  await pod.start();
}
