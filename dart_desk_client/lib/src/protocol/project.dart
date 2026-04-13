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
    _i1.UuidValue? id,
    required this.clientId,
    required this.name,
    required this.slug,
    this.description,
    bool? isActive,
    this.settings,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : id = id ?? const _i1.Uuid().v4obj(),
       isActive = isActive ?? true,
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory Project({
    _i1.UuidValue? id,
    required _i1.UuidValue clientId,
    required String name,
    required String slug,
    String? description,
    bool? isActive,
    String? settings,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _ProjectImpl;

  factory Project.fromJson(Map<String, dynamic> jsonSerialization) {
    return Project(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      clientId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['clientId'],
      ),
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
    );
  }

  /// The id of the object.
  _i1.UuidValue id;

  _i1.UuidValue clientId;

  String name;

  String slug;

  String? description;

  bool isActive;

  String? settings;

  DateTime? createdAt;

  DateTime? updatedAt;

  /// Returns a shallow copy of this [Project]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  Project copyWith({
    _i1.UuidValue? id,
    _i1.UuidValue? clientId,
    String? name,
    String? slug,
    String? description,
    bool? isActive,
    String? settings,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Project',
      'id': id.toJson(),
      'clientId': clientId.toJson(),
      'name': name,
      'slug': slug,
      if (description != null) 'description': description,
      'isActive': isActive,
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
    _i1.UuidValue? id,
    required _i1.UuidValue clientId,
    required String name,
    required String slug,
    String? description,
    bool? isActive,
    String? settings,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : super._(
         id: id,
         clientId: clientId,
         name: name,
         slug: slug,
         description: description,
         isActive: isActive,
         settings: settings,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [Project]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  Project copyWith({
    _i1.UuidValue? id,
    _i1.UuidValue? clientId,
    String? name,
    String? slug,
    Object? description = _Undefined,
    bool? isActive,
    Object? settings = _Undefined,
    Object? createdAt = _Undefined,
    Object? updatedAt = _Undefined,
  }) {
    return Project(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      description: description is String? ? description : this.description,
      isActive: isActive ?? this.isActive,
      settings: settings is String? ? settings : this.settings,
      createdAt: createdAt is DateTime? ? createdAt : this.createdAt,
      updatedAt: updatedAt is DateTime? ? updatedAt : this.updatedAt,
    );
  }
}
