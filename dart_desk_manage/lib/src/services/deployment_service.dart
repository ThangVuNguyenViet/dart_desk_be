import 'package:dart_desk_be_client/dart_desk_be_client.dart';
import 'package:signals/signals.dart';

class DeploymentService {
  final Client client;
  final int clientId;
  final String clientSlug;

  DeploymentService({
    required this.client,
    required this.clientId,
    required this.clientSlug,
  });

  final deployments = listSignal<CmsDeployment>([]);
  final isLoading = signal(false);

  Future<void> loadDeployments() async {
    isLoading.value = true;
    try {
      final result = await client.deployment.list(clientSlug);
      deployments.value = result;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> activateVersion(int version) async {
    await client.deployment.activate(clientSlug, version);
    await loadDeployments();
  }

  Future<void> deleteVersion(int version) async {
    await client.deployment.delete(clientSlug, version);
    await loadDeployments();
  }

  CmsDeployment? get activeDeployment {
    try {
      return deployments.value.firstWhere(
        (d) => d.status == DeploymentStatus.active,
      );
    } catch (_) {
      return null;
    }
  }
}
