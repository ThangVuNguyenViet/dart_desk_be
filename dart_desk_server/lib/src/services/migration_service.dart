import 'package:uuid/uuid.dart';

/// Represents a single migration operation.
class MigrationOperation {
  final String type; // 'renameField', 'deleteField', 'setField'
  final String? from;
  final String? to;
  final String? path;
  final dynamic value;

  MigrationOperation({
    required this.type,
    this.from,
    this.to,
    this.path,
    this.value,
  });

  factory MigrationOperation.fromJson(Map<String, dynamic> json) {
    return MigrationOperation(
      type: json['type'] as String,
      from: json['from'] as String?,
      to: json['to'] as String?,
      path: json['path'] as String?,
      value: json['value'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      if (from != null) 'from': from,
      if (to != null) 'to': to,
      if (path != null) 'path': path,
      if (value != null) 'value': value,
    };
  }
}

/// Result of applying operations to a single document.
class DocumentMigrationResult {
  final UuidValue documentId;
  final String title;
  final String status; // 'modified' or 'skipped'
  final List<String> changes;
  final String? reason; // reason for skip
  final Map<String, dynamic>? newData; // null if skipped

  DocumentMigrationResult({
    required this.documentId,
    required this.title,
    required this.status,
    this.changes = const [],
    this.reason,
    this.newData,
  });

  Map<String, dynamic> toJson() => {
        'documentId': documentId.toString(),
        'title': title,
        'status': status,
        'changes': changes,
        if (reason != null) 'reason': reason,
      };
}

/// Applies migration operations to document data maps.
/// Pure logic — no database access.
class MigrationService {
  /// Apply a list of operations to a document's data.
  DocumentMigrationResult applyOperations({
    required UuidValue documentId,
    required String title,
    required Map<String, dynamic> data,
    required List<MigrationOperation> operations,
  }) {
    final flatData = _flattenMap(data);
    final changes = <String>[];
    var modified = false;

    for (final op in operations) {
      switch (op.type) {
        case 'renameField':
          final result = _applyRename(flatData, op.from!, op.to!);
          if (result != null) {
            changes.add(result);
            modified = true;
          }
        case 'deleteField':
          final result = _applyDelete(flatData, op.path!);
          if (result != null) {
            changes.add(result);
            modified = true;
          }
        case 'setField':
          final result = _applySet(flatData, op.path!, op.value);
          changes.add(result);
          modified = true;
      }
    }

    if (!modified) {
      return DocumentMigrationResult(
        documentId: documentId,
        title: title,
        status: 'skipped',
        reason: 'no matching fields found',
      );
    }

    return DocumentMigrationResult(
      documentId: documentId,
      title: title,
      status: 'modified',
      changes: changes,
      newData: _unflattenMap(flatData),
    );
  }

  String? _applyRename(Map<String, dynamic> flat, String from, String to) {
    final keysToRename = flat.keys
        .where((k) => k == from || k.startsWith('$from.'))
        .toList();
    if (keysToRename.isEmpty) return null;
    for (final key in keysToRename) {
      final newKey = to + key.substring(from.length);
      flat[newKey] = flat[key];
      flat.remove(key);
    }
    return 'renameField: $from -> $to';
  }

  String? _applyDelete(Map<String, dynamic> flat, String path) {
    final keysToDelete = flat.keys
        .where((k) => k == path || k.startsWith('$path.'))
        .toList();
    if (keysToDelete.isEmpty) return null;
    for (final key in keysToDelete) {
      flat.remove(key);
    }
    return 'deleteField: $path';
  }

  String _applySet(Map<String, dynamic> flat, String path, dynamic value) {
    flat[path] = value;
    return 'setField: $path = $value';
  }

  Map<String, dynamic> _flattenMap(Map<String, dynamic> map, [String prefix = '']) {
    final result = <String, dynamic>{};
    for (var entry in map.entries) {
      final key = prefix.isEmpty ? entry.key : '$prefix.${entry.key}';
      if (entry.value is Map<String, dynamic>) {
        result.addAll(_flattenMap(entry.value as Map<String, dynamic>, key));
      } else {
        result[key] = entry.value;
      }
    }
    return result;
  }

  Map<String, dynamic> _unflattenMap(Map<String, dynamic> flat) {
    final result = <String, dynamic>{};
    for (var entry in flat.entries) {
      final keys = entry.key.split('.');
      dynamic current = result;
      for (var i = 0; i < keys.length - 1; i++) {
        if (current is! Map<String, dynamic>) break;
        current[keys[i]] ??= <String, dynamic>{};
        current = current[keys[i]];
      }
      if (current is Map<String, dynamic>) {
        current[keys.last] = entry.value;
      }
    }
    return result;
  }
}
