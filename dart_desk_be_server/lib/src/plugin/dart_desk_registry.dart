import 'package:serverpod/serverpod.dart';

import '../auth/external_auth_strategy.dart';
import '../services/document_crdt_service.dart';
import '../services/image_storage_provider.dart';
import '../services/local_image_storage_provider.dart';

/// Factory that creates an [ImageStorageProvider] from a [Session].
typedef ImageStorageProviderFactory = ImageStorageProvider Function(
    Session session);

/// Collects plugin contributions and provides them to the server.
///
/// Plugins call setters during [DartDeskPlugin.register] to override defaults.
/// The server reads from getters when handling requests.
class DartDeskRegistry {
  // -- Image Storage --

  ImageStorageProviderFactory _imageStorageFactory =
      (session) => LocalImageStorageProvider(session);

  /// Override the image storage provider factory.
  void setImageStorageProvider(ImageStorageProviderFactory factory) {
    _imageStorageFactory = factory;
  }

  /// Create an [ImageStorageProvider] for the given session.
  ImageStorageProvider createImageStorage(Session session) =>
      _imageStorageFactory(session);

  // -- Auth Strategies --

  final List<ExternalAuthStrategy> _authStrategies = [];

  /// Add an external auth strategy.
  void addAuthStrategy(ExternalAuthStrategy strategy) {
    _authStrategies.add(strategy);
  }

  /// All registered external auth strategies.
  List<ExternalAuthStrategy> get authStrategies =>
      List.unmodifiable(_authStrategies);

  // -- Tenant Resolver --

  Future<int?> Function(Session session) _tenantResolver =
      (_) async => null;

  /// Override the tenant resolver.
  void setTenantResolver(Future<int?> Function(Session session) resolver) {
    _tenantResolver = resolver;
  }

  /// Resolve tenant ID for the given session.
  Future<int?> resolveTenantId(Session session) => _tenantResolver(session);

  // -- CRDT Service --

  late DocumentCrdtService documentCrdtService;

  // -- Lifecycle Hooks --

  final List<Future<void> Function(Serverpod pod)> _onStartupHooks = [];
  final List<Future<void> Function()> _onShutdownHooks = [];

  /// Add a hook to run after the server starts.
  void addOnStartup(Future<void> Function(Serverpod pod) hook) {
    _onStartupHooks.add(hook);
  }

  /// Add a hook to run on server shutdown.
  void addOnShutdown(Future<void> Function() hook) {
    _onShutdownHooks.add(hook);
  }

  /// Run all startup hooks.
  Future<void> runStartupHooks(Serverpod pod) async {
    for (final hook in _onStartupHooks) {
      await hook(pod);
    }
  }

  /// Run all shutdown hooks.
  Future<void> runShutdownHooks() async {
    for (final hook in _onShutdownHooks) {
      await hook();
    }
  }

}
