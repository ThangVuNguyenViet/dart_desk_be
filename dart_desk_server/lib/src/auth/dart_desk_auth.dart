import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import 'api_key_context.dart';
import 'api_key_validator.dart';
import 'external_auth_strategy.dart';

/// Result of authenticating a request.
/// [apiKey] is always present for valid requests (x-api-key is required).
/// [user] is present when the request also has a valid Bearer JWT.
typedef AuthResult = ({ApiKeyContext apiKey, User? user});

/// Central authentication registry for Dart Desk.
///
/// Two-pass auth:
/// 1. x-api-key (required) → resolves client + role
/// 2. Authorization: Bearer (optional) → resolves user identity
class DartDeskAuth {
  static List<ExternalAuthStrategy> _strategies = [];

  /// Configure external auth strategies and admin bootstrap emails.
  static void configure({
    List<ExternalAuthStrategy> externalStrategies = const [],
    List<String> adminEmails = const [],
  }) {
    _strategies = externalStrategies;
  }

  /// Initialize all registered strategies. Call during server startup.
  static Future<void> initialize() async {
    for (final strategy in _strategies) {
      await strategy.initialize();
    }
  }

  /// Dispose all registered strategies. Call during server shutdown.
  static Future<void> dispose() async {
    for (final strategy in _strategies) {
      await strategy.dispose();
    }
  }

  /// Reset to default state (useful for testing).
  static void reset() {
    _strategies = [];
  }

  /// Validate the API key from request headers. Returns null if missing or invalid.
  ///
  /// Checks in order:
  /// 1. `x-api-key` header (backwards compat for direct REST/test calls)
  /// 2. `Authorization: DartDesk apiKey=<key>` scheme (Serverpod RPC calls)
  static Future<ApiKeyContext?> authenticateApiKey(Session session) async {
    final request = session.request;
    if (request == null) return null;

    // Try x-api-key header first (backwards compat for direct REST/test calls)
    final apiKeyHeader = request.headers['x-api-key']?.first;
    if (apiKeyHeader != null) {
      return ApiKeyValidator.validate(session, apiKeyHeader);
    }

    // Try DartDesk scheme in Authorization header (Serverpod RPC calls)
    final authHeader = request.headers['authorization']?.first;
    if (authHeader != null) {
      final apiKey = extractApiKeyFromDartDeskScheme(authHeader);
      if (apiKey != null) {
        return ApiKeyValidator.validate(session, apiKey);
      }
    }

    return null;
  }

  /// Parses `DartDesk apiKey=<key>` or `DartDesk apiKey=<key>;Basic <jwt>`
  /// Returns the API key value or null if malformed.
  static String? extractApiKeyFromDartDeskScheme(String header) {
    if (!header.startsWith('DartDesk ')) return null;
    final payload = header.substring('DartDesk '.length);
    final semicolonIndex = payload.indexOf(';');
    final apiKeyPart = semicolonIndex >= 0
        ? payload.substring(0, semicolonIndex).trim()
        : payload.trim();
    if (!apiKeyPart.startsWith('apiKey=')) return null;
    return apiKeyPart.substring('apiKey='.length);
  }

  /// Extracts the JWT portion from a DartDesk compound Authorization value.
  /// Returns the raw auth header string (e.g. `Basic <b64>`) or null.
  static String? extractAuthKeyFromDartDeskScheme(String header) {
    if (!header.startsWith('DartDesk ')) return null;
    final payload = header.substring('DartDesk '.length);
    final semicolonIndex = payload.indexOf(';');
    if (semicolonIndex < 0) return null;
    return payload.substring(semicolonIndex + 1).trim();
  }

  /// Authenticate the current request.
  ///
  /// 1. Validates x-api-key header (required) → resolves client + role
  /// 2. Checks Serverpod built-in IDP auth or external strategies → resolves user
  /// 3. Returns AuthResult with apiKey context and optional user
  ///
  /// Throws 401 if x-api-key is missing or invalid.
  static Future<AuthResult> authenticateRequest(Session session) async {
    // 1. Require API key
    final apiKeyCtx = await authenticateApiKey(session);
    if (apiKeyCtx == null) {
      throw Exception('Missing or invalid x-api-key header');
    }

    final clientId = apiKeyCtx.clientId;

    // 2. Check Serverpod built-in auth
    final authInfo = session.authenticated;
    if (authInfo != null) {
      final user = await User.db.findFirstRow(
        session,
        where: (t) {
          var expr = t.serverpodUserId.equals(authInfo.userIdentifier);
          if (clientId != null) {
            expr = expr & t.clientId.equals(clientId);
          }
          return expr;
        },
      );
      return (apiKey: apiKeyCtx, user: user);
    }

    // 3. Try external strategies
    if (_strategies.isEmpty) return (apiKey: apiKeyCtx, user: null);

    final request = session.request;
    if (request == null) return (apiKey: apiKeyCtx, user: null);

    final headers = <String, String>{};
    for (final entry in request.headers.entries) {
      final values = entry.value;
      if (values.isNotEmpty) {
        headers[entry.key] = values.first;
      }
    }

    for (final strategy in _strategies) {
      final extUser = await strategy.authenticate(headers, session);
      if (extUser != null) {
        final user =
            await _findOrCreateUser(session, extUser, strategy.name, clientId);
        return (apiKey: apiKeyCtx, user: user);
      }
    }

    return (apiKey: apiKeyCtx, user: null);
  }

  /// Find existing User by external ID or auto-create one.
  static Future<User> _findOrCreateUser(
    Session session,
    ExternalAuthUser extUser,
    String providerName,
    int? clientId,
  ) async {
    // Try to find existing user by external identity
    var user = await User.db.findFirstRow(
      session,
      where: (t) =>
          t.externalId.equals(extUser.externalId) &
          t.externalProvider.equals(providerName) &
          (clientId != null
              ? t.clientId.equals(clientId)
              : t.clientId.equals(null)),
    );

    if (user != null) return user;

    // Auto-create user
    user = User(
      clientId: clientId,
      email: extUser.email,
      name: extUser.name,
      role: 'viewer',
      isActive: true,
      externalId: extUser.externalId,
      externalProvider: providerName,
    );

    try {
      return await User.db.insertRow(session, user);
    } catch (e) {
      // Handle duplicate key race condition
      final retried = await User.db.findFirstRow(
        session,
        where: (t) =>
            t.externalId.equals(extUser.externalId) &
            t.externalProvider.equals(providerName) &
            (clientId != null
                ? t.clientId.equals(clientId)
                : t.clientId.equals(null)),
      );
      if (retried != null) return retried;
      rethrow;
    }
  }
}
