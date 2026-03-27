import 'dart:convert';
import 'dart:math';

import 'package:serverpod/serverpod.dart';

import '../auth/api_key_validator.dart';
import '../auth/dart_desk_session.dart';
import '../auth/resolve_user.dart';
import '../generated/protocol.dart';

/// Endpoint for managing CMS API tokens.
/// All methods require Serverpod auth (session.authenticated).
/// Authorization: caller must be a User belonging to the resolved tenant.
class ApiTokenEndpoint extends Endpoint {
  static const _maxRetries = 5;
  static const _rolePrefixes = {
    'read': 'cms_r_',
    'write': 'cms_w_',
  };

  /// List all tokens for the current tenant (metadata only, never the hash).
  Future<List<ApiToken>> getTokens(Session session, {int? clientId}) async {
    final auth = await _requireAuth(session, clientId: clientId);

    return await ApiToken.db.find(
      session,
      where: (t) => auth.clientId != null ? t.clientId.equals(auth.clientId) : t.clientId.equals(null),
      orderBy: (t) => t.createdAt,
      orderDescending: true,
    );
  }

  /// Create a new named token. Returns plaintext token (shown once).
  Future<ApiTokenWithValue> createToken(
    Session session,
    String name,
    String role,
    DateTime? expiresAt, {
    int? clientId,
  }) async {
    final auth = await _requireAuth(session, clientId: clientId);

    if (!_rolePrefixes.containsKey(role)) {
      throw Exception('Invalid role: $role. Must be read or write.');
    }

    final prefix = _rolePrefixes[role]!;

    for (var attempt = 0; attempt < _maxRetries; attempt++) {
      final rawToken = _generateToken(prefix);
      final suffix = rawToken.substring(rawToken.length - 4);
      final hash = ApiKeyValidator.hashToken(rawToken);

      // Check for collision on (clientId, tokenPrefix, tokenSuffix)
      final existing = await ApiToken.db.findFirstRow(
        session,
        where: (t) =>
            (auth.clientId != null ? t.clientId.equals(auth.clientId) : t.clientId.equals(null)) &
            t.tokenPrefix.equals(prefix) &
            t.tokenSuffix.equals(suffix),
      );
      if (existing != null) continue;

      final token = ApiToken(
        clientId: auth.clientId,
        name: name,
        tokenHash: hash,
        tokenPrefix: prefix,
        tokenSuffix: suffix,
        role: role,
        createdByUserId: auth.user!.id!,
        isActive: true,
        createdAt: DateTime.now(),
      );

      if (expiresAt != null) {
        token.expiresAt = expiresAt;
      }

      final inserted = await ApiToken.db.insertRow(session, token);
      return ApiTokenWithValue(token: inserted, plaintextToken: rawToken);
    }

    throw Exception(
        'Failed to generate unique token after $_maxRetries attempts');
  }

  /// Update token metadata (name, isActive, expiresAt).
  Future<ApiToken> updateToken(
    Session session,
    int tokenId,
    String? name,
    bool? isActive,
    DateTime? expiresAt, {
    int? clientId,
  }) async {
    final token = await ApiToken.db.findById(session, tokenId);
    if (token == null) throw Exception('Token not found: $tokenId');

    await _requireAuth(session, clientId: clientId);

    final updated = token.copyWith(
      name: name ?? token.name,
      isActive: isActive ?? token.isActive,
      expiresAt: expiresAt ?? token.expiresAt,
    );

    return await ApiToken.db.updateRow(session, updated);
  }

  /// Regenerate token value. Returns new plaintext token (shown once).
  Future<ApiTokenWithValue> regenerateToken(
    Session session,
    int tokenId, {
    int? clientId,
  }) async {
    final token = await ApiToken.db.findById(session, tokenId);
    if (token == null) throw Exception('Token not found: $tokenId');

    await _requireAuth(session, clientId: clientId);

    final prefix = _rolePrefixes[token.role]!;

    for (var attempt = 0; attempt < _maxRetries; attempt++) {
      final rawToken = _generateToken(prefix);
      final suffix = rawToken.substring(rawToken.length - 4);
      final hash = ApiKeyValidator.hashToken(rawToken);

      // Check collision (skip self)
      final existing = await ApiToken.db.findFirstRow(
        session,
        where: (t) =>
            (token.clientId != null ? t.clientId.equals(token.clientId) : t.clientId.equals(null)) &
            t.tokenPrefix.equals(prefix) &
            t.tokenSuffix.equals(suffix) &
            t.id.notEquals(tokenId),
      );
      if (existing != null) continue;

      final updated = token.copyWith(
        tokenHash: hash,
        tokenSuffix: suffix,
      );

      final result = await ApiToken.db.updateRow(session, updated);
      return ApiTokenWithValue(token: result, plaintextToken: rawToken);
    }

    throw Exception(
        'Failed to generate unique token after $_maxRetries attempts');
  }

  /// Delete a token permanently.
  Future<bool> deleteToken(
    Session session,
    int tokenId, {
    int? clientId,
  }) async {
    final token = await ApiToken.db.findById(session, tokenId);
    if (token == null) return false;

    await _requireAuth(session, clientId: clientId);

    await ApiToken.db.deleteRow(session, token);
    return true;
  }

  /// Verify the caller is an authenticated User and resolve tenant.
  Future<({User? user, int? clientId})> _requireAuth(
    Session session, {
    int? clientId,
  }) async {
    final apiKey = session.apiKey;
    if (apiKey != null) {
      final user = await resolveUser(session, clientId: apiKey.clientId);
      return (user: user as User?, clientId: apiKey.clientId);
    }
    // Session auth (manage app)
    if (session.authenticated == null) {
      throw Exception('Authentication required');
    }
    final user = await resolveUser(session, clientId: clientId);
    return (user: user as User?, clientId: clientId);
  }

  /// Generate a crypto-random API token with the given prefix.
  static String _generateToken(String prefix) {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (_) => random.nextInt(256));
    final randomPart = base64Url.encode(bytes).replaceAll('=', '');
    return '$prefix$randomPart';
  }
}
