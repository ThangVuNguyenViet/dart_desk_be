/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod/serverpod.dart' as _i1;

abstract class UploadResponse
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  UploadResponse._({
    required this.id,
    required this.url,
    this.fileName,
  });

  factory UploadResponse({
    required String id,
    required String url,
    String? fileName,
  }) = _UploadResponseImpl;

  factory UploadResponse.fromJson(Map<String, dynamic> jsonSerialization) {
    return UploadResponse(
      id: jsonSerialization['id'] as String,
      url: jsonSerialization['url'] as String,
      fileName: jsonSerialization['fileName'] as String?,
    );
  }

  String url;

  String id;

  String? fileName;

  /// Returns a shallow copy of this [UploadResponse]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  UploadResponse copyWith({
    String? id,
    String? url,
    String? fileName,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      if (fileName != null) 'fileName': fileName,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      'id': id,
      'url': url,
      if (fileName != null) 'fileName': fileName,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _UploadResponseImpl extends UploadResponse {
  _UploadResponseImpl({
    required String id,
    required String url,
    String? fileName,
  }) : super._(
          id: id,
          url: url,
          fileName: fileName,
        );

  /// Returns a shallow copy of this [UploadResponse]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  UploadResponse copyWith({
    String? id,
    String? url,
    Object? fileName = _Undefined,
  }) {
    return UploadResponse(
      id: id ?? this.id,
      url: url ?? this.url,
      fileName: fileName is String? ? fileName : this.fileName,
    );
  }
}
