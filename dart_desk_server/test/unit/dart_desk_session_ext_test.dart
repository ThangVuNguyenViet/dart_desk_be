import 'package:dart_desk_server/src/auth/dart_desk_session.dart';
import 'package:mocktail/mocktail.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';
import 'package:uuid/uuid.dart';

class _MockSession extends Mock implements Session {}

class _MockAuthInfo extends Mock implements AuthenticationInfo {}

void main() {
  group('DartDeskSessionExt', () {
    late _MockSession session;
    late AuthenticationInfo authInfo;
    late _MockAuthInfo mockAuth;

    setUp(() {
      session = _MockSession();
      mockAuth = _MockAuthInfo();
      authInfo = AuthenticationInfo(
        'user-1',
        {
          Scope('client:00000000-0000-4000-8000-000000000007'),
          Scope('project:00000000-0000-4000-8000-000000000012'),
          Scope('project.read'),
          Scope('project.write'),
        },
        authId: 'auth-1',
      );
    });

    test('clientId getter reads tenant scope', () {
      when(() => session.authenticated).thenReturn(authInfo);

      expect(session.clientId, equals(UuidValue.fromString('00000000-0000-4000-8000-000000000007')));
    });

    test('projectId getter reads project scope', () {
      when(() => session.authenticated).thenReturn(authInfo);

      expect(session.projectId, equals(UuidValue.fromString('00000000-0000-4000-8000-000000000012')));
    });

    test('clientId getter returns null when client scope is missing', () {
      when(() => session.authenticated).thenReturn(
        AuthenticationInfo('user-1', {Scope('project:00000000-0000-4000-8000-000000000012')}, authId: 'auth-1'),
      );

      expect(session.clientId, isNull);
    });

    test('canRead is true when project.read scope exists', () {
      when(() => session.authenticated).thenReturn(authInfo);

      expect(session.canRead, isTrue);
    });

    test('canWrite is true when project.write scope exists', () {
      when(() => session.authenticated).thenReturn(authInfo);

      expect(session.canWrite, isTrue);
    });

    test('canWrite is false without project.write scope', () {
      when(() => session.authenticated).thenReturn(
        AuthenticationInfo(
          'user-1',
          {Scope('project.read')},
          authId: 'auth-1',
        ),
      );

      expect(session.canWrite, isFalse);
    });

    test('isClientAdmin returns true for admin scope', () {
      when(() => mockAuth.scopes).thenReturn({
        const Scope('client:1'),
        const Scope('client.role:admin'),
      });
      when(() => session.authenticated).thenReturn(mockAuth);

      expect(session.isClientAdmin, isTrue);
    });

    test('isClientAdmin returns true for owner scope', () {
      when(() => mockAuth.scopes).thenReturn({
        const Scope('client:1'),
        const Scope('client.role:owner'),
      });
      when(() => session.authenticated).thenReturn(mockAuth);

      expect(session.isClientAdmin, isTrue);
    });

    test('isClientAdmin returns false for member scope', () {
      when(() => mockAuth.scopes).thenReturn({
        const Scope('client:1'),
        const Scope('client.role:member'),
      });
      when(() => session.authenticated).thenReturn(mockAuth);

      expect(session.isClientAdmin, isFalse);
    });

    test('clientRole parses role from scope', () {
      when(() => mockAuth.scopes).thenReturn({
        const Scope('client.role:admin'),
      });
      when(() => session.authenticated).thenReturn(mockAuth);

      expect(session.clientRole, equals('admin'));
    });
  });
}
