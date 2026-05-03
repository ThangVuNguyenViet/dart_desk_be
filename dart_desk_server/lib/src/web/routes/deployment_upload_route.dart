import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:path/path.dart' as p;
import 'package:serverpod/serverpod.dart';

import '../../auth/resolve_user.dart';
import '../../db/repositories/project_repository.dart' as repo;
import '../../generated/protocol.dart';

/// HTTP POST /deployment/upload?clientSlug=`<clientSlug>`&projectSlug=`<projectSlug>`[&commit=`<sha>`]
///
/// Accepts a gzipped tar of the Flutter web build, stores each file in the
/// `public` cloud storage bucket under `deployments/<deploymentId>/`, inserts
/// a Deployment row, and demotes the previously-active deployment to inactive.
///
/// Authentication: Bearer `<jwt-or-api-token>` via the standard Serverpod
/// authenticationHandler chain configured in server.dart. Authorization is
/// scope-based: requires `project:<id>` and `project.write` scopes (granted to
/// JWT users with `member`+ role and to API tokens with `write`/`admin` role).
///
/// Response 200:
///   `{"version": <int>, "url": "https://<deployHostname>.app.dartdesk.dev"}`
class DeploymentUploadRoute extends Route {
  static const _maxBodyBytes = 100 * 1024 * 1024; // 100 MB
  static const _bundleRoot = 'deployments';
  static const _storageId = 'public';

  // path is set by addRoute(...). Setting Route.path here would double-mount
  // the handler at '/deployment/upload/deployment/upload'.
  DeploymentUploadRoute() : super(methods: {Method.post});

