import 'package:serverpod/serverpod.dart';

import '../auth/dart_desk_session.dart';
import '../auth/resolve_user.dart';
import '../generated/protocol.dart';

/// Endpoint for managing users.
class UserEndpoint extends Endpoint {
  /// Get the current authenticated user.
  /// For Serverpod IDP: returns existing User (must exist via seed or prior creation).
  /// For external auth: auto-creates User on first call.
  Future<User?> getCurrentUser(Session session) async {
    final apiKey = session.apiKey;
    return await resolveUser(session, clientId: apiKey.clientId);
  }

  /// Get count of active users in the current tenant.
  Future<int> getUserCount(Session session) async {
    final apiKey = session.apiKey;
    // resolveUser throws if not authenticated
    await resolveUser(session, clientId: apiKey.clientId);
    return await User.db.count(
      session,
      where: (t) {
        var expr = t.isActive.equals(true);
        if (apiKey.clientId != null) {
          expr = expr & t.clientId.equals(apiKey.clientId);
        }
        return expr;
      },
    );
  }
}
