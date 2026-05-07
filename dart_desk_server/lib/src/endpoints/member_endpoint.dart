import 'dart:convert';
import 'dart:math';

import 'package:serverpod/serverpod.dart';

import '../auth/resolve_user.dart';
import '../generated/protocol.dart';
import '../services/invite_email.dart';

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
      where: (t) =>
          t.clientId.equals(clientId) &
          t.isActive.equals(true) &
          t.deletedAt.equals(null),
      orderBy: (t) => t.createdAt,
      orderDescending: true,
    );
  }

  Future<InviteResult> inviteMember(
    Session session, {
    required UuidValue clientId,
    required String email,
    required ClientRole role,
  }) async {
    final caller = await _requireClientAdmin(session, clientId);

    if (role == ClientRole.owner) {
      throw ApiException(message: 'Cannot invite as owner', code: 400);
    }

    final activeMember = await User.db.findFirstRow(
      session,
      where: (t) =>
          t.clientId.equals(clientId) &
          t.email.equals(email) &
          t.isActive.equals(true) &
          t.deletedAt.equals(null),
    );
    if (activeMember != null) {
      throw ApiException(
        message: 'A member with this email already exists in this workspace',
        code: 409,
        errorCode: 'EMAIL_ALREADY_MEMBER',
      );
    }

    final pending = await Invite.db.findFirstRow(
      session,
      where: (t) =>
          t.clientId.equals(clientId) &
          t.email.equals(email) &
          t.acceptedAt.equals(null) &
          t.revokedAt.equals(null),
    );
    if (pending != null) {
      throw ApiException(
        message: 'An invite is already pending for this email',
        code: 409,
        errorCode: 'INVITE_ALREADY_PENDING',
      );
    }

    final token = _generateToken();
    final now = DateTime.now().toUtc();
    final invite = await Invite.db.insertRow(
      session,
      Invite(
        clientId: clientId,
        email: email,
        role: role,
        token: token,
        invitedByUserId: caller.id,
        expiresAt: now.add(const Duration(days: 14)),
        createdAt: now,
        updatedAt: now,
      ),
    );
    session.log(
      'Invite created id=${invite.id} clientId=$clientId email=$email role=$role',
      level: LogLevel.info,
    );

    final emailSent = await _sendInvite(session, invite, caller);
    return InviteResult(invite: invite, emailSent: emailSent);
  }

  Future<List<Invite>> listPendingInvites(
    Session session, {
    required UuidValue clientId,
  }) async {
    await _requireClientAdmin(session, clientId);
    final now = DateTime.now().toUtc();
    return Invite.db.find(
      session,
      where: (t) =>
          t.clientId.equals(clientId) &
          t.acceptedAt.equals(null) &
          t.revokedAt.equals(null) &
          (t.expiresAt > now),
      orderBy: (t) => t.createdAt,
      orderDescending: true,
    );
  }

  Future<InviteResult> resendInvite(
    Session session, {
    required UuidValue inviteId,
  }) async {
    final invite = await Invite.db.findById(session, inviteId);
    if (invite == null) {
      throw ApiException(
        message: 'Invite not found',
        code: 404,
        errorCode: 'INVITE_NOT_FOUND',
      );
    }
    final caller = await _requireClientAdmin(session, invite.clientId);
    if (invite.acceptedAt != null) {
      throw ApiException(
        message: 'Invite already accepted',
        code: 409,
        errorCode: 'INVITE_ALREADY_ACCEPTED',
      );
    }
    if (invite.revokedAt != null) {
      throw ApiException(
        message: 'Invite revoked',
        code: 409,
        errorCode: 'INVITE_REVOKED',
      );
    }
    final now = DateTime.now().toUtc();
    invite.expiresAt = now.add(const Duration(days: 14));
    invite.updatedAt = now;
    await Invite.db.updateRow(session, invite);

    final emailSent = await _sendInvite(session, invite, caller);
    return InviteResult(invite: invite, emailSent: emailSent);
  }

  Future<void> revokeInvite(
    Session session, {
    required UuidValue inviteId,
  }) async {
    final invite = await Invite.db.findById(session, inviteId);
    if (invite == null) {
      throw ApiException(
        message: 'Invite not found',
        code: 404,
        errorCode: 'INVITE_NOT_FOUND',
      );
    }
    await _requireClientAdmin(session, invite.clientId);
    if (invite.acceptedAt != null) {
      throw ApiException(
        message: 'Cannot revoke accepted invite',
        code: 409,
        errorCode: 'INVITE_ALREADY_ACCEPTED',
      );
    }
    final now = DateTime.now().toUtc();
    invite.revokedAt = now;
    invite.updatedAt = now;
    await Invite.db.updateRow(session, invite);
    session.log('Invite revoked id=$inviteId', level: LogLevel.info);
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
    session.log(
      'Updated Member id=$userId clientId=$clientId role=$role',
      level: LogLevel.info,
    );
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
            t.clientId.equals(clientId) &
            t.role.equals(ClientRole.owner) &
            t.isActive.equals(true) &
            t.deletedAt.equals(null),
      );
      if (ownerCount <= 1) {
        throw ApiException(
          message: 'Cannot remove the last owner. Transfer ownership first.',
          code: 400,
          errorCode: 'LAST_OWNER',
        );
      }
    }

    // Soft-delete user
    target.isActive = false;
    target.deletedAt = DateTime.now();
    await User.db.updateRow(session, target);

    // Hard-delete all project memberships
    final memberships = await ProjectMember.db.find(
      session,
      where: (t) => t.userId.equals(userId),
    );
    for (final m in memberships) {
      await ProjectMember.db.deleteRow(session, m);
    }
    session.log('Removed Member id=$userId clientId=$clientId',
        level: LogLevel.info);
  }

  /// Returns true if the email was sent successfully; false if the SMTP
  /// path threw (logged at error level). Never rethrows — invite persistence
  /// is independent of email delivery.
  Future<bool> _sendInvite(Session session, Invite invite, User inviter) async {
    final clientRow = await CmsClient.db.findById(session, invite.clientId);
    final clientName = clientRow?.name ?? 'your workspace';
    final inviterName = inviter.name ?? inviter.email;
    try {
      await sendInviteEmail(
        session,
        invite: invite,
        clientName: clientName,
        inviterName: inviterName,
        inviterEmail: inviter.email,
      );
      return true;
    } catch (e) {
      session.log(
        'Invite email failed id=${invite.id} email=${invite.email}: $e',
        level: LogLevel.error,
      );
      return false;
    }
  }

  String _generateToken() {
    final bytes =
        List<int>.generate(32, (_) => Random.secure().nextInt(256));
    return base64Url.encode(bytes).replaceAll('=', '');
  }
}
