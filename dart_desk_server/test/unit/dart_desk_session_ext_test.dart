import 'package:dart_desk_server/src/auth/api_key_context.dart';
import 'package:dart_desk_server/src/auth/dart_desk_session.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';
import 'package:mocktail/mocktail.dart';

class _MockSession extends Mock implements Session {}

void main() {
  group('DartDeskSessionExt', () {
    late _MockSession session;

    setUp(() {
      session = _MockSession();
    });

    test('apiKey getter returns stored ApiKeyContext', () {
      final ctx = ApiKeyContext(clientId: 1, role: 'read', tokenId: 42);
      when(() => session.requestContext).thenReturn({'apiKey': ctx});

      expect(session.apiKey, same(ctx));
      expect(session.apiKey.clientId, 1);
      expect(session.apiKey.role, 'read');
      expect(session.apiKey.tokenId, 42);
    });

    test('apiKey getter returns default when requestContext is null', () {
      when(() => session.requestContext).thenReturn(null);

      final key = session.apiKey;
      expect(key.clientId, isNull);
      expect(key.role, 'write');
      expect(key.tokenId, 0);
    });

    test('apiKey getter returns default when key is missing from context', () {
      when(() => session.requestContext).thenReturn({});

      final key = session.apiKey;
      expect(key.clientId, isNull);
      expect(key.role, 'write');
      expect(key.tokenId, 0);
    });

    test('canWrite is true for write role', () {
      final ctx = ApiKeyContext(clientId: 1, role: 'write', tokenId: 10);
      when(() => session.requestContext).thenReturn({'apiKey': ctx});

      expect(session.apiKey.canWrite, isTrue);
      expect(session.apiKey.canRead, isTrue);
    });

    test('canWrite is false for read role', () {
      final ctx = ApiKeyContext(clientId: 1, role: 'read', tokenId: 10);
      when(() => session.requestContext).thenReturn({'apiKey': ctx});

      expect(session.apiKey.canWrite, isFalse);
      expect(session.apiKey.canRead, isTrue);
    });

    test('clientId can be null for single-tenant keys', () {
      final ctx = ApiKeyContext(clientId: null, role: 'read', tokenId: 10);
      when(() => session.requestContext).thenReturn({'apiKey': ctx});

      expect(session.apiKey.clientId, isNull);
    });
  });
}
