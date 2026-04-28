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

abstract class CmsClient implements _i1.SerializableModel {
  CmsClient._({
    _i1.UuidValue? id,
    required this.name,
    required this.slug,
    this.description,
    bool? isActive,
    this.settings,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.deletedAt,
  }) : id = id ?? const _i1.Uuid().v4obj(),
       isActive = isActive ?? true,
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory CmsClient({
    _i1.UuidValue? id,
    required String name,
    required String slug,
    String? description,
    bool? isActive,
    String? settings,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) = _CmsClientImpl;

  factory CmsClient.fromJson(Map<String, dynamic> jsonSerialization) {
    return CmsClient(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      name: jsonSerialization['name'] as String,
      slug: jsonSerialization['slug'] as String,
      description: jsonSerialization['description'] as String?,
      isActive: jsonSerialization['isActive'] == null
          ? null
          : _i1.BoolJsonExtension.fromJson(jsonSerialization['isActive']),
      settings: jsonSerialization['settings'] as String?,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
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

  String name;

  String slug;

  String? description;

  bool isActive;

  String? settings;

  DateTime? createdAt;

  DateTime? updatedAt;

  DateTime? deletedAt;

  /// Returns a shallow copy of this [CmsClient]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  CmsClient copyWith({
    _i1.UuidValue? id,
    String? name,
    String? slug,
    String? description,
    bool? isActive,
    String? settings,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'CmsClient',
      'id': id.toJson(),
      'name': name,
      'slug': slug,
      if (description != null) 'description': description,
      'isActive': isActive,
      if (settings != null) 'settings': settings,
      if (createdAt != null) 'createdAt': createdAt?.toJson(),
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

class _CmsClientImpl extends CmsClient {
  _CmsClientImpl({
    _i1.UuidValue? id,
    required String name,
    required String slug,
    String? description,
    bool? isActive,
    String? settings,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) : super._(
         id: id,
         name: name,
         slug: slug,
         description: description,
         isActive: isActive,
         settings: settings,
         createdAt: createdAt,
         updatedAt: updatedAt,
         deletedAt: deletedAt,
       );

  /// Returns a shallow copy of this [CmsClient]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  CmsClient copyWith({
    _i1.UuidValue? id,
    String? name,
    String? slug,
    Object? description = _Undefined,
    bool? isActive,
    Object? settings = _Undefined,
    Object? createdAt = _Undefined,
    Object? updatedAt = _Undefined,
    Object? deletedAt = _Undefined,
  }) {
    return CmsClient(
      id: id ?? this.id,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      description: description is String? ? description : this.description,
      isActive: isActive ?? this.isActive,
      settings: settings is String? ? settings : this.settings,
      createdAt: createdAt is DateTime? ? createdAt : this.createdAt,
      updatedAt: updatedAt is DateTime? ? updatedAt : this.updatedAt,
      deletedAt: deletedAt is DateTime? ? deletedAt : this.deletedAt,
    );
  }
}
