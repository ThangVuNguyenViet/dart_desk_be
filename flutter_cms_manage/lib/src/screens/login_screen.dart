import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';

import '../providers/manage_providers.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;
  String? _error;

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final controller = GoogleAuthController(
        client: serverpodClient,
        onAuthenticated: () {
          // Auth state change is handled by AuthGate's listener
        },
        onError: (error) {
          if (mounted) {
            setState(() {
              _error = 'Sign-in failed. Please try again.';
              _isLoading = false;
            });
          }
        },
      );
      await controller.signIn();
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Sign-in failed. Please try again.';
          _isLoading = false;
        });
      }
    }
  }

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
                ShadButton(
                  width: double.infinity,
                  enabled: !_isLoading,
                  onPressed: _signInWithGoogle,
                  child: _isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(LucideIcons.logIn, size: 16),
                            const SizedBox(width: 8),
                            const Text('Sign in with Google'),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
