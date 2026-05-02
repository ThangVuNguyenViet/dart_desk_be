// Integration tests for StudioRoute.
//
// Constructs Relic [Request] objects via [RequestInternal.create] (the same
// technique used by deployment_upload_route_test.dart) and calls
// `route.handleCall` directly — no HTTP server is required.

import 'dart:io';
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

      // Create a temporary bundle directory.
      final tmpDir = Directory.systemTemp.createTempSync('studio_test_');
      addTearDown(() => tmpDir.deleteSync(recursive: true));

      const indexContent = '<html>hello</html>';
      File(p.join(tmpDir.path, 'index.html'))
          .writeAsStringSync(indexContent);

      final deployment = await Deployment.db.insertRow(
        session,
        Deployment(
          projectId: project.id,
          version: 1,
          status: DeploymentStatus.active,
          filePath: tmpDir.path,
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

      final tmpDir = Directory.systemTemp.createTempSync('studio_js_');
      addTearDown(() => tmpDir.deleteSync(recursive: true));

      const jsContent = 'var x = 1;';
      File(p.join(tmpDir.path, 'main.dart.js')).writeAsStringSync(jsContent);

      final deployment = await Deployment.db.insertRow(
        session,
        Deployment(
          projectId: project.id,
          version: 1,
          status: DeploymentStatus.active,
          filePath: tmpDir.path,
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

      final tmpDir = Directory.systemTemp.createTempSync('studio_spa_');
      addTearDown(() => tmpDir.deleteSync(recursive: true));

      const indexContent = '<html>spa</html>';
      File(p.join(tmpDir.path, 'index.html'))
          .writeAsStringSync(indexContent);

      final deployment = await Deployment.db.insertRow(
        session,
        Deployment(
          projectId: project.id,
          version: 1,
          status: DeploymentStatus.active,
          filePath: tmpDir.path,
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

      final tmpDir = Directory.systemTemp.createTempSync('studio_deep_spa_');
      addTearDown(() => tmpDir.deleteSync(recursive: true));

      const indexContent = '<html>deep spa</html>';
      File(p.join(tmpDir.path, 'index.html'))
          .writeAsStringSync(indexContent);

      final deployment = await Deployment.db.insertRow(
        session,
        Deployment(
          projectId: project.id,
          version: 1,
          status: DeploymentStatus.active,
          filePath: tmpDir.path,
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

      final tmpDir = Directory.systemTemp.createTempSync('studio_trav_');
      addTearDown(() => tmpDir.deleteSync(recursive: true));

      const indexContent = '<html>spa</html>';
      File(p.join(tmpDir.path, 'index.html'))
          .writeAsStringSync(indexContent);

      final deployment = await Deployment.db.insertRow(
        session,
        Deployment(
          projectId: project.id,
          version: 1,
          status: DeploymentStatus.active,
          filePath: tmpDir.path,
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
