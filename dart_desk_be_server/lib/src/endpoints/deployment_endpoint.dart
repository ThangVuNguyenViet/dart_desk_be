import 'package:dart_desk_be_server/server.dart' show deploymentStorage;
import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';

/// Endpoint for managing CMS deployments.
/// All methods require authenticated admin user.
class DeploymentEndpoint extends Endpoint {
  /// List all deployments for a client by slug.
  Future<List<CmsDeployment>> list(
    Session session,
    String clientSlug,
  ) async {
    await _requireAdminUser(session, clientSlug);

    final client = await _getClient(session, clientSlug);
    return await CmsDeployment.db.find(
      session,
      where: (t) => t.clientId.equals(client.id!),
      orderBy: (t) => t.version,
      orderDescending: true,
    );
  }

  /// Get the currently active deployment for a client.
  Future<CmsDeployment?> getActive(
    Session session,
    String clientSlug,
  ) async {
    await _requireAdminUser(session, clientSlug);

    final client = await _getClient(session, clientSlug);
    return await CmsDeployment.db.findFirstRow(
      session,
      where: (t) =>
          t.clientId.equals(client.id!) &
          t.status.equals(DeploymentStatus.active),
    );
  }

  /// Activate (rollback to) a specific version.
  Future<CmsDeployment> activate(
    Session session,
    String clientSlug,
    int version,
  ) async {
    await _requireAdminUser(session, clientSlug);

    final client = await _getClient(session, clientSlug);

    // Find the target deployment
    final target = await CmsDeployment.db.findFirstRow(
      session,
      where: (t) =>
          t.clientId.equals(client.id!) & t.version.equals(version),
    );
    if (target == null) {
      throw Exception('Deployment version $version not found');
    }

    // Deactivate currently active deployment
    final currentActive = await CmsDeployment.db.findFirstRow(
      session,
      where: (t) =>
          t.clientId.equals(client.id!) &
          t.status.equals(DeploymentStatus.active),
    );
    if (currentActive != null) {
      await CmsDeployment.db.updateRow(
        session,
        currentActive.copyWith(
          status: DeploymentStatus.inactive,
          updatedAt: DateTime.now(),
        ),
      );
    }

    // Activate the target
    final activated = target.copyWith(
      status: DeploymentStatus.active,
      updatedAt: DateTime.now(),
    );
    return await CmsDeployment.db.updateRow(session, activated);
  }

  /// Delete a deployment version and its files.
  Future<bool> delete(
    Session session,
    String clientSlug,
    int version,
  ) async {
    await _requireAdminUser(session, clientSlug);

    final client = await _getClient(session, clientSlug);

    final deployment = await CmsDeployment.db.findFirstRow(
      session,
      where: (t) =>
          t.clientId.equals(client.id!) & t.version.equals(version),
    );
    if (deployment == null) return false;

    if (deployment.status == DeploymentStatus.active) {
      throw Exception('Cannot delete the active deployment. Activate another version first.');
    }

    // Delete files
    await deploymentStorage.delete(clientSlug, version);

    // Delete record
    await CmsDeployment.db.deleteRow(session, deployment);
    return true;
  }

  /// Get a CmsClient by slug, throws if not found.
  Future<CmsClient> _getClient(Session session, String slug) async {
    final client = await CmsClient.db.findFirstRow(
      session,
      where: (t) => t.slug.equals(slug) & t.isActive.equals(true),
    );
    if (client == null) {
      throw Exception('Client not found: $slug');
    }
    return client;
  }

  /// Verify the caller is an authenticated CmsUser with admin role
  /// belonging to the target client.
  Future<CmsUser> _requireAdminUser(Session session, String clientSlug) async {
    final authInfo = session.authenticated;
    if (authInfo == null) {
      throw Exception('User must be authenticated');
    }

    final client = await _getClient(session, clientSlug);

    final user = await CmsUser.db.findFirstRow(
      session,
      where: (t) =>
          t.serverpodUserId.equals(authInfo.userIdentifier) &
          t.clientId.equals(client.id!) &
          t.isActive.equals(true),
    );
    if (user == null) {
      throw Exception('User does not belong to client $clientSlug');
    }
    if (user.role != 'admin') {
      throw Exception('Admin role required');
    }
    return user;
  }
}
