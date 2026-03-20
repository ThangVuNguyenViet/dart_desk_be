import 'package:test/test.dart';
import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('StudioConfigEndpoint', (sessionBuilder, endpoints) {
    group('getStudioUrlTemplate', () {
      test('returns path-based URL template for localhost', () async {
        // Test config has publicHost: localhost, so this should return
        // path-based URL with {slug} placeholder
        final template =
            await endpoints.studioConfig.getStudioUrlTemplate(sessionBuilder);

        expect(template, contains('{slug}'));
        expect(template, contains('/preview/'));
        // Should be localhost path-based: http://localhost:{port}/preview/{slug}/
        expect(template, matches(RegExp(r'http://localhost(:\d+)?/preview/\{slug\}/')));
      });

      test('template contains replaceable slug placeholder', () async {
        final template =
            await endpoints.studioConfig.getStudioUrlTemplate(sessionBuilder);

        // Replacing {slug} should produce a valid-looking URL
        final url = template.replaceAll('{slug}', 'my-site');
        expect(url, contains('my-site'));
        expect(url, isNot(contains('{slug}')));
      });
    });
  });
}