  @override
  FutureOr<Result> handleCall(Session session, Request request) async {
    if (request.method != Method.post) {
      return _jsonResponse(405, {'error': 'Method not allowed'});
    }

    final clientSlug = request.url.queryParameters['clientSlug'];
    if (clientSlug == null || clientSlug.isEmpty) {
      return _jsonResponse(400, {'error': 'Missing clientSlug query parameter'});
    }
    final projectSlug = request.url.queryParameters['projectSlug'];
    if (projectSlug == null || projectSlug.isEmpty) {
      return _jsonResponse(400, {'error': 'Missing projectSlug query parameter'});
    }
    final commitHash = request.url.queryParameters['commit'];

    final auth = session.authenticated;
    if (auth == null) {
      return _jsonResponse(401, {'error': 'Not authenticated'});
    }

    final client = await CmsClient.db.findFirstRow(
      session,
      where: (t) => t.slug.equals(clientSlug),
    );
    if (client == null) {
      return _jsonResponse(404, {'error': 'Client not found: $clientSlug'});
    }

    final project = await repo.ProjectRepository.findByClientAndSlug(
      session,
      clientId: client.id,
      slug: projectSlug,
    );
    if (project == null || project.isActive == false) {
      return _jsonResponse(404, {'error': 'Project not found: $clientSlug/$projectSlug'});
    }

    if (!_canDeployProject(auth.scopes, project.id)) {
      return _jsonResponse(403, {
        'error': 'Insufficient permissions to deploy this project',
      });
    }

    // Try to attribute the upload to a real User row when the caller is a
    // signed-in human (JWT). API-token callers (CI) and the cloud-admin key
    // have no User row — leave uploadedByUserId null.
    UuidValue? uploadedByUserId;
    if (!auth.userIdentifier.startsWith('api-token:') &&
        auth.userIdentifier != 'cloud-admin') {
      try {
        final user = await resolveUser(session, clientId: project.clientId);
        uploadedByUserId = user.id;
      } catch (_) {
        // No user row — leave null.
      }
    }

    // Read request body up to the size limit.
    final builder = BytesBuilder(copy: false);
    var total = 0;
    await for (final chunk in request.body.read()) {
      total += chunk.length;
      if (total > _maxBodyBytes) {
        return _jsonResponse(413, {'error': 'Bundle exceeds 100 MB limit'});
      }
      builder.add(chunk);
    }
    final bytes = builder.takeBytes();
    if (bytes.isEmpty) {
      return _jsonResponse(400, {'error': 'Empty body'});
    }

    // Decompress gzip.
    final List<int> tarBytes;
    try {
      tarBytes = GZipDecoder().decodeBytes(bytes);
    } catch (_) {
      return _jsonResponse(400, {'error': 'Invalid gzip'});
    }

    // Decode tar.
    final Archive archive;
    try {
      archive = TarDecoder().decodeBytes(tarBytes);
    } catch (_) {
      return _jsonResponse(400, {'error': 'Invalid tar'});
    }

    // Pre-validate every entry path before touching the DB or storage.
    final entries = <_BundleEntry>[];
    for (final entry in archive) {
      if (!entry.isFile) continue;
      final normalized = p.posix.normalize(entry.name);
      if (normalized.startsWith('..') ||
          normalized.startsWith('/') ||
          normalized.contains('/../')) {
        return _jsonResponse(400, {'error': 'Unsafe path in archive: ${entry.name}'});
      }
      entries.add(_BundleEntry(normalized, entry.content as List<int>));
    }

    // Insert DB row first to obtain a stable id, then upload files. If any
    // upload fails after the row is inserted we mark it failed (rather than
    // try to roll back partial S3 writes).
    final Deployment inserted = await session.db.transaction((txn) async {
      final latestDeployment = await Deployment.db.findFirstRow(
        session,
        where: (t) => t.projectId.equals(project.id),
        orderBy: (t) => t.version,
        orderDescending: true,
        transaction: txn,
      );
      final nextVersion = (latestDeployment?.version ?? 0) + 1;

      final currentActive = await Deployment.db.findFirstRow(
        session,
        where: (t) =>
            t.projectId.equals(project.id) &
            t.status.equals(DeploymentStatus.active),
        transaction: txn,
      );
      if (currentActive != null) {
        await Deployment.db.updateRow(
          session,
          currentActive.copyWith(
            status: DeploymentStatus.inactive,
            updatedAt: DateTime.now().toUtc(),
          ),
          transaction: txn,
        );
      }

      return Deployment.db.insertRow(
        session,
        Deployment(
          projectId: project.id,
          version: nextVersion,
          status: DeploymentStatus.active,
          filePath: '', // set after upload succeeds
          fileSize: bytes.length,
          uploadedByUserId: uploadedByUserId,
          commitHash: commitHash,
          createdAt: DateTime.now().toUtc(),
          updatedAt: DateTime.now().toUtc(),
        ),
        transaction: txn,
      );
    });

    final bundlePrefix = p.posix.join(_bundleRoot, inserted.id.uuid);
    try {
      for (final entry in entries) {
        final storagePath = p.posix.join(bundlePrefix, entry.path);
        await session.storage.storeFile(
          storageId: _storageId,
          path: storagePath,
          byteData: ByteData.sublistView(Uint8List.fromList(entry.content)),
        );
      }
    } catch (e) {
      // Mark deployment failed so it doesn't shadow the previous active one.
      await Deployment.db.updateRow(
        session,
        inserted.copyWith(
          status: DeploymentStatus.inactive,
          updatedAt: DateTime.now().toUtc(),
        ),
      );
      session.log('Deployment upload failed: $e', level: LogLevel.error);
      return _jsonResponse(500, {'error': 'Failed to upload bundle'});
    }

    final newDeployment = await Deployment.db.updateRow(
      session,
      inserted.copyWith(
        filePath: bundlePrefix,
        updatedAt: DateTime.now().toUtc(),
      ),
    );

    session.log(
      'Uploaded Deployment id=${newDeployment.id} '
      'project=$clientSlug/$projectSlug '
      'version=${newDeployment.version} '
      'bytes=${bytes.length} '
      'files=${entries.length}',
      level: LogLevel.info,
    );

    return _jsonResponse(200, {
      'version': newDeployment.version,
      'url': 'https://${project.deployHostname}.app.dartdesk.dev',
    });
  }

  bool _canDeployProject(Set<Scope> scopes, UuidValue projectId) {
    final hasProject = scopes.contains(Scope('project:${projectId.uuid}'));
    final hasWrite = scopes.contains(const Scope('project.write'));
    final isAdmin = scopes.contains(const Scope('admin'));
    return isAdmin || (hasProject && hasWrite);
  }

  Response _jsonResponse(int status, Map<String, dynamic> body) {
    return Response(
      status,
      body: Body.fromString(
        jsonEncode(body),
        mimeType: MimeType.json,
      ),
    );
  }
}

class _BundleEntry {
  final String path;
  final List<int> content;
  _BundleEntry(this.path, this.content);
}
