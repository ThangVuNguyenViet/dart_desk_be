import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import '../tenancy.dart';

/// Endpoint for managing users
class UserEndpoint extends Endpoint {
  /// Ensure a user exists for the authenticated Serverpod user.
  /// Creates one automatically on first login.
  Future<User> ensureUser(Session session) async {
    final authInfo = session.authenticated;
    if (authInfo == null) {
      throw Exception('User must be authenticated');
    }

    final userIdentifier = authInfo.userIdentifier;
    final tenantId = await DartDeskTenancy.resolveTenantId(session);

    // Check if User already exists
    final existing = await User.db.findFirstRow(
      session,
      where: (t) {
        var expr = t.serverpodUserId.equals(userIdentifier);
        if (tenantId != null) {
          expr = expr & t.tenantId.equals(tenantId);
        } else {
          expr = expr & t.tenantId.equals(null);
        }
        return expr;
      },
    );
    if (existing != null) return existing;

    // Get user profile from serverpod_auth_core profile table
    String? email;
    String? name;
    try {
      final profileRows = await session.db.unsafeQuery(
        'SELECT "email", "fullName" FROM "serverpod_auth_core_profile" '
        'WHERE "authUserId" = \'$userIdentifier\' LIMIT 1',
      );
      if (profileRows.isNotEmpty) {
        email = profileRows.first[0] as String?;
        name = profileRows.first[1] as String?;
      }
    } catch (_) {}

    // Create the User
    final newUser = User(
      tenantId: tenantId,
      email: email ?? userIdentifier,
      name: name,
      role: 'viewer',
      isActive: true,
      serverpodUserId: userIdentifier,
    );

    try {
      return await User.db.insertRow(session, newUser);
    } catch (e) {
      // Handle duplicate key race condition
      final retried = await User.db.findFirstRow(
        session,
        where: (t) =>
            t.serverpodUserId.equals(userIdentifier) &
            (tenantId != null ? t.tenantId.equals(tenantId) : t.tenantId.equals(null)),
      );
      if (retried != null) return retried;
      rethrow;
    }
  }

  /// Get the current user for the authenticated session.
  Future<User?> getCurrentUser(Session session) async {
    final authInfo = session.authenticated;
    if (authInfo == null) {
      throw Exception('User must be authenticated');
    }

    final tenantId = await DartDeskTenancy.resolveTenantId(session);

    return await User.db.findFirstRow(
      session,
      where: (t) {
        var expr = t.serverpodUserId.equals(authInfo.userIdentifier);
        if (tenantId != null) {
          expr = expr & t.tenantId.equals(tenantId);
        }
        return expr;
      },
    );
  }

  /// Get count of users (for overview stats).
  Future<int> getUserCount(Session session) async {
    final authInfo = session.authenticated;
    if (authInfo == null) {
      throw Exception('User must be authenticated');
    }

    final tenantId = await DartDeskTenancy.resolveTenantId(session);

    return await User.db.count(
      session,
      where: (t) {
        var expr = t.isActive.equals(true);
        if (tenantId != null) {
          expr = expr & t.tenantId.equals(tenantId);
        }
        return expr;
      },
    );
  }
}
