import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dart_desk_server/src/storage/content_type_multipart_strategy.dart';
import 'package:serverpod_cloud_storage_s3_compat/serverpod_cloud_storage_s3_compat.dart';
import 'package:test/test.dart';

class _FakeEndpoint implements S3EndpointConfig {
  _FakeEndpoint(this._origin);
  final Uri _origin;

  @override
  Uri buildBucketUri(String bucket, String region) => _origin;


  @override
  bool get supportsObjectAcl => false;

  @override
  Uri buildPublicUri(String bucket, String region, String path,
          {Uri? publicHost}) =>
      _origin.replace(path: '/$path');

  @override
  String get serviceName => 's3';
}

Future<void> main() async {
  group('ContentTypeMultipartPostStrategy', () {
    late HttpServer server;
    late List<HttpRequest> received;
    late List<List<int>> bodies;

    setUp(() async {
      received = [];
      bodies = [];
      server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      server.listen((req) async {
        final body = <int>[];
        await for (final chunk in req) {
          body.addAll(chunk);
        }
        received.add(req);
        bodies.add(body);
        req.response.statusCode = 204;
        await req.response.close();
      });
    });

    tearDown(() async {
      await server.close(force: true);
    });

    test('uploads .png with Content-Type image/png and no ACL', () async {
      final strategy = ContentTypeMultipartPostStrategy();
      final endpoint = _FakeEndpoint(Uri.parse('http://${server.address.host}:${server.port}/'));
      final data = ByteData.view(Uint8List.fromList([0x89, 0x50, 0x4E, 0x47]).buffer);

      await strategy.uploadData(
        accessKey: 'AKIAIOSFODNN7EXAMPLE',
        secretKey: 'wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY',
        bucket: 'test-bucket',
        region: 'us-west-2',
        data: data,
        path: 'media/test/icon.png',
        public: true,
        endpoints: endpoint,
      );

      expect(received, hasLength(1));
      // Use latin1 (never throws) so binary file bytes don't crash the decode.
      final body = latin1.decode(bodies.single);

      // Form field present
      expect(
        body,
        contains('name="Content-Type"'),
        reason: 'Content-Type form field must be included',
      );
      // The next non-empty line after the disposition is the value
      final ctSection = body.split('name="Content-Type"').last;
      expect(ctSection, contains('image/png'));

      // No acl form field
      expect(body, isNot(contains('name="acl"')));

      // Policy contains an eq Content-Type condition
      final policySection = body.split('name="Policy"').last;
      // Policy is base64-encoded; decode the section between blank line and boundary
      // Find the base64-encoded policy line: a long line of only base64 chars.
      final base64Re = RegExp(r'^[A-Za-z0-9+/]+=*$');
      final policyValue = policySection
          .split('\r\n')
          .firstWhere(
            (line) => line.length > 50 && base64Re.hasMatch(line),
            orElse: () => '',
          );
      expect(policyValue, isNotEmpty,
          reason: 'Policy form field must contain a base64 value');
      final policyJson = utf8.decode(base64.decode(policyValue));
      expect(policyJson, contains('Content-Type'));
      expect(policyJson, contains('image/png'));
      expect(policyJson, isNot(contains('"acl"')));
    });

    test('uploads .bin with application/octet-stream fallback', () async {
      final strategy = ContentTypeMultipartPostStrategy();
      final endpoint = _FakeEndpoint(Uri.parse('http://${server.address.host}:${server.port}/'));
      final data = ByteData.view(Uint8List.fromList([0x00, 0x01]).buffer);

      await strategy.uploadData(
        accessKey: 'k',
        secretKey: 's',
        bucket: 'b',
        region: 'us-west-2',
        data: data,
        path: 'unknownext.unknownmimetype99999',
        public: true,
        endpoints: endpoint,
      );

      final body = latin1.decode(bodies.single);
      final ctSection = body.split('name="Content-Type"').last;
      expect(ctSection, contains('application/octet-stream'));
    });
  });
}
