import 'package:serverpod/serverpod.dart';

import '../auth/resolve_user.dart';
import '../generated/protocol.dart';

/// Endpoint for managing projects.
class ProjectEndpoint extends Endpoint {
  /// Get all projects with pagination and optional search.
  Future<ProjectList> getProjects(
    Session session, {
    String? search,
    int limit = 20,
    int offset = 0,
  }) async {
    final authInfo = session.authenticated;
    if (authInfo == null) {
      throw Exception('User must be authenticated to list projects');
    }

    final member = await resolveUser(session);
    final clientId = member.clientId;

    final total = await Project.db.count(
      session,
      where: (t) {
        var expr = t.clientId.equals(clientId);
        if (search != null && search.isNotEmpty) {
          expr = expr & (t.name.like('%$search%') | t.slug.like('%$search%'));
        }
        return expr;
      },
    );

    final projects = await Project.db.find(
      session,
      where: (t) {
        var expr = t.clientId.equals(clientId);
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

    return ProjectList(
      projects: projects,
      total: total,
      page: (offset ~/ limit) + 1,
      pageSize: limit,
    );
  }

  /// Get a project by slug.
  Future<Project?> getProjectBySlug(
    Session session,
    String slug,
  ) async {
    return await Project.db.findFirstRow(
      session,
      where: (t) => t.slug.equals(slug),
    );
  }

  /// Get a project by ID.
  Future<Project?> getProject(
    Session session,
    int projectId,
  ) async {
    return await Project.db.findById(session, projectId);
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
      throw Exception('User must be authenticated to create projects');
    }
    final member = await resolveUser(session);

    final project = Project(
      clientId: member.clientId!,
      name: name,
      slug: slug,
      description: description,
      isActive: true,
      settings: settings,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final inserted = await Project.db.insertRow(session, project);
    return inserted;
  }

  /// Update an existing project (requires authentication).
  Future<Project?> updateProject(
    Session session,
    int projectId, {
    String? name,
    String? description,
    bool? isActive,
    String? settings,
  }) async {
    final authInfo = session.authenticated;
    if (authInfo == null) {
      throw Exception('User must be authenticated to update projects');
    }
    final member = await resolveUser(session);

    final existing = await Project.db.findById(session, projectId);
    if (existing == null) {
      return null;
    }
    if (existing.clientId != member.clientId) {
      throw Exception('Project belongs to a different client');
    }

    final updated = existing.copyWith(
      name: name ?? existing.name,
      description: description ?? existing.description,
      isActive: isActive ?? existing.isActive,
      settings: settings ?? existing.settings,
      updatedAt: DateTime.now(),
    );

    await Project.db.updateRow(session, updated);
    return updated;
  }

  /// Delete a project (requires authentication).
  Future<bool> deleteProject(
    Session session,
    int projectId,
  ) async {
    final authInfo = session.authenticated;
    if (authInfo == null) {
      throw Exception('User must be authenticated to delete projects');
    }
    final member = await resolveUser(session);

    final existing = await Project.db.findById(session, projectId);
    if (existing == null) {
      return false;
    }
    if (existing.clientId != member.clientId) {
      throw Exception('Project belongs to a different client');
    }

    await Project.db.deleteRow(session, existing);
    return true;
  }

  /// Reserved slugs that cannot be used as project slugs.
  static const _reservedSlugs = {'login', 'setup', 'admin', 'api', 'app'};

  /// Slug validation regex: 3-63 chars, lowercase alphanumeric + hyphens,
  /// no leading/trailing hyphens.
  static final _slugRegex = RegExp(r'^[a-z0-9][a-z0-9-]{1,61}[a-z0-9]$');

  /// Create a new project and an admin User for the caller in one transaction.
  /// Used by the manage app's setup wizard for first-time users.
  Future<Project> createProjectWithOwner(
    Session session, {
    required String name,
    required String slug,
  }) async {
    final authInfo = session.authenticated;
    if (authInfo == null) {
      throw Exception('User must be authenticated');
    }

    // Validate slug format
    if (!_slugRegex.hasMatch(slug)) {
      throw Exception(
        'Invalid slug: must be 3-63 characters, lowercase alphanumeric and hyphens, '
        'cannot start or end with a hyphen',
      );
    }
    if (_reservedSlugs.contains(slug)) {
      throw Exception('Slug "$slug" is reserved and cannot be used');
    }

    // Check slug uniqueness
    final existing = await Project.db.findFirstRow(
      session,
      where: (t) => t.slug.equals(slug),
    );
    if (existing != null) {
      throw Exception('Slug "$slug" is already taken');
    }

    // Get user profile for email
    String? email;
    String? userName;
    try {
      final profileRows = await session.db.unsafeQuery(
        r'SELECT "email", "fullName" FROM "serverpod_auth_core_profile" '
        r'WHERE "authUserId" = $1 LIMIT 1',
        parameters: QueryParameters.positional([authInfo.userIdentifier]),
      );
      if (profileRows.isNotEmpty) {
        email = profileRows.first[0] as String?;
        userName = profileRows.first[1] as String?;
      }
    } catch (e) {
      // Profile lookup failed; use identifier as fallback
    }

    return session.db.transaction((transaction) async {
      final existingMember = await User.db.findFirstRow(
        session,
        where: (t) => t.serverpodUserId.equals(authInfo.userIdentifier),
      );

      final clientId = existingMember?.clientId ??
          (await CmsClient.db.insertRow(
            session,
            CmsClient(
              name: name,
              slug: slug,
              isActive: true,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
          ))
              .id!;

      final project = await Project.db.insertRow(
        session,
        Project(
          clientId: clientId,
          name: name,
          slug: slug,
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

      if (existingMember == null) {
        await User.db.insertRow(
          session,
          User(
            clientId: clientId,
            email: email ?? authInfo.userIdentifier,
            name: userName,
            role: 'admin',
            isActive: true,
            serverpodUserId: authInfo.userIdentifier,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );
      }

      return project;
    });
  }
}
