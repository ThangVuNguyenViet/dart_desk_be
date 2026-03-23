import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import '../auth/dart_desk_auth.dart';

/// Endpoint for managing users.
class UserEndpoint extends Endpoint {
  /// Get the current authenticated user.
  /// For Serverpod IDP: returns existing User (must exist via seed or prior creation).
  /// For external auth: auto-creates User on first call.
  Future<User?> getCurrentUser(Session session) async {
    return await DartDeskAuth.authenticateRequest(session);
  }

  /// Get count of active users in the current tenant.
  Future<int> getUserCount(Session session) async {
    final user = await DartDeskAuth.authenticateRequest(session);
    if (user == null) {
      throw Exception('User must be authenticated');
    }
    return await User.db.count(
      session,
      where: (t) {
        var expr = t.isActive.equals(true);
        if (user.clientId != null) {
          expr = expr & t.clientId.equals(user.clientId);
        }
        return expr;
      },
    );
  }
}
