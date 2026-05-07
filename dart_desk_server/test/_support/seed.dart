import 'package:dart_desk_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';

import '../integration/test_tools/serverpod_test_tools.dart';

/// Returned by [seedAdminContext] and [seedMemberContext].
class SeedContext {
  final UuidValue clientId;
  final UuidValue userId;

  /// An authenticated [TestSessionBuilder] scoped to [clientId].
  final TestSessionBuilder session;

  const SeedContext({
    required this.clientId,
    required this.userId,
    required this.session,
  });
}

/// Seeds a [CmsClient] + an admin [User], returns an authenticated session.
///
/// Each call generates a fresh UUID-based client so tests don't share rows.
Future<SeedContext> seedAdminContext(TestSessionBuilder sessionBuilder) =>
    _seed(sessionBuilder, ClientRole.admin);

/// Seeds a [CmsClient] + a member-role [User], returns an authenticated session.
Future<SeedContext> seedMemberContext(TestSessionBuilder sessionBuilder) =>
    _seed(sessionBuilder, ClientRole.member);

Future<SeedContext> _seed(
    TestSessionBuilder sessionBuilder, ClientRole role) async {
  final clientId = UuidValue.fromString(const Uuid().v4());
  final userIdentifier = 'seed-user-${const Uuid().v4()}';

  final session = sessionBuilder.build();

  // Insert the client row.
  await CmsClient.db.insertRow(
    session,
    CmsClient(
      id: clientId,
      name: 'Test Workspace',
      slug: 'test-${clientId.toString().substring(0, 8)}',
      isActive: true,
    ),
  );

  // Insert the user row directly (mirrors TestDataFactory.ensureTestUser).
  final user = await User.db.insertRow(
    session,
    User(
      clientId: clientId,
      email: '$userIdentifier@example.com',
      name: 'Seed User',
      role: role,
      isActive: true,
      serverpodUserId: userIdentifier,
    ),
  );

  // Build an authenticated session scoped to this client.
  final authed = sessionBuilder.copyWith(
    authentication: AuthenticationOverride.authenticationInfo(
      userIdentifier,
      {
        Scope('client:$clientId'),
      },
    ),
  );

  return SeedContext(
    clientId: clientId,
    userId: user.id,
    session: authed,
  );
}
