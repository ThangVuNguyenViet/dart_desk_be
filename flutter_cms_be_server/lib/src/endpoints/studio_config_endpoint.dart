import 'package:serverpod/serverpod.dart';

class StudioConfigEndpoint extends Endpoint {
  @override
  bool get requireLogin => false;

  /// Returns the studio URL template.
  /// Contains `{slug}` placeholder for the client to substitute.
  /// Dev: http://localhost:8082/preview/{slug}/
  /// Prod: https://{slug}.app.dartdesk.dev
  Future<String> getStudioUrlTemplate(Session session) async {
    final config = Serverpod.instance.config.webServer!;
    final scheme = config.publicScheme;
    final host = config.publicHost;
    final port = config.publicPort;

    // If host is localhost or 127.0.0.1, use path-based preview
    if (host == 'localhost' || host == '127.0.0.1') {
      final portSuffix = (scheme == 'http' && port == 80) ? '' : ':$port';
      return '$scheme://$host$portSuffix/preview/{slug}/';
    }

    // Cloud: use subdomain pattern {slug}.app.dartdesk.dev
    return '$scheme://{slug}.$host';
  }
}
