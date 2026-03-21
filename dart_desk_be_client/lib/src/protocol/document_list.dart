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
import 'cms_document.dart' as _i2;
import 'package:dart_desk_be_client/src/protocol/protocol.dart' as _i3;

abstract class DocumentList implements _i1.SerializableModel {
  DocumentList._({
    required this.documents,
    required this.total,
    required this.page,
    required this.pageSize,
  });

  factory DocumentList({
    required List<_i2.Document> documents,
    required int total,
    required int page,
    required int pageSize,
  }) = _DocumentListImpl;

  factory DocumentList.fromJson(Map<String, dynamic> jsonSerialization) {
    return DocumentList(
      documents: _i3.Protocol().deserialize<List<_i2.Document>>(
        jsonSerialization['documents'],
      ),
      total: jsonSerialization['total'] as int,
      page: jsonSerialization['page'] as int,
      pageSize: jsonSerialization['pageSize'] as int,
    );
  }

  List<_i2.Document> documents;

  int total;

  int page;

  int pageSize;

  /// Returns a shallow copy of this [DocumentList]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  DocumentList copyWith({
    List<_i2.Document>? documents,
    int? total,
    int? page,
    int? pageSize,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'DocumentList',
      'documents': documents.toJson(valueToJson: (v) => v.toJson()),
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

class _DocumentListImpl extends DocumentList {
  _DocumentListImpl({
    required List<_i2.Document> documents,
    required int total,
    required int page,
    required int pageSize,
  }) : super._(
         documents: documents,
         total: total,
         page: page,
         pageSize: pageSize,
       );

  /// Returns a shallow copy of this [DocumentList]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  DocumentList copyWith({
    List<_i2.Document>? documents,
    int? total,
    int? page,
    int? pageSize,
  }) {
    return DocumentList(
      documents:
          documents ?? this.documents.map((e0) => e0.copyWith()).toList(),
      total: total ?? this.total,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
    );
  }
}
