import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart';
import 'package:serverpod_auth_idp_server/providers/email.dart';

import '../auth/auth_user_resolver.dart';
import '../generated/protocol.dart';

class InviteEndpoint extends Endpoint {
  @override
  bool get requireLogin => false;

  Future<InvitePreview> previewInvite(
    Session session, {
    required String token,
  }) async {
    final invite = await _loadInvite(session, token);
    _checkLifecycle(invite);

    final clientRow = await CmsClient.db.findById(session, invite.clientId);
    final inviter = await User.db.findById(session, invite.invitedByUserId);
    final existingAuthUserId =
        await findAuthUserIdByEmail(session, invite.email);

    return InvitePreview(
      clientId: invite.clientId,
      clientName: clientRow?.name ?? 'this workspace',
      email: invite.email,
      role: invite.role,
      inviterName: inviter?.name ?? inviter?.email ?? 'Someone',
      inviterEmail: inviter?.email ?? '',
      expiresAt: invite.expiresAt,
      hasExistingAccount: existingAuthUserId != null,
    );
  }

  Future<AuthSuccess> acceptInvite(
    Session session, {
    required String token,
    String? password,
  }) async {
    final invite = await _loadInvite(session, token);
    _checkLifecycle(invite);

    final existingAuthUserId =
        await findAuthUserIdByEmail(session, invite.email);
    final auth = session.authenticated;

    UuidValue authUserId;
    if (existingAuthUserId != null) {
      // Caller must be that AuthUser.
      if (auth == null || auth.authUserId != existingAuthUserId) {
        throw ApiException(
          message:
              'An account already exists for this email — please sign in to accept.',
          code: 409,
          errorCode: 'SIGN_IN_REQUIRED',
        );
      }
      authUserId = existingAuthUserId;
    } else {
      // No AuthUser yet — must create one. Password required.
      if (password == null || password.isEmpty) {
        throw ApiException(
          message: 'Password required to create account',
          code: 400,
          errorCode: 'PASSWORD_REQUIRED',
        );
      }
      authUserId =
          await _createAuthUserWithPassword(session, invite.email, password);
    }

    // Create the User row (workspace membership).
    final now = DateTime.now().toUtc();
    final user = await User.db.insertRow(
      session,
      User(
        clientId: invite.clientId,
        email: invite.email,
        role: invite.role,
        isActive: true,
        serverpodUserId: authUserId.toString(),
        createdAt: now,
        updatedAt: now,
      ),
    );

    // Mark invite accepted.
    invite.acceptedAt = now;
    invite.acceptedUserId = user.id;
    invite.updatedAt = now;
    await Invite.db.updateRow(session, invite);

    session.log(
      'Invite accepted id=${invite.id} userId=${user.id}',
      level: LogLevel.info,
    );

    // Issue authentication token.
    return session.db.transaction((transaction) async {
      final authUser = await AuthServices.instance.authUsers.get(
        session,
        authUserId: authUserId,
        transaction: transaction,
      );

      return AuthServices.instance.tokenManager.issueToken(
        session,
        authUserId: authUserId,
        method: 'email',
        scopes: authUser.scopes,
        transaction: transaction,
      );
    });
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  Future<Invite> _loadInvite(Session session, String token) async {
    final invite = await Invite.db.findFirstRow(
      session,
      where: (t) => t.token.equals(token),
    );
    if (invite == null) {
      throw ApiException(
        message: 'Invite not found',
        code: 404,
        errorCode: 'INVITE_NOT_FOUND',
      );
    }
    return invite;
  }

  void _checkLifecycle(Invite invite) {
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
    if (invite.expiresAt.isBefore(DateTime.now().toUtc())) {
      throw ApiException(
        message: 'Invite expired',
        code: 410,
        errorCode: 'INVITE_EXPIRED',
      );
    }
  }

  /// Creates a new AuthUser and links an EmailAccount (with hashed password)
  /// to it. The email is treated as already-verified since this is an
  /// admin-issued invite flow.
  ///
  /// Returns the new AuthUser's id.
  Future<UuidValue> _createAuthUserWithPassword(
    Session session,
    String email,
    String password,
  ) async {
    return session.db.transaction((transaction) async {
      // 1. Create a new AuthUser.
      final newUser = await AuthServices.instance.authUsers.create(
        session,
        scopes: {Scope('user')},
        transaction: transaction,
      );

      // 2. Create an EmailAccount with hashed password, linked to the new
      //    AuthUser. This uses the EmailIdp admin helper which handles hashing
      //    internally via Argon2 — identical to what finishRegistration does.
      await AuthServices.getIdentityProvider<EmailIdp>()
          .admin
          .createEmailAuthentication(
            session,
            authUserId: newUser.id,
            email: email,
            password: password,
            transaction: transaction,
          );

      return newUser.id;
    });
  }
}
