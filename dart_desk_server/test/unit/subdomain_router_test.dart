import 'package:test/test.dart';
import 'package:dart_desk_server/src/web/routes/subdomain_router.dart';

void main() {
  const domain = 'app.dartdesk.dev';

  group('extractSubdomain with app.dartdesk.dev domain', () {
    test('extracts label from {label}.app.dartdesk.dev', () {
      expect(extractSubdomain('mysite.app.dartdesk.dev', domain), equals('mysite'));
    });
    test('extracts with port', () {
      expect(extractSubdomain('mysite.app.dartdesk.dev:443', domain), equals('mysite'));
    });
    test('returns null for bare app.dartdesk.dev', () {
      expect(extractSubdomain('app.dartdesk.dev', domain), isNull);
    });
    test('returns null for nested label', () {
      expect(extractSubdomain('foo.bar.app.dartdesk.dev', domain), isNull);
    });
    test('extracts hyphenated', () {
      expect(extractSubdomain('my-cool-site.app.dartdesk.dev', domain), equals('my-cool-site'));
    });
  });
}
