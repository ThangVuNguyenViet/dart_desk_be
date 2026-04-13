import 'package:serverpod/serverpod.dart';

import '../auth/resolve_user.dart';
import '../generated/protocol.dart';

class ProjectMemberEndpoint extends Endpoint {
  Future<User> _requireProjectAdmin(Session session, UuidValue projectId) async {
    final auth = session.authenticated;
    if (auth == null) {
      throw ApiException(message: 'User must be authenticated', code: 401);
    }

    final project = await Project.db.findById(session, projectId);
    if (project == null) {
      throw ApiException(message: 'Project not found', code: 404);
    }

    final caller = await resolveUser(session, clientId: project.clientId);
    if (caller.role != ClientRole.admin && caller.role != ClientRole.owner) {
      throw ApiException(message: 'Admin access required', code: 403);
    }
    return caller;
  }

  Future<List<ProjectMember>> listProjectMembers(
    Session session, {
    required UuidValue projectId,
  }) async {
    final auth = session.authenticated;
    if (auth == null) {
      throw ApiException(message: 'User must be authenticated', code: 401);
    }

    return ProjectMember.db.find(
      session,
      where: (t) => t.projectId.equals(projectId),
    );
  }

  Future<ProjectMember> addProjectMember(
    Session session, {
    required UuidValue projectId,
    required UuidValue userId,
    required ProjectRole role,
  }) async {
    await _requireProjectAdmin(session, projectId);

    final existing = await ProjectMember.db.findFirstRow(
      session,
      where: (t) => t.userId.equals(userId) & t.projectId.equals(projectId),
    );
    if (existing != null) {
      throw ApiException(
        message: 'User is already a member of this project',
        code: 409,
      );
    }

    return ProjectMember.db.insertRow(
      session,
      ProjectMember(
        userId: userId,
        projectId: projectId,
        role: role,
      ),
    );
  }

  Future<ProjectMember> updateProjectMemberRole(
    Session session, {
    required UuidValue projectId,
    required UuidValue userId,
    required ProjectRole role,
  }) async {
    await _requireProjectAdmin(session, projectId);

    final existing = await ProjectMember.db.findFirstRow(
      session,
      where: (t) => t.userId.equals(userId) & t.projectId.equals(projectId),
    );
    if (existing == null) {
      throw ApiException(
        message: 'User is not a member of this project',
        code: 404,
      );
    }

    final updated = existing.copyWith(role: role);
    await ProjectMember.db.updateRow(session, updated);
    return updated;
  }

  Future<void> removeProjectMember(
    Session session, {
    required UuidValue projectId,
    required UuidValue userId,
  }) async {
    await _requireProjectAdmin(session, projectId);

    final existing = await ProjectMember.db.findFirstRow(
      session,
      where: (t) => t.userId.equals(userId) & t.projectId.equals(projectId),
    );
    if (existing == null) {
      throw ApiException(
        message: 'User is not a member of this project',
        code: 404,
      );
    }

    await ProjectMember.db.deleteRow(session, existing);
  }
}
