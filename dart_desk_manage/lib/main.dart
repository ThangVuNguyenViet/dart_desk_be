import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dart_desk_be_client/dart_desk_be_client.dart';
import 'package:marionette_flutter/marionette_flutter.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'src/core/marionette_config.dart';
import 'src/providers/manage_providers.dart';
import 'src/routes/manage_coordinator.dart';
import 'src/widgets/auth_gate.dart';

void main() async {
  if (kDebugMode) {
    MarionetteBinding.ensureInitialized(ManageMarionetteConfig.configuration);
  }

  serverpodClient = Client(
    'http://$localhost:8080/',
  )
    ..connectivityMonitor = FlutterConnectivityMonitor()
    ..authSessionManager = FlutterAuthSessionManager();
  await serverpodClient.auth.initialize();
  await serverpodClient.auth.initializeGoogleSignIn();

  runApp(const ManageApp());
}

class ManageApp extends StatefulWidget {
  const ManageApp({super.key});

  @override
  State<ManageApp> createState() => _ManageAppState();
}

class _ManageAppState extends State<ManageApp> {
  late final ManageCoordinator coordinator;

  @override
  void initState() {
    super.initState();
    coordinator = ManageCoordinator();
  }

  @override
  Widget build(BuildContext context) {
    return ShadApp.router(
      title: 'Flutter CMS Manage',
      theme: ShadThemeData(
        brightness: Brightness.dark,
        colorScheme: const ShadSlateColorScheme.dark(),
      ),
      routeInformationParser: coordinator.routeInformationParser,
      routerDelegate: coordinator.routerDelegate,
      builder: (context, child) => AuthGate(
        coordinator: coordinator,
        child: child ?? const SizedBox.shrink(),
      ),
    );
  }
}
