import 'package:serverpod_client/serverpod_client.dart';

/// Header scheme prefix for DartDesk compound Authorization values.
const dartDeskScheme = 'DartDesk';

/// Sends the API key on every Serverpod RPC call via the Authorization header.
///
/// **Why this exists:** Serverpod's RPC client only sends one HTTP header
/// (`Authorization`) — there is no hook for custom headers like `x-api-key`.
/// The IO transport uses `dart:io HttpClient` directly, so `package:http`
/// interceptors don't work either. See https://github.com/serverpod/serverpod/issues/663
///
/// **How it works:** Wraps an inner [ClientAuthKeyProvider] (typically
/// [FlutterAuthSessionManager]) and produces a compound Authorization value
/// using the `DartDesk` scheme:
///
/// - Before login: `DartDesk apiKey=<key>`
/// - After login:  `DartDesk apiKey=<key>;Basic <base64-jwt>`
///
/// The server parses the API key from this header in
/// `DartDeskAuth.extractApiKeyFromDartDeskScheme`, and a wrapped
/// `authenticationHandler` extracts the JWT portion so that
/// `session.authenticated` still works.
class DartDeskAuthKeyProvider implements ClientAuthKeyProvider {
  final String apiKey;
  final ClientAuthKeyProvider? inner;

  const DartDeskAuthKeyProvider({required this.apiKey, this.inner});

  @override
  Future<String?> get authHeaderValue async {
    final innerValue = await inner?.authHeaderValue;
    if (innerValue != null) {
      return '$dartDeskScheme apiKey=$apiKey;$innerValue';
    }
    return '$dartDeskScheme apiKey=$apiKey';
  }
}
