import 'package:flutter_cms_be_client/flutter_cms_be_client.dart';
import 'package:signals/signals.dart';

import '../services/deployment_service.dart';
import '../services/token_service.dart';

/// Auth state for the AuthGate widget
enum AuthState {
  loading,
  unauthenticated,
  authenticatedLoading,
  ready,
  noClients
}

/// Current auth state — written by AuthGate widget
final authState = signal<AuthState>(AuthState.loading);

/// Global Serverpod client instance (initialized in main.dart)
late final Client serverpodClient;

/// Current authenticated CmsUser — derived from currentClientSlug
final currentUser = futureSignal<CmsUser?>(
  () async {
    final slug = currentClientSlug.value;
    if (slug.isEmpty) return null;
    return serverpodClient.user.getCurrentUserBySlug(slug);
  },
  dependencies: [currentClientSlug],
);

/// Current client slug (set from URL)
final currentClientSlug = signal<String>('');

/// All clients the user belongs to
final userClients = futureSignal<List<CmsClient>>(
  () => serverpodClient.user.getUserClients(),
  lazy: true,
);

/// Current CmsClient — derived from currentClientSlug + userClients
final currentClient = futureSignal<CmsClient?>(
  () async {
    final slug = currentClientSlug.value;
    if (slug.isEmpty) return null;
    final clients = await userClients.future;
    return clients.where((c) => c.slug == slug).firstOrNull;
  },
  dependencies: [currentClientSlug, userClients],
);

/// Token service for the current client
TokenService? _tokenService;

TokenService get tokenService {
  final client = currentClient.value.value;
  if (client == null) throw StateError('No client selected');
  if (_tokenService == null || _tokenService!.clientId != client.id!) {
    _tokenService = TokenService(
      client: serverpodClient,
      clientId: client.id!,
    );
  }
  return _tokenService!;
}

/// Deployment service for the current client
DeploymentService? _deploymentService;

DeploymentService get deploymentService {
  final client = currentClient.value.value;
  if (client == null) throw StateError('No client selected');
  final slug = currentClientSlug.value;
  if (_deploymentService == null || _deploymentService!.clientId != client.id!) {
    _deploymentService = DeploymentService(
      client: serverpodClient,
      clientId: client.id!,
      clientSlug: slug,
    );
  }
  return _deploymentService!;
}

/// Reset token service when client changes
void resetTokenService() {
  _tokenService = null;
  _deploymentService = null;
}

/// Initialize client context from slug
void initClientContext(String slug) {
  currentClientSlug.value = slug;
  resetTokenService();
}

/// Sign out and clear all state
Future<void> logout() async {
  await serverpodClient.auth.signOutDevice();
  currentClientSlug.value = '';
  userClients.reset();
  authState.value = AuthState.unauthenticated;
  resetTokenService();
}
