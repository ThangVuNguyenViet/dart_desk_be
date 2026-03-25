import 'package:dart_desk_server/src/auth/dart_desk_auth.dart';
import 'package:test/test.dart';

void main() {
  group('DartDeskAuth scheme parsing', () {
    group('extractApiKeyFromDartDeskScheme', () {
      test('extracts apiKey from DartDesk scheme', () {
        expect(
          DartDeskAuth.extractApiKeyFromDartDeskScheme(
              'DartDesk apiKey=cms_r_test1234'),
          'cms_r_test1234',
        );
      });

      test('extracts apiKey from compound header', () {
        expect(
          DartDeskAuth.extractApiKeyFromDartDeskScheme(
              'DartDesk apiKey=cms_r_test1234;Basic dG9rZW4='),
          'cms_r_test1234',
        );
      });

      test('returns null for non-DartDesk scheme', () {
        expect(
          DartDeskAuth.extractApiKeyFromDartDeskScheme('Bearer eyJhbGc'),
          isNull,
        );
      });

      test('returns null for malformed DartDesk header', () {
        expect(
          DartDeskAuth.extractApiKeyFromDartDeskScheme('DartDesk invalid'),
          isNull,
        );
      });
    });

    group('extractAuthKeyFromDartDeskScheme', () {
      test('extracts auth key from compound header', () {
        expect(
          DartDeskAuth.extractAuthKeyFromDartDeskScheme(
              'DartDesk apiKey=cms_r_test1234;Basic dG9rZW4='),
          'Basic dG9rZW4=',
        );
      });

      test('returns null when no JWT present', () {
        expect(
          DartDeskAuth.extractAuthKeyFromDartDeskScheme(
              'DartDesk apiKey=cms_r_test1234'),
          isNull,
        );
      });

      test('returns null for non-DartDesk scheme', () {
        expect(
          DartDeskAuth.extractAuthKeyFromDartDeskScheme('Bearer eyJhbGc'),
          isNull,
        );
      });
    });
  });
}
