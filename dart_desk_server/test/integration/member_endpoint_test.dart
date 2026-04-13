import 'package:dart_desk_server/src/generated/protocol.dart';
import 'package:test/test.dart';
import 'package:uuid/uuid.dart';

import 'helpers/test_data_factory.dart';
import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('MemberEndpoint', (sessionBuilder, endpoints) {
    late TestDataFactory factory;

    setUp(() {
      factory = TestDataFactory(
        sessionBuilder: sessionBuilder,
        endpoints: endpoints,
      );
    });

    group('listMembers', () {
      test('returns all users for the given client', () async {
        final client = await factory.ensureTestClient();
        await factory.ensureTestUser(
          userIdentifier: 'user-1',
          role: ClientRole.admin,
        );
        await factory.ensureTestUser(
          userIdentifier: 'user-2',
          email: 'user2@example.com',
          role: ClientRole.viewer,
        );

        final authed = factory.authenticatedSession(userIdentifier: 'user-1');
        final members = await endpoints.member.listMembers(
          authed,
          clientId: client.id,
        );

        expect(members.length, greaterThanOrEqualTo(2));
      });

      test('throws 401 when not authenticated', () async {
        expect(
          () => endpoints.member.listMembers(sessionBuilder, clientId: UuidValue.fromString('00000000-0000-0000-0000-000000000000')),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('inviteMember', () {
      test('creates a new user in the client', () async {
        final client = await factory.ensureTestClient();
        await factory.ensureTestUser(
          userIdentifier: 'admin-user',
          role: ClientRole.admin,
        );

        final authed =
            factory.authenticatedSession(userIdentifier: 'admin-user');
        final newUser = await endpoints.member.inviteMember(
          authed,
          clientId: client.id,
          email: 'newmember@example.com',
          role: ClientRole.member,
        );

        expect(newUser.email, equals('newmember@example.com'));
        expect(newUser.role, equals(ClientRole.member));
        expect(newUser.clientId, equals(client.id));
      });

      test('throws 403 when caller is not admin', () async {
        final client = await factory.ensureTestClient();
        await factory.ensureTestUser(
          userIdentifier: 'viewer-user',
          role: ClientRole.viewer,
        );

        final authed =
            factory.authenticatedSession(userIdentifier: 'viewer-user');
        expect(
          () => endpoints.member.inviteMember(
            authed,
            clientId: client.id,
            email: 'new@example.com',
            role: ClientRole.member,
          ),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('updateMemberRole', () {
      test('updates user role', () async {
        final client = await factory.ensureTestClient();
        await factory.ensureTestUser(
          userIdentifier: 'admin-user',
          role: ClientRole.admin,
        );
        final target = await factory.ensureTestUser(
          userIdentifier: 'target-user',
          email: 'target@example.com',
          role: ClientRole.viewer,
        );

        final authed =
            factory.authenticatedSession(userIdentifier: 'admin-user');
        final updated = await endpoints.member.updateMemberRole(
          authed,
          clientId: client.id,
          userId: target.id,
          role: ClientRole.member,
        );

        expect(updated.role, equals(ClientRole.member));
      });
    });

    group('removeMember', () {
      test('soft-deletes user and removes project memberships', () async {
        final client = await factory.ensureTestClient();
        await factory.ensureTestUser(
          userIdentifier: 'admin-user',
          role: ClientRole.admin,
        );
        final target = await factory.ensureTestUser(
          userIdentifier: 'target-user',
          email: 'target@example.com',
          role: ClientRole.viewer,
        );
        await factory.ensureTestProjectMember(userId: target.id);

        final authed =
            factory.authenticatedSession(userIdentifier: 'admin-user');
        await endpoints.member.removeMember(
          authed,
          clientId: client.id,
          userId: target.id,
        );

        // User should still exist but be soft-deleted
        final session = sessionBuilder.build();
        final found = await User.db.findById(session, target.id);
        expect(found, isNotNull);
        expect(found!.isActive, isFalse);
        expect(found.deletedAt, isNotNull);

        // Project memberships should be hard-deleted
        final memberships = await ProjectMember.db.find(
          session,
          where: (t) => t.userId.equals(target.id),
        );
        expect(memberships, isEmpty);
      });

      test('does not show soft-deleted users in listMembers', () async {
        final client = await factory.ensureTestClient();
        await factory.ensureTestUser(
          userIdentifier: 'admin-user',
          role: ClientRole.admin,
        );
        final target = await factory.ensureTestUser(
          userIdentifier: 'removed-user',
          email: 'removed@example.com',
          role: ClientRole.viewer,
        );

        final authed =
            factory.authenticatedSession(userIdentifier: 'admin-user');
        await endpoints.member.removeMember(
          authed,
          clientId: client.id,
          userId: target.id,
        );

        final members = await endpoints.member.listMembers(
          authed,
          clientId: client.id,
        );
        final removedIds = members.map((m) => m.id).toList();
        expect(removedIds, isNot(contains(target.id)));
      });
    });
  });
}
