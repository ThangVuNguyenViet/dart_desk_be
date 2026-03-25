import 'package:serverpod/serverpod.dart';

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
