import 'package:serverpod/serverpod.dart';

import '../../services/deployment_storage.dart';
import 'deployment_utils.dart';

/// Middleware that serves deployed static files based on subdomain.
/// Extracts slug from Host header ({slug}.app.dartdesk.dev).
/// Passes through for non-subdomain requests.
Middleware subdomainMiddleware({
  required DeploymentStorage storage,
  String domain = 'app.dartdesk.dev',
  Duration cacheTtl = const Duration(seconds: 60),
}) {
  final cache = <String, CacheEntry>{};

  return (Handler next) {
    return (Request request) async {
      // Extract host header
      final hostValues = request.headers['host'];
      final host = hostValues?.firstOrNull;
      if (host == null) return next(request);

      // Extract slug from subdomain
      final slug = _extractSlug(host, domain);
      if (slug == null) return next(request);

      // Create a session for DB access
      final session = await request.session;

      // Look up active version (cached)
      final activeVersion =
          await getActiveVersion(session, slug, cache, cacheTtl);
      if (activeVersion == null) {
        return Response.notFound(
          body: Body.fromString(
            notFoundPage(slug),
            mimeType: MimeType.html,
          ),
        );
      }

      // Determine requested file path
      var filePath = request.url.path;
      if (filePath.isEmpty || filePath == '/') {
        filePath = 'index.html';
      }
      // Remove leading slash
      if (filePath.startsWith('/')) {
        filePath = filePath.substring(1);
      }

      // Try to serve the requested file
      final file = storage.getFile(slug, activeVersion, filePath);
      if (file != null) {
        return serveFile(file);
      }

      // SPA fallback: serve index.html for non-file paths
      final indexFile = storage.getFile(slug, activeVersion, 'index.html');
      if (indexFile != null) {
        return serveFile(indexFile);
      }

      return Response.notFound(
        body: Body.fromString(
          notFoundPage(slug),
          mimeType: MimeType.html,
        ),
      );
    };
  };
}

/// Extract slug from host header. Returns null for non-subdomain requests.
String? _extractSlug(String host, String domain) {
  // Remove port if present
  final hostWithoutPort = host.split(':').first;

  // Check if it matches {slug}.{domain}
  if (!hostWithoutPort.endsWith('.$domain')) return null;

  final slug = hostWithoutPort.substring(
    0,
    hostWithoutPort.length - domain.length - 1,
  );

  // Validate slug (no dots, not empty)
  if (slug.isEmpty || slug.contains('.')) return null;

  return slug;
}
