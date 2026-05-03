import 'package:dart_desk_server/src/web/configure_web_routes.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

void main() {
  group('configureWebRoutes', () {
    test('Fix 2: registration runs without throwing', () {
      expect(
        () => configureWebRoutes(
          (_, __) {},
          studioDomain: 'app.dartdesk.dev',
        ),
        returnsNormally,
      );
    });

    test('Fix 3: no two web routes share the same path', () {
      // The bug: Relic's PathTrie throws `Invalid argument(s): Conflicting
      // parameters` when two routes register at the same path. Asserting
      // unique paths catches that class of mistake without booting Relic.
      final paths = <String>[];
      configureWebRoutes(
        (route, path) => paths.add(path),
        studioDomain: 'app.dartdesk.dev',
      );

      final duplicates = paths.toList()
        ..sort()
        ..removeWhere((p) {
          final first = paths.indexOf(p);
          final last = paths.lastIndexOf(p);
          return first == last;
        });

      expect(
        paths.toSet().length,
        paths.length,
        reason: 'duplicate web route paths registered: $duplicates',
      );
    });

    test('every registered handler is a Route', () {
      final routes = <Route>[];
      configureWebRoutes(
        (route, _) => routes.add(route),
        studioDomain: 'app.dartdesk.dev',
      );
      expect(routes, isNotEmpty);
      expect(routes, everyElement(isA<Route>()));
    });
  });
}
