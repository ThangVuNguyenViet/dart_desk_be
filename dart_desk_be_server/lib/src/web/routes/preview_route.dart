import 'package:serverpod/serverpod.dart';

import '../../services/deployment_storage.dart';
import 'deployment_utils.dart';

/// Route that handles GET /preview/{slug}/* for local studio preview.
/// Rewrites `<base href="/">` to `<base href="/preview/{slug}/">` in index.html
/// so Flutter web asset paths resolve correctly.
class PreviewRoute extends Route {
  final DeploymentStorage storage;
  final Duration cacheTtl;
  final _cache = <String, CacheEntry>{};

  PreviewRoute(this.storage, {this.cacheTtl = const Duration(seconds: 60)})
      : super(methods: {Method.get});

  @override
  Future<Result> handleCall(Session session, Request request) async {
    // URL path is like /preview/{slug}/path/to/file
    var path = request.url.path;
    if (path.startsWith('/')) path = path.substring(1);

    // Strip "preview/" prefix
    final segments = path.split('/');
    // segments: ["preview", slug, ...rest]
    if (segments.length < 2) {
      return Response.notFound(
        body: Body.fromString('Missing slug in preview URL'),
      );
    }

    final slug = segments[1];
    if (slug.isEmpty) {
      return Response.notFound(
        body: Body.fromString('Missing slug in preview URL'),
      );
    }

    // Look up active version
    final activeVersion =
        await getActiveVersion(session, slug, _cache, cacheTtl);
    if (activeVersion == null) {
      return Response.notFound(
        body: Body.fromString(
          notFoundPage(slug),
          mimeType: MimeType.html,
        ),
      );
    }

    // Determine requested file path (strip /preview/{slug}/ prefix)
    var filePath = segments.length > 2 ? segments.sublist(2).join('/') : '';
    if (filePath.isEmpty) {
      filePath = 'index.html';
    }

    // Try to serve the requested file
    final file = storage.getFile(slug, activeVersion, filePath);
    if (file != null) {
      // For index.html, rewrite <base href>
      if (filePath == 'index.html') {
        return _serveRewrittenIndex(file, slug);
      }
      return serveFile(file);
    }

    // SPA fallback: serve rewritten index.html for non-file paths
    final indexFile = storage.getFile(slug, activeVersion, 'index.html');
    if (indexFile != null) {
      return _serveRewrittenIndex(indexFile, slug);
    }

    return Response.notFound(
      body: Body.fromString(
        notFoundPage(slug),
        mimeType: MimeType.html,
      ),
    );
  }

  /// Serve index.html with `<base href="/">` rewritten to `<base href="/preview/{slug}/">`.
  Response _serveRewrittenIndex(dynamic file, String slug) {
    var html = file.readAsStringSync() as String;
    html = html.replaceFirst(
      '<base href="/">',
      '<base href="/preview/$slug/">',
    );

    return Response.ok(
      headers: Headers.build((h) {
        h['content-type'] = ['text/html; charset=utf-8'];
        h['cache-control'] = ['no-cache'];
      }),
      body: Body.fromString(html),
    );
  }
}
