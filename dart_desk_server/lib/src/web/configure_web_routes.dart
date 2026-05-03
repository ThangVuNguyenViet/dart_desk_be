import 'dart:io' show Directory;

import 'package:serverpod/serverpod.dart';

import 'routes/deployment_upload_route.dart';
import 'routes/studio_route.dart';

/// Signature compatible with `WebServer.addRoute`. Indirected so route
/// registration is testable without booting Serverpod.
typedef RouteRegistrar = void Function(Route route, String matchPath);

/// Sink for `pod.webServer.fallbackRoute = ...`, indirected for tests.
typedef FallbackRegistrar = void Function(Route route);

/// Registers every web route on [register] in the same order as production.
///
/// StudioRoute is wired through [setFallback] (not [register]) so it only
/// fires when no explicit route matches. Registering it at `'/*'` shadows
/// more-specific POST routes like `/deployment/upload` because Relic's
/// router matches the wildcard with GET/HEAD methods first and returns
/// 405 instead of falling through to the specific POST handler.
void configureWebRoutes(
  RouteRegistrar register, {
  required FallbackRegistrar setFallback,
  required String studioDomain,
  Directory? publicStorageDir,
  Directory? staticDir,
}) {
  register(DeploymentUploadRoute(), '/deployment/upload');
  if (publicStorageDir != null) {
    register(StaticRoute.directory(publicStorageDir), '/files/*');
  }
  setFallback(
    StudioRoute(domain: studioDomain, staticFallback: staticDir),
  );
}
