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

abstract class Document implements _i1.SerializableModel {
  Document._({
    this.id,
    required this.clientId,
    required this.documentType,
    required this.title,
    this.slug,
    this.currentVersionId,
    DateTime? createdAt,
    DateTime? updatedAt,
    required this.createdByUserId,
    this.updatedByUserId,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory Document({
    int? id,
    required int clientId,
    required String documentType,
    required String title,
    String? slug,
    int? currentVersionId,
    DateTime? createdAt,
    DateTime? updatedAt,
    required int createdByUserId,
    int? updatedByUserId,
  }) = _DocumentImpl;

  factory Document.fromJson(Map<String, dynamic> jsonSerialization) {
    return Document(
      id: jsonSerialization['id'] as int?,
      clientId: jsonSerialization['clientId'] as int,
      documentType: jsonSerialization['documentType'] as String,
      title: jsonSerialization['title'] as String,
      slug: jsonSerialization['slug'] as String?,
      currentVersionId: jsonSerialization['currentVersionId'] as int?,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
      createdByUserId: jsonSerialization['createdByUserId'] as int,
      updatedByUserId: jsonSerialization['updatedByUserId'] as int?,
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int clientId;

  String documentType;

  String title;

  String? slug;

  int? currentVersionId;

  DateTime? createdAt;

  DateTime? updatedAt;

  int createdByUserId;

  int? updatedByUserId;

  /// Returns a shallow copy of this [Document]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  Document copyWith({
    int? id,
    int? clientId,
    String? documentType,
    String? title,
    String? slug,
    int? currentVersionId,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? createdByUserId,
    int? updatedByUserId,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'clientId': clientId,
      'documentType': documentType,
      'title': title,
      if (slug != null) 'slug': slug,
      if (currentVersionId != null) 'currentVersionId': currentVersionId,
      if (createdAt != null) 'createdAt': createdAt?.toJson(),
      if (updatedAt != null) 'updatedAt': updatedAt?.toJson(),
      'createdByUserId': createdByUserId,
      if (updatedByUserId != null) 'updatedByUserId': updatedByUserId,
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
    int? id,
    required int clientId,
    required String documentType,
    required String title,
    String? slug,
    int? currentVersionId,
    DateTime? createdAt,
    DateTime? updatedAt,
    required int createdByUserId,
    int? updatedByUserId,
  }) : super._(
          id: id,
          clientId: clientId,
          documentType: documentType,
          title: title,
          slug: slug,
          currentVersionId: currentVersionId,
          createdAt: createdAt,
          updatedAt: updatedAt,
          createdByUserId: createdByUserId,
          updatedByUserId: updatedByUserId,
        );

  /// Returns a shallow copy of this [Document]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  Document copyWith({
    Object? id = _Undefined,
    int? clientId,
    String? documentType,
    String? title,
    Object? slug = _Undefined,
    Object? currentVersionId = _Undefined,
    Object? createdAt = _Undefined,
    Object? updatedAt = _Undefined,
    int? createdByUserId,
    Object? updatedByUserId = _Undefined,
  }) {
    return Document(
      id: id is int? ? id : this.id,
      clientId: clientId ?? this.clientId,
      documentType: documentType ?? this.documentType,
      title: title ?? this.title,
      slug: slug is String? ? slug : this.slug,
      currentVersionId:
          currentVersionId is int? ? currentVersionId : this.currentVersionId,
      createdAt: createdAt is DateTime? ? createdAt : this.createdAt,
      updatedAt: updatedAt is DateTime? ? updatedAt : this.updatedAt,
      createdByUserId: createdByUserId ?? this.createdByUserId,
      updatedByUserId:
          updatedByUserId is int? ? updatedByUserId : this.updatedByUserId,
    );
  }
}
