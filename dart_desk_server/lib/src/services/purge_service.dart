import 'package:dart_desk_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';

class PurgeService {
  static DateTime cutoffDate({required int retentionDays}) {
    return DateTime.now().subtract(Duration(days: retentionDays));
  }

  /// Permanently deletes soft-deleted records older than [retentionDays].
  /// Deletes in FK-safe order: versions → documents → projects → users.
  static Future<int> purge(Session session, {required int retentionDays}) async {
    if (retentionDays < 0) return 0;

    final cutoff = cutoffDate(retentionDays: retentionDays);
    var count = 0;

    // 1. DocumentVersions
    final versions = await DocumentVersion.db.find(
      session,
      where: (t) => t.deletedAt.notEquals(null) & (t.deletedAt <= cutoff),
    );
    for (final v in versions) {
      await DocumentVersion.db.deleteRow(session, v);
      count++;
    }

    // 2. Documents (CRDT ops/snapshots cascade via FK)
    final docs = await Document.db.find(
      session,
      where: (t) => t.deletedAt.notEquals(null) & (t.deletedAt <= cutoff),
    );
    for (final d in docs) {
      await Document.db.deleteRow(session, d);
      count++;
    }

    // 3. Projects
    final projects = await Project.db.find(
      session,
      where: (t) => t.deletedAt.notEquals(null) & (t.deletedAt <= cutoff),
    );
    for (final p in projects) {
      await Project.db.deleteRow(session, p);
      count++;
    }

    // 4. Users
    final users = await User.db.find(
      session,
      where: (t) => t.deletedAt.notEquals(null) & (t.deletedAt <= cutoff),
    );
    for (final u in users) {
      await User.db.deleteRow(session, u);
      count++;
    }

    session.log('Purge complete: $count records permanently deleted (cutoff: $cutoff)', level: LogLevel.info);
    return count;
  }
}
