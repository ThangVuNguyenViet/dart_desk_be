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
import 'package:serverpod/serverpod.dart' as _i1;
import 'project.dart' as _i2;
import 'package:dart_desk_be_server/src/generated/protocol.dart' as _i3;

abstract class ProjectWithToken
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  ProjectWithToken._({
    required this.project,
    required this.apiToken,
  });

  factory ProjectWithToken({
    required _i2.Project project,
    required String apiToken,
  }) = _ProjectWithTokenImpl;

  factory ProjectWithToken.fromJson(Map<String, dynamic> jsonSerialization) {
    return ProjectWithToken(
      project: _i3.Protocol().deserialize<_i2.Project>(
        jsonSerialization['project'],
      ),
      apiToken: jsonSerialization['apiToken'] as String,
    );
  }

  _i2.Project project;

  String apiToken;

  /// Returns a shallow copy of this [ProjectWithToken]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ProjectWithToken copyWith({
    _i2.Project? project,
    String? apiToken,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ProjectWithToken',
      'project': project.toJson(),
      'apiToken': apiToken,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'ProjectWithToken',
      'project': project.toJsonForProtocol(),
      'apiToken': apiToken,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _ProjectWithTokenImpl extends ProjectWithToken {
  _ProjectWithTokenImpl({
    required _i2.Project project,
    required String apiToken,
  }) : super._(
         project: project,
         apiToken: apiToken,
       );

  /// Returns a shallow copy of this [ProjectWithToken]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ProjectWithToken copyWith({
    _i2.Project? project,
    String? apiToken,
  }) {
    return ProjectWithToken(
      project: project ?? this.project.copyWith(),
      apiToken: apiToken ?? this.apiToken,
    );
  }
}
