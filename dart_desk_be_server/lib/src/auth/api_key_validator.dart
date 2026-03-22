import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import 'api_key_context.dart';

/// Result of parsing an API key string.
class ParsedApiKey {
  final String prefix;
  final String suffix;
  final String rawToken;

  const ParsedApiKey({
    required this.prefix,
    required this.suffix,
    required this.rawToken,
  });
}

/// Validates x-api-key header values against the ApiToken table.
///
/// This is a stateless utility. Call [validate] from endpoint methods
/// or from [DartDeskAuth.authenticateRequest].
class ApiKeyValidator {
  static const _validPrefixes = {'cms_r_', 'cms_w_'};
  static const _prefixLength = 6;
  static const _minTokenLength = 10; // prefix + at least 4 chars
  static const _lastUsedDebounce = Duration(hours: 1);

  /// Parse an API key string into its components.
  /// Returns null if the format is invalid.
  static ParsedApiKey? parseApiKey(String apiKey) {
    if (apiKey.length < _minTokenLength) return null;

    final prefix = apiKey.substring(0, _prefixLength);
    if (!_validPrefixes.contains(prefix)) return null;

    final suffix = apiKey.substring(apiKey.length - 4);

    return ParsedApiKey(
      prefix: prefix,
      suffix: suffix,
      rawToken: apiKey,
    );
  }

  /// Compute SHA-256 hash of a token string (hex-encoded).
  static String hashToken(String token) {
    final bytes = utf8.encode(token);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Validate an API key against the database.
  /// Returns ApiKeyContext on success, null on failure.
  static Future<ApiKeyContext?> validate(
    Session session,
    String apiKey,
  ) async {
    final parsed = parseApiKey(apiKey);
    if (parsed == null) return null;

    final hash = hashToken(parsed.rawToken);

    // Query by prefix + suffix without tenantId filter.
    // The token lookup IS the tenant resolution.
    final candidates = await ApiToken.db.find(
      session,
      where: (t) =>
          t.tokenPrefix.equals(parsed.prefix) &
          t.tokenSuffix.equals(parsed.suffix) &
          t.isActive.equals(true),
    );

    for (final candidate in candidates) {
      if (candidate.tokenHash != hash) continue;

      // Check expiry
      if (candidate.expiresAt != null &&
          candidate.expiresAt!.isBefore(DateTime.now())) {
        return null;
      }

      // Debounce lastUsedAt update — only write if >1 hour stale
      final now = DateTime.now();
      if (candidate.lastUsedAt == null ||
          now.difference(candidate.lastUsedAt!) > _lastUsedDebounce) {
        try {
          await ApiToken.db.updateRow(
            session,
            candidate.copyWith(lastUsedAt: now),
          );
        } catch (_) {
          // Non-critical — don't fail the request
        }
      }

      return ApiKeyContext(
        tenantId: candidate.tenantId,
        role: candidate.role,
        tokenId: candidate.id!,
      );
    }

    return null;
  }
}
