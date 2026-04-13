import 'package:serverpod/serverpod.dart';

import '../auth/resolve_user.dart';
import '../generated/protocol.dart';

class MemberEndpoint extends Endpoint {
  /// Helper to verify caller is admin+ for the client.
  Future<User> _requireClientAdmin(Session session, UuidValue clientId) async {
    final auth = session.authenticated;
    if (auth == null) {
      throw ApiException(message: 'User must be authenticated', code: 401);
    }
    final caller = await resolveUser(session, clientId: clientId);
    if (caller.role != ClientRole.admin && caller.role != ClientRole.owner) {
      throw ApiException(message: 'Admin access required', code: 403);
    }
    return caller;
  }

  /// Require caller is at least a member of the given client.
  Future<User> _requireClientMember(Session session, UuidValue clientId) async {
    final auth = session.authenticated;
    if (auth == null) {
      throw ApiException(message: 'User must be authenticated', code: 401);
    }
    return resolveUser(session, clientId: clientId);
  }

  Future<List<User>> listMembers(
    Session session, {
    required UuidValue clientId,
  }) async {
    await _requireClientMember(session, clientId);

    return User.db.find(
      session,
      where: (t) => t.clientId.equals(clientId) & t.isActive.equals(true),
      orderBy: (t) => t.createdAt,
      orderDescending: true,
    );
  }

  Future<User> inviteMember(
    Session session, {
    required UuidValue clientId,
    required String email,
    required ClientRole role,
  }) async {
    await _requireClientAdmin(session, clientId);

    // Check for duplicate
    final existing = await User.db.findFirstRow(
      session,
      where: (t) => t.clientId.equals(clientId) & t.email.equals(email),
    );
    if (existing != null) {
      throw ApiException(
        message: 'User with this email already exists in this workspace',
        code: 409,
      );
    }

    return User.db.insertRow(
      session,
      User(
        clientId: clientId,
        email: email,
        role: role,
        isActive: true,
      ),
    );
  }

  Future<User> updateMemberRole(
    Session session, {
    required UuidValue clientId,
    required UuidValue userId,
    required ClientRole role,
  }) async {
    await _requireClientAdmin(session, clientId);

    final target = await User.db.findById(session, userId);
    if (target == null || target.clientId != clientId) {
      throw ApiException(message: 'User not found', code: 404);
    }

    // Cannot demote last owner
    if (target.role == ClientRole.owner && role != ClientRole.owner) {
      final ownerCount = await User.db.count(
        session,
        where: (t) =>
            t.clientId.equals(clientId) & t.role.equals(ClientRole.owner),
      );
      if (ownerCount <= 1) {
        throw ApiException(
          message: 'Cannot remove the last owner',
          code: 400,
        );
      }
    }

    final updated = target.copyWith(role: role, updatedAt: DateTime.now());
    await User.db.updateRow(session, updated);
    return updated;
  }

  Future<void> removeMember(
    Session session, {
    required UuidValue clientId,
    required UuidValue userId,
  }) async {
    await _requireClientAdmin(session, clientId);

    final target = await User.db.findById(session, userId);
    if (target == null || target.clientId != clientId) {
      throw ApiException(message: 'User not found', code: 404);
    }

    // Cannot remove last owner
    if (target.role == ClientRole.owner) {
      final ownerCount = await User.db.count(
        session,
        where: (t) =>
            t.clientId.equals(clientId) & t.role.equals(ClientRole.owner),
      );
      if (ownerCount <= 1) {
        throw ApiException(
          message: 'Cannot remove the last owner',
          code: 400,
        );
      }
    }

    await User.db.deleteRow(session, target);
  }
}
