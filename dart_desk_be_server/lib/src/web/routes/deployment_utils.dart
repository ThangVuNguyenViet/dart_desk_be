import 'dart:io';

import 'package:mime/mime.dart' as mime_pkg;
import 'package:serverpod/serverpod.dart';

import '../../generated/protocol.dart';
/// In-memory cache entry for active version lookups.
class CacheEntry {
  final int? activeVersion;
  final DateTime expiresAt;

  CacheEntry(this.activeVersion, this.expiresAt);

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}

/// Get active version for a slug, with caching.
Future<int?> getActiveVersion(
  Session session,
  String slug,
  Map<String, CacheEntry> cache,
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
    cache[slug] = CacheEntry(null, DateTime.now().add(cacheTtl));
    return null;
  }

  final deployment = await CmsDeployment.db.findFirstRow(
    session,
    where: (t) =>
        t.clientId.equals(client.id!) &
        t.status.equals(DeploymentStatus.active),
  );

  final version = deployment?.version;
  cache[slug] = CacheEntry(version, DateTime.now().add(cacheTtl));
  return version;
}

/// Serve a static file with appropriate MIME type.
Response serveFile(File file) {
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
String notFoundPage(String slug) {
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
