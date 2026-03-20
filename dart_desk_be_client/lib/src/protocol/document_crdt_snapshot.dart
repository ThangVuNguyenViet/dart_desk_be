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

abstract class DocumentCrdtSnapshot implements _i1.SerializableModel {
  DocumentCrdtSnapshot._({
    this.id,
    required this.documentId,
    required this.snapshotHlc,
    required this.snapshotData,
    required this.operationCountAtSnapshot,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory DocumentCrdtSnapshot({
    int? id,
    required int documentId,
    required String snapshotHlc,
    required String snapshotData,
    required int operationCountAtSnapshot,
    DateTime? createdAt,
  }) = _DocumentCrdtSnapshotImpl;

  factory DocumentCrdtSnapshot.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return DocumentCrdtSnapshot(
      id: jsonSerialization['id'] as int?,
      documentId: jsonSerialization['documentId'] as int,
      snapshotHlc: jsonSerialization['snapshotHlc'] as String,
      snapshotData: jsonSerialization['snapshotData'] as String,
      operationCountAtSnapshot:
          jsonSerialization['operationCountAtSnapshot'] as int,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int documentId;

  String snapshotHlc;

  String snapshotData;

  int operationCountAtSnapshot;

  DateTime? createdAt;

  /// Returns a shallow copy of this [DocumentCrdtSnapshot]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  DocumentCrdtSnapshot copyWith({
    int? id,
    int? documentId,
    String? snapshotHlc,
    String? snapshotData,
    int? operationCountAtSnapshot,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'DocumentCrdtSnapshot',
      if (id != null) 'id': id,
      'documentId': documentId,
      'snapshotHlc': snapshotHlc,
      'snapshotData': snapshotData,
      'operationCountAtSnapshot': operationCountAtSnapshot,
      if (createdAt != null) 'createdAt': createdAt?.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _DocumentCrdtSnapshotImpl extends DocumentCrdtSnapshot {
  _DocumentCrdtSnapshotImpl({
    int? id,
    required int documentId,
    required String snapshotHlc,
    required String snapshotData,
    required int operationCountAtSnapshot,
    DateTime? createdAt,
  }) : super._(
         id: id,
         documentId: documentId,
         snapshotHlc: snapshotHlc,
         snapshotData: snapshotData,
         operationCountAtSnapshot: operationCountAtSnapshot,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [DocumentCrdtSnapshot]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  DocumentCrdtSnapshot copyWith({
    Object? id = _Undefined,
    int? documentId,
    String? snapshotHlc,
    String? snapshotData,
    int? operationCountAtSnapshot,
    Object? createdAt = _Undefined,
  }) {
    return DocumentCrdtSnapshot(
      id: id is int? ? id : this.id,
      documentId: documentId ?? this.documentId,
      snapshotHlc: snapshotHlc ?? this.snapshotHlc,
      snapshotData: snapshotData ?? this.snapshotData,
      operationCountAtSnapshot:
          operationCountAtSnapshot ?? this.operationCountAtSnapshot,
      createdAt: createdAt is DateTime? ? createdAt : this.createdAt,
    );
  }
}
