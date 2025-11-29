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
import 'cms_client.dart' as _i2;
import 'cms_client_user.dart' as _i3;
import 'cms_document.dart' as _i4;
import 'cms_document_data.dart' as _i5;
import 'cms_user.dart' as _i6;
import 'document_list.dart' as _i7;
import 'document_version.dart' as _i8;
import 'document_version_list.dart' as _i9;
import 'media_file.dart' as _i10;
import 'upload_response.dart' as _i11;
import 'package:flutter_cms_be_client/src/protocol/media_file.dart' as _i12;
import 'package:serverpod_auth_client/serverpod_auth_client.dart' as _i13;
export 'cms_client.dart';
export 'cms_client_user.dart';
export 'cms_document.dart';
export 'cms_document_data.dart';
export 'cms_user.dart';
export 'document_list.dart';
export 'document_version.dart';
export 'document_version_list.dart';
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
    if (t == _i2.CmsClient) {
      return _i2.CmsClient.fromJson(data) as T;
    }
    if (t == _i3.CmsClientUser) {
      return _i3.CmsClientUser.fromJson(data) as T;
    }
    if (t == _i4.CmsDocument) {
      return _i4.CmsDocument.fromJson(data) as T;
    }
    if (t == _i5.CmsDocumentData) {
      return _i5.CmsDocumentData.fromJson(data) as T;
    }
    if (t == _i6.CmsUser) {
      return _i6.CmsUser.fromJson(data) as T;
    }
    if (t == _i7.DocumentList) {
      return _i7.DocumentList.fromJson(data) as T;
    }
    if (t == _i8.DocumentVersion) {
      return _i8.DocumentVersion.fromJson(data) as T;
    }
    if (t == _i9.DocumentVersionList) {
      return _i9.DocumentVersionList.fromJson(data) as T;
    }
    if (t == _i10.MediaFile) {
      return _i10.MediaFile.fromJson(data) as T;
    }
    if (t == _i11.UploadResponse) {
      return _i11.UploadResponse.fromJson(data) as T;
    }
    if (t == _i1.getType<_i2.CmsClient?>()) {
      return (data != null ? _i2.CmsClient.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i3.CmsClientUser?>()) {
      return (data != null ? _i3.CmsClientUser.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i4.CmsDocument?>()) {
      return (data != null ? _i4.CmsDocument.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i5.CmsDocumentData?>()) {
      return (data != null ? _i5.CmsDocumentData.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i6.CmsUser?>()) {
      return (data != null ? _i6.CmsUser.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i7.DocumentList?>()) {
      return (data != null ? _i7.DocumentList.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i8.DocumentVersion?>()) {
      return (data != null ? _i8.DocumentVersion.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i9.DocumentVersionList?>()) {
      return (data != null ? _i9.DocumentVersionList.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i10.MediaFile?>()) {
      return (data != null ? _i10.MediaFile.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i11.UploadResponse?>()) {
      return (data != null ? _i11.UploadResponse.fromJson(data) : null) as T;
    }
    if (t == List<_i4.CmsDocument>) {
      return (data as List).map((e) => deserialize<_i4.CmsDocument>(e)).toList()
          as T;
    }
    if (t == List<_i8.DocumentVersion>) {
      return (data as List)
          .map((e) => deserialize<_i8.DocumentVersion>(e))
          .toList() as T;
    }
    if (t == Map<String, dynamic>) {
      return (data as Map).map((k, v) =>
          MapEntry(deserialize<String>(k), deserialize<dynamic>(v))) as T;
    }
    if (t == List<String>) {
      return (data as List).map((e) => deserialize<String>(e)).toList() as T;
    }
    if (t == List<_i12.MediaFile>) {
      return (data as List).map((e) => deserialize<_i12.MediaFile>(e)).toList()
          as T;
    }
    try {
      return _i13.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  @override
  String? getClassNameForObject(Object? data) {
    String? className = super.getClassNameForObject(data);
    if (className != null) return className;
    if (data is _i2.CmsClient) {
      return 'CmsClient';
    }
    if (data is _i3.CmsClientUser) {
      return 'CmsClientUser';
    }
    if (data is _i4.CmsDocument) {
      return 'CmsDocument';
    }
    if (data is _i5.CmsDocumentData) {
      return 'CmsDocumentData';
    }
    if (data is _i6.CmsUser) {
      return 'CmsUser';
    }
    if (data is _i7.DocumentList) {
      return 'DocumentList';
    }
    if (data is _i8.DocumentVersion) {
      return 'DocumentVersion';
    }
    if (data is _i9.DocumentVersionList) {
      return 'DocumentVersionList';
    }
    if (data is _i10.MediaFile) {
      return 'MediaFile';
    }
    if (data is _i11.UploadResponse) {
      return 'UploadResponse';
    }
    className = _i13.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod_auth.$className';
    }
    return null;
  }

  @override
  dynamic deserializeByClassName(Map<String, dynamic> data) {
    var dataClassName = data['className'];
    if (dataClassName is! String) {
      return super.deserializeByClassName(data);
    }
    if (dataClassName == 'CmsClient') {
      return deserialize<_i2.CmsClient>(data['data']);
    }
    if (dataClassName == 'CmsClientUser') {
      return deserialize<_i3.CmsClientUser>(data['data']);
    }
    if (dataClassName == 'CmsDocument') {
      return deserialize<_i4.CmsDocument>(data['data']);
    }
    if (dataClassName == 'CmsDocumentData') {
      return deserialize<_i5.CmsDocumentData>(data['data']);
    }
    if (dataClassName == 'CmsUser') {
      return deserialize<_i6.CmsUser>(data['data']);
    }
    if (dataClassName == 'DocumentList') {
      return deserialize<_i7.DocumentList>(data['data']);
    }
    if (dataClassName == 'DocumentVersion') {
      return deserialize<_i8.DocumentVersion>(data['data']);
    }
    if (dataClassName == 'DocumentVersionList') {
      return deserialize<_i9.DocumentVersionList>(data['data']);
    }
    if (dataClassName == 'MediaFile') {
      return deserialize<_i10.MediaFile>(data['data']);
    }
    if (dataClassName == 'UploadResponse') {
      return deserialize<_i11.UploadResponse>(data['data']);
    }
    if (dataClassName.startsWith('serverpod_auth.')) {
      data['className'] = dataClassName.substring(15);
      return _i13.Protocol().deserializeByClassName(data);
    }
    return super.deserializeByClassName(data);
  }
}
