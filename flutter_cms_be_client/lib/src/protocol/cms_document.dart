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

abstract class CmsDocument implements _i1.SerializableModel {
  CmsDocument._({
    this.id,
    required this.documentType,
    required this.data,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.createdByUserId,
    this.updatedByUserId,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory CmsDocument({
    int? id,
    required String documentType,
    required String data,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? createdByUserId,
    int? updatedByUserId,
  }) = _CmsDocumentImpl;

  factory CmsDocument.fromJson(Map<String, dynamic> jsonSerialization) {
    return CmsDocument(
      id: jsonSerialization['id'] as int?,
      documentType: jsonSerialization['documentType'] as String,
      data: jsonSerialization['data'] as String,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
      createdByUserId: jsonSerialization['createdByUserId'] as int?,
      updatedByUserId: jsonSerialization['updatedByUserId'] as int?,
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  String documentType;

  String data;

  DateTime? createdAt;

  DateTime? updatedAt;

  int? createdByUserId;

  int? updatedByUserId;

  /// Returns a shallow copy of this [CmsDocument]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  CmsDocument copyWith({
    int? id,
    String? documentType,
    String? data,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? createdByUserId,
    int? updatedByUserId,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'documentType': documentType,
      'data': data,
      if (createdAt != null) 'createdAt': createdAt?.toJson(),
      if (updatedAt != null) 'updatedAt': updatedAt?.toJson(),
      if (createdByUserId != null) 'createdByUserId': createdByUserId,
      if (updatedByUserId != null) 'updatedByUserId': updatedByUserId,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CmsDocumentImpl extends CmsDocument {
  _CmsDocumentImpl({
    int? id,
    required String documentType,
    required String data,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? createdByUserId,
    int? updatedByUserId,
  }) : super._(
          id: id,
          documentType: documentType,
          data: data,
          createdAt: createdAt,
          updatedAt: updatedAt,
          createdByUserId: createdByUserId,
          updatedByUserId: updatedByUserId,
        );

  /// Returns a shallow copy of this [CmsDocument]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  CmsDocument copyWith({
    Object? id = _Undefined,
    String? documentType,
    String? data,
    Object? createdAt = _Undefined,
    Object? updatedAt = _Undefined,
    Object? createdByUserId = _Undefined,
    Object? updatedByUserId = _Undefined,
  }) {
    return CmsDocument(
      id: id is int? ? id : this.id,
      documentType: documentType ?? this.documentType,
      data: data ?? this.data,
      createdAt: createdAt is DateTime? ? createdAt : this.createdAt,
      updatedAt: updatedAt is DateTime? ? updatedAt : this.updatedAt,
      createdByUserId:
          createdByUserId is int? ? createdByUserId : this.createdByUserId,
      updatedByUserId:
          updatedByUserId is int? ? updatedByUserId : this.updatedByUserId,
    );
  }
}
