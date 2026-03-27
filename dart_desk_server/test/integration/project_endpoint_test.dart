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
  withServerpod('ProjectEndpoint', (sessionBuilder, endpoints) {
    Future<Project> seedProject({
      String name = 'Test Project',
      String slug = 'test-project',
      bool isActive = true,
    }) async {
      final session = sessionBuilder.build();
      return Project.db.insertRow(
        session,
        Project(name: name, slug: slug, isActive: isActive),
      );
    }

    group('getProjects', () {
      test('returns empty list when search yields no results', () async {
        final result = await endpoints.project.getProjects(
          sessionBuilder,
          search: 'zzz-no-match-xyz',
          limit: 20,
          offset: 0,
        );
        expect(result.projects, isEmpty);
        expect(result.total, equals(0));
      });

      test('returns seeded projects via search', () async {
        await seedProject(name: 'GetProjAlpha', slug: 'getprojtest-alpha');
        await seedProject(name: 'GetProjBeta', slug: 'getprojtest-beta');
        final result = await endpoints.project.getProjects(
          sessionBuilder,
          search: 'getprojtest',
          limit: 20,
          offset: 0,
        );
        expect(result.total, equals(2));
        expect(result.projects.length, equals(2));
      });

      test('paginates correctly', () async {
        for (var i = 0; i < 5; i++) {
          await seedProject(name: 'Paginate$i', slug: 'paginatetest-$i');
        }
        final result = await endpoints.project.getProjects(
          sessionBuilder,
          search: 'paginatetest',
          limit: 2,
          offset: 0,
        );
        expect(result.projects.length, equals(2));
        expect(result.total, equals(5));
        expect(result.page, equals(1));
        expect(result.pageSize, equals(2));
      });

      test('filters by search term on name', () async {
        await seedProject(name: 'Alpha Unique App', slug: 'alpha-unique-app');
        await seedProject(name: 'Beta Unique App', slug: 'beta-unique-app');
        final result = await endpoints.project.getProjects(
          sessionBuilder,
          search: 'Alpha Unique',
          limit: 20,
          offset: 0,
        );
        expect(result.projects.length, equals(1));
        expect(result.projects.first.name, equals('Alpha Unique App'));
      });

      test('filters by search term on slug', () async {
        await seedProject(name: 'My App', slug: 'my-xuniquex-slug');
        await seedProject(name: 'Other App', slug: 'other-yuniquey-slug');
        final result = await endpoints.project.getProjects(
          sessionBuilder,
          search: 'xuniquex',
          limit: 20,
          offset: 0,
        );
        expect(result.projects.length, equals(1));
        expect(result.projects.first.slug, equals('my-xuniquex-slug'));
      });
    });

    group('getProjectBySlug', () {
      test('returns matching project', () async {
        await seedProject(slug: 'find-me-slug');
        final p = await endpoints.project.getProjectBySlug(
          sessionBuilder,
          'find-me-slug',
        );
        expect(p, isNotNull);
        expect(p!.slug, equals('find-me-slug'));
      });

      test('returns null for unknown slug', () async {
        final p = await endpoints.project.getProjectBySlug(
          sessionBuilder,
          'no-such-slug-zzz',
        );
        expect(p, isNull);
      });
    });

    group('getProject', () {
      test('returns project by id', () async {
        final seeded = await seedProject();
        final p = await endpoints.project.getProject(
          sessionBuilder,
          seeded.id!,
        );
        expect(p, isNotNull);
        expect(p!.id, equals(seeded.id));
      });

      test('returns null for unknown id', () async {
        final p = await endpoints.project.getProject(sessionBuilder, 999999);
        expect(p, isNull);
      });
    });

    group('createProject', () {
      test('inserts and returns project with correct fields', () async {
        final p = await endpoints.project.createProject(
          authedSession(sessionBuilder),
          'New Project',
          'new-project',
          description: 'A description',
        );
        expect(p.id, isNotNull);
        expect(p.name, equals('New Project'));
        expect(p.slug, equals('new-project'));
        expect(p.description, equals('A description'));
        expect(p.isActive, isTrue);
      });

      test('throws when not authenticated', () async {
        await expectLater(
          () => endpoints.project.createProject(sessionBuilder, 'X', 'x-slug'),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('updateProject', () {
      test('updates name', () async {
        final seeded = await seedProject();
        final updated = await endpoints.project.updateProject(
          authedSession(sessionBuilder),
          seeded.id!,
          name: 'Updated Name',
        );
        expect(updated, isNotNull);
        expect(updated!.name, equals('Updated Name'));
        final fromDb = await Project.db.findById(
          sessionBuilder.build(),
          seeded.id!,
        );
        expect(fromDb!.name, equals('Updated Name'));
      });

      test('sets isActive to false', () async {
        final seeded = await seedProject();
        final updated = await endpoints.project.updateProject(
          authedSession(sessionBuilder),
          seeded.id!,
          isActive: false,
        );
        expect(updated!.isActive, isFalse);
        final fromDb = await Project.db.findById(
          sessionBuilder.build(),
          seeded.id!,
        );
        expect(fromDb!.isActive, isFalse);
      });

      test('returns null for nonexistent id', () async {
        final result = await endpoints.project.updateProject(
          authedSession(sessionBuilder),
          999999,
        );
        expect(result, isNull);
      });

      test('throws when not authenticated', () async {
        final seeded = await seedProject();
        await expectLater(
          () => endpoints.project.updateProject(sessionBuilder, seeded.id!),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('deleteProject', () {
      test('returns true and removes row', () async {
        final seeded = await seedProject();
        final result = await endpoints.project.deleteProject(
          authedSession(sessionBuilder),
          seeded.id!,
        );
        expect(result, isTrue);
        final gone = await Project.db.findById(
          sessionBuilder.build(),
          seeded.id!,
        );
        expect(gone, isNull);
      });

      test('returns false for nonexistent id', () async {
        final result = await endpoints.project.deleteProject(
          authedSession(sessionBuilder),
          999999,
        );
        expect(result, isFalse);
      });

      test('throws when not authenticated', () async {
        final seeded = await seedProject();
        await expectLater(
          () => endpoints.project.deleteProject(sessionBuilder, seeded.id!),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('createProjectWithOwner slug validation', () {
      test('throws on slug too short', () async {
        await expectLater(
          () => endpoints.project.createProjectWithOwner(
            authedSession(sessionBuilder),
            name: 'X',
            slug: 'ab',
          ),
          throwsA(isA<Exception>()),
        );
      });

      test('throws on slug with leading hyphen', () async {
        await expectLater(
          () => endpoints.project.createProjectWithOwner(
            authedSession(sessionBuilder),
            name: 'X',
            slug: '-bad-start',
          ),
          throwsA(isA<Exception>()),
        );
      });

      test('throws on uppercase slug', () async {
        await expectLater(
          () => endpoints.project.createProjectWithOwner(
            authedSession(sessionBuilder),
            name: 'X',
            slug: 'UPPERCASE',
          ),
          throwsA(isA<Exception>()),
        );
      });

      for (final reserved in ['login', 'setup', 'admin', 'api', 'app']) {
        test('throws on reserved slug: "$reserved"', () async {
          await expectLater(
            () => endpoints.project.createProjectWithOwner(
              authedSession(sessionBuilder),
              name: 'X',
              slug: reserved,
            ),
            throwsA(isA<Exception>()),
          );
        });
      }

      test('throws when slug already taken', () async {
        await seedProject(slug: 'already-taken');
        await expectLater(
          () => endpoints.project.createProjectWithOwner(
            authedSession(sessionBuilder),
            name: 'Dup',
            slug: 'already-taken',
          ),
          throwsA(isA<Exception>()),
        );
      });

      test('throws when not authenticated', () async {
        await expectLater(
          () => endpoints.project.createProjectWithOwner(
            sessionBuilder,
            name: 'X',
            slug: 'valid-slug',
          ),
          throwsA(isA<Exception>()),
        );
      });
    });
  });

  // createProjectWithOwner success tests run with DB rollback disabled
  // because the endpoint uses an internal transaction (session.db.transaction)
  // which is incompatible with the test framework's per-test rollback wrapper.
  withServerpod(
    'ProjectEndpoint createProjectWithOwner success',
    (sessionBuilder, endpoints) {
      final insertedProjectIds = <int>[];

      tearDown(() async {
        // Clean up rows inserted during this test since rollback is disabled.
        final session = sessionBuilder.build();
        for (final id in insertedProjectIds) {
          await User.db.deleteWhere(
            session,
            where: (t) => t.clientId.equals(id),
          );
          await Project.db.deleteWhere(
            session,
            where: (t) => t.id.equals(id),
          );
        }
        insertedProjectIds.clear();
      });

      test('creates Project and admin User in transaction', () async {
        final project = await endpoints.project.createProjectWithOwner(
          authedSession(sessionBuilder),
          name: 'Owner Project',
          slug: 'owner-project',
        );
        insertedProjectIds.add(project.id!);
        expect(project.id, isNotNull);
        expect(project.slug, equals('owner-project'));
        final user = await User.db.findFirstRow(
          sessionBuilder.build(),
          where: (t) => t.clientId.equals(project.id!),
        );
        expect(user, isNotNull);
        expect(user!.role, equals('admin'));
        expect(user.serverpodUserId, equals('owner-1'));
        expect(user.isActive, isTrue);
      });

      test('falls back to userIdentifier as email when profile absent',
          () async {
        final project = await endpoints.project.createProjectWithOwner(
          authedSession(sessionBuilder),
          name: 'Fallback Email',
          slug: 'fallback-email',
        );
        insertedProjectIds.add(project.id!);
        final user = await User.db.findFirstRow(
          sessionBuilder.build(),
          where: (t) => t.clientId.equals(project.id!),
        );
        expect(user!.email, equals('owner-1'));
      });
    },
    rollbackDatabase: RollbackDatabase.disabled,
  );
}
