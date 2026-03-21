import 'package:serverpod/serverpod.dart';

/// User data returned by external auth strategies.
class ExternalAuthUser {
  final String externalId;
  final String email;
  final String? name;
  final Map<String, dynamic>? metadata;

  const ExternalAuthUser({
    required this.externalId,
    required this.email,
    this.name,
    this.metadata,
  });
}

/// Interface for external auth providers (Firebase, Clerk, Auth0, etc.).
///
/// Strategies are tried in registration order. First non-null result wins.
/// Return null for unrecognized tokens (wrong format for this strategy).
/// Only throw for unexpected errors (network failure, SDK crash) —
/// thrown exceptions fail the request immediately, skipping remaining strategies.
abstract class ExternalAuthStrategy {
  /// Unique name for this strategy (e.g., 'firebase', 'clerk').
  String get name;

  /// Called once on server startup for setup (fetch JWKS keys, init SDK, etc.).
  Future<void> initialize() async {}

  /// Called on server shutdown for cleanup (close connections, etc.).
  Future<void> dispose() async {}

  /// Verify the request and return a user, or null to pass to next strategy.
  Future<ExternalAuthUser?> authenticate(
    Map<String, String> headers,
    Session session,
  );
}
