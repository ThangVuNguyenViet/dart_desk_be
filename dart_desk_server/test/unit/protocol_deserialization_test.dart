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

    group('unsupported passthrough types', () {
      test('throws for raw Map<String, dynamic>', () {
        final json = {'key': 'value', 'nested': {'a': 1}};

        expect(
          () => protocol.deserialize<Map<String, dynamic>>(json),
          throwsA(isA<DeserializationTypeNotFoundException>()),
        );
      });

      test('throws for dynamic from map', () {
        final json = {'key': 'value'};

        expect(
          () => protocol.deserialize<dynamic>(json),
          throwsA(isA<DeserializationTypeNotFoundException>()),
        );
      });

      test('throws for dynamic from list', () {
        final list = [1, 2, 3];

        expect(
          () => protocol.deserialize<dynamic>(list),
          throwsA(isA<DeserializationTypeNotFoundException>()),
        );
      });
    });
  });
}
