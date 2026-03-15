import 'package:flutter/material.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../providers/manage_providers.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String? _error;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: Center(
        child: ShadCard(
          width: 400,
          title: const Text('Flutter CMS', style: TextStyle(fontSize: 24)),
          description: const Text('Sign in to manage your projects'),
          child: Padding(
            padding: const EdgeInsets.only(top: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_error != null) ...[
                  ShadAlert.destructive(
                    title: Text(_error!),
                  ),
                  const SizedBox(height: 16),
                ],
                GoogleSignInWidget(
                  client: serverpodClient,
                  scopes: const [],
                  onAuthenticated: () {
                    // Auth state change is handled by AuthGate's listener
                  },
                  onError: (error) {
                    debugPrint('Google sign-in error: $error');
                    if (mounted) {
                      setState(() {
                        _error = 'Sign-in failed: $error';
                      });
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
