import 'dart:convert';

import 'package:serverpod/serverpod.dart';

class HealthEndpoint extends Endpoint {
  @override
  bool get requireLogin => false;

  Future<String> check(Session session) async {
    final checks = <String, dynamic>{};

    // Database check
    try {
      await session.db.unsafeQuery('SELECT 1');
      checks['database'] = 'ok';
    } catch (e) {
      checks['database'] = 'error: $e';
    }

    checks['timestamp'] = DateTime.now().toIso8601String();
    return jsonEncode(checks);
  }
}
