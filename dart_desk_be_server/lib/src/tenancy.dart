import 'package:serverpod/serverpod.dart';

/// Resolves tenant ID from the current request.
/// Returns null for single-tenant deployments.
typedef TenantResolver = Future<int?> Function(Session session);

/// Global tenant resolution configuration.
///
/// Single-tenant (default): always returns null.
/// Multi-tenant (cloud plugin): configured via [configure] to extract
/// tenant from request headers, JWT claims, etc.
class DartDeskTenancy {
  static TenantResolver _resolver = (_) async => null;

  /// Configure a custom tenant resolver (called by cloud plugin).
  static void configure({required TenantResolver resolver}) {
    _resolver = resolver;
  }

  /// Resolve the current tenant ID. Returns null in single-tenant mode.
  static Future<int?> resolveTenantId(Session session) => _resolver(session);

  /// Reset to default single-tenant resolver (useful for testing).
  static void reset() {
    _resolver = (_) async => null;
  }
}
