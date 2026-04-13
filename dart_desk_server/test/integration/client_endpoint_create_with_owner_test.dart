import 'package:dart_desk_server/src/generated/protocol.dart';
import 'package:test/test.dart';
import 'package:uuid/uuid.dart';

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
    'ProjectEndpoint createClientWithOwner',
    (sessionBuilder, endpoints) {
      final insertedClientIds = <UuidValue>[];

      tearDown(() async {
        final session = sessionBuilder.build();
        for (final id in insertedClientIds) {
          await User.db.deleteWhere(
            session,
            where: (t) => t.clientId.equals(id),
          );
          await CmsClient.db.deleteWhere(
            session,
            where: (t) => t.id.equals(id),
          );
        }
        insertedClientIds.clear();
      });

      test('creates CmsClient and admin User in transaction', () async {
        const userIdentifier = 'client-owner-create';
        final client = await endpoints.project.createClientWithOwner(
          authedSession(sessionBuilder, userIdentifier: userIdentifier),
          clientName: 'Owner Workspace',
          clientSlug: 'owner-workspace',
        );
        insertedClientIds.add(client.id);

        expect(client.id, isNotNull);
        expect(client.slug, equals('owner-workspace'));
        expect(client.name, equals('Owner Workspace'));
        expect(client.isActive, isTrue);

        final user = await User.db.findFirstRow(
          sessionBuilder.build(),
          where: (t) => t.clientId.equals(client.id),
        );
        expect(user, isNotNull);
        expect(user!.role, equals('admin'));
        expect(user.serverpodUserId, equals(userIdentifier));
        expect(user.isActive, isTrue);
      });

      test('falls back to userIdentifier as email when profile absent',
          () async {
        const userIdentifier = 'client-owner-fallback-email';
        final client = await endpoints.project.createClientWithOwner(
          authedSession(sessionBuilder, userIdentifier: userIdentifier),
          clientName: 'Fallback Workspace',
          clientSlug: 'fallback-workspace',
        );
        insertedClientIds.add(client.id);

        final user = await User.db.findFirstRow(
          sessionBuilder.build(),
          where: (t) => t.clientId.equals(client.id),
        );
        expect(user!.email, equals(userIdentifier));
      });

      test('throws when caller already has a workspace', () async {
        const userIdentifier = 'client-owner-duplicate';
        final client = await endpoints.project.createClientWithOwner(
          authedSession(sessionBuilder, userIdentifier: userIdentifier),
          clientName: 'First Workspace',
          clientSlug: 'first-workspace',
        );
        insertedClientIds.add(client.id);

        await expectLater(
          endpoints.project.createClientWithOwner(
            authedSession(sessionBuilder, userIdentifier: userIdentifier),
            clientName: 'Second Workspace',
            clientSlug: 'second-workspace',
          ),
          throwsA(anything),
        );
      });

      test('throws when not authenticated', () async {
        await expectLater(
          endpoints.project.createClientWithOwner(
            sessionBuilder,
            clientName: 'X',
            clientSlug: 'valid-slug',
          ),
          throwsA(anything),
        );
      });

      group('slug validation', () {
        test('throws on slug too short', () async {
          await expectLater(
            endpoints.project.createClientWithOwner(
              authedSession(sessionBuilder,
                  userIdentifier: 'client-slug-short'),
              clientName: 'X',
              clientSlug: 'ab',
            ),
            throwsA(anything),
          );
        });

        test('throws on slug with leading hyphen', () async {
          await expectLater(
            endpoints.project.createClientWithOwner(
              authedSession(sessionBuilder,
                  userIdentifier: 'client-slug-hyphen'),
              clientName: 'X',
              clientSlug: '-bad-start',
            ),
            throwsA(anything),
          );
        });

        test('throws on uppercase slug', () async {
          await expectLater(
            endpoints.project.createClientWithOwner(
              authedSession(sessionBuilder,
                  userIdentifier: 'client-slug-upper'),
              clientName: 'X',
              clientSlug: 'UPPERCASE',
            ),
            throwsA(anything),
          );
        });

        for (final reserved in ['login', 'setup', 'admin', 'api', 'app']) {
          test('throws on reserved slug: "$reserved"', () async {
            await expectLater(
              endpoints.project.createClientWithOwner(
                authedSession(sessionBuilder,
                    userIdentifier: 'client-slug-reserved-$reserved'),
                clientName: 'X',
                clientSlug: reserved,
              ),
              throwsA(anything),
            );
          });
        }

        test('throws when slug already taken by another CmsClient', () async {
          // Seed a CmsClient with the slug directly
          final session = sessionBuilder.build();
          final existing = await CmsClient.db.insertRow(
            session,
            CmsClient(
              name: 'Existing',
              slug: 'client-already-taken',
              isActive: true,
            ),
          );
          insertedClientIds.add(existing.id);

          await expectLater(
            endpoints.project.createClientWithOwner(
              authedSession(sessionBuilder,
                  userIdentifier: 'client-slug-taken'),
              clientName: 'Dup',
              clientSlug: 'client-already-taken',
            ),
            throwsA(anything),
          );
        });
      });
    },
    rollbackDatabase: RollbackDatabase.disabled,
  );
}
