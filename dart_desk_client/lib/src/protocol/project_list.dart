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
import 'project.dart' as _i2;
import 'package:dart_desk_client/src/protocol/protocol.dart' as _i3;

abstract class ProjectList implements _i1.SerializableModel {
  ProjectList._({
    required this.projects,
    required this.total,
    required this.page,
    required this.pageSize,
  });

  factory ProjectList({
    required List<_i2.Project> projects,
    required int total,
    required int page,
    required int pageSize,
  }) = _ProjectListImpl;

  factory ProjectList.fromJson(Map<String, dynamic> jsonSerialization) {
    return ProjectList(
      projects: _i3.Protocol().deserialize<List<_i2.Project>>(
        jsonSerialization['projects'],
      ),
      total: jsonSerialization['total'] as int,
      page: jsonSerialization['page'] as int,
      pageSize: jsonSerialization['pageSize'] as int,
    );
  }

  List<_i2.Project> projects;

  int total;

  int page;

  int pageSize;

  /// Returns a shallow copy of this [ProjectList]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ProjectList copyWith({
    List<_i2.Project>? projects,
    int? total,
    int? page,
    int? pageSize,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ProjectList',
      'projects': projects.toJson(valueToJson: (v) => v.toJson()),
      'total': total,
      'page': page,
      'pageSize': pageSize,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _ProjectListImpl extends ProjectList {
  _ProjectListImpl({
    required List<_i2.Project> projects,
    required int total,
    required int page,
    required int pageSize,
  }) : super._(
         projects: projects,
         total: total,
         page: page,
         pageSize: pageSize,
       );

  /// Returns a shallow copy of this [ProjectList]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ProjectList copyWith({
    List<_i2.Project>? projects,
    int? total,
    int? page,
    int? pageSize,
  }) {
    return ProjectList(
      projects: projects ?? this.projects.map((e0) => e0.copyWith()).toList(),
      total: total ?? this.total,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
    );
  }
}
