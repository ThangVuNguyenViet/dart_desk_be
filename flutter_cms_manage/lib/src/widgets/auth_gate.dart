import 'package:flutter/material.dart';
import 'package:flutter_cms_be_client/flutter_cms_be_client.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../providers/manage_providers.dart';
import '../routes/manage_coordinator.dart';
import '../routes/overview_route.dart';
import '../screens/login_screen.dart';
import '../screens/setup_wizard_screen.dart';

class AuthGate extends StatefulWidget {
  final Widget child;
  final ManageCoordinator coordinator;

  const AuthGate({
    super.key,
    required this.child,
    required this.coordinator,
  });

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _checkAuth();
    // Listen for auth changes via ValueListenable
    serverpodClient.auth.authInfoListenable.addListener(_checkAuth);
  }

  Future<void> _checkAuth() async {
    final isSignedIn = serverpodClient.auth.isAuthenticated;

    if (!isSignedIn) {
      authState.value = AuthState.unauthenticated;
      _initialized = true;
      if (mounted) setState(() {});
      return;
    }

    // User is authenticated — fetch their clients
    authState.value = AuthState.authenticatedLoading;
    if (mounted) setState(() {});

    try {
      userClients.reload();
      final clients = await userClients.future;

      if (clients.isEmpty) {
        authState.value = AuthState.noClients;
      } else {
        // Set slug from URL if available
        final slug = widget.coordinator.clientSlug;
        if (slug.isNotEmpty) {
          currentClientSlug.value = slug;
        }

        authState.value = AuthState.ready;

        // If user has exactly one client and is on root/login/setup,
        // redirect to their client's overview
        if (clients.length == 1 && _isRootOrAuthRoute()) {
          currentClientSlug.value = clients.first.slug;
          widget.coordinator.replace(
            OverviewRoute(clients.first.slug),
          );
        }
      }
    } catch (e) {
      // If fetching clients fails, treat as unauthenticated
      authState.value = AuthState.unauthenticated;
    }

    _initialized = true;
    if (mounted) setState(() {});
  }

  bool _isRootOrAuthRoute() {
    final path = widget.coordinator.currentUri.path;
    return path == '/' || path == '/login' || path == '/setup';
  }

  @override
  void dispose() {
    serverpodClient.auth.authInfoListenable.removeListener(_checkAuth);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final state = authState.value;

    // Loading state
    if (!_initialized ||
        state == AuthState.loading ||
        state == AuthState.authenticatedLoading) {
      return Scaffold(
        backgroundColor: theme.colorScheme.background,
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Unauthenticated → show login
    if (state == AuthState.unauthenticated) {
      return const LoginScreen();
    }

    // Authenticated but no clients → show setup wizard
    if (state == AuthState.noClients) {
      return SetupWizardScreen(coordinator: widget.coordinator);
    }

    // Ready → show the router's output
    return widget.child;
  }
}
