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

    // Validate API token (multi-token + legacy fallback)
    // ignore: unused_local_variable
    final matchedRole = await _validateApiToken(
      session, client.id!, apiToken, client.apiTokenHash);

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

    // Validate API token (multi-token + legacy fallback)
    await _validateApiToken(
      session, client.id!, apiToken, client.apiTokenHash);

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

  /// Get all clients the authenticated user belongs to.
  /// Used by Manage app for client switcher.
  Future<List<CmsClient>> getUserClients(Session session) async {
    final authInfo = session.authenticated;
    if (authInfo == null) {
      throw Exception('User must be authenticated');
    }

    // Find all CmsUser records for this serverpod user
    final users = await CmsUser.db.find(
      session,
      where: (t) =>
          t.serverpodUserId.equals(authInfo.userIdentifier) &
          t.isActive.equals(true),
    );

    if (users.isEmpty) return [];

    // Fetch the corresponding clients
    final clientIds = users.map((u) => u.clientId).toSet();
    final clients = await CmsClient.db.find(
      session,
      where: (t) => t.id.inSet(clientIds.cast<int?>()) & t.isActive.equals(true),
    );

    return clients;
  }

  /// Get the current CMS user by client slug (for Manage app — no API token needed).
  /// Authenticates via Serverpod auth session only.
  Future<CmsUser?> getCurrentUserBySlug(
    Session session,
    String clientSlug,
  ) async {
    final authInfo = session.authenticated;
    if (authInfo == null) {
      throw Exception('User must be authenticated');
    }

    final client = await CmsClient.db.findFirstRow(
      session,
      where: (t) => t.slug.equals(clientSlug) & t.isActive.equals(true),
    );
    if (client == null) return null;

    return await CmsUser.db.findFirstRow(
      session,
      where: (t) =>
          t.serverpodUserId.equals(authInfo.userIdentifier) &
          t.clientId.equals(client.id!),
    );
  }

  /// Get count of CmsUsers for a client (for Overview stats).
  Future<int> getClientUserCount(
    Session session,
    int clientId,
  ) async {
    final authInfo = session.authenticated;
    if (authInfo == null) {
      throw Exception('User must be authenticated');
    }

    // Verify caller belongs to this client
    final callerUser = await CmsUser.db.findFirstRow(
      session,
      where: (t) =>
          t.serverpodUserId.equals(authInfo.userIdentifier) &
          t.clientId.equals(clientId) &
          t.isActive.equals(true),
    );
    if (callerUser == null) {
      throw Exception('User does not belong to client $clientId');
    }

    return await CmsUser.db.count(
      session,
      where: (t) => t.clientId.equals(clientId) & t.isActive.equals(true),
    );
  }

  /// Validate an API token against cms_api_tokens table, falling back to
  /// CmsClient.apiTokenHash for legacy tokens. Returns the matched role
  /// or throws if invalid.
  Future<String> _validateApiToken(
    Session session,
    int clientId,
    String apiToken,
    String clientApiTokenHash,
  ) async {
    // Try new multi-token system first
    final prefixMatch = RegExp(r'^(cms_(?:vi|ed|ad)_)').firstMatch(apiToken);
    if (prefixMatch != null) {
      final tokenPrefix = prefixMatch.group(1)!;
      final tokenSuffix = apiToken.substring(apiToken.length - 4);

      final candidate = await CmsApiToken.db.findFirstRow(
        session,
        where: (t) =>
            t.clientId.equals(clientId) &
            t.tokenPrefix.equals(tokenPrefix) &
            t.tokenSuffix.equals(tokenSuffix) &
            t.isActive.equals(true),
      );

      if (candidate != null) {
        if (candidate.expiresAt != null &&
            candidate.expiresAt!.isBefore(DateTime.now())) {
          throw Exception('API token has expired');
        }
        if (DBCrypt().checkpw(apiToken, candidate.tokenHash)) {
          await CmsApiToken.db.updateRow(
            session,
            candidate.copyWith(lastUsedAt: DateTime.now()),
          );
          return candidate.role;
        }
      }
    }

    // Fallback: legacy CmsClient.apiTokenHash (for cms_live_ tokens)
    if (DBCrypt().checkpw(apiToken, clientApiTokenHash)) {
      return 'admin'; // Legacy tokens have implicit admin role
    }

    throw Exception('Invalid API token');
  }
}
