import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';
import 'package:serverpod_auth_idp_server/providers/google.dart';

class GoogleIdpEndpoint extends GoogleIdpBaseEndpoint {
  @override
  Future<AuthSuccess> login(
    Session session, {
    required String idToken,
    required String? accessToken,
  }) async {
    final utils = googleIdp.utils;

    // Verify Google token and get account details
    final accountDetails = await utils.fetchAccountDetails(
      session,
      idToken: idToken,
      accessToken: accessToken,
    );

    // Check if this Google user ID is already known
    final existingGoogle = await GoogleAccount.db.findFirstRow(
      session,
      where: (t) => t.userIdentifier.equals(accountDetails.userIdentifier),
    );

    if (existingGoogle != null) {
      // Existing Google account — normal login flow
      return super.login(session, idToken: idToken, accessToken: accessToken);
    }

    // New Google user — check if email matches an existing EmailAccount
    final existingEmail = await EmailAccount.db.findFirstRow(
      session,
      where: (t) => t.email.equals(accountDetails.email.toLowerCase()),
    );

    if (existingEmail != null) {
      // Auto-link: attach Google to existing EmailAccount's AuthUser
      return await session.db.transaction((transaction) async {
        try {
          await utils.linkGoogleAuthentication(
            session,
            authUserId: existingEmail.authUserId,
            accountDetails: accountDetails,
            transaction: transaction,
          );
        } catch (e) {
          session.log(
            'Google link failed (likely race condition), falling back: $e',
            level: LogLevel.warning,
          );
          return super
              .login(session, idToken: idToken, accessToken: accessToken);
        }

        session.log(
          '[Auth] Auto-linked Google (${accountDetails.email}) to existing email account',
          level: LogLevel.info,
        );

        // Issue tokens for the existing AuthUser
        final authUser = await AuthServices.instance.authUsers.get(
          session,
          authUserId: existingEmail.authUserId,
          transaction: transaction,
        );

        return AuthServices.instance.tokenManager.issueToken(
          session,
          authUserId: existingEmail.authUserId,
          transaction: transaction,
          method: 'google',
          scopes: authUser.scopes,
        );
      });
    }

    // No existing account — normal flow creates new user
    return super.login(session, idToken: idToken, accessToken: accessToken);
  }
}
