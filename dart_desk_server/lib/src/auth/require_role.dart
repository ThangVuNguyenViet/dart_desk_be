import 'package:dart_desk_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';

import 'resolve_user.dart';

class RoleGuard {
  /// Roles allowed for destructive operations (delete).
  static const destructiveRoles = [ClientRole.owner, ClientRole.admin];

  /// Roles allowed for write operations (create, update).
  static const writeRoles = [ClientRole.owner, ClientRole.admin, ClientRole.member];

  /// Roles allowed for read operations.
  static const readRoles = [ClientRole.owner, ClientRole.admin, ClientRole.member, ClientRole.viewer];

  static bool isAllowed(ClientRole role, List<ClientRole> allowed) {
    return allowed.contains(role);
  }

  /// Resolves the current user and checks their ClientRole.
  /// Throws 403 if role is not in [allowed].
  static Future<User> requireRole(
    Session session, {
    required List<ClientRole> allowed,
    int? clientId,
  }) async {
    final user = await resolveUser(session, clientId: clientId);
    if (!isAllowed(user.role, allowed)) {
      throw ApiException(
        message: 'Insufficient permissions. Required role: ${allowed.map((r) => r.name).join(', ')}',
        code: 403,
        errorCode: 'INSUFFICIENT_ROLE',
      );
    }
    return user;
  }
}
