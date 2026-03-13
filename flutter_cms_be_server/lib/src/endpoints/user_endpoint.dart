import 'package:dbcrypt/dbcrypt.dart';
import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';

/// Endpoint for managing CMS users
class UserEndpoint extends Endpoint {
  /// Ensure a CMS user exists for the authenticated user in the given client.
  /// Creates one automatically on first login.
  /// Validates the API token (bcrypt) before creating the user.
  Future<CmsUser> ensureUser(
    Session session,
    String clientSlug,
    String apiToken,
  ) async {
    final authInfo = session.authenticated;
    if (authInfo == null) {
      throw Exception('User must be authenticated');
    }

    final userIdentifier = authInfo.userIdentifier;

    // Look up the client by slug
    final client = await CmsClient.db.findFirstRow(
      session,
      where: (t) => t.slug.equals(clientSlug) & t.isActive.equals(true),
    );
    if (client == null) {
      throw Exception('CMS client not found or inactive: $clientSlug');
    }

    // Validate API token against stored bcrypt hash
    if (!DBCrypt().checkpw(apiToken, client.apiTokenHash)) {
      throw Exception('Invalid API token');
    }

    // Track last usage time
    await CmsClient.db.updateRow(
        session, client.copyWith(lastUsedAt: DateTime.now()));

    final clientId = client.id!;

    // Check if CmsUser already exists for this serverpodUserId + clientId
    final existing = await CmsUser.db.findFirstRow(
      session,
      where: (t) =>
          t.serverpodUserId.equals(userIdentifier) &
          t.clientId.equals(clientId),
    );
    if (existing != null) {
      return existing;
    }

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
    } catch (e) {
      // Profile lookup failed; continue with defaults
    }

    // Create the CmsUser
    final newUser = CmsUser(
      clientId: clientId,
      email: email ?? userIdentifier,
      name: name,
      role: 'viewer',
      isActive: true,
      serverpodUserId: userIdentifier,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    try {
      return await CmsUser.db.insertRow(session, newUser);
    } catch (e) {
      // Handle duplicate key race condition: re-query
      final retried = await CmsUser.db.findFirstRow(
        session,
        where: (t) =>
            t.serverpodUserId.equals(userIdentifier) &
            t.clientId.equals(clientId),
      );
      if (retried != null) {
        return retried;
      }
      rethrow;
    }
  }

  /// Get the current CMS user for the authenticated user in a given client.
  /// Validates the API token.
  Future<CmsUser?> getCurrentUser(
    Session session,
    String clientSlug,
    String apiToken,
  ) async {
    final authInfo = session.authenticated;
    if (authInfo == null) {
      throw Exception('User must be authenticated');
    }

    final client = await CmsClient.db.findFirstRow(
      session,
      where: (t) => t.slug.equals(clientSlug),
    );
    if (client == null) {
      return null;
    }

    // Validate API token against stored bcrypt hash
    if (!DBCrypt().checkpw(apiToken, client.apiTokenHash)) {
      throw Exception('Invalid API token');
    }

    // Track last usage time
    await CmsClient.db.updateRow(
        session, client.copyWith(lastUsedAt: DateTime.now()));

    return await CmsUser.db.findFirstRow(
      session,
      where: (t) =>
          t.serverpodUserId.equals(authInfo.userIdentifier) &
          t.clientId.equals(client.id!),
    );
  }
}
