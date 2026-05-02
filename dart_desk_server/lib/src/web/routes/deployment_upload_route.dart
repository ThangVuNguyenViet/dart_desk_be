import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:path/path.dart' as p;
import 'package:serverpod/serverpod.dart';

import '../../auth/require_role.dart';
import '../../db/repositories/project_repository.dart' as repo;
import '../../generated/protocol.dart';

/// HTTP POST /deployment/upload?clientSlug=`<clientSlug>`&projectSlug=`<projectSlug>`[&commit=`<sha>`]
///
/// Accepts a gzipped tar of the Flutter web build, extracts it to
/// `storage/deployments/<deploymentId>/`, inserts a Deployment row, and
/// demotes the previously-active deployment to inactive.
///
/// Authentication: Bearer `<jwt-or-api-token>` via the standard Serverpod
/// authenticationHandler chain configured in server.dart.
///
/// Response 200:
///   `{"version": <int>, "url": "https://<deployHostname>.app.dartdesk.dev"}`
class DeploymentUploadRoute extends Route {
  static const _maxBodyBytes = 100 * 1024 * 1024; // 100 MB
  static const _bundleRoot = 'storage/deployments';

  DeploymentUploadRoute()
      : super(
          methods: {Method.post},
          path: '/deployment/upload',
        );

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

    // Require authentication (JWT or API key set by the authenticationHandler).
    if (session.authenticated == null) {
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

    final User user;
    try {
      user = await RoleGuard.requireRole(
        session,
        allowed: RoleGuard.destructiveRoles,
        clientId: project.clientId,
      );
    } on ApiException catch (e) {
      return _jsonResponse(e.code, {'error': e.message});
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

    // Insert DB row + extract files atomically (transaction rolls back on error).
    final Deployment newDeployment;
    try {
      newDeployment = await session.db.transaction((txn) async {
        // Determine next version number.
        final latestDeployment = await Deployment.db.findFirstRow(
          session,
          where: (t) => t.projectId.equals(project.id),
          orderBy: (t) => t.version,
          orderDescending: true,
          transaction: txn,
        );
        final nextVersion = (latestDeployment?.version ?? 0) + 1;

        // Demote any currently-active deployment.
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

        // Insert the Deployment row (auto-generates UUID id).
        final inserted = await Deployment.db.insertRow(
          session,
          Deployment(
            projectId: project.id,
            version: nextVersion,
            status: DeploymentStatus.active,
            // Temporary placeholder; updated below once we know the id.
            filePath: '',
            fileSize: bytes.length,
            uploadedByUserId: user.id,
            commitHash: commitHash,
            createdAt: DateTime.now().toUtc(),
            updatedAt: DateTime.now().toUtc(),
          ),
          transaction: txn,
        );

        // Derive stable directory path from the assigned id.
        final extractDir = p.join(_bundleRoot, inserted.id.uuid);

        // Extract archive files with zip-slip protection.
        final root = Directory(extractDir);
        await root.create(recursive: true);
        for (final entry in archive) {
          if (!entry.isFile) continue;
          final entryPath = p.normalize(entry.name);
          if (entryPath.startsWith('..') ||
              p.isAbsolute(entryPath) ||
              entryPath.contains('${p.separator}..${p.separator}')) {
            throw _UploadError(400, 'Unsafe path in archive: ${entry.name}');
          }
          final outFile = File(p.join(extractDir, entryPath));
          await outFile.parent.create(recursive: true);
          await outFile.writeAsBytes(entry.content as List<int>);
        }

        // Update filePath now that we have extracted the bundle.
        return Deployment.db.updateRow(
          session,
          inserted.copyWith(
            filePath: extractDir,
            updatedAt: DateTime.now().toUtc(),
          ),
          transaction: txn,
        );
      });
    } on _UploadError catch (e) {
      return _jsonResponse(e.code, {'error': e.message});
    }

    session.log(
      'Uploaded Deployment id=${newDeployment.id} '
      'project=$clientSlug/$projectSlug '
      'version=${newDeployment.version} '
      'bytes=${bytes.length}',
      level: LogLevel.info,
    );

    return _jsonResponse(200, {
      'version': newDeployment.version,
      'url': 'https://${project.deployHostname}.app.dartdesk.dev',
    });
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

class _UploadError implements Exception {
  final int code;
  final String message;
  _UploadError(this.code, this.message);
}
