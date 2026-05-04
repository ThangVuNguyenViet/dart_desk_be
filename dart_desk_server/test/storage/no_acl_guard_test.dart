import 'dart:io';

import 'package:test/test.dart';

void main() {
  test('no Dart source under lib/ contains x-amz-acl or public-read', () {
    final libDir = Directory('lib');
    expect(libDir.existsSync(), isTrue,
        reason: 'Test must run from package root');

    final pattern = RegExp(
      r'(x-amz-acl|public-read)',
      caseSensitive: false,
    );

    final hits = <String>[];
    for (final entity in libDir.listSync(recursive: true)) {
      if (entity is! File) continue;
      if (!entity.path.endsWith('.dart')) continue;
      final lines = entity.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        if (pattern.hasMatch(lines[i])) {
          hits.add('${entity.path}:${i + 1}: ${lines[i].trim()}');
        }
      }
    }

    expect(
      hits,
      isEmpty,
      reason:
          'Found ACL-related strings in source. The S3 bucket has '
          'BucketOwnerEnforced; ACL headers cause AccessControlListNotSupported. '
          'Public read is granted by bucket policy. Hits:\n'
          '${hits.join('\n')}',
    );
  });
}
