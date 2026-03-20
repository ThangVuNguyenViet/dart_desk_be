import 'package:test/test.dart';

/// Mirrors the _extractSlug logic from subdomain_router.dart
/// to test the domain matching with app.dartdesk.dev.
String? extractSlug(String host, String domain) {
  final hostWithoutPort = host.split(':').first;
  if (!hostWithoutPort.endsWith('.$domain')) return null;
  final slug = hostWithoutPort.substring(
    0,
    hostWithoutPort.length - domain.length - 1,
  );
  if (slug.isEmpty || slug.contains('.')) return null;
  return slug;
}

void main() {
  const domain = 'app.dartdesk.dev';

  group('extractSlug with app.dartdesk.dev domain', () {
    test('extracts slug from {slug}.app.dartdesk.dev', () {
      expect(extractSlug('mysite.app.dartdesk.dev', domain), equals('mysite'));
    });

    test('extracts slug with port', () {
      expect(
          extractSlug('mysite.app.dartdesk.dev:443', domain), equals('mysite'));
    });

    test('returns null for bare app.dartdesk.dev', () {
      expect(extractSlug('app.dartdesk.dev', domain), isNull);
    });

    test('returns null for unrelated domain', () {
      expect(extractSlug('example.com', domain), isNull);
    });

    test('returns null for slug with dots (multi-level)', () {
      // foo.bar.app.dartdesk.dev should NOT match (slug contains a dot)
      expect(extractSlug('foo.bar.app.dartdesk.dev', domain), isNull);
    });

    test('returns null for plain dartdesk.dev', () {
      expect(extractSlug('dartdesk.dev', domain), isNull);
    });

    test('returns null for slug.dartdesk.dev (missing app level)', () {
      expect(extractSlug('mysite.dartdesk.dev', domain), isNull);
    });

    test('extracts hyphenated slugs', () {
      expect(extractSlug('my-cool-site.app.dartdesk.dev', domain),
          equals('my-cool-site'));
    });

    test('returns null for localhost', () {
      expect(extractSlug('localhost:8082', domain), isNull);
    });
  });
}
