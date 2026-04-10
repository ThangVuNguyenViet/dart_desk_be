import 'package:dart_desk_server/src/auth/compound_token_parser.dart';
import 'package:test/test.dart';

void main() {
  group('CompoundTokenParser', () {
    test('plain JWT token returns jwtToken only', () {
      final result = CompoundTokenParser.parse('eyJhbGciOiJSUzI1NiJ9.payload.sig');
      expect(result.jwtToken, equals('eyJhbGciOiJSUzI1NiJ9.payload.sig'));
      expect(result.apiKey, isNull);
    });

    test('compound token splits into JWT and API key', () {
      final result = CompoundTokenParser.parse(
        'eyJhbGciOiJSUzI1NiJ9.payload.sig:cms_w_abc1234567890',
      );
      expect(result.jwtToken, equals('eyJhbGciOiJSUzI1NiJ9.payload.sig'));
      expect(result.apiKey, equals('cms_w_abc1234567890'));
    });

    test('API key only (empty left side of colon)', () {
      final result = CompoundTokenParser.parse(':cms_w_abc1234567890');
      expect(result.jwtToken, isNull);
      expect(result.apiKey, equals('cms_w_abc1234567890'));
    });

    test('JWT only with trailing colon', () {
      final result = CompoundTokenParser.parse('eyJhbGciOiJSUzI1NiJ9.payload.sig:');
      expect(result.jwtToken, equals('eyJhbGciOiJSUzI1NiJ9.payload.sig'));
      expect(result.apiKey, isNull);
    });

    test('plain cms_ prefixed token returns apiKey only', () {
      final result = CompoundTokenParser.parse('cms_w_abc1234567890');
      expect(result.jwtToken, isNull);
      expect(result.apiKey, equals('cms_w_abc1234567890'));
    });

    test('token with multiple colons uses first as separator', () {
      // JWT tokens contain dots not colons, but API keys could theoretically
      // contain colons — only the first colon is the separator.
      final result = CompoundTokenParser.parse('jwt-part:api:key:extra');
      expect(result.jwtToken, equals('jwt-part'));
      expect(result.apiKey, equals('api:key:extra'));
    });
  });
}
