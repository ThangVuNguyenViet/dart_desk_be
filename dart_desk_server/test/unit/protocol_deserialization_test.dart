import 'package:dart_desk_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/serverpod_auth_idp_server.dart'
    as idp;
import 'package:test/test.dart';

void main() {
  late Protocol protocol;

  setUp(() {
    protocol = Protocol();
  });

  group('Protocol deserialization', () {
    group('module types via delegation chain', () {
      final authUserId = UuidValue.fromString(
        '550e8400-e29b-41d4-a716-446655440000',
      );

      test('deserializes EmailAccount from JSON map', () {
        final json = {
          'authUserId': authUserId.toString(),
          'email': 'test@example.com',
          'passwordHash': 'hashed',
        };

        final result = protocol.deserialize<idp.EmailAccount>(json);

        expect(result, isA<idp.EmailAccount>());
        expect(result.email, equals('test@example.com'));
        expect(result.authUserId, equals(authUserId));
      });

      test('deserializes nullable EmailAccount from JSON map', () {
        final json = {
          'authUserId': authUserId.toString(),
          'email': 'test@example.com',
          'passwordHash': 'hashed',
        };

        final result = protocol.deserialize<idp.EmailAccount?>(json);

        expect(result, isA<idp.EmailAccount>());
        expect(result!.email, equals('test@example.com'));
      });

      test('deserializes nullable EmailAccount from null', () {
        final result = protocol.deserialize<idp.EmailAccount?>(null);

        expect(result, isNull);
      });
    });

    group('Map<String, dynamic> passthrough', () {
      test('deserializes Map<String, dynamic> from raw map', () {
        final json = {'key': 'value', 'nested': {'a': 1}};

        final result = protocol.deserialize<Map<String, dynamic>>(json);

        expect(result, isA<Map<String, dynamic>>());
        expect(result['key'], equals('value'));
        expect(result['nested'], isA<Map>());
      });

      test('deserializes dynamic from map returns map', () {
        final json = {'key': 'value'};

        final result = protocol.deserialize<dynamic>(json);

        expect(result, isA<Map>());
        expect(result['key'], equals('value'));
      });

      test('deserializes dynamic from list returns list', () {
        final list = [1, 2, 3];

        final result = protocol.deserialize<dynamic>(list);

        expect(result, isA<List>());
        expect(result, equals([1, 2, 3]));
      });
    });
  });
}
