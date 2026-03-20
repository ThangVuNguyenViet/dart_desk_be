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
  bool _isEmailSigningIn = false;
  bool _obscurePassword = true;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleEmailSubmit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) {
      setState(() => _error = 'Please enter both email and password.');
      return;
    }

    setState(() {
      _isEmailSigningIn = true;
      _error = null;
    });

    try {
      final authSuccess = await serverpodClient.emailIdp.login(
        email: email,
        password: password,
      );
      await serverpodClient.auth.updateSignedInUser(authSuccess);
    } catch (e) {
      if (mounted) {
        setState(() => _error = 'Email sign-in failed: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isEmailSigningIn = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: Center(
        child: SingleChildScrollView(
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
                      setState(() => _error = 'Sign-in failed: $error');
                    }
                  },
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text('or', style: theme.textTheme.muted),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 20),
                ShadInput(
                  controller: _emailController,
                  placeholder: const Text('Email'),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12),
                ShadInput(
                  key: const ValueKey('password_field'),
                  controller: _passwordController,
                  placeholder: const Text('Password'),
                  obscureText: _obscurePassword,
                  onSubmitted: (_) => _handleEmailSubmit(),
                ),
                const SizedBox(height: 16),
                ShadButton(
                  onPressed: _isEmailSigningIn ? null : _handleEmailSubmit,
                  width: double.infinity,
                  child: _isEmailSigningIn
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Sign in with email'),
                ),
              ],
            ),
          ),
        ),
        ),
      ),
    );
  }
}
