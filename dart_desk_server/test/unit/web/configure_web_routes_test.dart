import 'dart:io';

import 'package:dart_desk_server/src/web/configure_web_routes.dart';
import 'package:dart_desk_server/src/web/routes/studio_route.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

void main() {
  group('configureWebRoutes', () {
    test('registration runs without throwing', () {
      expect(
        () => configureWebRoutes(
          (_, __) {},
          setFallback: (_) {},
          studioDomain: 'app.dartdesk.dev',
          publicStorageDir: Directory.systemTemp.createTempSync(),
        ),
        returnsNormally,
      );
    });

    test('no two web routes share the same path', () {
      // Relic throws `Invalid argument(s): Conflicting parameters` when two
      // routes register at the same path. Asserting unique paths catches that.
      final paths = <String>[];
      configureWebRoutes(
        (route, path) => paths.add(path),
        setFallback: (_) {},
        studioDomain: 'app.dartdesk.dev',
        publicStorageDir: Directory.systemTemp.createTempSync(),
      );

      expect(paths.toSet().length, paths.length,
          reason: 'duplicate paths: $paths');
    });

    test('StudioRoute is wired through fallbackRoute, not addRoute', () {
      // Registering StudioRoute at '/*' shadows specific POST routes
      // (Relic returns 405 with `Allow: GET, HEAD`). Using fallbackRoute
      // ensures specific routes win and StudioRoute only fires when
      // nothing else matches.
      final addPaths = <String>[];
      Route? fallback;
      configureWebRoutes(
        (_, path) => addPaths.add(path),
        setFallback: (r) => fallback = r,
        studioDomain: 'app.dartdesk.dev',
      );

      expect(fallback, isA<StudioRoute>());
      expect(
        addPaths,
        isNot(contains('/*')),
        reason: 'StudioRoute must NOT be registered as a wildcard route — '
            'use fallbackRoute instead. See git log for context.',
      );
    });

    test('DeploymentUploadRoute is registered explicitly', () {
      final paths = <String>[];
      configureWebRoutes(
        (_, path) => paths.add(path),
        setFallback: (_) {},
        studioDomain: 'app.dartdesk.dev',
      );
      expect(paths, contains('/deployment/upload'));
    });
  });
}
