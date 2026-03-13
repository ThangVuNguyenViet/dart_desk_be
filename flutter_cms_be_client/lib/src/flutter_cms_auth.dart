import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../flutter_cms_be_client.dart';

/// A widget that provides authentication guard functionality using Serverpod's
/// IDP authentication system with Google Sign-In integration.
///
/// Simplified constructor only requires `clientId` (CmsClient slug) and `serverUrl`.
/// The widget creates the Client internally and calls `ensureUser` after sign-in.
///
/// Example usage:
/// ```dart
/// FlutterCmsAuth(
///   clientId: 'default',
///   serverUrl: 'http://localhost:8080/',
///   builder: (context, client) => MyAuthenticatedApp(client: client),
/// )
/// ```
class FlutterCmsAuth extends StatefulWidget {
  final String clientId;
  final String apiToken;
  final String serverUrl;
  final Widget Function(BuildContext context, Client client) builder;
  final String title;
  final String? subtitle;
  final Widget? logo;

  const FlutterCmsAuth({
    super.key,
    required this.clientId,
    required this.apiToken,
    required this.serverUrl,
    required this.builder,
    this.title = 'Welcome to Flutter CMS',
    this.subtitle,
    this.logo,
  });

  @override
  State<FlutterCmsAuth> createState() => _FlutterCmsAuthState();
}

class _FlutterCmsAuthState extends State<FlutterCmsAuth> {
  late final Client _client;
  bool _isLoading = true;
  bool _isEnsuringUser = false;
  String? _errorMessage;

  FlutterAuthSessionManager get _auth => _client.authSessionManager;

  @override
  void initState() {
    super.initState();
    _initializeClient();
  }

  Future<void> _initializeClient() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      _client = Client(widget.serverUrl)
        ..connectivityMonitor = FlutterConnectivityMonitor()
        ..authSessionManager = FlutterAuthSessionManager();

      await _client.auth.initialize();
      await _client.auth.initializeGoogleSignIn();

      _auth.authInfoListenable.addListener(_onAuthChanged);

      // If already authenticated, ensure user exists
      if (_auth.isAuthenticated) {
        await _ensureUser();
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to initialize: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _onAuthChanged() {
    if (mounted) {
      if (_auth.isAuthenticated && !_isEnsuringUser) {
        _ensureUser();
      }
      setState(() {});
    }
  }

  Future<void> _ensureUser() async {
    _isEnsuringUser = true;
    try {
      await _client.user.ensureUser(widget.clientId, widget.apiToken);
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to initialize user: ${e.toString()}';
        });
      }
    } finally {
      _isEnsuringUser = false;
    }
  }

  Future<void> _handleSignOut() async {
    try {
      await _auth.signOutDevice();
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
    _auth.authInfoListenable.removeListener(_onAuthChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingScreen();
    }

    if (_auth.isAuthenticated) {
      return _FlutterCmsAuthProvider(
        client: _client,
        clientId: widget.clientId,
        apiToken: widget.apiToken,
        authSessionManager: _auth,
        authSuccess: _auth.authInfo!,
        onSignOut: _handleSignOut,
        child: widget.builder(context, _client),
      );
    }

    return _buildSignInScreen();
  }

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

  Widget _buildSignInScreen() {
    return Scaffold(
      body: Builder(
        builder: (context) {
          final theme = ShadTheme.of(context);
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (widget.logo != null) ...[
                      Center(child: widget.logo!),
                      const SizedBox(height: 24),
                    ],
                    Text(
                      widget.title,
                      style: theme.textTheme.h1Large,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    if (widget.subtitle != null) ...[
                      Text(
                        widget.subtitle!,
                        style: theme.textTheme.muted,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                    ] else ...[
                      const SizedBox(height: 32),
                    ],
                    ShadCard(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Sign in to continue',
                            style: theme.textTheme.h4,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          if (_errorMessage != null) ...[
                            ShadAlert.destructive(
                              iconSrc: LucideIcons.circleAlert,
                              title: const Text('Error'),
                              description: Text(_errorMessage!),
                            ),
                            const SizedBox(height: 16),
                          ],
                          GoogleSignInWidget(
                            client: _client,
                            scopes: const [],
                            onAuthenticated: () {
                              if (mounted) setState(() {});
                            },
                            onError: (error) {
                              setState(() {
                                _errorMessage =
                                    'Google Sign-In failed. Please try again.';
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'By signing in, you agree to our Terms of Service and Privacy Policy.',
                      style: theme.textTheme.muted.copyWith(
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// InheritedWidget that provides authentication data to descendant widgets
class _FlutterCmsAuthProvider extends InheritedWidget {
  final Client client;
  final String clientId;
  final String apiToken;
  final FlutterAuthSessionManager authSessionManager;
  final AuthSuccess authSuccess;
  final VoidCallback onSignOut;

  const _FlutterCmsAuthProvider({
    required this.client,
    required this.clientId,
    required this.apiToken,
    required this.authSessionManager,
    required this.authSuccess,
    required this.onSignOut,
    required super.child,
  });

  static _FlutterCmsAuthProvider? of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_FlutterCmsAuthProvider>();
  }

  @override
  bool updateShouldNotify(_FlutterCmsAuthProvider oldWidget) {
    return authSuccess != oldWidget.authSuccess ||
        authSessionManager != oldWidget.authSessionManager ||
        client != oldWidget.client ||
        clientId != oldWidget.clientId ||
        apiToken != oldWidget.apiToken;
  }
}

/// Extension on BuildContext to easily access authentication data
extension FlutterCmsAuthContext on BuildContext {
  /// Get the CMS Client instance
  Client? get cmsClient {
    return _FlutterCmsAuthProvider.of(this)?.client;
  }

  /// Get the CMS client ID (slug)
  String? get cmsClientId {
    return _FlutterCmsAuthProvider.of(this)?.clientId;
  }

  /// Get the CMS API token
  String? get cmsApiToken {
    return _FlutterCmsAuthProvider.of(this)?.apiToken;
  }

  /// Get the current auth success info
  AuthSuccess? get currentAuthInfo {
    return _FlutterCmsAuthProvider.of(this)?.authSuccess;
  }

  /// Get the current user ID (UUID)
  UuidValue? get currentUserId {
    return _FlutterCmsAuthProvider.of(this)?.authSuccess.authUserId;
  }

  /// Get the auth session manager
  FlutterAuthSessionManager? get authSessionManager {
    return _FlutterCmsAuthProvider.of(this)?.authSessionManager;
  }

  /// Sign out the current user
  void signOut() {
    _FlutterCmsAuthProvider.of(this)?.onSignOut();
  }
}
