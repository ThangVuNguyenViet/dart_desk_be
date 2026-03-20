import 'dart:io';

import 'package:mime/mime.dart' as mime_pkg;
import 'package:serverpod/serverpod.dart';

import '../../generated/protocol.dart';
import '../../services/deployment_storage.dart';

/// In-memory cache entry for active version lookups.
class _CacheEntry {
  final int? activeVersion;
  final DateTime expiresAt;

  _CacheEntry(this.activeVersion, this.expiresAt);

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}

/// Middleware that serves deployed static files based on subdomain.
/// Extracts slug from Host header ({slug}.dartdesk.dev).
/// Passes through for non-subdomain requests.
Middleware subdomainMiddleware({
  required DeploymentStorage storage,
  String domain = 'dartdesk.dev',
  Duration cacheTtl = const Duration(seconds: 60),
}) {
  final cache = <String, _CacheEntry>{};

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
          await _getActiveVersion(session, slug, cache, cacheTtl);
      if (activeVersion == null) {
        return Response.notFound(
          body: Body.fromString(
            _notFoundPage(slug),
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
        return _serveFile(file);
      }

      // SPA fallback: serve index.html for non-file paths
      final indexFile = storage.getFile(slug, activeVersion, 'index.html');
      if (indexFile != null) {
        return _serveFile(indexFile);
      }

      return Response.notFound(
        body: Body.fromString(
          _notFoundPage(slug),
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

/// Get active version for a slug, with caching.
Future<int?> _getActiveVersion(
  Session session,
  String slug,
  Map<String, _CacheEntry> cache,
  Duration cacheTtl,
) async {
  final cached = cache[slug];
  if (cached != null && !cached.isExpired) {
    return cached.activeVersion;
  }

  // Query database
  final client = await CmsClient.db.findFirstRow(
    session,
    where: (t) => t.slug.equals(slug) & t.isActive.equals(true),
  );
  if (client == null) {
    cache[slug] = _CacheEntry(null, DateTime.now().add(cacheTtl));
    return null;
  }

  final deployment = await CmsDeployment.db.findFirstRow(
    session,
    where: (t) =>
        t.clientId.equals(client.id!) &
        t.status.equals(DeploymentStatus.active),
  );

  final version = deployment?.version;
  cache[slug] = _CacheEntry(version, DateTime.now().add(cacheTtl));
  return version;
}

/// Serve a static file with appropriate MIME type.
Response _serveFile(File file) {
  final mimeTypeStr =
      mime_pkg.lookupMimeType(file.path) ?? 'application/octet-stream';
  final bytes = file.readAsBytesSync();

  return Response.ok(
    headers: Headers.build((h) {
      h['content-type'] = [mimeTypeStr];
      h['cache-control'] = ['public, max-age=3600'];
    }),
    body: Body.fromData(bytes),
  );
}

/// Branded 404 page for missing studios.
String _notFoundPage(String slug) {
  return '''<!DOCTYPE html>
<html>
<head><title>Not Found</title></head>
<body style="font-family: sans-serif; text-align: center; padding: 80px;">
  <h1>Studio Not Found</h1>
  <p>The studio <strong>$slug</strong> does not have an active deployment.</p>
  <p style="color: #666;">Powered by Flutter CMS</p>
</body>
</html>''';
}
