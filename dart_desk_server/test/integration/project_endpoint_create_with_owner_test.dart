import 'package:dart_desk_server/src/generated/protocol.dart';
import 'package:test/test.dart';

import 'test_tools/serverpod_test_tools.dart';

TestSessionBuilder authedSession(
  TestSessionBuilder sessionBuilder, {
  String userIdentifier = 'owner-1',
}) {
  return sessionBuilder.copyWith(
    authentication: AuthenticationOverride.authenticationInfo(
      userIdentifier,
      {},
    ),
  );
}

void main() {
  withServerpod(
    'ProjectEndpoint createProjectWithOwner success',
    (sessionBuilder, endpoints) {
      final insertedProjectIds = <int>[];
      final insertedClientIds = <int>[];

      tearDown(() async {
        final session = sessionBuilder.build();
        for (final id in insertedClientIds) {
          await User.db.deleteWhere(
            session,
            where: (t) => t.clientId.equals(id),
          );
        }
        for (final id in insertedProjectIds) {
          await Project.db.deleteWhere(
            session,
            where: (t) => t.id.equals(id),
          );
        }
        for (final id in insertedClientIds) {
          await CmsClient.db.deleteWhere(
            session,
            where: (t) => t.id.equals(id),
          );
        }
        insertedProjectIds.clear();
        insertedClientIds.clear();
      });

      test('creates Project and admin User in transaction', () async {
        const userIdentifier = 'owner-create-project';
        final project = await endpoints.project.createProjectWithOwner(
          authedSession(sessionBuilder, userIdentifier: userIdentifier),
          name: 'Owner Project',
          slug: 'owner-project',
        );
        insertedProjectIds.add(project.id!);
        insertedClientIds.add(project.clientId);

        expect(project.id, isNotNull);
        expect(project.slug, equals('owner-project'));

        final user = await User.db.findFirstRow(
          sessionBuilder.build(),
          where: (t) => t.clientId.equals(project.clientId),
        );

        expect(user, isNotNull);
        expect(user!.role, equals('admin'));
        expect(user.serverpodUserId, equals(userIdentifier));
        expect(user.isActive, isTrue);
      });

      test('falls back to userIdentifier as email when profile absent', () async {
        const userIdentifier = 'owner-fallback-email';
        final project = await endpoints.project.createProjectWithOwner(
          authedSession(sessionBuilder, userIdentifier: userIdentifier),
          name: 'Fallback Email',
          slug: 'fallback-email',
        );
        insertedProjectIds.add(project.id!);
        insertedClientIds.add(project.clientId);

        final user = await User.db.findFirstRow(
          sessionBuilder.build(),
          where: (t) => t.clientId.equals(project.clientId),
        );

        expect(user!.email, equals(userIdentifier));
      });
    },
    rollbackDatabase: RollbackDatabase.disabled,
  );
}
