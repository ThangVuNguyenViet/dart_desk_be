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

abstract class Document implements _i1.SerializableModel {
  Document._({
    _i1.UuidValue? id,
    required this.projectId,
    required this.documentType,
    required this.title,
    required this.slug,
    bool? isDefault,
    this.data,
    this.crdtNodeId,
    this.crdtHlc,
    this.publishedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.createdByUserId,
    this.updatedByUserId,
    this.deletedAt,
  }) : id = id ?? const _i1.Uuid().v4obj(),
       isDefault = isDefault ?? false,
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory Document({
    _i1.UuidValue? id,
    required _i1.UuidValue projectId,
    required String documentType,
    required String title,
    required String slug,
    bool? isDefault,
    String? data,
    String? crdtNodeId,
    String? crdtHlc,
    DateTime? publishedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    _i1.UuidValue? createdByUserId,
    _i1.UuidValue? updatedByUserId,
    DateTime? deletedAt,
  }) = _DocumentImpl;

  factory Document.fromJson(Map<String, dynamic> jsonSerialization) {
    return Document(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      projectId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['projectId'],
      ),
      documentType: jsonSerialization['documentType'] as String,
      title: jsonSerialization['title'] as String,
      slug: jsonSerialization['slug'] as String,
      isDefault: jsonSerialization['isDefault'] == null
          ? null
          : _i1.BoolJsonExtension.fromJson(jsonSerialization['isDefault']),
      data: jsonSerialization['data'] as String?,
      crdtNodeId: jsonSerialization['crdtNodeId'] as String?,
      crdtHlc: jsonSerialization['crdtHlc'] as String?,
      publishedAt: jsonSerialization['publishedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(
              jsonSerialization['publishedAt'],
            ),
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
      deletedAt: jsonSerialization['deletedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['deletedAt']),
    );
  }

  /// The id of the object.
  _i1.UuidValue id;

  _i1.UuidValue projectId;

  String documentType;

  String title;

  String slug;

  bool isDefault;

  String? data;

  String? crdtNodeId;

  String? crdtHlc;

  DateTime? publishedAt;

  DateTime? createdAt;

  DateTime? updatedAt;

  _i1.UuidValue? createdByUserId;

  _i1.UuidValue? updatedByUserId;

  DateTime? deletedAt;

  /// Returns a shallow copy of this [Document]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  Document copyWith({
    _i1.UuidValue? id,
    _i1.UuidValue? projectId,
    String? documentType,
    String? title,
    String? slug,
    bool? isDefault,
    String? data,
    String? crdtNodeId,
    String? crdtHlc,
    DateTime? publishedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    _i1.UuidValue? createdByUserId,
    _i1.UuidValue? updatedByUserId,
    DateTime? deletedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Document',
      'id': id.toJson(),
      'projectId': projectId.toJson(),
      'documentType': documentType,
      'title': title,
      'slug': slug,
      'isDefault': isDefault,
      if (data != null) 'data': data,
      if (crdtNodeId != null) 'crdtNodeId': crdtNodeId,
      if (crdtHlc != null) 'crdtHlc': crdtHlc,
      if (publishedAt != null) 'publishedAt': publishedAt?.toJson(),
      if (createdAt != null) 'createdAt': createdAt?.toJson(),
      if (updatedAt != null) 'updatedAt': updatedAt?.toJson(),
      if (createdByUserId != null) 'createdByUserId': createdByUserId?.toJson(),
      if (updatedByUserId != null) 'updatedByUserId': updatedByUserId?.toJson(),
      if (deletedAt != null) 'deletedAt': deletedAt?.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _DocumentImpl extends Document {
  _DocumentImpl({
    _i1.UuidValue? id,
    required _i1.UuidValue projectId,
    required String documentType,
    required String title,
    required String slug,
    bool? isDefault,
    String? data,
    String? crdtNodeId,
    String? crdtHlc,
    DateTime? publishedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    _i1.UuidValue? createdByUserId,
    _i1.UuidValue? updatedByUserId,
    DateTime? deletedAt,
  }) : super._(
         id: id,
         projectId: projectId,
         documentType: documentType,
         title: title,
         slug: slug,
         isDefault: isDefault,
         data: data,
         crdtNodeId: crdtNodeId,
         crdtHlc: crdtHlc,
         publishedAt: publishedAt,
         createdAt: createdAt,
         updatedAt: updatedAt,
         createdByUserId: createdByUserId,
         updatedByUserId: updatedByUserId,
         deletedAt: deletedAt,
       );

  /// Returns a shallow copy of this [Document]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  Document copyWith({
    _i1.UuidValue? id,
    _i1.UuidValue? projectId,
    String? documentType,
    String? title,
    String? slug,
    bool? isDefault,
    Object? data = _Undefined,
    Object? crdtNodeId = _Undefined,
    Object? crdtHlc = _Undefined,
    Object? publishedAt = _Undefined,
    Object? createdAt = _Undefined,
    Object? updatedAt = _Undefined,
    Object? createdByUserId = _Undefined,
    Object? updatedByUserId = _Undefined,
    Object? deletedAt = _Undefined,
  }) {
    return Document(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      documentType: documentType ?? this.documentType,
      title: title ?? this.title,
      slug: slug ?? this.slug,
      isDefault: isDefault ?? this.isDefault,
      data: data is String? ? data : this.data,
      crdtNodeId: crdtNodeId is String? ? crdtNodeId : this.crdtNodeId,
      crdtHlc: crdtHlc is String? ? crdtHlc : this.crdtHlc,
      publishedAt: publishedAt is DateTime? ? publishedAt : this.publishedAt,
      createdAt: createdAt is DateTime? ? createdAt : this.createdAt,
      updatedAt: updatedAt is DateTime? ? updatedAt : this.updatedAt,
      createdByUserId: createdByUserId is _i1.UuidValue?
          ? createdByUserId
          : this.createdByUserId,
      updatedByUserId: updatedByUserId is _i1.UuidValue?
          ? updatedByUserId
          : this.updatedByUserId,
      deletedAt: deletedAt is DateTime? ? deletedAt : this.deletedAt,
    );
  }
}
