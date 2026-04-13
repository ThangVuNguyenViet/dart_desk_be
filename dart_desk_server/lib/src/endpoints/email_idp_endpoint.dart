import 'dart:convert';

import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';
import 'package:serverpod_auth_idp_server/providers/email.dart';

/// Custom email IDP endpoint that auto-links with existing Google accounts.
///
/// When a user registers via email and a Google account already exists for the
/// same email, the email credential is linked to the existing auth user instead
/// of creating a duplicate account.
class EmailIdpEndpoint extends EmailIdpBaseEndpoint {
  @override
  Future<AuthSuccess> finishRegistration(
    Session session, {
    required String registrationToken,
    required String password,
  }) async {
    // Peek at the email from the registration token without consuming it.
    final googleAuthUserId = await _findGoogleAuthUserForToken(
      session,
      registrationToken,
    );

    if (googleAuthUserId == null) {
      // No Google account for this email — normal registration.
      return super.finishRegistration(
        session,
        registrationToken: registrationToken,
        password: password,
      );
    }

    // Google account exists. Let the base class complete registration (which
    // validates the token, creates a new AuthUser + EmailAccount), then merge
    // the EmailAccount onto the existing Google AuthUser.
    await super.finishRegistration(
      session,
      registrationToken: registrationToken,
      password: password,
    );

    // Re-point the newly created EmailAccount to the Google AuthUser and
    // clean up the orphaned AuthUser + profile.
    await _mergeToExistingAuthUser(session, googleAuthUserId);

    session.log(
      '[Auth] Auto-linked email registration to existing Google account',
      level: LogLevel.info,
    );

    // Issue a fresh token for the Google AuthUser (the one that now owns both
    // credentials).
    return session.db.transaction((transaction) async {
      final authUser = await AuthServices.instance.authUsers.get(
        session,
        authUserId: googleAuthUserId,
        transaction: transaction,
      );

      return AuthServices.instance.tokenManager.issueToken(
        session,
        authUserId: googleAuthUserId,
        method: 'email',
        scopes: authUser.scopes,
        transaction: transaction,
      );
    });
  }

  /// Decodes the registration token to extract the email, then checks if a
  /// Google account already exists for that email. Returns the Google account's
  /// authUserId if found, null otherwise.
  Future<UuidValue?> _findGoogleAuthUserForToken(
    Session session,
    String registrationToken,
  ) async {
    final accountRequestId = parseAccountRequestId(registrationToken);
    if (accountRequestId == null) return null;

    try {
      final request = await emailIdp.admin.findActiveEmailAccountRequest(
        session,
        accountRequestId: accountRequestId,
      );
      if (request == null) return null;

      final googleAccount = await GoogleAccount.db.findFirstRow(
        session,
        where: (t) => t.email.equals(request.email.toLowerCase()),
      );

      return googleAccount?.authUserId;
    } catch (_) {
      return null;
    }
  }

  /// Extracts the accountRequestId from a base64-encoded registration token.
  /// Returns null if the token is malformed.
  static UuidValue? parseAccountRequestId(String registrationToken) {
    try {
      final decoded = utf8.decode(base64Decode(registrationToken));
      final colonIndex = decoded.indexOf(':');
      if (colonIndex < 0) return null;
      return UuidValue.withValidation(decoded.substring(0, colonIndex));
    } catch (_) {
      return null;
    }
  }

  /// After super.finishRegistration created a new AuthUser + EmailAccount,
  /// re-point the EmailAccount to [targetAuthUserId] and delete the orphan.
  Future<void> _mergeToExistingAuthUser(
    Session session,
    UuidValue targetAuthUserId,
  ) async {
    await session.db.transaction((transaction) async {
      // Find the EmailAccount that was just created (most recent one).
      // It's the one whose authUserId != targetAuthUserId.
      final emailAccounts = await EmailAccount.db.find(
        session,
        where: (t) => t.authUserId.notEquals(targetAuthUserId),
        orderBy: (t) => t.createdAt,
        orderDescending: true,
        limit: 1,
        transaction: transaction,
      );

      if (emailAccounts.isEmpty) return;
      final emailAccount = emailAccounts.first;
      final orphanAuthUserId = emailAccount.authUserId;

      // Re-point the EmailAccount to the Google AuthUser.
      emailAccount.authUserId = targetAuthUserId;
      await EmailAccount.db.updateRow(
        session,
        emailAccount,
        transaction: transaction,
      );

      // Delete orphaned profile and auth user.
      try {
        await AuthServices.instance.userProfiles.deleteProfileForUser(
          session,
          orphanAuthUserId,
          transaction: transaction,
        );
      } catch (_) {
        // Profile may not exist yet.
      }
      await AuthServices.instance.authUsers.delete(
        session,
        authUserId: orphanAuthUserId,
        transaction: transaction,
      );
    });
  }
}
