import 'dart:convert';
import 'dart:math';

import 'package:serverpod/serverpod.dart';

import '../auth/api_key_validator.dart';
import '../auth/require_role.dart';
import '../auth/resolve_user.dart';
import '../generated/protocol.dart';

/// Endpoint for managing CMS API keys.
/// All methods require Serverpod auth (session.authenticated).
/// Authorization: caller must be a User belonging to the project's tenant.
class ApiKeyEndpoint extends Endpoint {
  static const _maxRetries = 5;
  static const _rolePrefixes = {
    'read': 'cms_r_',
    'write': 'cms_w_',
  };

  /// List all keys for a project (metadata only, never the hash).
  Future<List<ApiKey>> getKeys(Session session,
      {required UuidValue projectId}) async {
    await _requireAuth(session, projectId: projectId);

    return await ApiKey.db.find(
      session,
      where: (t) => t.projectId.equals(projectId),
      orderBy: (t) => t.createdAt,
      orderDescending: true,
    );
  }

  /// Create a new named key. Returns plaintext key (shown once).
  Future<ApiKeyWithValue> createKey(
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
      final rawKey = _generateKey(prefix);
      final suffix = rawKey.substring(rawKey.length - 4);
      final hash = ApiKeyValidator.hashToken(rawKey);

      // Check for collision on (projectId, tokenPrefix, tokenSuffix)
      final existing = await ApiKey.db.findFirstRow(
        session,
        where: (t) =>
            t.projectId.equals(auth.projectId) &
            t.tokenPrefix.equals(prefix) &
            t.tokenSuffix.equals(suffix),
      );
      if (existing != null) continue;

      final key = ApiKey(
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
        key.expiresAt = expiresAt;
      }

      final inserted = await ApiKey.db.insertRow(session, key);
      session.log('Created ApiKey id=${inserted.id} projectId=$projectId role=$role', level: LogLevel.info);
      return ApiKeyWithValue(apiKey: inserted, plaintextKey: rawKey);
    }

    throw ApiException(message: 'Failed to generate unique key after $_maxRetries attempts', code: 400);
  }

  /// Update key metadata (name, isActive, expiresAt).
  Future<ApiKey> updateKey(
    Session session,
    UuidValue keyId,
    String? name,
    bool? isActive,
    DateTime? expiresAt, {
    required UuidValue projectId,
  }) async {
    final key = await ApiKey.db.findById(session, keyId);
    if (key == null) throw ApiException(message: 'Key not found: $keyId', code: 404);

    await _requireAuth(session, projectId: projectId);
    if (key.projectId != projectId) {
      throw ApiException(message: 'Key belongs to a different project', code: 403);
    }

    final updated = key.copyWith(
      name: name ?? key.name,
      isActive: isActive ?? key.isActive,
      expiresAt: expiresAt ?? key.expiresAt,
    );

    return await ApiKey.db.updateRow(session, updated);
  }

  /// Regenerate key value. Returns new plaintext key (shown once).
  Future<ApiKeyWithValue> regenerateKey(
    Session session,
    UuidValue keyId, {
    required UuidValue projectId,
  }) async {
    final key = await ApiKey.db.findById(session, keyId);
    if (key == null) throw ApiException(message: 'Key not found: $keyId', code: 404);

    await _requireAuth(session, projectId: projectId);
    await RoleGuard.requireRole(session, allowed: RoleGuard.destructiveRoles);
    if (key.projectId != projectId) {
      throw ApiException(message: 'Key belongs to a different project', code: 403);
    }

    final prefix = _rolePrefixes[key.role]!;

    for (var attempt = 0; attempt < _maxRetries; attempt++) {
      final rawKey = _generateKey(prefix);
      final suffix = rawKey.substring(rawKey.length - 4);
      final hash = ApiKeyValidator.hashToken(rawKey);

      // Check collision (skip self)
      final existing = await ApiKey.db.findFirstRow(
        session,
        where: (t) =>
            t.projectId.equals(key.projectId) &
            t.tokenPrefix.equals(prefix) &
            t.tokenSuffix.equals(suffix) &
            t.id.notEquals(keyId),
      );
      if (existing != null) continue;

      final updated = key.copyWith(
        tokenHash: hash,
        tokenSuffix: suffix,
      );

      final result = await ApiKey.db.updateRow(session, updated);
      session.log('Regenerated ApiKey id=$keyId projectId=$projectId', level: LogLevel.info);
      return ApiKeyWithValue(apiKey: result, plaintextKey: rawKey);
    }

    throw ApiException(message: 'Failed to generate unique key after $_maxRetries attempts', code: 400);
  }

  /// Delete a key permanently.
  Future<bool> deleteKey(
    Session session,
    UuidValue keyId, {
    required UuidValue projectId,
  }) async {
    final key = await ApiKey.db.findById(session, keyId);
    if (key == null) return false;

    await _requireAuth(session, projectId: projectId);
    await RoleGuard.requireRole(session, allowed: RoleGuard.destructiveRoles);
    if (key.projectId != projectId) {
      throw ApiException(message: 'Key belongs to a different project', code: 403);
    }

    await ApiKey.db.deleteRow(session, key);
    session.log('Deleted ApiKey id=$keyId projectId=$projectId', level: LogLevel.info);
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

  /// Generate a crypto-random API key with the given prefix.
  static String _generateKey(String prefix) {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (_) => random.nextInt(256));
    final randomPart = base64Url.encode(bytes).replaceAll('=', '');
    return '$prefix$randomPart';
  }
}
