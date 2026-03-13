import 'dart:convert';
import 'dart:math';

import 'package:dbcrypt/dbcrypt.dart';
import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';

/// Endpoint for managing CMS clients
class CmsClientEndpoint extends Endpoint {
  /// Get all clients with pagination and optional search
  Future<CmsClientList> getClients(
    Session session, {
    String? search,
    int limit = 20,
    int offset = 0,
  }) async {
    final total = await CmsClient.db.count(
      session,
      where: (t) {
        if (search != null && search.isNotEmpty) {
          return t.name.like('%$search%') | t.slug.like('%$search%');
        }
        return Constant.bool(true);
      },
    );

    final clients = await CmsClient.db.find(
      session,
      where: (t) {
        if (search != null && search.isNotEmpty) {
          return t.name.like('%$search%') | t.slug.like('%$search%');
        }
        return Constant.bool(true);
      },
      orderBy: (t) => t.createdAt,
      orderDescending: true,
      limit: limit,
      offset: offset,
    );

    return CmsClientList(
      clients: clients,
      total: total,
      page: (offset ~/ limit) + 1,
      pageSize: limit,
    );
  }

  /// Get a client by slug
  Future<CmsClient?> getClientBySlug(
    Session session,
    String slug,
  ) async {
    return await CmsClient.db.findFirstRow(
      session,
      where: (t) => t.slug.equals(slug),
    );
  }

  /// Get a client by ID
  Future<CmsClient?> getClient(
    Session session,
    int clientId,
  ) async {
    return await CmsClient.db.findById(session, clientId);
  }

