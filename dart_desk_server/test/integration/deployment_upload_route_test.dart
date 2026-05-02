// Integration tests for DeploymentUploadRoute.
//
// Test harness note: Serverpod's `withServerpod` sets up a real test database
// but does NOT spin up an HTTP web server. Therefore these tests call
// `route.handleCall(session, request)` directly, constructing Relic `Request`
// objects via `RequestInternal.create` (an internal extension that exposes the
// private constructor — used by Relic's own test suite).
//
// The `Session` is obtained from `sessionBuilder.build()` with an
// `AuthenticationOverride`, so `session.authenticated` is non-null as it would
// be in production after the authenticationHandler chain runs.

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:dart_desk_server/src/generated/protocol.dart';
import 'package:dart_desk_server/src/web/routes/deployment_upload_route.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

import 'helpers/test_data_factory.dart';
import 'test_tools/serverpod_test_tools.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Build a minimal .tar.gz archive containing a single `index.html`.
List<int> _buildTarGz({String content = 'hello'}) {
  final archive = Archive();
  final fileBytes = utf8.encode(content);
  archive.addFile(
    ArchiveFile('index.html', fileBytes.length, fileBytes),
  );
  final tarBytes = TarEncoder().encode(archive);
  return GZipEncoder().encode(tarBytes);
}

/// Create a Relic [Request] suitable for calling [DeploymentUploadRoute.handleCall].
///
/// Uses [RequestInternal.create] — the same technique used by Relic's own test
/// suite — to bypass the private constructor.
Request _buildRequest({
  required String method,
  required String url,
  List<int> body = const [],
}) {
  return RequestInternal.create(
    Method.parse(method),
    Uri.parse(url),
    Object(), // opaque token required by the internal constructor
    body: body.isEmpty
        ? Body.empty()
        : Body.fromData(Uint8List.fromList(body)),
  );
}

