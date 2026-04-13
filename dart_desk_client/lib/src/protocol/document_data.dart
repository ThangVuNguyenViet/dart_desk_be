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

abstract class DocumentData implements _i1.SerializableModel {
  DocumentData._({
    _i1.UuidValue? id,
    required this.documentType,
    required this.data,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.createdByUserId,
    this.updatedByUserId,
  }) : id = id ?? const _i1.Uuid().v4obj(),
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory DocumentData({
    _i1.UuidValue? id,
    required String documentType,
    required String data,
    DateTime? createdAt,
    DateTime? updatedAt,
    _i1.UuidValue? createdByUserId,
    _i1.UuidValue? updatedByUserId,
  }) = _DocumentDataImpl;

  factory DocumentData.fromJson(Map<String, dynamic> jsonSerialization) {
    return DocumentData(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      documentType: jsonSerialization['documentType'] as String,
      data: jsonSerialization['data'] as String,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
      createdByUserId: jsonSerialization['createdByUserId'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(
              jsonSerialization['createdByUserId'],
            ),
      updatedByUserId: jsonSerialization['updatedByUserId'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(
              jsonSerialization['updatedByUserId'],
            ),
    );
  }

  /// The id of the object.
  _i1.UuidValue id;

  String documentType;

  String data;

  DateTime? createdAt;

  DateTime? updatedAt;

  _i1.UuidValue? createdByUserId;

  _i1.UuidValue? updatedByUserId;

  /// Returns a shallow copy of this [DocumentData]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  DocumentData copyWith({
    _i1.UuidValue? id,
    String? documentType,
    String? data,
    DateTime? createdAt,
    DateTime? updatedAt,
    _i1.UuidValue? createdByUserId,
    _i1.UuidValue? updatedByUserId,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'DocumentData',
      'id': id.toJson(),
      'documentType': documentType,
      'data': data,
      if (createdAt != null) 'createdAt': createdAt?.toJson(),
      if (updatedAt != null) 'updatedAt': updatedAt?.toJson(),
      if (createdByUserId != null) 'createdByUserId': createdByUserId?.toJson(),
      if (updatedByUserId != null) 'updatedByUserId': updatedByUserId?.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _DocumentDataImpl extends DocumentData {
  _DocumentDataImpl({
    _i1.UuidValue? id,
    required String documentType,
    required String data,
    DateTime? createdAt,
    DateTime? updatedAt,
    _i1.UuidValue? createdByUserId,
    _i1.UuidValue? updatedByUserId,
  }) : super._(
         id: id,
         documentType: documentType,
         data: data,
         createdAt: createdAt,
         updatedAt: updatedAt,
         createdByUserId: createdByUserId,
         updatedByUserId: updatedByUserId,
       );

  /// Returns a shallow copy of this [DocumentData]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  DocumentData copyWith({
    _i1.UuidValue? id,
    String? documentType,
    String? data,
    Object? createdAt = _Undefined,
    Object? updatedAt = _Undefined,
    Object? createdByUserId = _Undefined,
    Object? updatedByUserId = _Undefined,
  }) {
    return DocumentData(
      id: id ?? this.id,
      documentType: documentType ?? this.documentType,
      data: data ?? this.data,
      createdAt: createdAt is DateTime? ? createdAt : this.createdAt,
      updatedAt: updatedAt is DateTime? ? updatedAt : this.updatedAt,
      createdByUserId: createdByUserId is _i1.UuidValue?
          ? createdByUserId
          : this.createdByUserId,
      updatedByUserId: updatedByUserId is _i1.UuidValue?
          ? updatedByUserId
          : this.updatedByUserId,
    );
  }
}
