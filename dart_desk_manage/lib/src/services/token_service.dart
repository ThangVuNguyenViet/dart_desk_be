import 'package:dart_desk_be_client/dart_desk_be_client.dart';
import 'package:signals/signals.dart';

class TokenService {
  final Client client;
  final int clientId;

  TokenService({required this.client, required this.clientId});

  final tokens = listSignal<CmsApiToken>([]);
  final isLoading = signal(false);
  final error = signal<String?>(null);

  Future<void> loadTokens() async {
    isLoading.value = true;
    error.value = null;
    try {
      final result = await client.cmsApiToken.getTokens(clientId);
      tokens.value = result;
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<CmsApiTokenWithValue?> createToken({
    required String name,
    required String role,
    DateTime? expiresAt,
  }) async {
    try {
      final result = await client.cmsApiToken.createToken(
        clientId,
        name,
        role,
        expiresAt,
      );
      await loadTokens();
      return result;
    } catch (e) {
      error.value = e.toString();
      return null;
    }
  }

  Future<bool> updateToken({
    required int tokenId,
    String? name,
    bool? isActive,
    DateTime? expiresAt,
  }) async {
    try {
      await client.cmsApiToken.updateToken(tokenId, name, isActive, expiresAt);
      await loadTokens();
      return true;
    } catch (e) {
      error.value = e.toString();
      return false;
    }
  }

  Future<CmsApiTokenWithValue?> regenerateToken(int tokenId) async {
    try {
      final result = await client.cmsApiToken.regenerateToken(tokenId);
      await loadTokens();
      return result;
    } catch (e) {
      error.value = e.toString();
      return null;
    }
  }

  Future<bool> deleteToken(int tokenId) async {
    try {
      await client.cmsApiToken.deleteToken(tokenId);
      await loadTokens();
      return true;
    } catch (e) {
      error.value = e.toString();
      return false;
    }
  }
}
