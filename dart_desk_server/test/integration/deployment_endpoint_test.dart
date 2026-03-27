import 'package:dart_desk_server/src/generated/protocol.dart';
import 'package:test/test.dart';

import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('DeploymentEndpoint', (sessionBuilder, endpoints) {
    const adminUserId = 'deploy-admin-1';
    const projectSlug = 'deploy-project';

    TestSessionBuilder authed({String userIdentifier = adminUserId}) {
      return sessionBuilder.copyWith(
        authentication: AuthenticationOverride.authenticationInfo(
          userIdentifier,
          {},
        ),
      );
    }

    Future<Project> seedProjectAndAdmin() async {
      final session = sessionBuilder.build();
      final project = await Project.db.insertRow(
        session,
        Project(name: 'Deploy Project', slug: projectSlug, isActive: true),
      );
      await User.db.insertRow(
        session,
        User(
          clientId: project.id,
          email: 'admin@deploy.test',
          role: 'admin',
          isActive: true,
          serverpodUserId: adminUserId,
        ),
      );
      return project;
    }

    Future<Deployment> seedDeployment(
      int projectId, {
      required int version,
      DeploymentStatus status = DeploymentStatus.inactive,
    }) async {
      final session = sessionBuilder.build();
      return Deployment.db.insertRow(
        session,
        Deployment(
          projectId: projectId,
          version: version,
          status: status,
          filePath: 'builds/v$version.zip',
        ),
      );
    }

    group('_requireAdminUser guard', () {
      test('throws when not authenticated', () async {
        await seedProjectAndAdmin();
        await expectLater(
          () => endpoints.deployment.list(sessionBuilder, projectSlug),
          throwsA(isA<Exception>()),
        );
      });

      test('throws when user is not a project member', () async {
        await seedProjectAndAdmin();
        final stranger = authed(userIdentifier: 'stranger');
        await expectLater(
          () => endpoints.deployment.list(stranger, projectSlug),
          throwsA(isA<Exception>()),
        );
      });

      test('throws when user role is not admin', () async {
        final project = await seedProjectAndAdmin();
        final session = sessionBuilder.build();
        await User.db.insertRow(
          session,
          User(
            clientId: project.id,
            email: 'viewer@deploy.test',
            role: 'viewer',
            isActive: true,
            serverpodUserId: 'viewer-user',
          ),
        );
        await expectLater(
          () => endpoints.deployment.list(
            authed(userIdentifier: 'viewer-user'),
            projectSlug,
          ),
          throwsA(isA<Exception>()),
        );
      });

      test('throws when project slug does not exist', () async {
        await expectLater(
          () => endpoints.deployment.list(authed(), 'no-such-project'),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('list', () {
      test('returns empty list when no deployments', () async {
        await seedProjectAndAdmin();
        final result = await endpoints.deployment.list(authed(), projectSlug);
        expect(result, isEmpty);
      });

      test('returns all deployments for project', () async {
        final project = await seedProjectAndAdmin();
        await seedDeployment(project.id!, version: 1);
        await seedDeployment(project.id!, version: 2);
        final result = await endpoints.deployment.list(authed(), projectSlug);
        expect(result.length, equals(2));
      });
    });

    group('getActive', () {
      test('returns null when no active deployment', () async {
        final project = await seedProjectAndAdmin();
        await seedDeployment(project.id!, version: 1, status: DeploymentStatus.inactive);
        final result = await endpoints.deployment.getActive(authed(), projectSlug);
        expect(result, isNull);
      });

      test('returns the active deployment', () async {
        final project = await seedProjectAndAdmin();
        final active = await seedDeployment(project.id!, version: 1, status: DeploymentStatus.active);
        final result = await endpoints.deployment.getActive(authed(), projectSlug);
        expect(result, isNotNull);
        expect(result!.id, equals(active.id));
        expect(result.status, equals(DeploymentStatus.active));
      });
    });

    group('activate', () {
      test('sets target deployment to active', () async {
        final project = await seedProjectAndAdmin();
        await seedDeployment(project.id!, version: 1);
        final result = await endpoints.deployment.activate(authed(), projectSlug, 1);
        expect(result.status, equals(DeploymentStatus.active));
      });

      test('deactivates previously active deployment', () async {
        final project = await seedProjectAndAdmin();
        final wasActive = await seedDeployment(project.id!, version: 1, status: DeploymentStatus.active);
        await seedDeployment(project.id!, version: 2);
        await endpoints.deployment.activate(authed(), projectSlug, 2);
        final session = sessionBuilder.build();
        final nowInactive = await Deployment.db.findById(session, wasActive.id!);
        expect(nowInactive!.status, equals(DeploymentStatus.inactive));
      });

      test('throws when version does not exist', () async {
        await seedProjectAndAdmin();
        await expectLater(
          () => endpoints.deployment.activate(authed(), projectSlug, 999),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('delete', () {
      test('returns true and removes the row', () async {
        final project = await seedProjectAndAdmin();
        await seedDeployment(project.id!, version: 1);
        final result = await endpoints.deployment.delete(authed(), projectSlug, 1);
        expect(result, isTrue);
        final session = sessionBuilder.build();
        final gone = await Deployment.db.findFirstRow(
          session,
          where: (t) => t.projectId.equals(project.id!) & t.version.equals(1),
        );
        expect(gone, isNull);
      });

      test('returns false when version does not exist', () async {
        await seedProjectAndAdmin();
        final result = await endpoints.deployment.delete(authed(), projectSlug, 999);
        expect(result, isFalse);
      });

      test('throws when attempting to delete active deployment', () async {
        final project = await seedProjectAndAdmin();
        await seedDeployment(project.id!, version: 1, status: DeploymentStatus.active);
        await expectLater(
          () => endpoints.deployment.delete(authed(), projectSlug, 1),
          throwsA(isA<Exception>()),
        );
      });
    });
  });
}
