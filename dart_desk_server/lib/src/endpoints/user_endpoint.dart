import 'package:serverpod/serverpod.dart';
import 'package:uuid/uuid.dart';

import '../auth/dart_desk_session.dart';
import '../auth/resolve_user.dart';
import '../generated/protocol.dart';

/// Endpoint for managing users.
class UserEndpoint extends Endpoint {
  /// Get the current authenticated user.
  /// [clientId] is optional — if omitted, falls back to session.clientId.
  /// The _manage app passes clientId explicitly; consumer apps rely on API key in Authorization header.
  Future<User?> getCurrentUser(Session session, {UuidValue? clientId}) async {
    final effectiveClientId = clientId ?? session.clientId;
    return await resolveUser(session, clientId: effectiveClientId);
  }

  /// Get count of active users in the current tenant.
  Future<int> getUserCount(Session session, {required UuidValue clientId}) async {
    await resolveUser(session, clientId: clientId);
    return await User.db.count(
      session,
      where: (t) =>
          t.isActive.equals(true) & t.clientId.equals(clientId),
    );
  }
}
