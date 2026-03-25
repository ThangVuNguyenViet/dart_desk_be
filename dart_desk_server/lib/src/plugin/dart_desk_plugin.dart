import 'package:serverpod/serverpod.dart';

import 'dart_desk_registry.dart';

/// Abstract plugin interface for extending Dart Desk.
///
/// Plugins register their contributions (storage providers, auth strategies,
/// tenant resolvers) during [register], then perform async setup in [onStartup].
abstract class DartDeskPlugin {
  /// Unique name for this plugin.
  String get name;

  /// Register contributions with the registry. Called synchronously before
  /// the server starts. Use this to set factories, add auth strategies, etc.
  void register(DartDeskRegistry registry);

  /// Called after the Serverpod instance has started. Use for async
  /// initialization (fetch keys, warm caches, configure cloud storage, etc.).
  Future<void> onStartup(Serverpod pod) async {}

  /// Called during server shutdown for cleanup.
  Future<void> onShutdown() async {}
}
