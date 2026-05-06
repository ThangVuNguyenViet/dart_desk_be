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
  Map<String, String>? extraHeaders,
}) {
  final url = Uri.parse('http://$host$path');
  final headers = Headers.build((h) {
    h.host = HostHeader(host);
    if (extraHeaders != null) {
      for (final entry in extraHeaders.entries) {
        h[entry.key.toLowerCase()] = [entry.value];
      }
    }
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

    test('GET /some-route falls back to index.html (top-level SPA route)',
        () async {
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

    test(
        'Path traversal /../etc/passwd is normalized and falls back to index.html',
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

    // -----------------------------------------------------------------------
    // Cache-Control: hashed asset gets immutable cache
    // -----------------------------------------------------------------------

    test('Hashed asset gets immutable cache-control and etag', () async {
      final session = sessionBuilder.build();
      const hostname = 'cache-hash-test';
      const domain = 'app.dartdesk.dev';

      final project = await Project.db.insertRow(
        session,
        Project(
          clientId: TestDataFactory.testClientId,
          name: 'Cache Hash Test',
          slug: 'cache-hash-test',
          deployHostname: hostname,
          isActive: true,
        ),
      );

      const content = 'binary-image-data';
      final bundlePrefix = await _seedBundle(
        session,
        files: {'assets/abc1234567def890.png': content},
      );

      final deployment = await Deployment.db.insertRow(
        session,
        Deployment(
          projectId: project.id,
          version: 1,
          status: DeploymentStatus.active,
          filePath: bundlePrefix,
          fileSize: content.length,
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
        path: '/assets/abc1234567def890.png',
      );
      final result = await route.handleCall(session, request);
      final response = result as Response;

      expect(response.statusCode, equals(200));
      final cc = response.headers['cache-control'];
      expect(cc, isNotNull);
      expect(cc!.first, equals('public, max-age=31536000, immutable'));
      final etag = response.headers['etag'];
      expect(etag, isNotNull);
      expect(etag!.first, startsWith('"'));
      expect(etag.first, endsWith('"'));
    });

    // -----------------------------------------------------------------------
    // Cache-Control: index.html gets short cache
    // -----------------------------------------------------------------------

    test('index.html gets must-revalidate cache-control', () async {
      final session = sessionBuilder.build();
      const hostname = 'cache-idx-test';
      const domain = 'app.dartdesk.dev';

      final project = await Project.db.insertRow(
        session,
        Project(
          clientId: TestDataFactory.testClientId,
          name: 'Cache Idx Test',
          slug: 'cache-idx-test',
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
        path: '/',
      );
      final result = await route.handleCall(session, request);
      final response = result as Response;

      expect(response.statusCode, equals(200));
      final cc = response.headers['cache-control'];
      expect(cc, isNotNull);
      expect(cc!.first, equals('public, max-age=0, must-revalidate'));
    });

    // -----------------------------------------------------------------------
    // SPA fallback shares etag with index.html
    // -----------------------------------------------------------------------

    test('SPA fallback shares etag with index.html', () async {
      final session = sessionBuilder.build();
      const hostname = 'spa-etag-test';
      const domain = 'app.dartdesk.dev';

      final project = await Project.db.insertRow(
        session,
        Project(
          clientId: TestDataFactory.testClientId,
          name: 'SPA Etag Test',
          slug: 'spa-etag-test',
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

      final reqFoo = _buildRequest(
        host: '$hostname.$domain',
        path: '/foo',
      );
      final resultFoo = await route.handleCall(session, reqFoo);
      final respFoo = resultFoo as Response;
      final etagFoo = respFoo.headers['etag']!.first;

      final reqRoot = _buildRequest(
        host: '$hostname.$domain',
        path: '/',
      );
      final resultRoot = await route.handleCall(session, reqRoot);
      final respRoot = resultRoot as Response;
      final etagRoot = respRoot.headers['etag']!.first;

      expect(etagFoo, equals(etagRoot));
    });

    // -----------------------------------------------------------------------
    // Service worker is NOT immutable
    // -----------------------------------------------------------------------

    test('flutter_service_worker.js gets must-revalidate cache-control',
        () async {
      final session = sessionBuilder.build();
      const hostname = 'sw-cache-test';
      const domain = 'app.dartdesk.dev';

      final project = await Project.db.insertRow(
        session,
        Project(
          clientId: TestDataFactory.testClientId,
          name: 'SW Cache Test',
          slug: 'sw-cache-test',
          deployHostname: hostname,
          isActive: true,
        ),
      );

      const swContent = 'self.addEventListener("install", ()=>{});';
      final bundlePrefix = await _seedBundle(
        session,
        files: {'flutter_service_worker.js': swContent},
      );

      final deployment = await Deployment.db.insertRow(
        session,
        Deployment(
          projectId: project.id,
          version: 1,
          status: DeploymentStatus.active,
          filePath: bundlePrefix,
          fileSize: swContent.length,
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
        path: '/flutter_service_worker.js',
      );
      final result = await route.handleCall(session, request);
      final response = result as Response;

      expect(response.statusCode, equals(200));
      final cc = response.headers['cache-control'];
      expect(cc, isNotNull);
      expect(cc!.first, equals('public, max-age=0, must-revalidate'));
    });

    // -----------------------------------------------------------------------
    // If-None-Match returns 304
    // -----------------------------------------------------------------------

    test('If-None-Match match returns 304 with empty body', () async {
      final session = sessionBuilder.build();
      const hostname = 'etag-304-test';
      const domain = 'app.dartdesk.dev';

      final project = await Project.db.insertRow(
        session,
        Project(
          clientId: TestDataFactory.testClientId,
          name: 'ETag 304 Test',
          slug: 'etag-304-test',
          deployHostname: hostname,
          isActive: true,
        ),
      );

      const content = 'hashed-content';
      final bundlePrefix = await _seedBundle(
        session,
        files: {'assets/abc1234567def890.png': content},
      );

      final deployment = await Deployment.db.insertRow(
        session,
        Deployment(
          projectId: project.id,
          version: 1,
          status: DeploymentStatus.active,
          filePath: bundlePrefix,
          fileSize: content.length,
          createdAt: DateTime.now().toUtc(),
          updatedAt: DateTime.now().toUtc(),
        ),
      );
      addTearDown(() async {
        await Deployment.db.deleteRow(session, deployment);
        await Project.db.deleteRow(session, project);
      });

      final route = StudioRoute(domain: domain);

      final req1 = _buildRequest(
        host: '$hostname.$domain',
        path: '/assets/abc1234567def890.png',
      );
      final result1 = await route.handleCall(session, req1);
      final resp1 = result1 as Response;
      final etag = resp1.headers['etag']!.first;

      final req2 = _buildRequest(
        host: '$hostname.$domain',
        path: '/assets/abc1234567def890.png',
        extraHeaders: {'if-none-match': etag},
      );
      final result2 = await route.handleCall(session, req2);
      final resp2 = result2 as Response;

      expect(resp2.statusCode, equals(304));
      final body2 = await _readBody(resp2);
      expect(body2, isEmpty);
      expect(resp2.headers['cache-control']!.first,
          equals('public, max-age=31536000, immutable'));
      expect(resp2.headers['etag']!.first, equals(etag));
    });

    // -----------------------------------------------------------------------
    // If-None-Match mismatch returns 200 + body
    // -----------------------------------------------------------------------

    test('If-None-Match mismatch returns 200 with full body', () async {
      final session = sessionBuilder.build();
      const hostname = 'etag-mismatch-test';
      const domain = 'app.dartdesk.dev';

      final project = await Project.db.insertRow(
        session,
        Project(
          clientId: TestDataFactory.testClientId,
          name: 'ETag Mismatch Test',
          slug: 'etag-mismatch-test',
          deployHostname: hostname,
          isActive: true,
        ),
      );

      const content = 'mismatch-content';
      final bundlePrefix = await _seedBundle(
        session,
        files: {'main.dart.js': content},
      );

      final deployment = await Deployment.db.insertRow(
        session,
        Deployment(
          projectId: project.id,
          version: 1,
          status: DeploymentStatus.active,
          filePath: bundlePrefix,
          fileSize: content.length,
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
        extraHeaders: {'if-none-match': '"wrong-etag-value"'},
      );
      final result = await route.handleCall(session, request);
      final response = result as Response;

      expect(response.statusCode, equals(200));
      final body = await _readBody(response);
      expect(String.fromCharCodes(body), equals(content));
    });

    // -----------------------------------------------------------------------
    // Default cache for non-hashed .js
    // -----------------------------------------------------------------------

    test('Non-hashed .js gets default 5-minute cache-control', () async {
      final session = sessionBuilder.build();
      const hostname = 'default-cache-test';
      const domain = 'app.dartdesk.dev';

      final project = await Project.db.insertRow(
        session,
        Project(
          clientId: TestDataFactory.testClientId,
          name: 'Default Cache Test',
          slug: 'default-cache-test',
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
      final cc = response.headers['cache-control'];
      expect(cc, isNotNull);
      expect(cc!.first, equals('public, max-age=300'));
    });
  });
}
