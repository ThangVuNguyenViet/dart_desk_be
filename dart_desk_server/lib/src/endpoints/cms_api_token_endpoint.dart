import 'dart:convert';
import 'dart:math';

import 'package:serverpod/serverpod.dart';

import '../auth/api_key_validator.dart';
import '../auth/require_role.dart';
import '../auth/resolve_user.dart';
import '../generated/protocol.dart';

/// Endpoint for managing CMS API tokens.
/// All methods require Serverpod auth (session.authenticated).
/// Authorization: caller must be a User belonging to the project's tenant.
class ApiTokenEndpoint extends Endpoint {
  static const _maxRetries = 5;
  static const _rolePrefixes = {
    'read': 'cms_r_',
    'write': 'cms_w_',
  };

  /// List all tokens for a project (metadata only, never the hash).
  Future<List<ApiToken>> getTokens(Session session,
      {required UuidValue projectId}) async {
    await _requireAuth(session, projectId: projectId);

    return await ApiToken.db.find(
      session,
      where: (t) => t.projectId.equals(projectId),
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
    required UuidValue projectId,
  }) async {
    final auth = await _requireAuth(session, projectId: projectId);
    await RoleGuard.requireRole(session, allowed: RoleGuard.destructiveRoles);

    if (!_rolePrefixes.containsKey(role)) {
      throw ApiException(message: 'Invalid role: $role. Must be read or write.', code: 400);
    }

    final prefix = _rolePrefixes[role]!;

    for (var attempt = 0; attempt < _maxRetries; attempt++) {
      final rawToken = _generateToken(prefix);
      final suffix = rawToken.substring(rawToken.length - 4);
      final hash = ApiKeyValidator.hashToken(rawToken);

      // Check for collision on (projectId, tokenPrefix, tokenSuffix)
      final existing = await ApiToken.db.findFirstRow(
        session,
        where: (t) =>
            t.projectId.equals(auth.projectId) &
            t.tokenPrefix.equals(prefix) &
            t.tokenSuffix.equals(suffix),
      );
      if (existing != null) continue;

      final token = ApiToken(
        projectId: auth.projectId,
        name: name,
        tokenHash: hash,
        tokenPrefix: prefix,
        tokenSuffix: suffix,
        role: role,
        createdByUserId: auth.user.id,
        isActive: true,
        createdAt: DateTime.now(),
      );

      if (expiresAt != null) {
        token.expiresAt = expiresAt;
      }

      final inserted = await ApiToken.db.insertRow(session, token);
      session.log('Created ApiToken id=${inserted.id} projectId=$projectId role=$role', level: LogLevel.info);
      return ApiTokenWithValue(token: inserted, plaintextToken: rawToken);
    }

    throw ApiException(message: 'Failed to generate unique token after $_maxRetries attempts', code: 400);
  }

  /// Update token metadata (name, isActive, expiresAt).
  Future<ApiToken> updateToken(
    Session session,
    UuidValue tokenId,
    String? name,
    bool? isActive,
    DateTime? expiresAt, {
    required UuidValue projectId,
  }) async {
    final token = await ApiToken.db.findById(session, tokenId);
    if (token == null) throw ApiException(message: 'Token not found: $tokenId', code: 404);

    await _requireAuth(session, projectId: projectId);
    if (token.projectId != projectId) {
      throw ApiException(message: 'Token belongs to a different project', code: 403);
    }

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
    UuidValue tokenId, {
    required UuidValue projectId,
  }) async {
    final token = await ApiToken.db.findById(session, tokenId);
    if (token == null) throw ApiException(message: 'Token not found: $tokenId', code: 404);

    await _requireAuth(session, projectId: projectId);
    await RoleGuard.requireRole(session, allowed: RoleGuard.destructiveRoles);
    if (token.projectId != projectId) {
      throw ApiException(message: 'Token belongs to a different project', code: 403);
    }

    final prefix = _rolePrefixes[token.role]!;

    for (var attempt = 0; attempt < _maxRetries; attempt++) {
      final rawToken = _generateToken(prefix);
      final suffix = rawToken.substring(rawToken.length - 4);
      final hash = ApiKeyValidator.hashToken(rawToken);

      // Check collision (skip self)
      final existing = await ApiToken.db.findFirstRow(
        session,
        where: (t) =>
            t.projectId.equals(token.projectId) &
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
      session.log('Regenerated ApiToken id=$tokenId projectId=$projectId', level: LogLevel.info);
      return ApiTokenWithValue(token: result, plaintextToken: rawToken);
    }

    throw ApiException(message: 'Failed to generate unique token after $_maxRetries attempts', code: 400);
  }

  /// Delete a token permanently.
  Future<bool> deleteToken(
    Session session,
    UuidValue tokenId, {
    required UuidValue projectId,
  }) async {
    final token = await ApiToken.db.findById(session, tokenId);
    if (token == null) return false;

    await _requireAuth(session, projectId: projectId);
    await RoleGuard.requireRole(session, allowed: RoleGuard.destructiveRoles);
    if (token.projectId != projectId) {
      throw ApiException(message: 'Token belongs to a different project', code: 403);
    }

    await ApiToken.db.deleteRow(session, token);
    session.log('Deleted ApiToken id=$tokenId projectId=$projectId', level: LogLevel.info);
    return true;
  }

  /// Verify the caller is an authenticated User and resolve the owning tenant.
  Future<({User user, UuidValue clientId, UuidValue projectId})> _requireAuth(
    Session session, {
    required UuidValue projectId,
  }) async {
    if (session.authenticated == null) {
      throw ApiException(message: 'Authentication required', code: 401);
    }

    final project = await Project.db.findById(session, projectId);
    if (project == null) {
      throw ApiException(message: 'Project not found: $projectId', code: 404);
    }

    final user = await resolveUser(session, clientId: project.clientId);
    return (user: user, clientId: project.clientId, projectId: projectId);
  }

  /// Generate a crypto-random API token with the given prefix.
  static String _generateToken(String prefix) {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (_) => random.nextInt(256));
    final randomPart = base64Url.encode(bytes).replaceAll('=', '');
    return '$prefix$randomPart';
  }
}
