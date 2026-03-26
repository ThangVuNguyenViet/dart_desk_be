import 'package:serverpod/serverpod.dart';

import '../auth/resolve_user.dart';
import '../generated/protocol.dart';

/// Endpoint for managing users.
class UserEndpoint extends Endpoint {
  /// Get the current authenticated user.
  /// For Serverpod IDP: returns existing User (must exist via seed or prior creation).
  /// For external auth: auto-creates User on first call.
  Future<User?> getCurrentUser(Session session, {required int clientId}) async {
    return await resolveUser(session, clientId: clientId);
  }

  /// Get count of active users in the current tenant.
  Future<int> getUserCount(Session session, {required int clientId}) async {
    await resolveUser(session, clientId: clientId);
    return await User.db.count(
      session,
      where: (t) =>
          t.isActive.equals(true) & t.clientId.equals(clientId),
    );
  }
}
