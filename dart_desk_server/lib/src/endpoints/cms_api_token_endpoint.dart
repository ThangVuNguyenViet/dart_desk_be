import 'dart:convert';
import 'dart:math';

import 'package:serverpod/serverpod.dart';

import '../auth/api_key_context.dart';
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
  Future<List<ApiToken>> getTokens(Session session) async {
    final (_, clientId) = await _requireAuth(session);

    return await ApiToken.db.find(
      session,
      where: (t) => clientId != null ? t.clientId.equals(clientId) : t.clientId.equals(null),
      orderBy: (t) => t.createdAt,
      orderDescending: true,
    );
  }

  /// Create a new named token. Returns plaintext token (shown once).
  Future<ApiTokenWithValue> createToken(
    Session session,
    String name,
    String role,
    DateTime? expiresAt,
  ) async {
    final (auth, clientId) = await _requireAuth(session);

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
            (clientId != null ? t.clientId.equals(clientId) : t.clientId.equals(null)) &
            t.tokenPrefix.equals(prefix) &
            t.tokenSuffix.equals(suffix),
      );
      if (existing != null) continue;

      final token = ApiToken(
        clientId: clientId,
        name: name,
        tokenHash: hash,
        tokenPrefix: prefix,
        tokenSuffix: suffix,
        role: role,
        createdByUserId: auth.user!.id,
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
    DateTime? expiresAt,
  ) async {
    final token = await ApiToken.db.findById(session, tokenId);
    if (token == null) throw Exception('Token not found: $tokenId');

    await _requireAuth(session);

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
    int tokenId,
  ) async {
    final token = await ApiToken.db.findById(session, tokenId);
    if (token == null) throw Exception('Token not found: $tokenId');

    await _requireAuth(session);

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
    int tokenId,
  ) async {
    final token = await ApiToken.db.findById(session, tokenId);
    if (token == null) return false;

    await _requireAuth(session);

    await ApiToken.db.deleteRow(session, token);
    return true;
  }

  /// Verify the caller is an authenticated User and resolve tenant.
  Future<(({ApiKeyContext apiKey, User? user}), int?)> _requireAuth(Session session) async {
    final apiKey = session.apiKey;
    if (apiKey == null) throw Exception('Missing API key');
    final user = await resolveUser(session, clientId: apiKey.clientId);
    final authResult = (apiKey: apiKey, user: user as User?);
    return (authResult, apiKey.clientId);
  }

  /// Generate a crypto-random API token with the given prefix.
  static String _generateToken(String prefix) {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (_) => random.nextInt(256));
    final randomPart = base64Url.encode(bytes).replaceAll('=', '');
    return '$prefix$randomPart';
  }
}
