import 'dart:convert';

import 'package:dbcrypt/dbcrypt.dart';
import 'package:serverpod/serverpod.dart';

import '../../generated/protocol.dart';
import '../../services/deployment_storage.dart';

/// Maximum upload size: 100 MB.
const _maxUploadSize = 100 * 1024 * 1024;

/// Number of old versions to retain per client.
const _retentionCount = 10;

/// Route handler for deployment uploads.
/// POST /deployment/upload?slug=my-slug
/// Authorization: Bearer <api-token>
class DeploymentUploadRoute extends Route {
  final DeploymentStorage storage;

  DeploymentUploadRoute(this.storage) : super(methods: {Method.post});

  @override
  Future<Result> handleCall(Session session, Request request) async {
    try {
      // Extract slug from query params
      final slug = request.url.queryParameters['slug'];
      if (slug == null || slug.isEmpty) {
        return Response.badRequest(
          body: Body.fromString(jsonEncode({'error': 'Missing slug parameter'})),
        );
      }

      // Authenticate via Bearer token
      final authHeader = request.headers['authorization'];
      if (authHeader == null || !authHeader.startsWith('Bearer ')) {
        return Response.unauthorized(
          body: Body.fromString(jsonEncode({'error': 'Missing or invalid Authorization header'})),
        );
      }
      final rawToken = authHeader.substring(7);

      // Look up client
      final client = await CmsClient.db.findFirstRow(
        session,
        where: (t) => t.slug.equals(slug) & t.isActive.equals(true),
      );
      if (client == null) {
        return Response.notFound(
          body: Body.fromString(jsonEncode({'error': 'Client not found: $slug'})),
        );
      }

      // Validate API token against CmsApiToken table
      final apiToken = await _validateApiToken(session, client.id!, rawToken);
      if (apiToken == null) {
        return Response.unauthorized(
          body: Body.fromString(jsonEncode({'error': 'Invalid API token'})),
        );
      }
      if (apiToken.role != 'admin') {
        return Response.unauthorized(
          body: Body.fromString(jsonEncode({'error': 'Admin role required'})),
        );
      }

      // Stream and collect request body with size limit
      final bodyBytes = <int>[];
      await for (final chunk in request.body) {
        bodyBytes.addAll(chunk);
        if (bodyBytes.length > _maxUploadSize) {
          return Response.badRequest(
            body: Body.fromString(jsonEncode({
              'error': 'Upload exceeds maximum size of ${_maxUploadSize ~/ (1024 * 1024)}MB',
            })),
          );
        }
      }

      if (bodyBytes.isEmpty) {
        return Response.badRequest(
          body: Body.fromString(jsonEncode({'error': 'Empty request body'})),
        );
      }

      // Extract optional metadata from query params
      final commitHash = request.url.queryParameters['commitHash'];
      final metadata = request.url.queryParameters['metadata'];

      // Transaction: determine next version, create record, extract, activate
      late CmsDeployment deployment;

      await session.db.transaction((tx) async {
        // Determine next version number
        final latest = await CmsDeployment.db.findFirstRow(
          session,
          where: (t) => t.clientId.equals(client.id!),
          orderBy: (t) => t.version,
          orderDescending: true,
          transaction: tx,
        );
        final nextVersion = (latest?.version ?? 0) + 1;

        // Create deployment record in uploading state
        var record = CmsDeployment(
          clientId: client.id!,
          version: nextVersion,
          status: DeploymentStatus.uploading,
          filePath: 'storage/deployments/$slug/v$nextVersion',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        if (commitHash != null) record.commitHash = commitHash;
        if (metadata != null) record.metadata = metadata;

        record = await CmsDeployment.db.insertRow(session, record, transaction: tx);

        // Extract tar.gz
        final fileSize = await storage.store(slug, nextVersion, bodyBytes);

        // Deactivate currently active deployment
        final currentActive = await CmsDeployment.db.findFirstRow(
          session,
          where: (t) =>
              t.clientId.equals(client.id!) &
              t.status.equals(DeploymentStatus.active),
          transaction: tx,
        );
        if (currentActive != null) {
          await CmsDeployment.db.updateRow(
            session,
            currentActive.copyWith(
              status: DeploymentStatus.inactive,
              updatedAt: DateTime.now(),
            ),
            transaction: tx,
          );
        }

        // Activate new deployment
        deployment = record.copyWith(
          status: DeploymentStatus.active,
          fileSize: fileSize,
          updatedAt: DateTime.now(),
        );
        deployment = await CmsDeployment.db.updateRow(session, deployment, transaction: tx);
      });

      // Retention: delete old versions beyond limit
      await _enforceRetention(session, client.id!, slug);

      // Update token last used
      await CmsApiToken.db.updateRow(
        session,
        apiToken.copyWith(lastUsedAt: DateTime.now()),
      );

      return Response.ok(
        body: Body.fromString(jsonEncode({
          'version': deployment.version,
          'status': deployment.status.name,
          'url': 'https://$slug.fluttercms.cloud',
          'fileSize': deployment.fileSize,
        })),
      );
    } catch (e, st) {
      session.log('Deployment upload error: $e', level: LogLevel.error, stackTrace: st);
      return Response.internalServerError(
        body: Body.fromString(jsonEncode({'error': 'Upload failed: $e'})),
      );
    }
  }

  /// Validate a raw API token against the CmsApiToken table using bcrypt.
  Future<CmsApiToken?> _validateApiToken(
    Session session,
    int clientId,
    String rawToken,
  ) async {
    // Determine prefix (first 7 chars like "cms_ad_")
    if (rawToken.length < 8) return null;

    final prefix = rawToken.substring(0, 7);
    final suffix = rawToken.substring(rawToken.length - 4);

    // Look up by prefix+suffix for efficiency
    final candidates = await CmsApiToken.db.find(
      session,
      where: (t) =>
          t.clientId.equals(clientId) &
          t.tokenPrefix.equals(prefix) &
          t.tokenSuffix.equals(suffix) &
          t.isActive.equals(true),
    );

    for (final candidate in candidates) {
      // Check expiry
      if (candidate.expiresAt != null &&
          candidate.expiresAt!.isBefore(DateTime.now())) {
        continue;
      }

      // Bcrypt verify
      if (DBCrypt().checkpw(rawToken, candidate.tokenHash)) {
        return candidate;
      }
    }
    return null;
  }

  /// Remove old deployments beyond the retention count.
  Future<void> _enforceRetention(
    Session session,
    int clientId,
    String slug,
  ) async {
    final allDeployments = await CmsDeployment.db.find(
      session,
      where: (t) => t.clientId.equals(clientId),
      orderBy: (t) => t.version,
      orderDescending: true,
    );

    if (allDeployments.length <= _retentionCount) return;

    final toDelete = allDeployments.sublist(_retentionCount);
    for (final dep in toDelete) {
      if (dep.status == DeploymentStatus.active) continue; // Never delete active
      await storage.delete(slug, dep.version);
      await CmsDeployment.db.deleteRow(session, dep);
    }
  }
}
