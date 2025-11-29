/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _i1;
import 'document_version_status.dart' as _i2;

abstract class DocumentVersion implements _i1.SerializableModel {
  DocumentVersion._({
    this.id,
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
    required this.createdByUserId,
  })  : operationCount = operationCount ?? 0,
        createdAt = createdAt ?? DateTime.now();

  factory DocumentVersion({
    int? id,
    required int documentId,
    required int versionNumber,
    required _i2.DocumentVersionStatus status,
    String? snapshotHlc,
    int? operationCount,
    String? changeLog,
    DateTime? publishedAt,
    DateTime? scheduledAt,
    DateTime? archivedAt,
    DateTime? createdAt,
    required int createdByUserId,
  }) = _DocumentVersionImpl;

  factory DocumentVersion.fromJson(Map<String, dynamic> jsonSerialization) {
    return DocumentVersion(
      id: jsonSerialization['id'] as int?,
      documentId: jsonSerialization['documentId'] as int,
      versionNumber: jsonSerialization['versionNumber'] as int,
      status: _i2.DocumentVersionStatus.fromJson(
          (jsonSerialization['status'] as String)),
      snapshotHlc: jsonSerialization['snapshotHlc'] as String?,
      operationCount: jsonSerialization['operationCount'] as int,
      changeLog: jsonSerialization['changeLog'] as String?,
      publishedAt: jsonSerialization['publishedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(
              jsonSerialization['publishedAt']),
      scheduledAt: jsonSerialization['scheduledAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(
              jsonSerialization['scheduledAt']),
      archivedAt: jsonSerialization['archivedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['archivedAt']),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      createdByUserId: jsonSerialization['createdByUserId'] as int,
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int documentId;

  int versionNumber;

  _i2.DocumentVersionStatus status;

  String? snapshotHlc;

  int operationCount;

  String? changeLog;

  DateTime? publishedAt;

  DateTime? scheduledAt;

  DateTime? archivedAt;

  DateTime? createdAt;

  int createdByUserId;

  /// Returns a shallow copy of this [DocumentVersion]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  DocumentVersion copyWith({
    int? id,
    int? documentId,
    int? versionNumber,
    _i2.DocumentVersionStatus? status,
    String? snapshotHlc,
    int? operationCount,
    String? changeLog,
    DateTime? publishedAt,
    DateTime? scheduledAt,
    DateTime? archivedAt,
    DateTime? createdAt,
    int? createdByUserId,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'documentId': documentId,
      'versionNumber': versionNumber,
      'status': status.toJson(),
      if (snapshotHlc != null) 'snapshotHlc': snapshotHlc,
      'operationCount': operationCount,
      if (changeLog != null) 'changeLog': changeLog,
      if (publishedAt != null) 'publishedAt': publishedAt?.toJson(),
      if (scheduledAt != null) 'scheduledAt': scheduledAt?.toJson(),
      if (archivedAt != null) 'archivedAt': archivedAt?.toJson(),
      if (createdAt != null) 'createdAt': createdAt?.toJson(),
      'createdByUserId': createdByUserId,
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
    int? id,
    required int documentId,
    required int versionNumber,
    required _i2.DocumentVersionStatus status,
    String? snapshotHlc,
    int? operationCount,
    String? changeLog,
    DateTime? publishedAt,
    DateTime? scheduledAt,
    DateTime? archivedAt,
    DateTime? createdAt,
    required int createdByUserId,
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
    Object? id = _Undefined,
    int? documentId,
    int? versionNumber,
    _i2.DocumentVersionStatus? status,
    Object? snapshotHlc = _Undefined,
    int? operationCount,
    Object? changeLog = _Undefined,
    Object? publishedAt = _Undefined,
    Object? scheduledAt = _Undefined,
    Object? archivedAt = _Undefined,
    Object? createdAt = _Undefined,
    int? createdByUserId,
  }) {
    return DocumentVersion(
      id: id is int? ? id : this.id,
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
      createdByUserId: createdByUserId ?? this.createdByUserId,
    );
  }
}
