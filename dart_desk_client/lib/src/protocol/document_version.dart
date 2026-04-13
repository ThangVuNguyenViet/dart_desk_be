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
import 'document_version_status.dart' as _i2;

abstract class DocumentVersion implements _i1.SerializableModel {
  DocumentVersion._({
    _i1.UuidValue? id,
    required this.documentId,
    required this.versionNumber,
    required this.status,
    this.snapshotHlc,
    int? operationCount,
    this.changeLog,
    this.publishedAt,
    this.scheduledAt,
    this.archivedAt,
    DateTime? createdAt,
    this.createdByUserId,
  }) : id = id ?? const _i1.Uuid().v4obj(),
       operationCount = operationCount ?? 0,
       createdAt = createdAt ?? DateTime.now();

  factory DocumentVersion({
    _i1.UuidValue? id,
    required _i1.UuidValue documentId,
    required int versionNumber,
    required _i2.DocumentVersionStatus status,
    String? snapshotHlc,
    int? operationCount,
    String? changeLog,
    DateTime? publishedAt,
    DateTime? scheduledAt,
    DateTime? archivedAt,
    DateTime? createdAt,
    _i1.UuidValue? createdByUserId,
  }) = _DocumentVersionImpl;

  factory DocumentVersion.fromJson(Map<String, dynamic> jsonSerialization) {
    return DocumentVersion(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      documentId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['documentId'],
      ),
      versionNumber: jsonSerialization['versionNumber'] as int,
      status: _i2.DocumentVersionStatus.fromJson(
        (jsonSerialization['status'] as String),
      ),
      snapshotHlc: jsonSerialization['snapshotHlc'] as String?,
      operationCount: jsonSerialization['operationCount'] as int?,
      changeLog: jsonSerialization['changeLog'] as String?,
      publishedAt: jsonSerialization['publishedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(
              jsonSerialization['publishedAt'],
            ),
      scheduledAt: jsonSerialization['scheduledAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(
              jsonSerialization['scheduledAt'],
            ),
      archivedAt: jsonSerialization['archivedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['archivedAt']),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      createdByUserId: jsonSerialization['createdByUserId'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(
              jsonSerialization['createdByUserId'],
            ),
    );
  }

  /// The id of the object.
  _i1.UuidValue id;

  _i1.UuidValue documentId;

  int versionNumber;

  _i2.DocumentVersionStatus status;

  String? snapshotHlc;

  int operationCount;

  String? changeLog;

  DateTime? publishedAt;

  DateTime? scheduledAt;

  DateTime? archivedAt;

  DateTime? createdAt;

  _i1.UuidValue? createdByUserId;

  /// Returns a shallow copy of this [DocumentVersion]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  DocumentVersion copyWith({
    _i1.UuidValue? id,
    _i1.UuidValue? documentId,
    int? versionNumber,
    _i2.DocumentVersionStatus? status,
    String? snapshotHlc,
    int? operationCount,
    String? changeLog,
    DateTime? publishedAt,
    DateTime? scheduledAt,
    DateTime? archivedAt,
    DateTime? createdAt,
    _i1.UuidValue? createdByUserId,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'DocumentVersion',
      'id': id.toJson(),
      'documentId': documentId.toJson(),
      'versionNumber': versionNumber,
      'status': status.toJson(),
      if (snapshotHlc != null) 'snapshotHlc': snapshotHlc,
      'operationCount': operationCount,
      if (changeLog != null) 'changeLog': changeLog,
      if (publishedAt != null) 'publishedAt': publishedAt?.toJson(),
      if (scheduledAt != null) 'scheduledAt': scheduledAt?.toJson(),
      if (archivedAt != null) 'archivedAt': archivedAt?.toJson(),
      if (createdAt != null) 'createdAt': createdAt?.toJson(),
      if (createdByUserId != null) 'createdByUserId': createdByUserId?.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _DocumentVersionImpl extends DocumentVersion {
  _DocumentVersionImpl({
    _i1.UuidValue? id,
    required _i1.UuidValue documentId,
    required int versionNumber,
    required _i2.DocumentVersionStatus status,
    String? snapshotHlc,
    int? operationCount,
    String? changeLog,
    DateTime? publishedAt,
    DateTime? scheduledAt,
    DateTime? archivedAt,
    DateTime? createdAt,
    _i1.UuidValue? createdByUserId,
  }) : super._(
         id: id,
         documentId: documentId,
         versionNumber: versionNumber,
         status: status,
         snapshotHlc: snapshotHlc,
         operationCount: operationCount,
         changeLog: changeLog,
         publishedAt: publishedAt,
         scheduledAt: scheduledAt,
         archivedAt: archivedAt,
         createdAt: createdAt,
         createdByUserId: createdByUserId,
       );

  /// Returns a shallow copy of this [DocumentVersion]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  DocumentVersion copyWith({
    _i1.UuidValue? id,
    _i1.UuidValue? documentId,
    int? versionNumber,
    _i2.DocumentVersionStatus? status,
    Object? snapshotHlc = _Undefined,
    int? operationCount,
    Object? changeLog = _Undefined,
    Object? publishedAt = _Undefined,
    Object? scheduledAt = _Undefined,
    Object? archivedAt = _Undefined,
    Object? createdAt = _Undefined,
    Object? createdByUserId = _Undefined,
  }) {
    return DocumentVersion(
      id: id ?? this.id,
      documentId: documentId ?? this.documentId,
      versionNumber: versionNumber ?? this.versionNumber,
      status: status ?? this.status,
      snapshotHlc: snapshotHlc is String? ? snapshotHlc : this.snapshotHlc,
      operationCount: operationCount ?? this.operationCount,
      changeLog: changeLog is String? ? changeLog : this.changeLog,
      publishedAt: publishedAt is DateTime? ? publishedAt : this.publishedAt,
      scheduledAt: scheduledAt is DateTime? ? scheduledAt : this.scheduledAt,
      archivedAt: archivedAt is DateTime? ? archivedAt : this.archivedAt,
      createdAt: createdAt is DateTime? ? createdAt : this.createdAt,
      createdByUserId: createdByUserId is _i1.UuidValue?
          ? createdByUserId
          : this.createdByUserId,
    );
  }
}
