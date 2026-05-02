import 'package:serverpod/serverpod.dart';
import 'package:dart_desk_server/src/generated/protocol.dart';

class ProjectRepository {
  static Future<Project?> findByClientAndSlug(
    Session session, {
    required UuidValue clientId,
    required String slug,
  }) async {
    return Project.db.findFirstRow(
      session,
      where: (t) =>
          t.clientId.equals(clientId) &
          t.slug.equals(slug) &
          t.deletedAt.equals(null),
    );
  }

  static Future<Project?> findByDeployHostname(
    Session session,
    String deployHostname,
  ) async {
    return Project.db.findFirstRow(
      session,
      where: (t) =>
          t.deployHostname.equals(deployHostname) & t.deletedAt.equals(null),
    );
  }
}
