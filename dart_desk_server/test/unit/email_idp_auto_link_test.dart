import 'dart:convert';

import 'package:dart_desk_server/src/endpoints/email_idp_endpoint.dart';
import 'package:test/test.dart';
import 'package:uuid/uuid.dart';

void main() {
  group('EmailIdpEndpoint.parseAccountRequestId', () {
    test('parses a valid registration token', () {
      final requestId = const Uuid().v4obj();
      final secret = const Uuid().v4();
      final token = base64Encode(utf8.encode('$requestId:$secret'));

      final result = EmailIdpEndpoint.parseAccountRequestId(token);

      expect(result, isNotNull);
      expect(result.toString(), equals(requestId.toString()));
    });

    test('returns null for empty string', () {
      expect(EmailIdpEndpoint.parseAccountRequestId(''), isNull);
    });

    test('returns null for non-base64 input', () {
      expect(EmailIdpEndpoint.parseAccountRequestId('not-base64!!!'), isNull);
    });

    test('returns null for base64 without colon separator', () {
      final token = base64Encode(utf8.encode('no-colon-here'));
      expect(EmailIdpEndpoint.parseAccountRequestId(token), isNull);
    });

    test('returns null for base64 with invalid UUID before colon', () {
      final token = base64Encode(utf8.encode('not-a-uuid:some-secret'));
      expect(EmailIdpEndpoint.parseAccountRequestId(token), isNull);
    });

    test('handles token with multiple colons (UUID contains hyphens)', () {
      final requestId = const Uuid().v4obj();
      final secret = 'part1:part2:part3';
      final token = base64Encode(utf8.encode('$requestId:$secret'));

      final result = EmailIdpEndpoint.parseAccountRequestId(token);

      // Should parse correctly — indexOf(':') finds the first colon,
      // but UUID format uses hyphens not colons, so first colon is the separator.
      expect(result, isNotNull);
      expect(result.toString(), equals(requestId.toString()));
    });
  });
}
