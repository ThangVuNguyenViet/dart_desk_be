import 'package:dart_desk_be_server/src/auth/api_key_validator.dart';
import 'package:test/test.dart';

void main() {
  group('ApiKeyValidator', () {
    group('parseApiKey', () {
      test('parses valid read token', () {
        final result = ApiKeyValidator.parseApiKey(
          'cms_r_abcdefghijklmnopqrstuvwxyz1234567890abcdefg',
        );
        expect(result, isNotNull);
        expect(result!.prefix, equals('cms_r_'));
        expect(result.suffix, hasLength(4));
      });

      test('parses valid write token', () {
        final result = ApiKeyValidator.parseApiKey(
          'cms_w_abcdefghijklmnopqrstuvwxyz1234567890abcdefg',
        );
        expect(result, isNotNull);
        expect(result!.prefix, equals('cms_w_'));
      });

      test('returns null for invalid prefix', () {
        final result = ApiKeyValidator.parseApiKey(
          'cms_x_abcdefghijklmnopqrstuvwxyz1234567890abcdefg',
        );
        expect(result, isNull);
      });

      test('returns null for too-short token', () {
        final result = ApiKeyValidator.parseApiKey('cms_r_abc');
        expect(result, isNull);
      });

      test('returns null for empty string', () {
        final result = ApiKeyValidator.parseApiKey('');
        expect(result, isNull);
      });
    });

    group('hashToken', () {
      test('produces consistent SHA-256 hash', () {
        const token = 'cms_r_testtoken1234';
        final hash1 = ApiKeyValidator.hashToken(token);
        final hash2 = ApiKeyValidator.hashToken(token);
        expect(hash1, equals(hash2));
      });

      test('produces different hashes for different tokens', () {
        final hash1 = ApiKeyValidator.hashToken('cms_r_token_a');
        final hash2 = ApiKeyValidator.hashToken('cms_r_token_b');
        expect(hash1, isNot(equals(hash2)));
      });

      test('hash is 64 character hex string', () {
        final hash = ApiKeyValidator.hashToken('cms_r_test');
        expect(hash, hasLength(64));
        expect(hash, matches(RegExp(r'^[0-9a-f]{64}$')));
      });
    });
  });
}
