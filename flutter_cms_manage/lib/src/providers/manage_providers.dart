import 'package:flutter_cms_be_client/flutter_cms_be_client.dart';
import 'package:signals/signals.dart';

import '../services/token_service.dart';

/// Auth state for the AuthGate widget
enum AuthState { loading, unauthenticated, authenticatedLoading, ready, noClients }

/// Current auth state — written by AuthGate widget
final authState = signal<AuthState>(AuthState.loading);

/// Global Serverpod client instance (initialized in main.dart)
late final Client serverpodClient;

/// Current authenticated CmsUser
final currentUser = signal<CmsUser?>(null);

/// Current CmsClient (resolved from URL slug)
final currentClient = signal<CmsClient?>(null);

/// All clients the user belongs to
final userClients = listSignal<CmsClient>([]);

/// Token service for the current client
TokenService? _tokenService;

TokenService get tokenService {
  final client = currentClient.value;
  if (client == null) throw StateError('No client selected');
  if (_tokenService == null || _tokenService!.clientId != client.id!) {
    _tokenService = TokenService(
      client: serverpodClient,
      clientId: client.id!,
    );
  }
  return _tokenService!;
}

/// Reset token service when client changes
void resetTokenService() {
  _tokenService = null;
}

/// Initialize client context from slug
Future<void> initClientContext(String clientSlug) async {
  final clients = await serverpodClient.user.getUserClients();
  userClients.value = clients;

  final client = clients.where((c) => c.slug == clientSlug).firstOrNull;
  currentClient.value = client;
  resetTokenService();

  if (client != null) {
    final user =
        await serverpodClient.user.getCurrentUserBySlug(clientSlug);
    currentUser.value = user;
  }
}

/// Sign out and clear all state
Future<void> logout() async {
  await serverpodClient.auth.signOutDevice();
  currentUser.value = null;
  currentClient.value = null;
  userClients.value = [];
  authState.value = AuthState.unauthenticated;
  resetTokenService();
}
