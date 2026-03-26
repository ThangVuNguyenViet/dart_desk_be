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

abstract class PublicDocument implements _i1.SerializableModel {
  PublicDocument._({
    required this.id,
    required this.documentType,
    required this.title,
    required this.slug,
    required this.isDefault,
    required this.data,
    required this.publishedAt,
    required this.updatedAt,
  });

  factory PublicDocument({
    required int id,
    required String documentType,
    required String title,
    required String slug,
    required bool isDefault,
    required String data,
    required DateTime publishedAt,
    required DateTime updatedAt,
  }) = _PublicDocumentImpl;

  factory PublicDocument.fromJson(Map<String, dynamic> jsonSerialization) {
    return PublicDocument(
      id: jsonSerialization['id'] as int,
      documentType: jsonSerialization['documentType'] as String,
      title: jsonSerialization['title'] as String,
      slug: jsonSerialization['slug'] as String,
      isDefault: _i1.BoolJsonExtension.fromJson(jsonSerialization['isDefault']),
      data: jsonSerialization['data'] as String,
      publishedAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['publishedAt'],
      ),
      updatedAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['updatedAt'],
      ),
    );
  }

  int id;

  String documentType;

  String title;

  String slug;

  bool isDefault;

  String data;

  DateTime publishedAt;

  DateTime updatedAt;

  /// Returns a shallow copy of this [PublicDocument]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  PublicDocument copyWith({
    int? id,
    String? documentType,
    String? title,
    String? slug,
    bool? isDefault,
    String? data,
    DateTime? publishedAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'PublicDocument',
      'id': id,
      'documentType': documentType,
      'title': title,
      'slug': slug,
      'isDefault': isDefault,
      'data': data,
      'publishedAt': publishedAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _PublicDocumentImpl extends PublicDocument {
  _PublicDocumentImpl({
    required int id,
    required String documentType,
    required String title,
    required String slug,
    required bool isDefault,
    required String data,
    required DateTime publishedAt,
    required DateTime updatedAt,
  }) : super._(
         id: id,
         documentType: documentType,
         title: title,
         slug: slug,
         isDefault: isDefault,
         data: data,
         publishedAt: publishedAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [PublicDocument]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  PublicDocument copyWith({
    int? id,
    String? documentType,
    String? title,
    String? slug,
    bool? isDefault,
    String? data,
    DateTime? publishedAt,
    DateTime? updatedAt,
  }) {
    return PublicDocument(
      id: id ?? this.id,
      documentType: documentType ?? this.documentType,
      title: title ?? this.title,
      slug: slug ?? this.slug,
      isDefault: isDefault ?? this.isDefault,
      data: data ?? this.data,
      publishedAt: publishedAt ?? this.publishedAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
