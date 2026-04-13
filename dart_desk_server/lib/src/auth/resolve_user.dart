import 'package:serverpod/serverpod.dart';
import 'package:uuid/uuid.dart';

import '../generated/protocol.dart';

/// Find the [User] record for the currently authenticated session.
///
/// Requires [session.authenticated] to be non-null (caller must be logged in).
/// Throws if no matching User record exists — users must be created explicitly
/// (e.g., via [ProjectEndpoint.createClientWithOwner]).
Future<User> resolveUser(Session session, {UuidValue? clientId}) async {
  final auth = session.authenticated;
  if (auth == null) {
    throw ApiException(message: 'User must be authenticated', code: 401);
  }
  final serverpodUserId = auth.userIdentifier;

  final user = await User.db.findFirstRow(
    session,
    where: (t) {
      var expr = t.serverpodUserId.equals(serverpodUserId);
      if (clientId != null) {
        expr = expr & t.clientId.equals(clientId);
      }
      return expr;
    },
  );

  if (user == null) {
    throw ApiException(
        message:
            'No user record found for this account. Please create a client first.',
        code: 404);
  }

  return user;
}
