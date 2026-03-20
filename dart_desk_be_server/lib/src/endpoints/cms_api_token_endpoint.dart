import 'dart:convert';
import 'dart:math';

import 'package:dbcrypt/dbcrypt.dart';
import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';

/// Endpoint for managing CMS API tokens.
/// All methods require Serverpod auth (session.authenticated).
/// Authorization: caller must be a CmsUser belonging to the target client.
class CmsApiTokenEndpoint extends Endpoint {
  static const _maxRetries = 5;
  static const _rolePrefixes = {
    'viewer': 'cms_vi_',
    'editor': 'cms_ed_',
    'admin': 'cms_ad_',
  };

  /// List all tokens for a client (metadata only, never the hash).
  Future<List<CmsApiToken>> getTokens(
    Session session,
    int clientId,
  ) async {
    await _requireUser(session, clientId);

    return await CmsApiToken.db.find(
      session,
      where: (t) => t.clientId.equals(clientId),
      orderBy: (t) => t.createdAt,
      orderDescending: true,
    );
  }

  /// Create a new named token. Returns plaintext token (shown once).
  Future<CmsApiTokenWithValue> createToken(
    Session session,
    int clientId,
    String name,
    String role,
    DateTime? expiresAt,
  ) async {
    final user = await _requireUser(session, clientId);

    if (!_rolePrefixes.containsKey(role)) {
      throw Exception('Invalid role: $role. Must be viewer, editor, or admin.');
    }

    final prefix = _rolePrefixes[role]!;

    for (var attempt = 0; attempt < _maxRetries; attempt++) {
      final rawToken = _generateToken(prefix);
      final suffix = rawToken.substring(rawToken.length - 4);
      final hash = DBCrypt().hashpw(rawToken, DBCrypt().gensalt());

      // Check for collision on (clientId, tokenPrefix, tokenSuffix)
      final existing = await CmsApiToken.db.findFirstRow(
        session,
        where: (t) =>
            t.clientId.equals(clientId) &
            t.tokenPrefix.equals(prefix) &
            t.tokenSuffix.equals(suffix),
      );
      if (existing != null) continue;

      final token = CmsApiToken(
        clientId: clientId,
        name: name,
        tokenHash: hash,
        tokenPrefix: prefix,
        tokenSuffix: suffix,
        role: role,
        createdByUserId: user.id,
        isActive: true,
        createdAt: DateTime.now(),
      );

      if (expiresAt != null) {
        token.expiresAt = expiresAt;
      }

      final inserted = await CmsApiToken.db.insertRow(session, token);
      return CmsApiTokenWithValue(token: inserted, plaintextToken: rawToken);
    }

    throw Exception(
        'Failed to generate unique token after $_maxRetries attempts');
  }

  /// Update token metadata (name, isActive, expiresAt).
  Future<CmsApiToken> updateToken(
    Session session,
    int tokenId,
    String? name,
    bool? isActive,
    DateTime? expiresAt,
  ) async {
    final token = await CmsApiToken.db.findById(session, tokenId);
    if (token == null) throw Exception('Token not found: $tokenId');

    await _requireUser(session, token.clientId);

    final updated = token.copyWith(
      name: name ?? token.name,
      isActive: isActive ?? token.isActive,
      expiresAt: expiresAt ?? token.expiresAt,
    );

    return await CmsApiToken.db.updateRow(session, updated);
  }

  /// Regenerate token value. Returns new plaintext token (shown once).
  Future<CmsApiTokenWithValue> regenerateToken(
    Session session,
    int tokenId,
  ) async {
    final token = await CmsApiToken.db.findById(session, tokenId);
    if (token == null) throw Exception('Token not found: $tokenId');

    await _requireUser(session, token.clientId);

    final prefix = _rolePrefixes[token.role]!;

    for (var attempt = 0; attempt < _maxRetries; attempt++) {
      final rawToken = _generateToken(prefix);
      final suffix = rawToken.substring(rawToken.length - 4);
      final hash = DBCrypt().hashpw(rawToken, DBCrypt().gensalt());

      // Check collision (skip self)
      final existing = await CmsApiToken.db.findFirstRow(
        session,
        where: (t) =>
            t.clientId.equals(token.clientId) &
            t.tokenPrefix.equals(prefix) &
            t.tokenSuffix.equals(suffix) &
            t.id.notEquals(tokenId),
      );
      if (existing != null) continue;

      final updated = token.copyWith(
        tokenHash: hash,
        tokenSuffix: suffix,
      );

      final result = await CmsApiToken.db.updateRow(session, updated);
      return CmsApiTokenWithValue(token: result, plaintextToken: rawToken);
    }

    throw Exception(
        'Failed to generate unique token after $_maxRetries attempts');
  }

  /// Delete a token permanently.
  Future<bool> deleteToken(
    Session session,
    int tokenId,
  ) async {
    final token = await CmsApiToken.db.findById(session, tokenId);
    if (token == null) return false;

    await _requireUser(session, token.clientId);

    await CmsApiToken.db.deleteRow(session, token);
    return true;
  }

  /// Verify the caller is an authenticated CmsUser of the given client.
  Future<CmsUser> _requireUser(Session session, int clientId) async {
    final authInfo = session.authenticated;
    if (authInfo == null) {
      throw Exception('User must be authenticated');
    }

    final user = await CmsUser.db.findFirstRow(
      session,
      where: (t) =>
          t.serverpodUserId.equals(authInfo.userIdentifier) &
          t.clientId.equals(clientId) &
          t.isActive.equals(true),
    );
    if (user == null) {
      throw Exception('User does not belong to client $clientId');
    }
    return user;
  }

  /// Generate a crypto-random API token with the given prefix.
  static String _generateToken(String prefix) {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (_) => random.nextInt(256));
    final randomPart = base64Url.encode(bytes).replaceAll('=', '');
    return '$prefix$randomPart';
  }
}
