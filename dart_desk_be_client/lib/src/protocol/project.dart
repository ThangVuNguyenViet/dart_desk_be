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

abstract class Project implements _i1.SerializableModel {
  Project._({
    this.id,
    required this.name,
    required this.slug,
    required this.apiTokenHash,
    this.description,
    bool? isActive,
    this.apiTokenPrefix,
    this.lastUsedAt,
    this.settings,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : isActive = isActive ?? true,
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory Project({
    int? id,
    required String name,
    required String slug,
    required String apiTokenHash,
    String? description,
    bool? isActive,
    String? apiTokenPrefix,
    DateTime? lastUsedAt,
    String? settings,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _ProjectImpl;

  factory Project.fromJson(Map<String, dynamic> jsonSerialization) {
    return Project(
      id: jsonSerialization['id'] as int?,
      name: jsonSerialization['name'] as String,
      slug: jsonSerialization['slug'] as String,
      apiTokenHash: jsonSerialization['apiTokenHash'] as String,
      description: jsonSerialization['description'] as String?,
      isActive: jsonSerialization['isActive'] == null
          ? null
          : _i1.BoolJsonExtension.fromJson(jsonSerialization['isActive']),
      apiTokenPrefix: jsonSerialization['apiTokenPrefix'] as String?,
      lastUsedAt: jsonSerialization['lastUsedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['lastUsedAt']),
      settings: jsonSerialization['settings'] as String?,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  String name;

  String slug;

  String apiTokenHash;

  String? description;

  bool isActive;

  String? apiTokenPrefix;

  DateTime? lastUsedAt;

  String? settings;

  DateTime? createdAt;

  DateTime? updatedAt;

  /// Returns a shallow copy of this [Project]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  Project copyWith({
    int? id,
    String? name,
    String? slug,
    String? apiTokenHash,
    String? description,
    bool? isActive,
    String? apiTokenPrefix,
    DateTime? lastUsedAt,
    String? settings,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Project',
      if (id != null) 'id': id,
      'name': name,
      'slug': slug,
      'apiTokenHash': apiTokenHash,
      if (description != null) 'description': description,
      'isActive': isActive,
      if (apiTokenPrefix != null) 'apiTokenPrefix': apiTokenPrefix,
      if (lastUsedAt != null) 'lastUsedAt': lastUsedAt?.toJson(),
      if (settings != null) 'settings': settings,
      if (createdAt != null) 'createdAt': createdAt?.toJson(),
      if (updatedAt != null) 'updatedAt': updatedAt?.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ProjectImpl extends Project {
  _ProjectImpl({
    int? id,
    required String name,
    required String slug,
    required String apiTokenHash,
    String? description,
    bool? isActive,
    String? apiTokenPrefix,
    DateTime? lastUsedAt,
    String? settings,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : super._(
         id: id,
         name: name,
         slug: slug,
         apiTokenHash: apiTokenHash,
         description: description,
         isActive: isActive,
         apiTokenPrefix: apiTokenPrefix,
         lastUsedAt: lastUsedAt,
         settings: settings,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [Project]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  Project copyWith({
    Object? id = _Undefined,
    String? name,
    String? slug,
    String? apiTokenHash,
    Object? description = _Undefined,
    bool? isActive,
    Object? apiTokenPrefix = _Undefined,
    Object? lastUsedAt = _Undefined,
    Object? settings = _Undefined,
    Object? createdAt = _Undefined,
    Object? updatedAt = _Undefined,
  }) {
    return Project(
      id: id is int? ? id : this.id,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      apiTokenHash: apiTokenHash ?? this.apiTokenHash,
      description: description is String? ? description : this.description,
      isActive: isActive ?? this.isActive,
      apiTokenPrefix: apiTokenPrefix is String?
          ? apiTokenPrefix
          : this.apiTokenPrefix,
      lastUsedAt: lastUsedAt is DateTime? ? lastUsedAt : this.lastUsedAt,
      settings: settings is String? ? settings : this.settings,
      createdAt: createdAt is DateTime? ? createdAt : this.createdAt,
      updatedAt: updatedAt is DateTime? ? updatedAt : this.updatedAt,
    );
  }
}
