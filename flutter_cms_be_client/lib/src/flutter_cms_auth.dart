import 'package:flutter/material.dart';
import 'package:serverpod_auth_google_flutter/serverpod_auth_google_flutter.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../flutter_cms_be_client.dart';

/// A widget that provides authentication guard functionality using Serverpod's
/// authentication system with Google Sign-In integration.
///
/// This widget manages the authentication state and displays either a sign-in UI
/// or the authenticated content based on the user's authentication status.
///
/// Example usage:
/// ```dart
/// FlutterCmsAuth(
///   client: client,
///   serverClientId: '491670473884-ung977o6k7t8dmj69abcg601abso2d7e.apps.googleusercontent.com',
///   redirectUri: Uri.parse('http://localhost:8080/googlesignin'),
///   child: MyAuthenticatedApp(),
/// )
/// ```
class FlutterCmsAuth extends StatefulWidget {
  /// The Serverpod client instance used for authentication.
  final Client client;

  /// The content to display when the user is authenticated.
  final Widget child;

  /// Google OAuth client ID for authentication.
  final String? serverClientId;

  /// OAuth redirect URI for handling authentication callbacks.
  final Uri? redirectUri;

  /// The title to display on the sign-in screen.
  final String title;

  /// The subtitle or description to display on the sign-in screen.
  final String? subtitle;

  /// Optional logo widget to display above the title.
  final Widget? logo;

  const FlutterCmsAuth({
    super.key,
    required this.client,
    required this.child,
    this.serverClientId,
    this.redirectUri,
    this.title = 'Welcome to Flutter CMS',
    this.subtitle,
    this.logo,
  });

  @override
  State<FlutterCmsAuth> createState() => _FlutterCmsAuthState();
}

class _FlutterCmsAuthState extends State<FlutterCmsAuth> {
  late SessionManager _sessionManager;
  late Caller _caller;
  UserInfo? _userInfo;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeAuth();
  }

  /// Initialize the session manager and check for existing session
  Future<void> _initializeAuth() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Initialize session manager
      _sessionManager = SessionManager(
        caller: widget.client.modules.auth,
      );
      _caller = widget.client.modules.auth;

      // Initialize the session with stored data
      await _sessionManager.initialize();

      // Register listener for authentication state changes
      _sessionManager.addListener(() {
        if (mounted) {
          _checkAuthStatus();
        }
      });

      // Check initial authentication status
      _checkAuthStatus();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to initialize authentication: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  /// Check the current authentication status and update the user info
  void _checkAuthStatus() {
    if (mounted) {
      setState(() {
        _userInfo = _sessionManager.signedInUser;
        _isLoading = false;
      });
    }
  }

  /// Handle sign-out
  Future<void> _handleSignOut() async {
    try {
      await _sessionManager.signOutDevice();
      if (mounted) {
        setState(() {
          _userInfo = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to sign out: ${e.toString()}';
        });
      }
    }
  }

  @override
  void dispose() {
    // Clean up session manager
    _sessionManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Show loading indicator while checking authentication status
    if (_isLoading) {
      return _buildLoadingScreen();
    }

    // Show authenticated content if user is signed in
    if (_userInfo != null) {
      return _FlutterCmsAuthProvider(
        sessionManager: _sessionManager,
        userInfo: _userInfo!,
        onSignOut: _handleSignOut,
        child: widget.child,
      );
    }

    // Show sign-in screen if user is not authenticated
    return _buildSignInScreen();
  }

  /// Build the loading screen
  Widget _buildLoadingScreen() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Loading...',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }

  /// Build the sign-in screen with shadcn_ui components
  Widget _buildSignInScreen() {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo (if provided)
                if (widget.logo != null) ...[
                  Center(child: widget.logo!),
                  const SizedBox(height: 24),
                ],

                // Title
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),

                // Subtitle (if provided)
                if (widget.subtitle != null) ...[
                  Text(
                    widget.subtitle!,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                ] else ...[
                  const SizedBox(height: 32),
                ],

                // Sign-in card
                ShadCard(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Sign in to continue',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),

                      // Error message (if any)
                      if (_errorMessage != null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red[200]!),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: Colors.red[700],
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: TextStyle(
                                    color: Colors.red[700],
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Google Sign-In button using Serverpod's official widget
                      if (widget.serverClientId != null &&
                          widget.redirectUri != null)
                        SignInWithGoogleButton(
                          caller: _caller,
                          serverClientId: widget.serverClientId!,
                          redirectUri: widget.redirectUri!,
                        )
                      else
                        ShadButton(
                          onPressed: null,
                          size: ShadButtonSize.lg,
                          child: const Text(
                            'Configure Google Sign-In',
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Footer text
                Text(
                  'By signing in, you agree to our Terms of Service and Privacy Policy.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// InheritedWidget that provides authentication data to descendant widgets
class _FlutterCmsAuthProvider extends InheritedWidget {
  final SessionManager sessionManager;
  final UserInfo userInfo;
  final VoidCallback onSignOut;

  const _FlutterCmsAuthProvider({
    required this.sessionManager,
    required this.userInfo,
    required this.onSignOut,
    required super.child,
  });

  /// Retrieve the authentication provider from the widget tree
  static _FlutterCmsAuthProvider? of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_FlutterCmsAuthProvider>();
  }

  @override
  bool updateShouldNotify(_FlutterCmsAuthProvider oldWidget) {
    return userInfo != oldWidget.userInfo ||
        sessionManager != oldWidget.sessionManager;
  }
}

/// Extension on BuildContext to easily access authentication data
extension FlutterCmsAuthContext on BuildContext {
  /// Get the current user info from the authentication provider
  UserInfo? get currentUser {
    return _FlutterCmsAuthProvider.of(this)?.userInfo;
  }

  /// Get the session manager from the authentication provider
  SessionManager? get sessionManager {
    return _FlutterCmsAuthProvider.of(this)?.sessionManager;
  }

  /// Sign out the current user
  void signOut() {
    _FlutterCmsAuthProvider.of(this)?.onSignOut();
  }
}
