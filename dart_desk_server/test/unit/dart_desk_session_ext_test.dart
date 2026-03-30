import 'package:dart_desk_server/src/auth/dart_desk_session.dart';
import 'package:mocktail/mocktail.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

class _MockSession extends Mock implements Session {}

void main() {
  group('DartDeskSessionExt', () {
    late _MockSession session;
    late AuthenticationInfo authInfo;

    setUp(() {
      session = _MockSession();
      authInfo = AuthenticationInfo(
        'user-1',
        {
          Scope('client:7'),
          Scope('project:12'),
          Scope('project.read'),
          Scope('project.write'),
        },
        authId: 'auth-1',
      );
    });

    test('clientId getter reads tenant scope', () {
      when(() => session.authenticated).thenReturn(authInfo);

      expect(session.clientId, 7);
    });

    test('projectId getter reads project scope', () {
      when(() => session.authenticated).thenReturn(authInfo);

      expect(session.projectId, 12);
    });

    test('clientId getter returns null when client scope is missing', () {
      when(() => session.authenticated).thenReturn(
        AuthenticationInfo('user-1', {Scope('project:12')}, authId: 'auth-1'),
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
  });
}
