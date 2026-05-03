import 'package:serverpod/serverpod.dart';
import 'package:serverpod_cloud_storage_s3/serverpod_cloud_storage_s3.dart';
import 'package:serverpod_cloud_storage_s3_compat/serverpod_cloud_storage_s3_compat.dart';

/// AWS endpoint config that disables per-object ACLs.
///
/// Use this when the bucket has `BucketOwnerEnforced` ownership (i.e.,
/// Object ACLs are disabled). Serverpod's default [AwsEndpointConfig]
/// sets `supportsObjectAcl = true`, which causes every upload to include
/// `x-amz-acl: public-read` — a header S3 rejects with 400
/// `AccessControlListNotSupported` on ACL-disabled buckets.
class _NoAclAwsEndpointConfig extends AwsEndpointConfig {
  const _NoAclAwsEndpointConfig({super.publicHost});

  @override
  bool get supportsObjectAcl => false;
}

/// [S3CloudStorage] variant for buckets with `BucketOwnerEnforced` ownership.
///
/// Identical to [S3CloudStorage] except it uses [_NoAclAwsEndpointConfig] so
/// no `x-amz-acl` header or policy condition is sent on upload. Public access
/// is instead controlled by a bucket policy on the S3 side.
class NoAclS3CloudStorage extends S3CompatCloudStorage {
  /// Creates an S3 cloud storage instance that omits ACL headers.
  ///
  /// [serverpod] is used to load AWS credentials.
  /// [storageId] identifies this storage (typically `'public'`).
  /// [region] is the AWS region (e.g. `'us-west-2'`).
  /// [bucket] is the S3 bucket name.
  /// [publicHost] optionally overrides the public URL host for CDN.
  NoAclS3CloudStorage({
    required Serverpod serverpod,
    required super.storageId,
    required super.region,
    required super.bucket,
    String? publicHost,
  }) : super(
         public: true,
         accessKey: _loadAccessKey(serverpod),
         secretKey: _loadSecretKey(serverpod),
         endpoints: _NoAclAwsEndpointConfig(
           publicHost:
               publicHost != null ? Uri.parse('https://$publicHost') : null,
         ),
         uploadStrategy: MultipartPostUploadStrategy(),
       );

  static String _loadAccessKey(Serverpod serverpod) {
    serverpod.loadCustomPasswords([
      (envName: 'SERVERPOD_AWS_ACCESS_KEY_ID', alias: 'AWSAccessKeyId'),
    ]);
    final key = serverpod.getPassword('AWSAccessKeyId');
    if (key == null) {
      throw StateError(
        'AWS access key not configured. '
        'Set AWSAccessKeyId in passwords.yaml or '
        'SERVERPOD_AWS_ACCESS_KEY_ID environment variable.',
      );
    }
    return key;
  }

  static String _loadSecretKey(Serverpod serverpod) {
    serverpod.loadCustomPasswords([
      (envName: 'SERVERPOD_AWS_SECRET_KEY', alias: 'AWSSecretKey'),
    ]);
    final key = serverpod.getPassword('AWSSecretKey');
    if (key == null) {
      throw StateError(
        'AWS secret key not configured. '
        'Set AWSSecretKey in passwords.yaml or '
        'SERVERPOD_AWS_SECRET_KEY environment variable.',
      );
    }
    return key;
  }
}
