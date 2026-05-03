// Integration tests for StudioRoute.
//
// Constructs Relic [Request] objects via [RequestInternal.create] (the same
// technique used by deployment_upload_route_test.dart) and calls
// `route.handleCall` directly — no HTTP server is required.

import 'dart:convert';
import 'dart:typed_data';

import 'package:dart_desk_server/src/generated/protocol.dart';
import 'package:dart_desk_server/src/web/routes/studio_route.dart';
import 'package:path/path.dart' as p;
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

import 'helpers/test_data_factory.dart';
import 'test_tools/serverpod_test_tools.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Build a Relic [Request] with a custom [host] header value.
Request _buildRequest({
  required String host,
  String path = '/',
}) {
  final url = Uri.parse('http://$host$path');
  final headers = Headers.build((h) {
    h.host = HostHeader(host);
  });
  return RequestInternal.create(
    Method.get,
    url,
    Object(),
    headers: headers,
  );
}

/// Read body bytes from a [Response].
Future<List<int>> _readBody(Response response) async {
  return response.body.read().expand((b) => b).toList();
}

/// Seed a deployment bundle into the `public` cloud storage and return the
/// bundle prefix (the value to set on `Deployment.filePath`).
///
/// `StudioRoute` reads bundle assets via `session.storage.retrieveFile`
/// (S3 in prod, DB-backed in tests) keyed at `<filePath>/<rel>`.
Future<String> _seedBundle(
  Session session, {
  required Map<String, String> files,
}) async {
  final prefix = 'deployments/${const Uuid().v4()}';
  for (final entry in files.entries) {
    final bytes = Uint8List.fromList(utf8.encode(entry.value));
    await session.storage.storeFile(
      storageId: 'public',
      path: p.posix.join(prefix, entry.key),
      byteData: ByteData.sublistView(bytes),
    );
  }
  return prefix;
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  withServerpod('StudioRoute', (sessionBuilder, endpoints) {
    late TestDataFactory factory;

    setUp(() async {
      factory = TestDataFactory(
        sessionBuilder: sessionBuilder,
        endpoints: endpoints,
      );
      await factory.ensureTestClient();
    });

    // -----------------------------------------------------------------------
    // Happy path: index.html
    // -----------------------------------------------------------------------

    test('GET /index.html on acme-demo.app.dartdesk.dev returns 200 text/html',
        () async {
      final session = sessionBuilder.build();
      const hostname = 'acme-demo';
      const domain = 'app.dartdesk.dev';

      final project = await Project.db.insertRow(
        session,
        Project(
          clientId: TestDataFactory.testClientId,
          name: 'Acme Demo',
          slug: 'acme-demo',
          deployHostname: hostname,
          isActive: true,
        ),
      );

      const indexContent = '<html>hello</html>';
      final bundlePrefix = await _seedBundle(
        session,
        files: {'index.html': indexContent},
      );

      final deployment = await Deployment.db.insertRow(
        session,
        Deployment(
          projectId: project.id,
          version: 1,
          status: DeploymentStatus.active,
          filePath: bundlePrefix,
          fileSize: indexContent.length,
          createdAt: DateTime.now().toUtc(),
          updatedAt: DateTime.now().toUtc(),
        ),
      );
      addTearDown(() async {
        await Deployment.db.deleteRow(session, deployment);
        await Project.db.deleteRow(session, project);
      });

      final route = StudioRoute(domain: domain);
      final request = _buildRequest(
        host: '$hostname.$domain',
        path: '/index.html',
      );
      final result = await route.handleCall(session, request);
      final response = result as Response;

      expect(response.statusCode, equals(200));
      final body = await _readBody(response);
      expect(String.fromCharCodes(body), equals(indexContent));
      expect(response.body.bodyType?.mimeType.primaryType, equals('text'));
      expect(response.body.bodyType?.mimeType.subType, equals('html'));
    });

    // -----------------------------------------------------------------------
    // Asset fetch: main.dart.js
    // -----------------------------------------------------------------------

    test('GET /main.dart.js returns 200 application/javascript', () async {
      final session = sessionBuilder.build();
      const hostname = 'js-test';
      const domain = 'app.dartdesk.dev';

      final project = await Project.db.insertRow(
        session,
        Project(
          clientId: TestDataFactory.testClientId,
          name: 'JS Test',
          slug: 'js-test',
          deployHostname: hostname,
          isActive: true,
        ),
      );

      const jsContent = 'var x = 1;';
      final bundlePrefix = await _seedBundle(
        session,
        files: {'main.dart.js': jsContent},
      );

      final deployment = await Deployment.db.insertRow(
        session,
        Deployment(
          projectId: project.id,
          version: 1,
          status: DeploymentStatus.active,
          filePath: bundlePrefix,
          fileSize: jsContent.length,
          createdAt: DateTime.now().toUtc(),
          updatedAt: DateTime.now().toUtc(),
        ),
      );
      addTearDown(() async {
        await Deployment.db.deleteRow(session, deployment);
        await Project.db.deleteRow(session, project);
      });

      final route = StudioRoute(domain: domain);
      final request = _buildRequest(
        host: '$hostname.$domain',
        path: '/main.dart.js',
      );
      final result = await route.handleCall(session, request);
      final response = result as Response;

      expect(response.statusCode, equals(200));
      expect(response.body.bodyType?.mimeType.subType, equals('javascript'));
    });

    // -----------------------------------------------------------------------
    // SPA fallback
    // -----------------------------------------------------------------------

    test('GET /some-route falls back to index.html (top-level SPA route)', () async {
      final session = sessionBuilder.build();
      const hostname = 'spa-test';
      const domain = 'app.dartdesk.dev';

      final project = await Project.db.insertRow(
        session,
        Project(
          clientId: TestDataFactory.testClientId,
          name: 'SPA Test',
          slug: 'spa-test',
          deployHostname: hostname,
          isActive: true,
        ),
      );

      const indexContent = '<html>spa</html>';
      final bundlePrefix = await _seedBundle(
        session,
        files: {'index.html': indexContent},
      );

      final deployment = await Deployment.db.insertRow(
        session,
        Deployment(
          projectId: project.id,
          version: 1,
          status: DeploymentStatus.active,
          filePath: bundlePrefix,
          fileSize: indexContent.length,
          createdAt: DateTime.now().toUtc(),
          updatedAt: DateTime.now().toUtc(),
        ),
      );
      addTearDown(() async {
        await Deployment.db.deleteRow(session, deployment);
        await Project.db.deleteRow(session, project);
      });

      final route = StudioRoute(domain: domain);
      final request = _buildRequest(
        host: '$hostname.$domain',
        path: '/some-route',
      );
      final result = await route.handleCall(session, request);
      final response = result as Response;

      expect(response.statusCode, equals(200));
      final body = await _readBody(response);
      expect(String.fromCharCodes(body), equals(indexContent));
    });

    test('GET /dashboard/settings falls back to index.html (deep SPA route)',
        () async {
      final session = sessionBuilder.build();
      const hostname = 'deep-spa-test';
      const domain = 'app.dartdesk.dev';

      final project = await Project.db.insertRow(
        session,
        Project(
          clientId: TestDataFactory.testClientId,
          name: 'Deep SPA Test',
          slug: 'deep-spa-test',
          deployHostname: hostname,
          isActive: true,
        ),
      );

      const indexContent = '<html>deep spa</html>';
      final bundlePrefix = await _seedBundle(
        session,
        files: {'index.html': indexContent},
      );

      final deployment = await Deployment.db.insertRow(
        session,
        Deployment(
          projectId: project.id,
          version: 1,
          status: DeploymentStatus.active,
          filePath: bundlePrefix,
          fileSize: indexContent.length,
          createdAt: DateTime.now().toUtc(),
          updatedAt: DateTime.now().toUtc(),
        ),
      );
      addTearDown(() async {
        await Deployment.db.deleteRow(session, deployment);
        await Project.db.deleteRow(session, project);
      });

      final route = StudioRoute(domain: domain);
      final request = _buildRequest(
        host: '$hostname.$domain',
        path: '/dashboard/settings',
      );
      final result = await route.handleCall(session, request);
      final response = result as Response;

      expect(response.statusCode, equals(200));
      final body = await _readBody(response);
      expect(String.fromCharCodes(body), equals(indexContent));
    });

    // -----------------------------------------------------------------------
    // Unknown subdomain → 404
    // -----------------------------------------------------------------------

    test('Unknown subdomain returns 404', () async {
      final session = sessionBuilder.build();
      const domain = 'app.dartdesk.dev';

      final route = StudioRoute(domain: domain);
      final request = _buildRequest(
        host: 'no-such-site.$domain',
        path: '/',
      );
      final result = await route.handleCall(session, request);
      final response = result as Response;

      expect(response.statusCode, equals(404));
    });

    // -----------------------------------------------------------------------
    // Project exists but no active deployment → 404
    // -----------------------------------------------------------------------

    test('Project with no active deployment returns 404', () async {
      final session = sessionBuilder.build();
      const hostname = 'no-deploy';
      const domain = 'app.dartdesk.dev';

      final project = await Project.db.insertRow(
        session,
        Project(
          clientId: TestDataFactory.testClientId,
          name: 'No Deploy',
          slug: 'no-deploy',
          deployHostname: hostname,
          isActive: true,
        ),
      );
      addTearDown(() async {
        await Project.db.deleteRow(session, project);
      });

      final route = StudioRoute(domain: domain);
      final request = _buildRequest(
        host: '$hostname.$domain',
        path: '/',
      );
      final result = await route.handleCall(session, request);
      final response = result as Response;

      expect(response.statusCode, equals(404));
    });

    // -----------------------------------------------------------------------
    // Path normalization and SPA fallback
    // -----------------------------------------------------------------------

    test('Path traversal /../etc/passwd is normalized and falls back to index.html',
        () async {
      final session = sessionBuilder.build();
      const hostname = 'traversal-test';
      const domain = 'app.dartdesk.dev';

      final project = await Project.db.insertRow(
        session,
        Project(
          clientId: TestDataFactory.testClientId,
          name: 'Traversal Test',
          slug: 'traversal-test',
          deployHostname: hostname,
          isActive: true,
        ),
      );

      const indexContent = '<html>spa</html>';
      final bundlePrefix = await _seedBundle(
        session,
        files: {'index.html': indexContent},
      );

      final deployment = await Deployment.db.insertRow(
        session,
        Deployment(
          projectId: project.id,
          version: 1,
          status: DeploymentStatus.active,
          filePath: bundlePrefix,
          fileSize: indexContent.length,
          createdAt: DateTime.now().toUtc(),
          updatedAt: DateTime.now().toUtc(),
        ),
      );
      addTearDown(() async {
        await Deployment.db.deleteRow(session, deployment);
        await Project.db.deleteRow(session, project);
      });

      final route = StudioRoute(domain: domain);
      // The HTTP layer normalizes /../etc/passwd to /etc/passwd before it
      // reaches the handler. Since /etc/passwd doesn't exist in the bundle
      // and has no extension, it falls back to index.html (SPA route behavior).
      final request = _buildRequest(
        host: '$hostname.$domain',
        path: '/../etc/passwd',
      );
      final result = await route.handleCall(session, request);
      final response = result as Response;

      expect(response.statusCode, equals(200));
      final body = await _readBody(response);
      expect(String.fromCharCodes(body), equals(indexContent));
    });
  });
}
