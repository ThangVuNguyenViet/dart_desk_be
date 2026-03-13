import 'package:flutter/material.dart';
import 'package:flutter_cms_be_client/flutter_cms_be_client.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'src/providers/manage_providers.dart';
import 'src/routes/manage_coordinator.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();

  serverpodClient = Client(
    'http://$localhost:8080/',
  )
    ..connectivityMonitor = FlutterConnectivityMonitor()
    ..authSessionManager = FlutterAuthSessionManager();
  serverpodClient.auth.initialize();

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
    );
  }
}
