/// Runtime application configuration.
class AppConfig {
  final String manageBaseUrl;
  const AppConfig({required this.manageBaseUrl});
}

/// Registry that holds the singleton [AppConfig] instance.
///
/// [AppConfigRegistry.set] is called once at server startup (in `server.dart`).
/// Endpoints and services that need runtime config call [AppConfigRegistry.get].
class AppConfigRegistry {
  static AppConfig? _instance;

  static AppConfig? get() => _instance;
  static void set(AppConfig? config) => _instance = config;
  static void reset() => _instance = null;
}
