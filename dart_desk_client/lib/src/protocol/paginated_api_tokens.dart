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
import 'api_token.dart' as _i2;
import 'package:dart_desk_client/src/protocol/protocol.dart' as _i3;

abstract class PaginatedApiTokens implements _i1.SerializableModel {
  PaginatedApiTokens._({
    required this.items,
    required this.total,
    required this.limit,
    required this.offset,
    required this.hasMore,
  });

  factory PaginatedApiTokens({
    required List<_i2.ApiToken> items,
    required int total,
    required int limit,
    required int offset,
    required bool hasMore,
  }) = _PaginatedApiTokensImpl;

  factory PaginatedApiTokens.fromJson(Map<String, dynamic> jsonSerialization) {
    return PaginatedApiTokens(
      items: _i3.Protocol().deserialize<List<_i2.ApiToken>>(
        jsonSerialization['items'],
      ),
      total: jsonSerialization['total'] as int,
      limit: jsonSerialization['limit'] as int,
      offset: jsonSerialization['offset'] as int,
      hasMore: _i1.BoolJsonExtension.fromJson(jsonSerialization['hasMore']),
    );
  }

  List<_i2.ApiToken> items;

  int total;

  int limit;

  int offset;

  bool hasMore;

  /// Returns a shallow copy of this [PaginatedApiTokens]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  PaginatedApiTokens copyWith({
    List<_i2.ApiToken>? items,
    int? total,
    int? limit,
    int? offset,
    bool? hasMore,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'PaginatedApiTokens',
      'items': items.toJson(valueToJson: (v) => v.toJson()),
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

class _PaginatedApiTokensImpl extends PaginatedApiTokens {
  _PaginatedApiTokensImpl({
    required List<_i2.ApiToken> items,
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

  /// Returns a shallow copy of this [PaginatedApiTokens]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  PaginatedApiTokens copyWith({
    List<_i2.ApiToken>? items,
    int? total,
    int? limit,
    int? offset,
    bool? hasMore,
  }) {
    return PaginatedApiTokens(
      items: items ?? this.items.map((e0) => e0.copyWith()).toList(),
      total: total ?? this.total,
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}
