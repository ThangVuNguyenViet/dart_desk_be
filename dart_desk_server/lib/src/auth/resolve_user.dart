import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';

/// Find the [User] record for the currently authenticated session.
///
/// Requires [session.authenticated] to be non-null (caller must be logged in).
/// Throws if no matching User record exists — users must be created explicitly
/// (e.g., via [ProjectEndpoint.createProjectWithOwner]).
Future<User> resolveUser(Session session, {int? clientId}) async {
  final auth = session.authenticated;
  if (auth == null) {
    throw Exception('User must be authenticated');
  }
  final serverpodUserId = auth.userIdentifier;

  final user = await User.db.findFirstRow(
    session,
    where: (t) {
      var expr = t.serverpodUserId.equals(serverpodUserId);
      if (clientId != null) {
        expr = expr & t.clientId.equals(clientId);
      } else {
        expr = expr & t.clientId.equals(null);
      }
      return expr;
    },
  );

  if (user == null) {
    throw Exception('No user record found for this account');
  }

  return user;
}
