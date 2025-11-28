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
import 'cms_user.dart' as _i3;
import 'document_list_response.dart' as _i4;
import 'media_file.dart' as _i5;
import 'upload_response.dart' as _i6;
import 'package:flutter_cms_be_client/src/protocol/media_file.dart' as _i7;
export 'cms_document.dart';
export 'cms_user.dart';
export 'document_list_response.dart';
export 'media_file.dart';
export 'upload_response.dart';
export 'client.dart';

class Protocol extends _i1.SerializationManager {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._();

  @override
  T deserialize<T>(
    dynamic data, [
    Type? t,
  ]) {
    t ??= T;
    if (t == _i2.CmsDocument) {
      return _i2.CmsDocument.fromJson(data) as T;
    }
    if (t == _i3.CmsUser) {
      return _i3.CmsUser.fromJson(data) as T;
    }
    if (t == _i4.DocumentListResponse) {
      return _i4.DocumentListResponse.fromJson(data) as T;
    }
    if (t == _i5.MediaFile) {
      return _i5.MediaFile.fromJson(data) as T;
    }
    if (t == _i6.UploadResponse) {
      return _i6.UploadResponse.fromJson(data) as T;
    }
    if (t == _i1.getType<_i2.CmsDocument?>()) {
      return (data != null ? _i2.CmsDocument.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i3.CmsUser?>()) {
      return (data != null ? _i3.CmsUser.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i4.DocumentListResponse?>()) {
      return (data != null ? _i4.DocumentListResponse.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i5.MediaFile?>()) {
      return (data != null ? _i5.MediaFile.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i6.UploadResponse?>()) {
      return (data != null ? _i6.UploadResponse.fromJson(data) : null) as T;
    }
    if (t == List<_i2.CmsDocument>) {
      return (data as List).map((e) => deserialize<_i2.CmsDocument>(e)).toList()
          as T;
    }
    if (t == Map<String, dynamic>) {
      return (data as Map).map((k, v) =>
          MapEntry(deserialize<String>(k), deserialize<dynamic>(v))) as T;
    }
    if (t == List<String>) {
      return (data as List).map((e) => deserialize<String>(e)).toList() as T;
    }
    if (t == List<_i7.MediaFile>) {
      return (data as List).map((e) => deserialize<_i7.MediaFile>(e)).toList()
          as T;
    }
    return super.deserialize<T>(data, t);
  }

  @override
  String? getClassNameForObject(Object? data) {
    String? className = super.getClassNameForObject(data);
    if (className != null) return className;
    if (data is _i2.CmsDocument) {
      return 'CmsDocument';
    }
    if (data is _i3.CmsUser) {
      return 'CmsUser';
    }
    if (data is _i4.DocumentListResponse) {
      return 'DocumentListResponse';
    }
    if (data is _i5.MediaFile) {
      return 'MediaFile';
    }
    if (data is _i6.UploadResponse) {
      return 'UploadResponse';
    }
    return null;
  }

  @override
  dynamic deserializeByClassName(Map<String, dynamic> data) {
    var dataClassName = data['className'];
    if (dataClassName is! String) {
      return super.deserializeByClassName(data);
    }
    if (dataClassName == 'CmsDocument') {
      return deserialize<_i2.CmsDocument>(data['data']);
    }
    if (dataClassName == 'CmsUser') {
      return deserialize<_i3.CmsUser>(data['data']);
    }
    if (dataClassName == 'DocumentListResponse') {
      return deserialize<_i4.DocumentListResponse>(data['data']);
    }
    if (dataClassName == 'MediaFile') {
      return deserialize<_i5.MediaFile>(data['data']);
    }
    if (dataClassName == 'UploadResponse') {
      return deserialize<_i6.UploadResponse>(data['data']);
    }
    return super.deserializeByClassName(data);
  }
}
