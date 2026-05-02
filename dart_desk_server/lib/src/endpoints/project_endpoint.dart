import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';

import '../auth/require_role.dart';
import '../auth/resolve_user.dart';
import '../generated/protocol.dart';
import '../util/deploy_hostname.dart';

/// Endpoint for managing projects.
class ProjectEndpoint extends Endpoint {
  /// Get all projects with pagination and optional search.
  Future<PaginatedProjects> getProjects(
    Session session, {
    String? search,
    int limit = 20,
    int offset = 0,
  }) async {
    final authInfo = session.authenticated;
    if (authInfo == null) {
      throw ApiException(message: 'User must be authenticated to list projects', code: 401);
    }

    final user = await User.db.findFirstRow(
      session,
      where: (t) => t.serverpodUserId.equals(authInfo.userIdentifier),
    );
    if (user == null) {
      return PaginatedProjects(items: [], total: 0, limit: limit, offset: offset, hasMore: false);
    }
    final clientId = user.clientId;

    final total = await Project.db.count(
      session,
      where: (t) {
        var expr = t.clientId.equals(clientId) & t.deletedAt.equals(null);
        if (search != null && search.isNotEmpty) {
          expr = expr & (t.name.like('%$search%') | t.slug.like('%$search%'));
        }
        return expr;
      },
    );

    final projects = await Project.db.find(
      session,
      where: (t) {
        var expr = t.clientId.equals(clientId) & t.deletedAt.equals(null);
        if (search != null && search.isNotEmpty) {
          expr = expr & (t.name.like('%$search%') | t.slug.like('%$search%'));
        }
        return expr;
      },
      orderBy: (t) => t.createdAt,
      orderDescending: true,
      limit: limit,
      offset: offset,
    );

    return PaginatedProjects(
      items: projects,
      total: total,
      limit: limit,
      offset: offset,
      hasMore: offset + projects.length < total,
    );
  }

  /// Get a project by slug.
  Future<Project?> getProjectBySlug(
    Session session,
    String slug,
  ) async {
    final project = await Project.db.findFirstRow(
      session,
      where: (t) => t.slug.equals(slug),
    );
    if (project != null && project.deletedAt != null) {
      throw ApiException(message: 'Project has been deleted', code: 410, errorCode: 'RESOURCE_DELETED');
    }
    return project;
  }

  /// Get a project by ID.
  Future<Project?> getProject(
    Session session,
    UuidValue projectId,
  ) async {
    final project = await Project.db.findById(session, projectId);
    if (project != null && project.deletedAt != null) {
      throw ApiException(message: 'Project has been deleted', code: 410, errorCode: 'RESOURCE_DELETED');
    }
    return project;
  }

  /// Create a new project (requires authentication).
  Future<Project> createProject(
    Session session,
    String name,
    String slug, {
    String? description,
    String? settings,
  }) async {
    final authInfo = session.authenticated;
    if (authInfo == null) {
      throw ApiException(message: 'User must be authenticated to create projects', code: 401);
    }
    final member = await resolveUser(session);

    final cmsClient = await CmsClient.db.findById(session, member.clientId!);
    if (cmsClient == null) {
      throw ApiException(message: 'Client not found', code: 404);
    }

    final base = slugifyForHostname('${cmsClient.slug}-$slug');

    final inserted = await session.db.transaction((txn) async {
      String? chosenHostname;
      for (final candidate in deriveDeployHostnameCandidates(base)) {
        if (!isValidDeployHostname(candidate) || isReservedDeployHostname(candidate)) {
          continue;
        }
        final taken = await Project.db.findFirstRow(
          session,
          where: (t) => t.deployHostname.equals(candidate) & t.deletedAt.equals(null),
          transaction: txn,
        );
        if (taken == null) {
          chosenHostname = candidate;
          break;
        }
      }

      if (chosenHostname == null) {
        throw ApiException(
          message: 'Could not derive a unique deploy hostname for project',
          code: 500,
        );
      }

      return Project.db.insertRow(
        session,
        Project(
          clientId: member.clientId!,
          name: name,
          slug: slug,
          deployHostname: chosenHostname,
          description: description,
          isActive: true,
          settings: settings,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          createdByUserId: member.id,
          updatedByUserId: member.id,
        ),
        transaction: txn,
      );
    });

    session.log('Created Project id=${inserted.id} slug=$slug deployHostname=${inserted.deployHostname}', level: LogLevel.info);
    return inserted;
  }

  /// Update an existing project (requires authentication).
  Future<Project?> updateProject(
    Session session,
    UuidValue projectId, {
    String? name,
    String? description,
    bool? isActive,
    String? settings,
  }) async {
    final authInfo = session.authenticated;
    if (authInfo == null) {
      throw ApiException(message: 'User must be authenticated to update projects', code: 401);
    }
    final member = await resolveUser(session);

    final existing = await Project.db.findById(session, projectId);
    if (existing == null) {
      return null;
    }
    if (existing.clientId != member.clientId) {
      throw ApiException(message: 'Project belongs to a different client', code: 403);
    }

    final updated = existing.copyWith(
      name: name ?? existing.name,
      description: description ?? existing.description,
      isActive: isActive ?? existing.isActive,
      settings: settings ?? existing.settings,
      updatedAt: DateTime.now(),
      updatedByUserId: member.id,
    );

    await Project.db.updateRow(session, updated);
    session.log('Updated Project id=$projectId', level: LogLevel.info);
    return updated;
  }

