import 'package:serverpod/serverpod.dart';

import 'api_key_context.dart';

const _apiKeyContextKey = 'apiKey';

/// Typed extension on [Session] for accessing pre-validated request context.
///
/// The [ApiKeyContext] is attached by the pre-endpoint handler registered
/// in `server.dart` via `pod.server.preEndpointHandlers`. By the time an
/// endpoint method runs, the API key has already been validated.
extension DartDeskSessionExt on Session {
  /// Fallback [ApiKeyContext] used when no key was attached to the session.
  ///
  /// **Why this exists:** Serverpod's `withServerpod` test framework calls
  /// endpoint methods directly — bypassing HTTP and therefore bypassing the
  /// pre-endpoint handler that normally attaches [ApiKeyContext] via
  /// `session.apiKey = ...`. The framework's [TestSessionBuilder.copyWith]
  /// only supports `authentication` and `enableLogging`; there is no hook
  /// to inject `requestContext`. Without this fallback every integration
  /// test would fail with "Missing API key".
  ///
  /// Set this once in test setUp (e.g. via `TestDataFactory`) and clear it
  /// in tearDown. **Never set this in production code.**
  static ApiKeyContext? testDefault;

  /// The validated API key context for this request.
  ///
  /// Returns the context attached by the pre-endpoint handler, falling back
  /// to [testDefault] if set. Returns `null` otherwise — callers must
  /// null-check and throw to enforce authentication.
  ApiKeyContext? get apiKey {
    final ctx = requestContext?[_apiKeyContextKey];
    if (ctx is ApiKeyContext) return ctx;
    return testDefault;
  }

  /// Sets the API key context. Called by the pre-endpoint handler.
  set apiKey(ApiKeyContext? ctx) {
    if (ctx == null) return;
    requestContext ??= {};
    requestContext![_apiKeyContextKey] = ctx;
  }
}
