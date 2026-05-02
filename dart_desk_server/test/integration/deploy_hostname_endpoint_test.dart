import 'package:dart_desk_server/src/generated/protocol.dart';
import 'package:test/test.dart';
import 'package:uuid/uuid.dart';

import 'helpers/test_data_factory.dart';
import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('ProjectEndpoint.updateDeployHostname', (sessionBuilder, endpoints) {
    late TestDataFactory factory;

    setUp(() async {
      factory = TestDataFactory(
        sessionBuilder: sessionBuilder,
        endpoints: endpoints,
      );
    });

    TestSessionBuilder authed({String userIdentifier = 'hn-owner-1'}) {
      return sessionBuilder.copyWith(
        authentication: AuthenticationOverride.authenticationInfo(
          userIdentifier,
          {},
        ),
      );
    }

    /// Seeds a client + project + admin user under that client.
    /// Returns the seeded [Project].
    Future<Project> seedClientProjectAndAdmin({
      String userIdentifier = 'hn-owner-1',
      ClientRole role = ClientRole.admin,
      String slug = 'hn-project',
      String hostname = 'hn-project-base',
      UuidValue? clientId,
    }) async {
      final cid = clientId ?? TestDataFactory.testClientId;
      final session = sessionBuilder.build();
      await factory.ensureTestClient(clientId: cid);
      final project = await Project.db.insertRow(
        session,
        Project(
          clientId: cid,
          name: 'HN Project',
          slug: '$slug-${DateTime.now().microsecondsSinceEpoch}',
          deployHostname: '$hostname-${DateTime.now().microsecondsSinceEpoch}',
          isActive: true,
        ),
      );
      // Ensure user for this client
      await factory.ensureTestUser(
        userIdentifier: userIdentifier,
        clientId: cid,
        role: role,
      );
      return project;
    }

    group('updateDeployHostname', () {
      test('rejects invalid format (starts with digit)', () async {
        final project = await seedClientProjectAndAdmin();
        await expectLater(
          () => endpoints.project.updateDeployHostname(
            authed(),
            project.id,
            '1abc-invalid',
          ),
          throwsA(isA<ApiException>().having((e) => e.code, 'code', 400)),
        );
      });

      test('rejects reserved hostname', () async {
        final project = await seedClientProjectAndAdmin();
        await expectLater(
          () => endpoints.project.updateDeployHostname(
            authed(),
            project.id,
            'admin',
          ),
          throwsA(isA<ApiException>().having((e) => e.code, 'code', 400)),
        );
      });

      test('returns 404 for nonexistent project', () async {
        // Ensure user exists so auth passes
        await factory.ensureTestUser(
          userIdentifier: 'hn-owner-1',
          clientId: TestDataFactory.testClientId,
          role: ClientRole.admin,
        );
        await factory.ensureTestClient();
        await expectLater(
          () => endpoints.project.updateDeployHostname(
            authed(),
            UuidValue.fromString('00000000-0000-4000-8000-000000000099'),
            'valid-hostname',
          ),
          throwsA(isA<ApiException>().having((e) => e.code, 'code', 404)),
        );
      });

      test('rejects non-admin (viewer role)', () async {
        final project = await seedClientProjectAndAdmin(
          userIdentifier: 'hn-owner-1',
          role: ClientRole.admin,
        );
        // Create a viewer user
        await factory.ensureTestUser(
          userIdentifier: 'hn-viewer-1',
          clientId: TestDataFactory.testClientId,
          role: ClientRole.viewer,
        );
        final viewerSession = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            'hn-viewer-1',
            {},
          ),
        );
        await expectLater(
          () => endpoints.project.updateDeployHostname(
            viewerSession,
            project.id,
            'valid-hostname',
          ),
          throwsA(isA<ApiException>().having((e) => e.code, 'code', 403)),
        );
      });

      test('updates hostname successfully', () async {
        final project = await seedClientProjectAndAdmin();
        final updated = await endpoints.project.updateDeployHostname(
          authed(),
          project.id,
          'my-new-hostname',
        );
        expect(updated.deployHostname, equals('my-new-hostname'));
        // Verify in DB
        final fromDb = await Project.db.findById(sessionBuilder.build(), project.id);
        expect(fromDb!.deployHostname, equals('my-new-hostname'));
      });

      test('rejects already-taken hostname with 409', () async {
        // Create a second client with its own project that already has 'claimed-already'
        final otherClientId =
            UuidValue.fromString('00000000-0000-4000-8000-000000000099');
        final session = sessionBuilder.build();
        await factory.ensureTestClient(
          clientId: otherClientId,
          name: 'Other Client',
          slug: 'other-client-hn',
        );
        await Project.db.insertRow(
          session,
          Project(
            clientId: otherClientId,
            name: 'Claimed Project',
            slug: 'claimed-project-hn',
            deployHostname: 'claimed-already',
            isActive: true,
          ),
        );

        // Our project under the primary client
        final project = await seedClientProjectAndAdmin();
        await expectLater(
          () => endpoints.project.updateDeployHostname(
            authed(),
            project.id,
            'claimed-already',
          ),
          throwsA(isA<ApiException>().having((e) => e.code, 'code', 409)),
        );
      });
    });
  });
}
