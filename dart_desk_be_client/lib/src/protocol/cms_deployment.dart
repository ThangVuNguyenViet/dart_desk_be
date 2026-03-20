/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _i1;
import 'deployment_status.dart' as _i2;

abstract class CmsDeployment implements _i1.SerializableModel {
  CmsDeployment._({
    this.id,
    required this.clientId,
    required this.version,
    required this.status,
    required this.filePath,
    this.fileSize,
    this.uploadedByUserId,
    this.commitHash,
    this.metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory CmsDeployment({
    int? id,
    required int clientId,
    required int version,
    required _i2.DeploymentStatus status,
    required String filePath,
    int? fileSize,
    int? uploadedByUserId,
    String? commitHash,
    String? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _CmsDeploymentImpl;

  factory CmsDeployment.fromJson(Map<String, dynamic> jsonSerialization) {
    return CmsDeployment(
      id: jsonSerialization['id'] as int?,
      clientId: jsonSerialization['clientId'] as int,
      version: jsonSerialization['version'] as int,
      status: _i2.DeploymentStatus.fromJson(
        (jsonSerialization['status'] as String),
      ),
      filePath: jsonSerialization['filePath'] as String,
      fileSize: jsonSerialization['fileSize'] as int?,
      uploadedByUserId: jsonSerialization['uploadedByUserId'] as int?,
      commitHash: jsonSerialization['commitHash'] as String?,
      metadata: jsonSerialization['metadata'] as String?,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int clientId;

  int version;

  _i2.DeploymentStatus status;

  String filePath;

  int? fileSize;

  int? uploadedByUserId;

  String? commitHash;

  String? metadata;

  DateTime? createdAt;

  DateTime? updatedAt;

  /// Returns a shallow copy of this [CmsDeployment]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  CmsDeployment copyWith({
    int? id,
    int? clientId,
    int? version,
    _i2.DeploymentStatus? status,
    String? filePath,
    int? fileSize,
    int? uploadedByUserId,
    String? commitHash,
    String? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'CmsDeployment',
      if (id != null) 'id': id,
      'clientId': clientId,
      'version': version,
      'status': status.toJson(),
      'filePath': filePath,
      if (fileSize != null) 'fileSize': fileSize,
      if (uploadedByUserId != null) 'uploadedByUserId': uploadedByUserId,
      if (commitHash != null) 'commitHash': commitHash,
      if (metadata != null) 'metadata': metadata,
      if (createdAt != null) 'createdAt': createdAt?.toJson(),
      if (updatedAt != null) 'updatedAt': updatedAt?.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CmsDeploymentImpl extends CmsDeployment {
  _CmsDeploymentImpl({
    int? id,
    required int clientId,
    required int version,
    required _i2.DeploymentStatus status,
    required String filePath,
    int? fileSize,
    int? uploadedByUserId,
    String? commitHash,
    String? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : super._(
         id: id,
         clientId: clientId,
         version: version,
         status: status,
         filePath: filePath,
         fileSize: fileSize,
         uploadedByUserId: uploadedByUserId,
         commitHash: commitHash,
         metadata: metadata,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [CmsDeployment]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  CmsDeployment copyWith({
    Object? id = _Undefined,
    int? clientId,
    int? version,
    _i2.DeploymentStatus? status,
    String? filePath,
    Object? fileSize = _Undefined,
    Object? uploadedByUserId = _Undefined,
    Object? commitHash = _Undefined,
    Object? metadata = _Undefined,
    Object? createdAt = _Undefined,
    Object? updatedAt = _Undefined,
  }) {
    return CmsDeployment(
      id: id is int? ? id : this.id,
      clientId: clientId ?? this.clientId,
      version: version ?? this.version,
      status: status ?? this.status,
      filePath: filePath ?? this.filePath,
      fileSize: fileSize is int? ? fileSize : this.fileSize,
      uploadedByUserId: uploadedByUserId is int?
          ? uploadedByUserId
          : this.uploadedByUserId,
      commitHash: commitHash is String? ? commitHash : this.commitHash,
      metadata: metadata is String? ? metadata : this.metadata,
      createdAt: createdAt is DateTime? ? createdAt : this.createdAt,
      updatedAt: updatedAt is DateTime? ? updatedAt : this.updatedAt,
    );
  }
}
