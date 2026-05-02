import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:serverpod/serverpod.dart';

import '../../db/repositories/project_repository.dart'
    as project_repo;
import '../../generated/protocol.dart';
import 'subdomain_router.dart';

/// Serves Flutter web bundles for `*.<domain>` hostnames.
///
/// Route: `/*` (GET / HEAD).
///
/// Resolution order:
/// 1. Extract subdomain label from `Host` header. If none → 404.
/// 2. Look up `Project` by `deployHostname`. If none → 404.
/// 3. Find active `Deployment` for that project. If none → 404.
/// 4. Serve the requested file from `deployment.filePath/<path>`.
/// 5. For paths with no extension (SPA routes), fall back to `index.html`.
/// 6. Otherwise → 404.
class StudioRoute extends Route {
  final String domain;

  StudioRoute({required this.domain})
      : super(
          methods: {Method.get, Method.head},
          path: '/*',
        );

  @override
  FutureOr<Result> handleCall(Session session, Request request) async {
    // Extract the Host header value as a raw string (host + optional port).
    final hostHeader = request.headers.host;
    if (hostHeader == null) return _notFound();

    // Reconstruct the full host[:port] string for extractSubdomain.
    final rawHost = hostHeader.port != null
        ? '${hostHeader.host}:${hostHeader.port}'
        : hostHeader.host;

    final hostname = extractSubdomain(rawHost, domain);
    if (hostname == null) return _notFound();

    final project =
        await project_repo.ProjectRepository.findByDeployHostname(session, hostname);
    if (project == null) return _notFound();

    final active = await Deployment.db.findFirstRow(
      session,
      where: (t) =>
          t.projectId.equals(project.id!) &
          t.status.equals(DeploymentStatus.active),
    );
    if (active == null) return _notFound();

    final reqPath = request.url.path; // e.g. "/main.dart.js" or "/"
    final safePath = _safeRelative(reqPath);
    if (safePath == null) return _notFound();

    final body = await _readAsset(active.filePath, safePath);
    if (body != null) {
      return _bodyResponse(body, _mimeTypeFor(safePath));
    }

    // SPA fallback: only for extension-free, top-level paths (likely a
    // client-side route). Paths with directory separators are treated as
    // missing assets rather than SPA routes.
    if (!_looksLikeAsset(safePath) && !safePath.contains(p.separator)) {
      final fallback = await _readAsset(active.filePath, 'index.html');
      if (fallback != null) {
        return _bodyResponse(fallback, MimeType.html);
      }
    }

    return _notFound();
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Converts [reqPath] to a safe relative path, or returns null for traversal.
  String? _safeRelative(String reqPath) {
    var rel = reqPath.startsWith('/') ? reqPath.substring(1) : reqPath;
    if (rel.isEmpty) rel = 'index.html';
    final normalized = p.normalize(rel);
    if (normalized.startsWith('..') || p.isAbsolute(normalized)) return null;
    return normalized;
  }

  Future<List<int>?> _readAsset(String bundleDir, String relPath) async {
    final file = File(p.join(bundleDir, relPath));
    if (!await file.exists()) return null;
    return file.readAsBytes();
  }

  bool _looksLikeAsset(String path) => p.extension(path).isNotEmpty;

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

  Response _bodyResponse(List<int> body, MimeType contentType) {
    return Response(
      200,
      body: Body.fromData(
        Uint8List.fromList(body),
        mimeType: contentType,
      ),
    );
  }
}
