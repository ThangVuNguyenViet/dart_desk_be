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
import 'package:dart_desk_server/src/generated/protocol.dart' as _i3;

abstract class PaginatedProjects
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  PaginatedProjects._({
    required this.items,
    required this.total,
    required this.limit,
    required this.offset,
    required this.hasMore,
  });

  factory PaginatedProjects({
    required List<_i2.Project> items,
    required int total,
    required int limit,
    required int offset,
    required bool hasMore,
  }) = _PaginatedProjectsImpl;

  factory PaginatedProjects.fromJson(Map<String, dynamic> jsonSerialization) {
    return PaginatedProjects(
      items: _i3.Protocol().deserialize<List<_i2.Project>>(
        jsonSerialization['items'],
      ),
      total: jsonSerialization['total'] as int,
      limit: jsonSerialization['limit'] as int,
      offset: jsonSerialization['offset'] as int,
      hasMore: _i1.BoolJsonExtension.fromJson(jsonSerialization['hasMore']),
    );
  }

  List<_i2.Project> items;

  int total;

  int limit;

  int offset;

  bool hasMore;

  /// Returns a shallow copy of this [PaginatedProjects]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  PaginatedProjects copyWith({
    List<_i2.Project>? items,
    int? total,
    int? limit,
    int? offset,
    bool? hasMore,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'PaginatedProjects',
      'items': items.toJson(valueToJson: (v) => v.toJson()),
      'total': total,
      'limit': limit,
      'offset': offset,
      'hasMore': hasMore,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'PaginatedProjects',
      'items': items.toJson(valueToJson: (v) => v.toJsonForProtocol()),
      'total': total,
      'limit': limit,
      'offset': offset,
      'hasMore': hasMore,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _PaginatedProjectsImpl extends PaginatedProjects {
  _PaginatedProjectsImpl({
    required List<_i2.Project> items,
    required int total,
    required int limit,
    required int offset,
    required bool hasMore,
  }) : super._(
         items: items,
         total: total,
         limit: limit,
         offset: offset,
         hasMore: hasMore,
       );

  /// Returns a shallow copy of this [PaginatedProjects]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  PaginatedProjects copyWith({
    List<_i2.Project>? items,
    int? total,
    int? limit,
    int? offset,
    bool? hasMore,
  }) {
    return PaginatedProjects(
      items: items ?? this.items.map((e0) => e0.copyWith()).toList(),
      total: total ?? this.total,
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}
