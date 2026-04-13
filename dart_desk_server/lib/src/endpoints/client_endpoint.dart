import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';

class ClientEndpoint extends Endpoint {
  /// Returns all active clients the authenticated user belongs to,
  /// along with their role in each client and the project count.
  Future<List<ClientWithRole>> getClientsForUser(Session session) async {
    final auth = session.authenticated;
    if (auth == null) {
      throw Exception('User must be authenticated');
    }

    // Find all User rows for this serverpod identity
    final userRows = await User.db.find(
      session,
      where: (t) =>
          t.serverpodUserId.equals(auth.userIdentifier) &
          t.isActive.equals(true),
    );

    if (userRows.isEmpty) return [];

    // Collect distinct clientIds
    final clientIds = userRows
        .where((u) => u.clientId != null)
        .map((u) => u.clientId!)
        .toSet()
        .toList();

    if (clientIds.isEmpty) return [];

    // Fetch active CmsClient rows
    final clients = await CmsClient.db.find(
      session,
      where: (t) =>
          t.id.inSet(clientIds.toSet()) & t.isActive.equals(true),
      orderBy: (t) => t.name,
    );

    // Build result with role and project count per client
    final results = <ClientWithRole>[];
    for (final client in clients) {
      final userRow = userRows.firstWhere(
        (u) => u.clientId == client.id,
      );

      final projectCount = await Project.db.count(
        session,
        where: (t) =>
            t.clientId.equals(client.id) & t.isActive.equals(true),
      );

      results.add(ClientWithRole(
        client: client,
        role: userRow.role,
        projectCount: projectCount,
      ));
    }

    return results;
  }
}
