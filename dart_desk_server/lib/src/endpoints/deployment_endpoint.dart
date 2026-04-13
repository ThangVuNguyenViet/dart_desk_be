import 'package:serverpod/serverpod.dart';

import '../auth/require_role.dart';
import '../generated/protocol.dart';

/// Endpoint for managing deployments.
/// All methods require authenticated admin user.
class DeploymentEndpoint extends Endpoint {
  /// List all deployments for a project by slug.
  Future<List<Deployment>> list(
    Session session,
    String projectSlug,
  ) async {
    await _requireAdminUser(session, projectSlug);

    final project = await _getProject(session, projectSlug);
    return await Deployment.db.find(
      session,
      where: (t) => t.projectId.equals(project.id),
      orderBy: (t) => t.version,
      orderDescending: true,
    );
  }

  /// Get the currently active deployment for a project.
  Future<Deployment?> getActive(
    Session session,
    String projectSlug,
  ) async {
    await _requireAdminUser(session, projectSlug);

    final project = await _getProject(session, projectSlug);
    return await Deployment.db.findFirstRow(
      session,
      where: (t) =>
          t.projectId.equals(project.id) &
          t.status.equals(DeploymentStatus.active),
    );
  }

  /// Activate (rollback to) a specific version.
  Future<Deployment> activate(
    Session session,
    String projectSlug,
    int version,
  ) async {
    await RoleGuard.requireRole(session, allowed: RoleGuard.destructiveRoles);

    final project = await _getProject(session, projectSlug);

    // Find the target deployment
    final target = await Deployment.db.findFirstRow(
      session,
      where: (t) =>
          t.projectId.equals(project.id) & t.version.equals(version),
    );
    if (target == null) {
      throw ApiException(message: 'Deployment version $version not found', code: 404);
    }

    // Deactivate currently active deployment
    final currentActive = await Deployment.db.findFirstRow(
      session,
      where: (t) =>
          t.projectId.equals(project.id) &
          t.status.equals(DeploymentStatus.active),
    );
    if (currentActive != null) {
      await Deployment.db.updateRow(
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
    final result = await Deployment.db.updateRow(session, activated);
    session.log('Activated Deployment projectSlug=$projectSlug version=$version', level: LogLevel.info);
    return result;
  }

  /// Delete a deployment version.
  Future<bool> delete(
    Session session,
    String projectSlug,
    int version,
  ) async {
    await RoleGuard.requireRole(session, allowed: RoleGuard.destructiveRoles);

    final project = await _getProject(session, projectSlug);

    final deployment = await Deployment.db.findFirstRow(
      session,
      where: (t) =>
          t.projectId.equals(project.id) & t.version.equals(version),
    );
    if (deployment == null) return false;

    if (deployment.status == DeploymentStatus.active) {
      throw ApiException(message: 'Cannot delete the active deployment. Activate another version first.', code: 400);
    }

    await Deployment.db.deleteRow(session, deployment);
    session.log('Deleted Deployment projectSlug=$projectSlug version=$version', level: LogLevel.info);
    return true;
  }

  /// Get a Project by slug, throws if not found.
  Future<Project> _getProject(Session session, String slug) async {
    final project = await Project.db.findFirstRow(
      session,
      where: (t) => t.slug.equals(slug) & t.isActive.equals(true),
    );
    if (project == null) {
      throw ApiException(message: 'Project not found: $slug', code: 404);
    }
    return project;
  }

  /// Verify the caller is an authenticated User with admin role
  /// belonging to the target project.
  Future<User> _requireAdminUser(Session session, String projectSlug) async {
    final authInfo = session.authenticated;
    if (authInfo == null) {
      throw ApiException(message: 'User must be authenticated', code: 401);
    }

    final project = await _getProject(session, projectSlug);

    final user = await User.db.findFirstRow(
      session,
      where: (t) =>
          t.serverpodUserId.equals(authInfo.userIdentifier) &
          t.clientId.equals(project.clientId) &
          t.isActive.equals(true),
    );
    if (user == null) {
      throw ApiException(message: 'User does not belong to project $projectSlug', code: 403);
    }
    if (user.role != ClientRole.admin && user.role != ClientRole.owner) {
      throw ApiException(message: 'Admin access required', code: 403);
    }
    return user;
  }
}