  /// Create a new client (requires authentication).
  /// Generates a prefixed API token, stores its bcrypt hash.
  /// Returns the client and the raw token (shown once only).
  Future<ClientWithToken> createClient(
    Session session,
    String name,
    String slug, {
    String? description,
    String? settings,
  }) async {
    final authInfo = session.authenticated;
    if (authInfo == null) {
      throw Exception('User must be authenticated to create clients');
    }

    final rawToken = _generateToken();
    final prefix = rawToken.substring(0, 16);
    final hash = DBCrypt().hashpw(rawToken, DBCrypt().gensalt());

    final client = CmsClient(
      name: name,
      slug: slug,
      apiTokenHash: hash,
      apiTokenPrefix: prefix,
      description: description,
      isActive: true,
      settings: settings,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final inserted = await CmsClient.db.insertRow(session, client);
    return ClientWithToken(client: inserted, apiToken: rawToken);
  }

  /// Update an existing client (requires authentication).
  /// Note: apiTokenHash cannot be updated through this method — use regenerateApiToken.
  Future<CmsClient?> updateClient(
    Session session,
    int clientId, {
    String? name,
    String? description,
    bool? isActive,
    String? settings,
  }) async {
    final authInfo = session.authenticated;
    if (authInfo == null) {
      throw Exception('User must be authenticated to update clients');
    }

    final existing = await CmsClient.db.findById(session, clientId);
    if (existing == null) {
      return null;
    }

    final updated = existing.copyWith(
      name: name ?? existing.name,
      description: description ?? existing.description,
      isActive: isActive ?? existing.isActive,
      settings: settings ?? existing.settings,
      updatedAt: DateTime.now(),
    );

    await CmsClient.db.updateRow(session, updated);
    return updated;
  }

  /// Regenerate the API token for a client (requires authentication).
  /// Returns the client and the new raw token (shown once only).
  Future<ClientWithToken> regenerateApiToken(
    Session session,
    int clientId,
  ) async {
    final authInfo = session.authenticated;
    if (authInfo == null) {
      throw Exception('User must be authenticated to regenerate tokens');
    }

    final existing = await CmsClient.db.findById(session, clientId);
    if (existing == null) {
      throw Exception('Client not found: $clientId');
    }

    final rawToken = _generateToken();
    final prefix = rawToken.substring(0, 16);
    final hash = DBCrypt().hashpw(rawToken, DBCrypt().gensalt());

    final updated = existing.copyWith(
      apiTokenHash: hash,
      apiTokenPrefix: prefix,
      updatedAt: DateTime.now(),
    );

    await CmsClient.db.updateRow(session, updated);
    return ClientWithToken(client: updated, apiToken: rawToken);
  }

  /// Generate a crypto-random API token with `cms_live_` prefix.
  static String _generateToken() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (_) => random.nextInt(256));
    final randomPart = base64Url.encode(bytes).replaceAll('=', '');
    return 'cms_live_$randomPart';
  }

  /// Delete a client (requires authentication)
  /// Will fail if client has associated users (FK restriction)
  Future<bool> deleteClient(
    Session session,
    int clientId,
  ) async {
    final authInfo = session.authenticated;
    if (authInfo == null) {
      throw Exception('User must be authenticated to delete clients');
    }

    final existing = await CmsClient.db.findById(session, clientId);
    if (existing == null) {
      return false;
    }

    await CmsClient.db.deleteRow(session, existing);
    return true;
  }

  /// Reserved slugs that cannot be used as client slugs.
  static const _reservedSlugs = {'login', 'setup', 'admin', 'api', 'app'};

  /// Slug validation regex: 3-63 chars, lowercase alphanumeric + hyphens,
  /// no leading/trailing hyphens.
  static final _slugRegex = RegExp(r'^[a-z0-9][a-z0-9-]{1,61}[a-z0-9]$');

  /// Create a new client and an admin CmsUser for the caller in one transaction.
  /// Used by the manage app's setup wizard for first-time users.
  Future<CmsClient> createClientWithOwner(
    Session session, {
    required String name,
    required String slug,
  }) async {
    final authInfo = session.authenticated;
    if (authInfo == null) {
      throw Exception('User must be authenticated');
    }

    // Validate slug format
    if (!_slugRegex.hasMatch(slug)) {
      throw Exception(
        'Invalid slug: must be 3-63 characters, lowercase alphanumeric and hyphens, '
        'cannot start or end with a hyphen',
      );
    }
    if (_reservedSlugs.contains(slug)) {
      throw Exception('Slug "$slug" is reserved and cannot be used');
    }

    // Check slug uniqueness
    final existing = await CmsClient.db.findFirstRow(
      session,
      where: (t) => t.slug.equals(slug),
    );
    if (existing != null) {
      throw Exception('Slug "$slug" is already taken');
    }

    // Generate internal API token (same pattern as createClient)
    final rawToken = _generateToken();
    final prefix = rawToken.substring(0, 16);
    final hash = DBCrypt().hashpw(rawToken, DBCrypt().gensalt());

    // Get user profile for email (same pattern as UserEndpoint.ensureUser lines 57-68)
    String? email;
    String? userName;
    try {
      final profileRows = await session.db.unsafeQuery(
        'SELECT "email", "fullName" FROM "serverpod_auth_core_profile" '
        'WHERE "authUserId" = \'${authInfo.userIdentifier}\' LIMIT 1',
      );
      if (profileRows.isNotEmpty) {
        email = profileRows.first[0] as String?;
        userName = profileRows.first[1] as String?;
      }
    } catch (e) {
      // Profile lookup failed; use identifier as fallback
    }

    return session.db.transaction((transaction) async {
      final client = await CmsClient.db.insertRow(
        session,
        CmsClient(
          name: name,
          slug: slug,
          apiTokenHash: hash,
          apiTokenPrefix: prefix,
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

      await CmsUser.db.insertRow(
        session,
        CmsUser(
          clientId: client.id!,
          email: email ?? authInfo.userIdentifier,
          name: userName,
          role: 'admin',
          isActive: true,
          serverpodUserId: authInfo.userIdentifier,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

      return client;
    });
  }
}