  /// Update the deploy hostname for a project (requires admin/owner role).
  Future<Project> updateDeployHostname(
    Session session,
    UuidValue projectId,
    String newHostname,
  ) async {
    // Validate format
    if (!isValidDeployHostname(newHostname)) {
      throw ApiException(message: 'Invalid deploy hostname format: "$newHostname"', code: 400);
    }
    // Reject reserved names
    if (isReservedDeployHostname(newHostname)) {
      throw ApiException(message: 'Deploy hostname "$newHostname" is reserved', code: 400);
    }

    // Authz: caller must be admin or owner
    final user = await RoleGuard.requireRole(session, allowed: RoleGuard.destructiveRoles);

    // Look up project
    final project = await Project.db.findById(session, projectId);
    if (project == null) {
      throw ApiException(message: 'Project not found', code: 404);
    }

    // Cross-client check
    if (project.clientId != user.clientId) {
      throw ApiException(message: 'Project belongs to a different client', code: 403);
    }

    // Update
    final now = DateTime.now();
    final updated = project.copyWith(
      deployHostname: newHostname,
      updatedAt: now,
      updatedByUserId: user.id,
    );

    try {
      await Project.db.updateRow(session, updated);
    } catch (e) {
      if (e.toString().contains('23505') || e.toString().toLowerCase().contains('unique')) {
        throw ApiException(
          message: 'Hostname "$newHostname" is already taken',
          code: 409,
        );
      }
      rethrow;
    }

    session.log('Updated deployHostname for Project id=$projectId to $newHostname', level: LogLevel.info);
    return updated;
  }

  /// Delete a project (requires owner role, soft delete).
  Future<bool> deleteProject(
    Session session,
    UuidValue projectId,
  ) async {
    final authInfo = session.authenticated;
    if (authInfo == null) {
      throw ApiException(message: 'User must be authenticated', code: 401);
    }
    final user = await RoleGuard.requireRole(session, allowed: [ClientRole.owner]);

    final existing = await Project.db.findById(session, projectId);
    if (existing == null || existing.deletedAt != null) return false;
    if (existing.clientId != user.clientId) {
      throw ApiException(message: 'Project belongs to a different client', code: 403);
    }

    final now = DateTime.now();
    existing.deletedAt = now;
    await Project.db.updateRow(session, existing);

    // Soft-delete all documents in project
    final docs = await Document.db.find(
      session,
      where: (t) => t.projectId.equals(projectId) & t.deletedAt.equals(null),
    );
    for (final doc in docs) {
      doc.deletedAt = now;
      await Document.db.updateRow(session, doc);
      final versions = await DocumentVersion.db.find(
        session,
        where: (t) => t.documentId.equals(doc.id) & t.deletedAt.equals(null),
      );
      for (final v in versions) {
        v.deletedAt = now;
        await DocumentVersion.db.updateRow(session, v);
      }
    }
    session.log('Soft-deleted Project id=$projectId', level: LogLevel.info);
    return true;
  }

  /// Create a new CmsClient (workspace) and an admin User for the caller in one transaction.
  /// Used by the manage app's setup wizard for first-time users.
  Future<CmsClient> createClientWithOwner(
    Session session, {
    required String clientName,
    required String clientSlug,
  }) async {
    final authInfo = session.authenticated;
    if (authInfo == null) {
      throw ApiException(message: 'User must be authenticated', code: 401);
    }

    // Guard: caller already has a workspace
    final existingUser = await User.db.findFirstRow(
      session,
      where: (t) => t.serverpodUserId.equals(authInfo.userIdentifier),
    );
    if (existingUser != null) {
      throw ApiException(message: 'Account already has a workspace', code: 409);
    }

    // Validate slug format
    if (!_slugRegex.hasMatch(clientSlug)) {
      throw ApiException(message: 'Invalid slug: must be 3-63 characters, lowercase alphanumeric and hyphens, '
        'cannot start or end with a hyphen', code: 400);
    }
    if (_reservedSlugs.contains(clientSlug)) {
      throw ApiException(message: 'Slug "$clientSlug" is reserved and cannot be used', code: 400);
    }

    // Check slug uniqueness in CmsClient table
    final existing = await CmsClient.db.findFirstRow(
      session,
      where: (t) => t.slug.equals(clientSlug),
    );
    if (existing != null) {
      throw ApiException(message: 'Slug "$clientSlug" is already taken', code: 409);
    }

    // Get user profile for email
    String? email;
    String? userName;
    try {
      final authUserId = UuidValue.fromString(authInfo.userIdentifier);
      final profile = await UserProfile.db.findFirstRow(
        session,
        where: (t) => t.authUserId.equals(authUserId),
      );
      if (profile != null) {
        email = profile.email;
        userName = profile.fullName;
      }
    } catch (e) {
      session.log('Profile lookup failed for ${authInfo.userIdentifier}: $e',
          level: LogLevel.warning);
    }

    final client = await session.db.transaction((transaction) async {
      final client = await CmsClient.db.insertRow(
        session,
        CmsClient(
          name: clientName,
          slug: clientSlug,
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        transaction: transaction,
      );

      await User.db.insertRow(
        session,
        User(
          clientId: client.id,
          email: email ?? authInfo.userIdentifier,
          name: userName,
          role: ClientRole.owner,
          isActive: true,
          serverpodUserId: authInfo.userIdentifier,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        transaction: transaction,
      );

      return client;
    });
    session.log('Created CmsClient id=${client.id} slug=$clientSlug with owner', level: LogLevel.info);
    return client;
  }

  /// Reserved slugs that cannot be used as project slugs.
  static const _reservedSlugs = {'login', 'setup', 'admin', 'api', 'app'};

  /// Slug validation regex: 3-63 chars, lowercase alphanumeric + hyphens,
  /// no leading/trailing hyphens.
  static final _slugRegex = RegExp(r'^[a-z0-9][a-z0-9-]{1,61}[a-z0-9]$');
}
