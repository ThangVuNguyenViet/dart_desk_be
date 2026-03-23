import 'package:serverpod/serverpod.dart';

import '../services/document_crdt_service.dart';
import '../services/image_storage_provider.dart';
import 'dart_desk_registry.dart';

/// Extension on [Session] for accessing plugin-provided services.
///
/// Uses a static [DartDeskRegistry] reference since Serverpod sessions
/// don't have extensible property bags.
extension DartDeskSession on Session {
  static DartDeskRegistry? _registry;

  /// Set the global registry. Called once during server startup.
  static void setRegistry(DartDeskRegistry registry) {
    _registry = registry;
  }

  /// Get the global registry. Throws if not initialized.
  static DartDeskRegistry get registry {
    if (_registry == null) {
      throw StateError(
        'DartDeskSession.registry not initialized. '
        'Call DartDeskSession.setRegistry() during server startup.',
      );
    }
    return _registry!;
  }

  /// Get an [ImageStorageProvider] for this session.
  ImageStorageProvider get imageStorage =>
      DartDeskSession.registry.createImageStorage(this);

  /// Get the [DocumentCrdtService] instance.
  DocumentCrdtService get crdtService =>
      DartDeskSession.registry.documentCrdtService;

}
