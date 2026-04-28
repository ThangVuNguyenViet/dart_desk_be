import 'package:dart_desk_server/src/generated/protocol.dart';
import 'package:test/test.dart';
import 'package:uuid/uuid.dart';

import 'helpers/test_data_factory.dart';
import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('ClientEndpoint', (sessionBuilder, endpoints) {
    late TestDataFactory factory;

    setUp(() async {
      factory = TestDataFactory(
        sessionBuilder: sessionBuilder,
        endpoints: endpoints,
      );
      // Drop project rows that may have leaked from earlier test files run
      // with RollbackDatabase.disabled (e.g. public_content_endpoint_test).
      // Without this, projectCount assertions are inflated by stale rows.
      final session = sessionBuilder.build();
      await Document.db
          .deleteWhere(session, where: (t) => t.id.notEquals(null));
      await Project.db.deleteWhere(
        session,
        where: (t) => t.id.notEquals(TestDataFactory.testProjectId),
      );
    });

    group('getClientsForUser', () {
      test('returns empty list when user has no client memberships', () async {
        final authed = factory.authenticatedSession(
          userIdentifier: 'no-membership-user',
        );
        final result = await endpoints.client.getClientsForUser(authed);
        expect(result, isEmpty);
      });

      test('returns single client with role and project count', () async {
        final client = await factory.ensureTestClient();
        await factory.ensureTestUser(
          userIdentifier: 'owner-user',
          role: ClientRole.owner,
        );
        await factory.ensureTestProject(
          projectId: UuidValue.fromString(
              '00000000-0000-4000-8000-000000000101'),
          clientId: client.id,
          name: 'Project One',
          slug: 'project-one',
        );
        await factory.ensureTestProject(
          projectId: UuidValue.fromString(
              '00000000-0000-4000-8000-000000000102'),
          clientId: client.id,
          name: 'Project Two',
          slug: 'project-two',
        );

        final authed = factory.authenticatedSession(
          userIdentifier: 'owner-user',
          clientId: client.id,
        );
        final result = await endpoints.client.getClientsForUser(authed);

        expect(result.length, equals(1));
        expect(result.first.client.id, equals(client.id));
        expect(result.first.role, equals(ClientRole.owner));
        // ensureTestUser creates a default project, plus 2 explicit ones = 3
        expect(result.first.projectCount, equals(3));
      });

      test('returns multiple clients for multi-tenant user', () async {
        final client1 = await factory.ensureTestClient(
          clientId: UuidValue.fromString(
              '00000000-0000-4000-8000-000000000010'),
          name: 'First Client',
          slug: 'first-client',
        );
        final client2 = await factory.ensureTestClient(
          clientId: UuidValue.fromString(
              '00000000-0000-4000-8000-000000000020'),
          name: 'Second Client',
          slug: 'second-client',
        );

        await factory.ensureTestUser(
          userIdentifier: 'multi-tenant-user',
          role: ClientRole.owner,
          clientId: client1.id,
        );
        await factory.ensureTestUser(
          userIdentifier: 'multi-tenant-user',
          email: 'multi-tenant-user-c2@example.com',
          role: ClientRole.member,
          clientId: client2.id,
        );

        await factory.ensureTestProject(
          projectId: UuidValue.fromString(
              '00000000-0000-4000-8000-000000000201'),
          clientId: client1.id,
          name: 'Client1 Project',
          slug: 'client1-project',
        );
        await factory.ensureTestProject(
          projectId: UuidValue.fromString(
              '00000000-0000-4000-8000-000000000202'),
          clientId: client2.id,
          name: 'Client2 Project A',
          slug: 'client2-project-a',
        );
        await factory.ensureTestProject(
          projectId: UuidValue.fromString(
              '00000000-0000-4000-8000-000000000203'),
          clientId: client2.id,
          name: 'Client2 Project B',
          slug: 'client2-project-b',
        );

        final authed = factory.authenticatedSession(
          userIdentifier: 'multi-tenant-user',
          clientId: client1.id,
        );
        final result = await endpoints.client.getClientsForUser(authed);

        expect(result.length, equals(2));

        final entry1 = result.firstWhere((r) => r.client.id == client1.id);
        expect(entry1.role, equals(ClientRole.owner));
        expect(entry1.projectCount, greaterThanOrEqualTo(1));

        final entry2 = result.firstWhere((r) => r.client.id == client2.id);
        expect(entry2.role, equals(ClientRole.member));
        expect(entry2.projectCount, greaterThanOrEqualTo(2));
      });

      test('excludes inactive clients', () async {
        final activeClient = await factory.ensureTestClient(
          clientId: UuidValue.fromString(
              '00000000-0000-4000-8000-000000000030'),
          name: 'Active Client',
          slug: 'active-client',
        );
        final inactiveClient = await factory.ensureTestClient(
          clientId: UuidValue.fromString(
              '00000000-0000-4000-8000-000000000040'),
          name: 'Inactive Client',
          slug: 'inactive-client',
        );

        await factory.ensureTestUser(
          userIdentifier: 'inactive-client-user',
          role: ClientRole.member,
          clientId: activeClient.id,
        );
        await factory.ensureTestUser(
          userIdentifier: 'inactive-client-user',
          email: 'inactive-client-user-c2@example.com',
          role: ClientRole.member,
          clientId: inactiveClient.id,
        );

        // Deactivate the second client
        final session = sessionBuilder.build();
        await CmsClient.db.updateRow(
          session,
          inactiveClient.copyWith(isActive: false),
        );

        final authed = factory.authenticatedSession(
          userIdentifier: 'inactive-client-user',
          clientId: activeClient.id,
        );
        final result = await endpoints.client.getClientsForUser(authed);

        expect(result.length, equals(1));
        expect(result.first.client.id, equals(activeClient.id));
      });

      test('excludes inactive user memberships', () async {
        final client = await factory.ensureTestClient();
        final user = await factory.ensureTestUser(
          userIdentifier: 'inactive-member-user',
          role: ClientRole.member,
        );

        // Deactivate the user membership
        final session = sessionBuilder.build();
        await User.db.updateRow(
          session,
          user.copyWith(isActive: false),
        );

        final authed = factory.authenticatedSession(
          userIdentifier: 'inactive-member-user',
          clientId: client.id,
        );
        final result = await endpoints.client.getClientsForUser(authed);

        expect(result, isEmpty);
      });

      test('throws 401 when not authenticated', () async {
        expect(
          () => endpoints.client.getClientsForUser(sessionBuilder),
          throwsA(isA<Exception>()),
        );
      });
    });
  });
}
