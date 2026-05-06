import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;
import 'package:serverpod/serverpod.dart';

import '../../db/repositories/project_repository.dart' as project_repo;
import '../../generated/protocol.dart';
import 'subdomain_router.dart';

/// Serves Flutter web bundles for `*.<domain>` hostnames.
///
/// Route: registered as the WebServer fallback (GET / HEAD).
///
/// Resolution order:
/// 1. Extract subdomain label from `Host` header. If none → serve from
///    [staticFallback] if provided, otherwise 404.
/// 2. Look up `Project` by `deployHostname`. If none → 404.
/// 3. Find active `Deployment` for that project. If none → 404.
/// 4. Read the requested file from `<deployment.filePath>/<path>` in the
///    `public` cloud storage bucket (S3 in prod, local in dev).
/// 5. For paths with no extension (SPA routes), fall back to `index.html`.
/// 6. Otherwise → 404.
class StudioRoute extends Route {
  final String domain;
  final Directory? staticFallback;

  static const _storageId = 'public';

  StudioRoute({required this.domain, this.staticFallback})
      : super(methods: {Method.get, Method.head});

  @override
  FutureOr<Result> handleCall(Session session, Request request) async {
    final hostHeader = request.headers.host;
    final rawHost = hostHeader == null
        ? null
        : (hostHeader.port != null
            ? '${hostHeader.host}:${hostHeader.port}'
            : hostHeader.host);

    final hostname = rawHost == null ? null : extractSubdomain(rawHost, domain);
    if (hostname == null) return _serveStatic(request);

    final project = await project_repo.ProjectRepository.findByDeployHostname(
        session, hostname);
    if (project == null) return _notFound();

    final active = await Deployment.db.findFirstRow(
      session,
      where: (t) =>
          t.projectId.equals(project.id) &
          t.status.equals(DeploymentStatus.active),
    );
    if (active == null) return _notFound();

    final reqPath = request.url.path;
    final safePath = _safeRelative(reqPath);
    if (safePath == null) return _notFound();

    final isAsset = _looksLikeAsset(safePath);
    final etagRelPath = isAsset ? safePath : 'index.html';
    final etag = _etagFor(active.id.toString(), etagRelPath);
    final cacheControl = _cacheControlFor(safePath);

    final ifNoneMatch = request.headers['if-none-match'];
    if (ifNoneMatch != null) {
      for (final v in ifNoneMatch) {
        final trimmed = v.trim();
        if (trimmed == etag || trimmed == 'W/$etag' || trimmed == '*') {
          final headers = Headers.build((h) {
            h['cache-control'] = [cacheControl];
            h['etag'] = [etag];
          });
          return Response.notModified(headers: headers);
        }
      }
    }

    final body = await _readBundleAsset(session, active.filePath, safePath);
    if (body != null) {
      final headers = Headers.build((h) {
        h['cache-control'] = [cacheControl];
        h['etag'] = [etag];
      });
      return _bodyResponse(body, _mimeTypeFor(safePath), extraHeaders: headers);
    }

    if (!isAsset) {
      final fallbackEtag = _etagFor(active.id.toString(), 'index.html');
      final fallbackCache = _cacheControlFor('index.html');
      final fallbackHeaders = Headers.build((h) {
        h['cache-control'] = [fallbackCache];
        h['etag'] = [fallbackEtag];
      });
      final fallback =
          await _readBundleAsset(session, active.filePath, 'index.html');
      if (fallback != null) {
        return _bodyResponse(fallback, MimeType.html,
            extraHeaders: fallbackHeaders);
      }
    }

    return _notFound();
  }

  Future<Result> _serveStatic(Request request) async {
    final dir = staticFallback;
    if (dir == null) return _notFound();
    final safePath = _safeRelative(request.url.path);
    if (safePath == null) return _notFound();
    final file = File(p.join(dir.path, safePath));
    if (!await file.exists()) return _notFound();
    final body = await file.readAsBytes();
    final cacheControl = _cacheControlFor(safePath);
    final headers = Headers.build((h) {
      h['cache-control'] = [cacheControl];
    });
    return _bodyResponse(body, _mimeTypeFor(safePath), extraHeaders: headers);
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Converts [reqPath] to a safe relative path, or returns null for traversal.
  String? _safeRelative(String reqPath) {
    var rel = reqPath.startsWith('/') ? reqPath.substring(1) : reqPath;
    if (rel.isEmpty) rel = 'index.html';
    final normalized = p.posix.normalize(rel);
    if (normalized.startsWith('..') || normalized.startsWith('/')) return null;
    return normalized;
  }

  Future<List<int>?> _readBundleAsset(
    Session session,
    String bundlePrefix,
    String relPath,
  ) async {
    if (bundlePrefix.isEmpty) return null;
    final storagePath = p.posix.join(bundlePrefix, relPath);
    try {
      final data = await session.storage.retrieveFile(
        storageId: _storageId,
        path: storagePath,
      );
      if (data == null) return null;
      return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    } catch (_) {
      return null;
    }
  }

  bool _looksLikeAsset(String path) => p.extension(path).isNotEmpty;

  static final _contentHashRegex =
      RegExp(r'[0-9a-f]{8,}');

  String _cacheControlFor(String relPath) {
    final baseName = p.basename(relPath);
    if (baseName == 'index.html' || p.extension(relPath).isEmpty) {
      return 'public, max-age=0, must-revalidate';
    }
    if (baseName == 'flutter_service_worker.js') {
      return 'public, max-age=0, must-revalidate';
    }
    if (_contentHashRegex.hasMatch(baseName)) {
      return 'public, max-age=31536000, immutable';
    }
    return 'public, max-age=300';
  }

  String _etagFor(String deploymentId, String relPath) {
    final pathHash =
        sha1.convert(utf8.encode(relPath)).toString().substring(0, 16);
    return '"$deploymentId-$pathHash"';
  }

  MimeType _mimeTypeFor(String path) {
    if (path.endsWith('.html')) return MimeType.html;
    if (path.endsWith('.css')) return MimeType.css;
    if (path.endsWith('.js')) return MimeType.javascript;
    if (path.endsWith('.json')) return MimeType.json;
    if (path.endsWith('.png')) return MimeType.parse('image/png');
    if (path.endsWith('.svg')) return MimeType.parse('image/svg+xml');
    if (path.endsWith('.woff2')) return MimeType.parse('font/woff2');
    if (path.endsWith('.wasm')) return MimeType.parse('application/wasm');
    return MimeType.octetStream;
  }

  Response _notFound() {
    return Response(
      404,
      body: Body.fromString('Not found', mimeType: MimeType.plainText),
    );
  }

  Response _bodyResponse(List<int> body, MimeType contentType,
      {Headers? extraHeaders}) {
    return Response(
      200,
      body: Body.fromData(
        body is Uint8List ? body : Uint8List.fromList(body),
        mimeType: contentType,
      ),
      headers: extraHeaders ?? Headers.empty(),
    );
  }
}
