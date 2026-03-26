import 'package:serverpod/serverpod.dart';

import '../auth/dart_desk_session.dart';
import '../auth/resolve_user.dart';
import '../generated/protocol.dart';

/// Endpoint for managing users.
class UserEndpoint extends Endpoint {
  /// Get the current authenticated user.
  /// [clientId] is optional — if omitted, falls back to session.apiKey.clientId.
  /// The _manage app passes clientId explicitly; consumer apps rely on x-api-key.
  Future<User?> getCurrentUser(Session session, {int? clientId}) async {
    final effectiveClientId = clientId ?? session.apiKey?.clientId;
    return await resolveUser(session, clientId: effectiveClientId);
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
