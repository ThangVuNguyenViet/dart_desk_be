import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';

/// Find or auto-create a [User] record for the currently authenticated session.
///
/// Requires [session.authenticated] to be non-null (caller must be logged in).
/// The first user in a tenant automatically gets the 'admin' role.
Future<User> resolveUser(Session session, {int? clientId}) async {
  final auth = session.authenticated;
  if (auth == null) {
    throw Exception('User must be authenticated');
  }
  final serverpodUserId = auth.userIdentifier;

  // Try to find existing User
  var user = await User.db.findFirstRow(
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
  if (user != null) return user;

  // Get email/name from Serverpod UserProfile via raw SQL
  String? email;
  String? name;
  try {
    final profileRows = await session.db.unsafeQuery(
      'SELECT "email", "fullName" FROM "serverpod_auth_core_profile" '
      'WHERE "authUserId" = \'$serverpodUserId\' LIMIT 1',
    );
    if (profileRows.isNotEmpty) {
      email = profileRows.first[0] as String?;
      name = profileRows.first[1] as String?;
    }
  } catch (_) {
    // Profile lookup failed; use fallback values
  }

  // First user in tenant becomes admin
  final userCount = await User.db.count(
    session,
    where: (t) => clientId != null
        ? t.clientId.equals(clientId)
        : t.clientId.equals(null),
  );
  final role = userCount == 0 ? 'admin' : 'viewer';

  user = User(
    clientId: clientId,
    email: email ?? '',
    name: name,
    role: role,
    isActive: true,
    serverpodUserId: serverpodUserId,
  );

  try {
    return await User.db.insertRow(session, user);
  } catch (e) {
    // Race condition: another request may have created the user
    final retried = await User.db.findFirstRow(
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
    if (retried != null) return retried;
    rethrow;
  }
}
