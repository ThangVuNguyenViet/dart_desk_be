import 'dart:io' show Directory;

import 'package:serverpod/serverpod.dart';

import 'routes/deployment_upload_route.dart';
import 'routes/root.dart';
import 'routes/studio_route.dart';

/// Signature compatible with `WebServer.addRoute`. Indirected so route
/// registration is testable without booting Serverpod.
typedef RouteRegistrar = void Function(Route route, String matchPath);

/// Registers every web route on [register] in the same order as production.
///
/// Relic's `PathTrie` throws `Invalid argument(s): Conflicting parameters`
/// at registration time if two routes share a path. Tests inject a recording
/// [register] to assert paths are unique without standing up a full pod.
void configureWebRoutes(
  RouteRegistrar register, {
  required String studioDomain,
  Directory? publicStorageDir,
  Directory? staticDir,
}) {
  register(RouteRoot(), '/');
  register(RouteRoot(), '/index.html');
  register(DeploymentUploadRoute(), '/deployment/upload');
  if (publicStorageDir != null) {
    register(StaticRoute.directory(publicStorageDir), '/files/*');
  }
  register(
    StudioRoute(domain: studioDomain, staticFallback: staticDir),
    '/*',
  );
}
