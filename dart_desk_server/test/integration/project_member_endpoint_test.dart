import 'package:dart_desk_server/src/generated/protocol.dart';
import 'package:test/test.dart';

import 'helpers/test_data_factory.dart';
import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('ProjectMemberEndpoint', (sessionBuilder, endpoints) {
    late TestDataFactory factory;

    setUp(() {
      factory = TestDataFactory(
        sessionBuilder: sessionBuilder,
        endpoints: endpoints,
      );
    });

    group('listProjectMembers', () {
      test('returns members of a project', () async {
        await factory.ensureTestProject();
        await factory.ensureTestUser(
          userIdentifier: 'pm-admin-1',
          email: 'pm-admin-1@example.com',
          role: ClientRole.admin,
        );
        final user2 = await factory.ensureTestUser(
          userIdentifier: 'pm-member-1',
          email: 'pm-member-1@example.com',
          role: ClientRole.member,
        );
        await factory.ensureTestProjectMember(
          userId: user2.id!,
          role: ProjectRole.editor,
        );

        final authed = factory.authenticatedSession(
          userIdentifier: 'pm-admin-1',
        );
        final members = await endpoints.projectMember.listProjectMembers(
          authed,
          projectId: TestDataFactory.testProjectId,
        );

        expect(members.length, greaterThanOrEqualTo(1));
        expect(
          members.any((m) => m.userId == user2.id && m.role == ProjectRole.editor),
          isTrue,
        );
      });
    });

    group('addProjectMember', () {
      test('adds a user to a project', () async {
        await factory.ensureTestProject();
        await factory.ensureTestUser(
          userIdentifier: 'pm-admin-2',
          email: 'pm-admin-2@example.com',
          role: ClientRole.admin,
        );
        final user2 = await factory.ensureTestUser(
          userIdentifier: 'pm-member-2',
          email: 'pm-member-2@example.com',
          role: ClientRole.member,
        );

        final authed = factory.authenticatedSession(
          userIdentifier: 'pm-admin-2',
        );
        final pm = await endpoints.projectMember.addProjectMember(
          authed,
          projectId: TestDataFactory.testProjectId,
          userId: user2.id!,
          role: ProjectRole.editor,
        );

        expect(pm.userId, equals(user2.id));
        expect(pm.role, equals(ProjectRole.editor));
      });
    });

    group('removeProjectMember', () {
      test('removes a user from a project', () async {
        await factory.ensureTestProject();
        await factory.ensureTestUser(
          userIdentifier: 'pm-admin-3',
          email: 'pm-admin-3@example.com',
          role: ClientRole.admin,
        );
        final user2 = await factory.ensureTestUser(
          userIdentifier: 'pm-member-3',
          email: 'pm-member-3@example.com',
          role: ClientRole.member,
        );
        final pm = await factory.ensureTestProjectMember(
          userId: user2.id!,
          role: ProjectRole.editor,
        );

        final authed = factory.authenticatedSession(
          userIdentifier: 'pm-admin-3',
        );
        await endpoints.projectMember.removeProjectMember(
          authed,
          projectId: TestDataFactory.testProjectId,
          userId: user2.id!,
        );

        final session = sessionBuilder.build();
        final found = await ProjectMember.db.findById(session, pm.id!);
        expect(found, isNull);
      });
    });
  });
}
