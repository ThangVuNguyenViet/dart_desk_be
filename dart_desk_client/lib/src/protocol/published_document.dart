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
import 'package:dart_desk_client/src/protocol/protocol.dart' as _i2;

abstract class PublishedDocument implements _i1.SerializableModel {
  PublishedDocument._({
    _i1.UuidValue? id,
    required this.documentId,
    required this.projectId,
    required this.documentType,
    required this.title,
    required this.slug,
    bool? isDefault,
    this.data,
    required this.publishedAt,
    required this.publishedVersionId,
    DateTime? updatedAt,
    this.deletedAt,
  }) : id = id ?? const _i1.Uuid().v4obj(),
       isDefault = isDefault ?? false,
       updatedAt = updatedAt ?? DateTime.now();

  factory PublishedDocument({
    _i1.UuidValue? id,
    required _i1.UuidValue documentId,
    required _i1.UuidValue projectId,
    required String documentType,
    required String title,
    required String slug,
    bool? isDefault,
    Map<String, dynamic>? data,
    required DateTime publishedAt,
    required _i1.UuidValue publishedVersionId,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) = _PublishedDocumentImpl;

  factory PublishedDocument.fromJson(Map<String, dynamic> jsonSerialization) {
    return PublishedDocument(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      documentId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['documentId'],
      ),
      projectId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['projectId'],
      ),
      documentType: jsonSerialization['documentType'] as String,
      title: jsonSerialization['title'] as String,
      slug: jsonSerialization['slug'] as String,
      isDefault: jsonSerialization['isDefault'] == null
          ? null
          : _i1.BoolJsonExtension.fromJson(jsonSerialization['isDefault']),
      data: jsonSerialization['data'] == null
          ? null
          : _i2.Protocol().deserialize<Map<String, dynamic>>(
              jsonSerialization['data'],
            ),
      publishedAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['publishedAt'],
      ),
      publishedVersionId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['publishedVersionId'],
      ),
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
      deletedAt: jsonSerialization['deletedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['deletedAt']),
    );
  }

  /// The id of the object.
  _i1.UuidValue id;

  _i1.UuidValue documentId;

  _i1.UuidValue projectId;

  String documentType;

  String title;

  String slug;

  bool isDefault;

  Map<String, dynamic>? data;

  DateTime publishedAt;

  _i1.UuidValue publishedVersionId;

  DateTime? updatedAt;

  DateTime? deletedAt;

  /// Returns a shallow copy of this [PublishedDocument]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  PublishedDocument copyWith({
    _i1.UuidValue? id,
    _i1.UuidValue? documentId,
    _i1.UuidValue? projectId,
    String? documentType,
    String? title,
    String? slug,
    bool? isDefault,
    Map<String, dynamic>? data,
    DateTime? publishedAt,
    _i1.UuidValue? publishedVersionId,
    DateTime? updatedAt,
    DateTime? deletedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'PublishedDocument',
      'id': id.toJson(),
      'documentId': documentId.toJson(),
      'projectId': projectId.toJson(),
      'documentType': documentType,
      'title': title,
      'slug': slug,
      'isDefault': isDefault,
      if (data != null)
        'data': data?.toJson(
          valueToJson: (v) => _i2.Protocol().encodeWithType(v),
        ),
      'publishedAt': publishedAt.toJson(),
      'publishedVersionId': publishedVersionId.toJson(),
      if (updatedAt != null) 'updatedAt': updatedAt?.toJson(),
      if (deletedAt != null) 'deletedAt': deletedAt?.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _PublishedDocumentImpl extends PublishedDocument {
  _PublishedDocumentImpl({
    _i1.UuidValue? id,
    required _i1.UuidValue documentId,
    required _i1.UuidValue projectId,
    required String documentType,
    required String title,
    required String slug,
    bool? isDefault,
    Map<String, dynamic>? data,
    required DateTime publishedAt,
    required _i1.UuidValue publishedVersionId,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) : super._(
         id: id,
         documentId: documentId,
         projectId: projectId,
         documentType: documentType,
         title: title,
         slug: slug,
         isDefault: isDefault,
         data: data,
         publishedAt: publishedAt,
         publishedVersionId: publishedVersionId,
         updatedAt: updatedAt,
         deletedAt: deletedAt,
       );

  /// Returns a shallow copy of this [PublishedDocument]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  PublishedDocument copyWith({
    _i1.UuidValue? id,
    _i1.UuidValue? documentId,
    _i1.UuidValue? projectId,
    String? documentType,
    String? title,
    String? slug,
    bool? isDefault,
    Object? data = _Undefined,
    DateTime? publishedAt,
    _i1.UuidValue? publishedVersionId,
    Object? updatedAt = _Undefined,
    Object? deletedAt = _Undefined,
  }) {
    return PublishedDocument(
      id: id ?? this.id,
      documentId: documentId ?? this.documentId,
      projectId: projectId ?? this.projectId,
      documentType: documentType ?? this.documentType,
      title: title ?? this.title,
      slug: slug ?? this.slug,
      isDefault: isDefault ?? this.isDefault,
      data: data is Map<String, dynamic>?
          ? data
          : this.data?.map(
              (
                key0,
                value0,
              ) => MapEntry(
                key0,
                value0,
              ),
            ),
      publishedAt: publishedAt ?? this.publishedAt,
      publishedVersionId: publishedVersionId ?? this.publishedVersionId,
      updatedAt: updatedAt is DateTime? ? updatedAt : this.updatedAt,
      deletedAt: deletedAt is DateTime? ? deletedAt : this.deletedAt,
    );
  }
}
