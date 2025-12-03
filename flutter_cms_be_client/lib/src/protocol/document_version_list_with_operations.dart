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
import 'document_version_with_operations.dart' as _i2;

abstract class DocumentVersionListWithOperations
    implements _i1.SerializableModel {
  DocumentVersionListWithOperations._({
    required this.versions,
    this.baseData,
    required this.total,
    required this.page,
    required this.pageSize,
  });

  factory DocumentVersionListWithOperations({
    required List<_i2.DocumentVersionWithOperations> versions,
    String? baseData,
    required int total,
    required int page,
    required int pageSize,
  }) = _DocumentVersionListWithOperationsImpl;

  factory DocumentVersionListWithOperations.fromJson(
      Map<String, dynamic> jsonSerialization) {
    return DocumentVersionListWithOperations(
      versions: (jsonSerialization['versions'] as List)
          .map((e) => _i2.DocumentVersionWithOperations.fromJson(
              (e as Map<String, dynamic>)))
          .toList(),
      baseData: jsonSerialization['baseData'] as String?,
      total: jsonSerialization['total'] as int,
      page: jsonSerialization['page'] as int,
      pageSize: jsonSerialization['pageSize'] as int,
    );
  }

  List<_i2.DocumentVersionWithOperations> versions;

  String? baseData;

  int total;

  int page;

  int pageSize;

  /// Returns a shallow copy of this [DocumentVersionListWithOperations]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  DocumentVersionListWithOperations copyWith({
    List<_i2.DocumentVersionWithOperations>? versions,
    String? baseData,
    int? total,
    int? page,
    int? pageSize,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      'versions': versions.toJson(valueToJson: (v) => v.toJson()),
      if (baseData != null) 'baseData': baseData,
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

class _Undefined {}

class _DocumentVersionListWithOperationsImpl
    extends DocumentVersionListWithOperations {
  _DocumentVersionListWithOperationsImpl({
    required List<_i2.DocumentVersionWithOperations> versions,
    String? baseData,
    required int total,
    required int page,
    required int pageSize,
  }) : super._(
          versions: versions,
          baseData: baseData,
          total: total,
          page: page,
          pageSize: pageSize,
        );

  /// Returns a shallow copy of this [DocumentVersionListWithOperations]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  DocumentVersionListWithOperations copyWith({
    List<_i2.DocumentVersionWithOperations>? versions,
    Object? baseData = _Undefined,
    int? total,
    int? page,
    int? pageSize,
  }) {
    return DocumentVersionListWithOperations(
      versions: versions ?? this.versions.map((e0) => e0.copyWith()).toList(),
      baseData: baseData is String? ? baseData : this.baseData,
      total: total ?? this.total,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
    );
  }
}
