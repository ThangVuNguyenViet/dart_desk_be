import 'dart:convert';
import 'dart:typed_data';

import 'package:amazon_cognito_identity_dart_2/sig_v4.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as p;
import 'package:serverpod_cloud_storage_s3_compat/serverpod_cloud_storage_s3_compat.dart';

/// [MultipartPostUploadStrategy] variant that forwards `Content-Type` to S3.
///
/// The upstream strategy omits `Content-Type`, so objects land in S3 as
/// `application/octet-stream` — fine for files proxied through the server,
/// broken for images served directly from S3 or via a transform CDN.
///
/// This subclass declares `Content-Type` in the presigned POST policy
/// (required: S3 rejects form fields not matched by a policy condition)
/// and sends a matching form field. `MultipartFile.contentType` is also
/// set so the part header is correct.
class ContentTypeMultipartPostStrategy extends MultipartPostUploadStrategy {
  @override
  Future<void> uploadData({
    required String accessKey,
    required String secretKey,
    required String bucket,
    required String region,
    required ByteData data,
    required String path,
    bool public = false,
    required S3EndpointConfig endpoints,
    bool preventOverwrite = false,
  }) async {
    final filename = p.basename(path);
    final contentType =
        lookupMimeType(filename) ?? 'application/octet-stream';

    final uploadUri = endpoints.buildBucketUri(bucket, region);
    final length = data.lengthInBytes;
    final stream = http.ByteStream.fromBytes(Uint8List.sublistView(data));

    // Build policy by hand: upstream Policy.toString() builds a fixed
    // condition list and is not extension-friendly. Mirror its structure
    // and add a Content-Type eq condition.
    final datetime = SigV4.generateDatetime();
    final exp = DateTime.now().add(const Duration(minutes: 15)).toUtc();
    final expiration =
        '${exp.year}-'
        '${exp.month.toString().padLeft(2, '0')}-'
        '${exp.day.toString().padLeft(2, '0')}T'
        '${exp.hour.toString().padLeft(2, '0')}:'
        '${exp.minute.toString().padLeft(2, '0')}:'
        '${exp.second.toString().padLeft(2, '0')}.000Z';
    final credential =
        '$accessKey/${SigV4.buildCredentialScope(datetime, region, 's3')}';

    final conditions = <String>[
      '{"bucket": "$bucket"}',
      '["starts-with", "\$key", "$path"]',
      '["content-length-range", 1, $length]',
      '{"Content-Type": "$contentType"}',
      '{"x-amz-credential": "$credential"}',
      '{"x-amz-algorithm": "AWS4-HMAC-SHA256"}',
      '{"x-amz-date": "$datetime" }',
    ];
    final policyDoc = '''
{ "expiration": "$expiration",
  "conditions": [
    ${conditions.join(',\n    ')}
  ]
}
''';
    final encodedPolicy = base64.encode(utf8.encode(policyDoc));

    final signingKey =
        SigV4.calculateSigningKey(secretKey, datetime, region, 's3');
    final signature = SigV4.calculateSignature(signingKey, encodedPolicy);

    final req = http.MultipartRequest('POST', uploadUri);
    req.files.add(
      http.MultipartFile(
        'file',
        stream,
        length,
        filename: filename,
        contentType: MediaType.parse(contentType),
      ),
    );
    req.fields['key'] = path;
    req.fields['Content-Type'] = contentType;
    req.fields['X-Amz-Credential'] = credential;
    req.fields['X-Amz-Algorithm'] = 'AWS4-HMAC-SHA256';
    req.fields['X-Amz-Date'] = datetime;
    req.fields['Policy'] = encodedPolicy;
    req.fields['X-Amz-Signature'] = signature;

    final res = await req.send();
    final response = await http.Response.fromStream(res);

    if (response.statusCode == 204) return;
    if (response.statusCode == 403) throw NoPermissionsException(response);
    throw S3Exception(response);
  }
}