/// Decode a JSON response body from the route's [Response].
Future<Map<String, dynamic>> _decodeResponse(Response response) async {
  final bytes = await response.body.read().expand((b) => b).toList();
  return jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  withServerpod('DeploymentUploadRoute', (sessionBuilder, endpoints) {
    const adminUserId = 'upload-admin-1';
    const clientSlug = 'test-client';
    const projectSlug = 'upload-test-project';

    late TestDataFactory factory;
    late Project seedProject;

    TestSessionBuilder authedSession() => sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            adminUserId,
            {Scope('user')},
          ),
        );

    setUp(() async {
      factory = TestDataFactory(
        sessionBuilder: sessionBuilder,
        endpoints: endpoints,
      );
      final session = sessionBuilder.build();

      await factory.ensureTestClient();

      seedProject = await Project.db.insertRow(
        session,
        Project(
          clientId: TestDataFactory.testClientId,
          name: 'Upload Test Project',
          slug: projectSlug,
          deployHostname: 'upload-test',
          isActive: true,
        ),
      );

      await User.db.insertRow(
        session,
        User(
          clientId: TestDataFactory.testClientId,
          email: 'admin@upload.test',
          role: ClientRole.admin,
          isActive: true,
          serverpodUserId: adminUserId,
        ),
      );
    });

    // -----------------------------------------------------------------------
    // Happy path
    // -----------------------------------------------------------------------

    group('happy path', () {
      test('returns 200 with version and url, extracts bundle to disk',
          () async {
        final route = DeploymentUploadRoute();
        final session = authedSession().build();
        String? extractDir;

        addTearDown(() {
          if (extractDir != null) {
            final dir = Directory(extractDir);
            if (dir.existsSync()) dir.deleteSync(recursive: true);
          }
        });

        final request = _buildRequest(
          method: 'POST',
          url: 'http://localhost/deployment/upload?clientSlug=$clientSlug&projectSlug=$projectSlug',
          body: _buildTarGz(),
        );

        final result = await route.handleCall(session, request);
        final response = result as Response;

        expect(response.statusCode, equals(200));
        final body = await _decodeResponse(response);
        expect(body['version'], equals(1));
        expect(body['url'], equals('https://upload-test.app.dartdesk.dev'));

        // Verify DB row.
        final dbSession = sessionBuilder.build();
        final deployment = await Deployment.db.findFirstRow(
          dbSession,
          where: (t) =>
              t.projectId.equals(seedProject.id) & t.version.equals(1),
        );
        expect(deployment, isNotNull);
        expect(deployment!.status, equals(DeploymentStatus.active));
        extractDir = deployment.filePath;
        expect(extractDir, isNotEmpty);

        // Verify file on disk.
        final indexFile = File('$extractDir/index.html');
        expect(indexFile.existsSync(), isTrue,
            reason: 'index.html should be extracted to $extractDir');
        expect(indexFile.readAsStringSync(), equals('hello'));
      });

      test('second upload increments version and demotes previous', () async {
        final route = DeploymentUploadRoute();
        final dirs = <String>[];

        addTearDown(() {
          for (final d in dirs) {
            final dir = Directory(d);
            if (dir.existsSync()) dir.deleteSync(recursive: true);
          }
        });

        // First upload.
        final result1 = await route.handleCall(
          authedSession().build(),
          _buildRequest(
            method: 'POST',
            url: 'http://localhost/deployment/upload?clientSlug=$clientSlug&projectSlug=$projectSlug',
            body: _buildTarGz(content: 'v1'),
          ),
        );
        expect((result1 as Response).statusCode, equals(200));

        // Second upload.
        final result2 = await route.handleCall(
          authedSession().build(),
          _buildRequest(
            method: 'POST',
            url: 'http://localhost/deployment/upload?clientSlug=$clientSlug&projectSlug=$projectSlug',
            body: _buildTarGz(content: 'v2'),
          ),
        );
        final resp2 = result2 as Response;
        expect(resp2.statusCode, equals(200));
        final body2 = await _decodeResponse(resp2);
        expect(body2['version'], equals(2));

        // Verify first is now inactive, second is active.
        final dbSession = sessionBuilder.build();
        final d1 = await Deployment.db.findFirstRow(
          dbSession,
          where: (t) =>
              t.projectId.equals(seedProject.id) & t.version.equals(1),
        );
        expect(d1!.status, equals(DeploymentStatus.inactive));
        dirs.add(d1.filePath);

        final d2 = await Deployment.db.findFirstRow(
          dbSession,
          where: (t) =>
              t.projectId.equals(seedProject.id) & t.version.equals(2),
        );
        expect(d2!.status, equals(DeploymentStatus.active));
        dirs.add(d2.filePath);
      });
    });

    // -----------------------------------------------------------------------
    // Error cases
    // -----------------------------------------------------------------------

    group('error cases', () {
      test('returns 405 for non-POST method', () async {
        final route = DeploymentUploadRoute();
        final request = _buildRequest(
          method: 'GET',
          url: 'http://localhost/deployment/upload?clientSlug=$clientSlug&projectSlug=$projectSlug',
        );

        final result =
            await route.handleCall(authedSession().build(), request);
        expect((result as Response).statusCode, equals(405));
      });

      test('returns 400 when clientSlug is missing', () async {
        final route = DeploymentUploadRoute();
        final request = _buildRequest(
          method: 'POST',
          url: 'http://localhost/deployment/upload?projectSlug=$projectSlug',
        );

        final result =
            await route.handleCall(authedSession().build(), request);
        final response = result as Response;
        expect(response.statusCode, equals(400));
        final body = await _decodeResponse(response);
        expect(body['error'], contains('clientSlug'));
      });

      test('returns 400 when projectSlug is missing', () async {
        final route = DeploymentUploadRoute();
        final request = _buildRequest(
          method: 'POST',
          url: 'http://localhost/deployment/upload?clientSlug=$clientSlug',
        );

        final result =
            await route.handleCall(authedSession().build(), request);
        final response = result as Response;
        expect(response.statusCode, equals(400));
        final body = await _decodeResponse(response);
        expect(body['error'], contains('projectSlug'));
      });

      test('returns 401 when not authenticated', () async {
        final route = DeploymentUploadRoute();
        // Unauthenticated session (no AuthenticationOverride).
        final session = sessionBuilder.build();
        final request = _buildRequest(
          method: 'POST',
          url: 'http://localhost/deployment/upload?clientSlug=$clientSlug&projectSlug=$projectSlug',
          body: _buildTarGz(),
        );

        final result = await route.handleCall(session, request);
        expect((result as Response).statusCode, equals(401));
      });

      test('returns 404 when project slug does not exist', () async {
        final route = DeploymentUploadRoute();
        final request = _buildRequest(
          method: 'POST',
          url: 'http://localhost/deployment/upload?clientSlug=$clientSlug&projectSlug=no-such-project',
          body: _buildTarGz(),
        );

        final result =
            await route.handleCall(authedSession().build(), request);
        expect((result as Response).statusCode, equals(404));
      });

      test('returns 403 when user role is insufficient (viewer)', () async {
        final route = DeploymentUploadRoute();
        const viewerUserId = 'upload-viewer-1';

        await User.db.insertRow(
          sessionBuilder.build(),
          User(
            clientId: TestDataFactory.testClientId,
            email: 'viewer@upload.test',
            role: ClientRole.viewer,
            isActive: true,
            serverpodUserId: viewerUserId,
          ),
        );

        final viewerSession = sessionBuilder
            .copyWith(
              authentication: AuthenticationOverride.authenticationInfo(
                viewerUserId,
                {Scope('user')},
              ),
            )
            .build();

        final request = _buildRequest(
          method: 'POST',
          url: 'http://localhost/deployment/upload?clientSlug=$clientSlug&projectSlug=$projectSlug',
          body: _buildTarGz(),
        );

        final result = await route.handleCall(viewerSession, request);
        expect((result as Response).statusCode, equals(403));
      });

      test('returns 400 for invalid gzip body', () async {
        final route = DeploymentUploadRoute();
        final request = _buildRequest(
          method: 'POST',
          url: 'http://localhost/deployment/upload?clientSlug=$clientSlug&projectSlug=$projectSlug',
          body: [0x00, 0x01, 0x02, 0x03], // not valid gzip
        );

        final result =
            await route.handleCall(authedSession().build(), request);
        final response = result as Response;
        expect(response.statusCode, equals(400));
        final body = await _decodeResponse(response);
        expect(body['error'], contains('gzip'));
      });

      test('returns 400 for empty body', () async {
        final route = DeploymentUploadRoute();
        final request = _buildRequest(
          method: 'POST',
          url: 'http://localhost/deployment/upload?clientSlug=$clientSlug&projectSlug=$projectSlug',
          body: [],
        );

        final result =
            await route.handleCall(authedSession().build(), request);
        final response = result as Response;
        expect(response.statusCode, equals(400));
        final body = await _decodeResponse(response);
        expect(body['error'], contains('Empty'));
      });
    });
  });
}
