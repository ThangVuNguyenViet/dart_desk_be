import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import '../tenancy.dart';
import 'api_key_context.dart';
import 'api_key_validator.dart';
import 'external_auth_strategy.dart';

/// Result of authenticating a request.
/// [apiKey] is always present for valid requests (x-api-key is required).
/// [user] is present when the request also has a valid Bearer JWT.
typedef AuthResult = ({ApiKeyContext apiKey, User? user});

/// Central authentication registry for Dart Desk.
///
/// Checks Serverpod's built-in IDP auth first, then tries external strategies
/// in registration order. Auto-creates User records on first external auth.
class DartDeskAuth {
  static List<ExternalAuthStrategy> _strategies = [];
  static List<String> _adminEmails = [];

  /// Configure external auth strategies and admin bootstrap emails.
  static void configure({
    List<ExternalAuthStrategy> externalStrategies = const [],
    List<String> adminEmails = const [],
  }) {
    _strategies = externalStrategies;
    _adminEmails = adminEmails;
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
    _adminEmails = [];
  }

  /// Validate the x-api-key header. Returns null if missing or invalid.
  static Future<ApiKeyContext?> authenticateApiKey(Session session) async {
    final request = session.request;
    if (request == null) return null;

    final apiKeyHeader = request.headers['x-api-key']?.first;
    if (apiKeyHeader == null) return null;

    return ApiKeyValidator.validate(session, apiKeyHeader);
  }

  /// Authenticate the current request.
  ///
  /// 1. Checks Serverpod built-in IDP auth (session.authenticated)
  /// 2. If null, tries external strategies in order
  /// 3. First non-null ExternalAuthUser wins → find or create User
  /// 4. Returns null if all strategies return null (unauthenticated)
  static Future<User?> authenticateRequest(Session session) async {
    // Resolve API key context (if x-api-key header present)
    final apiKeyCtx = await authenticateApiKey(session);
    final tenantId =
        apiKeyCtx?.tenantId ?? await DartDeskTenancy.resolveTenantId(session);

    // 1. Check Serverpod built-in auth
    final authInfo = session.authenticated;
    if (authInfo != null) {
      return User.db.findFirstRow(
        session,
        where: (t) {
          var expr = t.serverpodUserId.equals(authInfo.userIdentifier);
          if (tenantId != null) {
            expr = expr & t.tenantId.equals(tenantId);
          }
          return expr;
        },
      );
    }

    // 2. Try external strategies
    if (_strategies.isEmpty) return null;

    final request = session.request;
    if (request == null) return null;

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
        return _findOrCreateUser(session, extUser, strategy.name, tenantId);
      }
    }

    return null; // unauthenticated
  }

  /// Find existing User by external ID or auto-create one.
  static Future<User> _findOrCreateUser(
    Session session,
    ExternalAuthUser extUser,
    String providerName,
    int? tenantId,
  ) async {
    // Try to find existing user by external identity
    var user = await User.db.findFirstRow(
      session,
      where: (t) =>
          t.externalId.equals(extUser.externalId) &
          t.externalProvider.equals(providerName) &
          (tenantId != null
              ? t.tenantId.equals(tenantId)
              : t.tenantId.equals(null)),
    );

    if (user != null) return user;

    // Determine role: admin if email is in adminEmails list, otherwise viewer
    final role = _adminEmails.contains(extUser.email) ? 'admin' : 'viewer';

    // Auto-create user
    user = User(
      tenantId: tenantId,
      email: extUser.email,
      name: extUser.name,
      role: role,
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
            (tenantId != null
                ? t.tenantId.equals(tenantId)
                : t.tenantId.equals(null)),
      );
      if (retried != null) return retried;
      rethrow;
    }
  }
}
