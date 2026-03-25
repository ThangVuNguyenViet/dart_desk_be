import 'package:serverpod/serverpod.dart';

import 'api_key_context.dart';

const _apiKeyContextKey = 'apiKey';

/// Typed extension on [Session] for accessing pre-validated request context.
///
/// The [ApiKeyContext] is attached by the pre-endpoint handler registered
/// in `server.dart` via `pod.server.preEndpointHandlers`. By the time an
/// endpoint method runs, the API key has already been validated.
extension DartDeskSessionExt on Session {
  /// The validated API key context for this request.
  ///
  /// Always available in endpoint methods — the pre-endpoint handler
  /// rejects requests with missing/invalid API keys before the endpoint
  /// is reached.
  ApiKeyContext get apiKey =>
      requestContext![_apiKeyContextKey] as ApiKeyContext;

  /// Sets the API key context. Called by the pre-endpoint handler.
  set apiKey(ApiKeyContext ctx) {
    requestContext ??= {};
    requestContext![_apiKeyContextKey] = ctx;
  }
}
