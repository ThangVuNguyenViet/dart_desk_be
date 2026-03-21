import 'dart:convert';
import 'dart:math';

import 'package:dbcrypt/dbcrypt.dart';
import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import '../tenancy.dart';

/// Endpoint for managing CMS API tokens.
/// All methods require Serverpod auth (session.authenticated).
/// Authorization: caller must be a User belonging to the resolved tenant.
class ApiTokenEndpoint extends Endpoint {
  static const _maxRetries = 5;
  static const _rolePrefixes = {
    'viewer': 'cms_vi_',
    'editor': 'cms_ed_',
    'admin': 'cms_ad_',
  };

  /// List all tokens for the current tenant (metadata only, never the hash).
  Future<List<ApiToken>> getTokens(Session session) async {
    final (_, tenantId) = await _requireUser(session);

    return await ApiToken.db.find(
      session,
      where: (t) => tenantId != null ? t.tenantId.equals(tenantId) : t.tenantId.equals(null),
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
    final (user, tenantId) = await _requireUser(session);

    if (!_rolePrefixes.containsKey(role)) {
      throw Exception('Invalid role: $role. Must be viewer, editor, or admin.');
    }

    final prefix = _rolePrefixes[role]!;

    for (var attempt = 0; attempt < _maxRetries; attempt++) {
      final rawToken = _generateToken(prefix);
      final suffix = rawToken.substring(rawToken.length - 4);
      final hash = DBCrypt().hashpw(rawToken, DBCrypt().gensalt());

      // Check for collision on (tenantId, tokenPrefix, tokenSuffix)
      final existing = await ApiToken.db.findFirstRow(
        session,
        where: (t) =>
            (tenantId != null ? t.tenantId.equals(tenantId) : t.tenantId.equals(null)) &
            t.tokenPrefix.equals(prefix) &
            t.tokenSuffix.equals(suffix),
      );
      if (existing != null) continue;

      final token = ApiToken(
        tenantId: tenantId,
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

    await _requireUser(session);

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

    await _requireUser(session);

    final prefix = _rolePrefixes[token.role]!;

    for (var attempt = 0; attempt < _maxRetries; attempt++) {
      final rawToken = _generateToken(prefix);
      final suffix = rawToken.substring(rawToken.length - 4);
      final hash = DBCrypt().hashpw(rawToken, DBCrypt().gensalt());

      // Check collision (skip self)
      final existing = await ApiToken.db.findFirstRow(
        session,
        where: (t) =>
            (token.tenantId != null ? t.tenantId.equals(token.tenantId) : t.tenantId.equals(null)) &
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

    await _requireUser(session);

    await ApiToken.db.deleteRow(session, token);
    return true;
  }

  /// Verify the caller is an authenticated User and resolve tenant.
  Future<(User, int?)> _requireUser(Session session) async {
    final authInfo = session.authenticated;
    if (authInfo == null) {
      throw Exception('User must be authenticated');
    }

    final tenantId = await DartDeskTenancy.resolveTenantId(session);

    final user = await User.db.findFirstRow(
      session,
      where: (t) {
        var expr = t.serverpodUserId.equals(authInfo.userIdentifier) &
            t.isActive.equals(true);
        if (tenantId != null) {
          expr = expr & t.tenantId.equals(tenantId);
        }
        return expr;
      },
    );
    if (user == null) {
      throw Exception('User not found');
    }
    return (user, tenantId);
  }

  /// Generate a crypto-random API token with the given prefix.
  static String _generateToken(String prefix) {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (_) => random.nextInt(256));
    final randomPart = base64Url.encode(bytes).replaceAll('=', '');
    return '$prefix$randomPart';
  }
}
