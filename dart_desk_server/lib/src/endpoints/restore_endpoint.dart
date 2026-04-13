import 'package:dart_desk_server/src/auth/require_role.dart';
import 'package:dart_desk_server/src/generated/protocol.dart';
import 'package:dart_desk_server/src/auth/dart_desk_session.dart';
import 'package:serverpod/serverpod.dart';

class RestoreEndpoint extends Endpoint {
  Future<Document> restoreDocument(Session session, int documentId) async {
    if (!session.canWrite) {
      throw ApiException(message: 'Missing write permission', code: 403);
    }
    await RoleGuard.requireRole(
      session,
      allowed: RoleGuard.destructiveRoles,
      clientId: session.clientId,
    );

    final doc = await Document.db.findById(session, documentId);
    if (doc == null) {
      throw ApiException(message: 'Document not found', code: 404);
    }
    if (doc.projectId != session.projectId) {
      throw ApiException(message: 'Access denied', code: 403);
    }
    if (doc.deletedAt == null) {
      throw ApiException(message: 'Document is not deleted', code: 400);
    }

    doc.deletedAt = null;
    await Document.db.updateRow(session, doc);

    // Restore versions that were soft-deleted
    final versions = await DocumentVersion.db.find(
      session,
      where: (t) =>
          t.documentId.equals(documentId) & t.deletedAt.notEquals(null),
    );
    for (final v in versions) {
      v.deletedAt = null;
      await DocumentVersion.db.updateRow(session, v);
    }
    session.log('Restored Document id=$documentId', level: LogLevel.info);

    return doc;
  }

  Future<Project> restoreProject(Session session, int projectId) async {
    if (session.authenticated == null) {
      throw ApiException(message: 'Authentication required', code: 401);
    }
    await RoleGuard.requireRole(
      session,
      allowed: [ClientRole.owner],
    );

    final project = await Project.db.findById(session, projectId);
    if (project == null) {
      throw ApiException(message: 'Project not found', code: 404);
    }
    if (project.deletedAt == null) {
      throw ApiException(message: 'Project is not deleted', code: 400);
    }

    project.deletedAt = null;
    await Project.db.updateRow(session, project);

    // Restore documents that belong to this project
    final docs = await Document.db.find(
      session,
      where: (t) =>
          t.projectId.equals(projectId) & t.deletedAt.notEquals(null),
    );
    for (final doc in docs) {
      doc.deletedAt = null;
      await Document.db.updateRow(session, doc);

      final versions = await DocumentVersion.db.find(
        session,
        where: (t) =>
            t.documentId.equals(doc.id!) & t.deletedAt.notEquals(null),
      );
      for (final v in versions) {
        v.deletedAt = null;
        await DocumentVersion.db.updateRow(session, v);
      }
    }
    session.log('Restored Project id=$projectId', level: LogLevel.info);

    return project;
  }

  Future<User> restoreUser(Session session, int userId) async {
    if (session.authenticated == null) {
      throw ApiException(message: 'Authentication required', code: 401);
    }
    await RoleGuard.requireRole(
      session,
      allowed: RoleGuard.destructiveRoles,
    );

    final user = await User.db.findById(session, userId);
    if (user == null) {
      throw ApiException(message: 'User not found', code: 404);
    }
    if (user.deletedAt == null) {
      throw ApiException(message: 'User is not deleted', code: 400);
    }

    user.isActive = true;
    user.deletedAt = null;
    await User.db.updateRow(session, user);
    session.log('Restored User id=$userId', level: LogLevel.info);

    return user;
  }
}
