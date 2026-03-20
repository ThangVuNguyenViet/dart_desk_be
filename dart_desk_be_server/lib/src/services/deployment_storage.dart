import 'dart:io';

import 'package:archive/archive.dart';
import 'package:path/path.dart' as p;

/// Abstract interface for deployment file storage.
abstract class DeploymentStorage {
  /// Store a tar.gz archive for the given client slug and version.
  /// Extracts contents and returns the total size in bytes.
  Future<int> store(String slug, int version, List<int> tarGzBytes);

  /// Get a file from a deployed version. Returns null if not found.
  /// [filePath] is relative to the deployment root (e.g. "index.html").
  File? getFile(String slug, int version, String filePath);

  /// Delete all files for a given client slug and version.
  Future<void> delete(String slug, int version);
}

/// Local filesystem implementation of [DeploymentStorage].
/// Stores extracted files at `storage/deployments/{slug}/v{version}/`.
class LocalDeploymentStorage extends DeploymentStorage {
  final String basePath;

  LocalDeploymentStorage({this.basePath = 'storage/deployments'});

  String _versionDir(String slug, int version) =>
      p.join(basePath, slug, 'v$version');

  @override
  Future<int> store(String slug, int version, List<int> tarGzBytes) async {
    final dir = Directory(_versionDir(slug, version));
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
    await dir.create(recursive: true);

    // Decode tar.gz
    final gzDecoded = GZipDecoder().decodeBytes(tarGzBytes);
    final archive = TarDecoder().decodeBytes(gzDecoded);

    var totalSize = 0;

    for (final file in archive) {
      if (file.isFile) {
        final filePath = _sanitizePath(file.name);
        if (filePath == null) continue; // Skip path traversal attempts

        final outFile = File(p.join(dir.path, filePath));
        await outFile.parent.create(recursive: true);
        await outFile.writeAsBytes(file.content as List<int>);
        totalSize += file.size;
      }
    }

    return totalSize;
  }

  @override
  File? getFile(String slug, int version, String filePath) {
    final sanitized = _sanitizePath(filePath);
    if (sanitized == null) return null;

    final versionDir = _versionDir(slug, version);
    final file = File(p.join(versionDir, sanitized));
    if (!file.existsSync()) return null;

    // Double-check the resolved path is within the version directory
    final resolvedPath = file.resolveSymbolicLinksSync();
    final resolvedBase = Directory(versionDir).resolveSymbolicLinksSync();
    if (!resolvedPath.startsWith(resolvedBase)) {
      return null; // Path traversal attempt
    }

    return file;
  }

  @override
  Future<void> delete(String slug, int version) async {
    final dir = Directory(_versionDir(slug, version));
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
  }

  /// Sanitize a file path to prevent directory traversal.
  /// Returns null if the path is suspicious.
  String? _sanitizePath(String path) {
    // Normalize and remove leading slashes
    var normalized = p.normalize(path);
    normalized = normalized.replaceAll(RegExp(r'^[/\\]+'), '');

    // Reject paths that try to escape
    if (normalized.contains('..') ||
        normalized.startsWith('/') ||
        normalized.startsWith('\\') ||
        p.isAbsolute(normalized)) {
      return null;
    }

    return normalized;
  }
}
