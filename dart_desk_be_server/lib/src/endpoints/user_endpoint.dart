import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';

/// Endpoint for managing users.
/// TODO: Rewrite for multi-tenancy extraction (Task 5).
class UserEndpoint extends Endpoint {
  /// Get the current user by tenant context.
  /// Placeholder — will be rewritten in Task 5.
  Future<User?> getCurrentUser(Session session) async {
    final authInfo = session.authenticated;
    if (authInfo == null) {
      throw Exception('User must be authenticated');
    }

    return await User.db.findFirstRow(
      session,
      where: (t) => t.serverpodUserId.equals(authInfo.userIdentifier),
    );
  }
}
