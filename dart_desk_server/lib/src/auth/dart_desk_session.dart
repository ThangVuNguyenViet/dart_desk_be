import 'package:serverpod/serverpod.dart';

import 'api_key_context.dart';

const _apiKeyContextKey = 'apiKey';

/// Typed extension on [Session] for accessing pre-validated request context.
///
/// The [ApiKeyContext] is attached by the pre-endpoint handler registered
/// in `server.dart` via `pod.server.preEndpointHandlers`. By the time an
/// endpoint method runs, the API key has already been validated (or the
/// endpoint is exempt and gets a permissive default).
extension DartDeskSessionExt on Session {
  /// The validated API key context for this request.
  ///
  /// Non-exempt endpoints always have a real key (pre-handler rejects
  /// otherwise). Exempt endpoints and test contexts get a permissive default.
  ApiKeyContext get apiKey {
    final ctx = requestContext?[_apiKeyContextKey];
    if (ctx is ApiKeyContext) return ctx;
    return const ApiKeyContext(clientId: null, role: 'write', tokenId: 0);
  }

  /// Sets the API key context. Called by the pre-endpoint handler.
  set apiKey(ApiKeyContext ctx) {
    requestContext ??= {};
    requestContext![_apiKeyContextKey] = ctx;
  }
}
