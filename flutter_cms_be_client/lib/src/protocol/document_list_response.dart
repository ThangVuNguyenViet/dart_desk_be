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
import 'cms_document.dart' as _i2;

abstract class DocumentListResponse implements _i1.SerializableModel {
  DocumentListResponse._({
    required this.documents,
    required this.total,
    required this.page,
    required this.pageSize,
  });

  factory DocumentListResponse({
    required List<_i2.CmsDocument> documents,
    required int total,
    required int page,
    required int pageSize,
  }) = _DocumentListResponseImpl;

  factory DocumentListResponse.fromJson(
      Map<String, dynamic> jsonSerialization) {
    return DocumentListResponse(
      documents: (jsonSerialization['documents'] as List)
          .map((e) => _i2.CmsDocument.fromJson((e as Map<String, dynamic>)))
          .toList(),
      total: jsonSerialization['total'] as int,
      page: jsonSerialization['page'] as int,
      pageSize: jsonSerialization['pageSize'] as int,
    );
  }

  List<_i2.CmsDocument> documents;

  int total;

  int page;

  int pageSize;

  /// Returns a shallow copy of this [DocumentListResponse]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  DocumentListResponse copyWith({
    List<_i2.CmsDocument>? documents,
    int? total,
    int? page,
    int? pageSize,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
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

class _DocumentListResponseImpl extends DocumentListResponse {
  _DocumentListResponseImpl({
    required List<_i2.CmsDocument> documents,
    required int total,
    required int page,
    required int pageSize,
  }) : super._(
          documents: documents,
          total: total,
          page: page,
          pageSize: pageSize,
        );

  /// Returns a shallow copy of this [DocumentListResponse]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  DocumentListResponse copyWith({
    List<_i2.CmsDocument>? documents,
    int? total,
    int? page,
    int? pageSize,
  }) {
    return DocumentListResponse(
      documents:
          documents ?? this.documents.map((e0) => e0.copyWith()).toList(),
      total: total ?? this.total,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
    );
  }
}
