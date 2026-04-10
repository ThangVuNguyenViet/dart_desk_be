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
import 'api_exception.dart' as _i2;
import 'api_token.dart' as _i3;
import 'api_token_with_value.dart' as _i4;
import 'client_role.dart' as _i5;
import 'cms_client.dart' as _i6;
import 'crdt_operation_type.dart' as _i7;
import 'deployment.dart' as _i8;
import 'deployment_status.dart' as _i9;
import 'document.dart' as _i10;
import 'document_crdt_operation.dart' as _i11;
import 'document_crdt_snapshot.dart' as _i12;
import 'document_data.dart' as _i13;
import 'document_list.dart' as _i14;
import 'document_version.dart' as _i15;
import 'document_version_list.dart' as _i16;
import 'document_version_list_with_operations.dart' as _i17;
import 'document_version_status.dart' as _i18;
import 'document_version_with_operations.dart' as _i19;
import 'media_asset.dart' as _i20;
import 'media_asset_metadata_status.dart' as _i21;
import 'migration_history.dart' as _i22;
import 'project.dart' as _i23;
import 'project_list.dart' as _i24;
import 'project_member.dart' as _i25;
import 'project_role.dart' as _i26;
import 'public_document.dart' as _i27;
import 'user.dart' as _i28;
import 'package:dart_desk_client/src/protocol/api_token.dart' as _i29;
import 'package:dart_desk_client/src/protocol/deployment.dart' as _i30;
import 'package:dart_desk_client/src/protocol/document_crdt_operation.dart'
    as _i31;
import 'package:dart_desk_client/src/protocol/media_asset.dart' as _i32;
import 'package:dart_desk_client/src/protocol/user.dart' as _i33;
import 'package:dart_desk_client/src/protocol/migration_history.dart' as _i34;
import 'package:dart_desk_client/src/protocol/project_member.dart' as _i35;
import 'package:dart_desk_client/src/protocol/public_document.dart' as _i36;
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _i37;
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    as _i38;
export 'api_exception.dart';
export 'api_token.dart';
export 'api_token_with_value.dart';
export 'client_role.dart';
export 'cms_client.dart';
export 'crdt_operation_type.dart';
export 'deployment.dart';
export 'deployment_status.dart';
export 'document.dart';
export 'document_crdt_operation.dart';
export 'document_crdt_snapshot.dart';
export 'document_data.dart';
export 'document_list.dart';
export 'document_version.dart';
export 'document_version_list.dart';
export 'document_version_list_with_operations.dart';
export 'document_version_status.dart';
export 'document_version_with_operations.dart';
export 'media_asset.dart';
export 'media_asset_metadata_status.dart';
export 'migration_history.dart';
export 'project.dart';
export 'project_list.dart';
export 'project_member.dart';
export 'project_role.dart';
export 'public_document.dart';
export 'user.dart';
export 'client.dart';

class Protocol extends _i1.SerializationManager {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._();

  static String? getClassNameFromObjectJson(dynamic data) {
    if (data is! Map) return null;
    final className = data['__className__'] as String?;
    return className;
  }

  @override
  T deserialize<T>(
    dynamic data, [
    Type? t,
  ]) {
    t ??= T;

    final dataClassName = getClassNameFromObjectJson(data);
    if (dataClassName != null && dataClassName != getClassNameForType(t)) {
      try {
        return deserializeByClassName({
          'className': dataClassName,
          'data': data,
        });
      } on FormatException catch (_) {
        // If the className is not recognized (e.g., older client receiving
        // data with a new subtype), fall back to deserializing without the
        // className, using the expected type T.
      }
    }

    if (t == _i2.ApiException) {
      return _i2.ApiException.fromJson(data) as T;
    }
    if (t == _i3.ApiToken) {
      return _i3.ApiToken.fromJson(data) as T;
    }
    if (t == _i4.ApiTokenWithValue) {
      return _i4.ApiTokenWithValue.fromJson(data) as T;
    }
    if (t == _i5.ClientRole) {
      return _i5.ClientRole.fromJson(data) as T;
    }
    if (t == _i6.CmsClient) {
      return _i6.CmsClient.fromJson(data) as T;
    }
    if (t == _i7.CrdtOperationType) {
      return _i7.CrdtOperationType.fromJson(data) as T;
    }
    if (t == _i8.Deployment) {
      return _i8.Deployment.fromJson(data) as T;
    }
    if (t == _i9.DeploymentStatus) {
      return _i9.DeploymentStatus.fromJson(data) as T;
    }
    if (t == _i10.Document) {
      return _i10.Document.fromJson(data) as T;
    }
    if (t == _i11.DocumentCrdtOperation) {
      return _i11.DocumentCrdtOperation.fromJson(data) as T;
    }
    if (t == _i12.DocumentCrdtSnapshot) {
      return _i12.DocumentCrdtSnapshot.fromJson(data) as T;
    }
    if (t == _i13.DocumentData) {
      return _i13.DocumentData.fromJson(data) as T;
    }
    if (t == _i14.DocumentList) {
      return _i14.DocumentList.fromJson(data) as T;
    }
    if (t == _i15.DocumentVersion) {
      return _i15.DocumentVersion.fromJson(data) as T;
    }
    if (t == _i16.DocumentVersionList) {
      return _i16.DocumentVersionList.fromJson(data) as T;
    }
    if (t == _i17.DocumentVersionListWithOperations) {
      return _i17.DocumentVersionListWithOperations.fromJson(data) as T;
    }
    if (t == _i18.DocumentVersionStatus) {
      return _i18.DocumentVersionStatus.fromJson(data) as T;
    }
    if (t == _i19.DocumentVersionWithOperations) {
      return _i19.DocumentVersionWithOperations.fromJson(data) as T;
    }
    if (t == _i20.MediaAsset) {
      return _i20.MediaAsset.fromJson(data) as T;
    }
    if (t == _i21.MediaAssetMetadataStatus) {
      return _i21.MediaAssetMetadataStatus.fromJson(data) as T;
    }
    if (t == _i22.MigrationHistory) {
      return _i22.MigrationHistory.fromJson(data) as T;
    }
    if (t == _i23.Project) {
      return _i23.Project.fromJson(data) as T;
    }
    if (t == _i24.ProjectList) {
      return _i24.ProjectList.fromJson(data) as T;
    }
    if (t == _i25.ProjectMember) {
      return _i25.ProjectMember.fromJson(data) as T;
    }
    if (t == _i26.ProjectRole) {
      return _i26.ProjectRole.fromJson(data) as T;
    }
    if (t == _i27.PublicDocument) {
      return _i27.PublicDocument.fromJson(data) as T;
    }
    if (t == _i28.User) {
      return _i28.User.fromJson(data) as T;
    }
    if (t == _i1.getType<_i2.ApiException?>()) {
      return (data != null ? _i2.ApiException.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i3.ApiToken?>()) {
      return (data != null ? _i3.ApiToken.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i4.ApiTokenWithValue?>()) {
      return (data != null ? _i4.ApiTokenWithValue.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i5.ClientRole?>()) {
      return (data != null ? _i5.ClientRole.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i6.CmsClient?>()) {
      return (data != null ? _i6.CmsClient.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i7.CrdtOperationType?>()) {
      return (data != null ? _i7.CrdtOperationType.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i8.Deployment?>()) {
      return (data != null ? _i8.Deployment.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i9.DeploymentStatus?>()) {
      return (data != null ? _i9.DeploymentStatus.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i10.Document?>()) {
      return (data != null ? _i10.Document.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i11.DocumentCrdtOperation?>()) {
      return (data != null ? _i11.DocumentCrdtOperation.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i12.DocumentCrdtSnapshot?>()) {
      return (data != null ? _i12.DocumentCrdtSnapshot.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i13.DocumentData?>()) {
      return (data != null ? _i13.DocumentData.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i14.DocumentList?>()) {
      return (data != null ? _i14.DocumentList.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i15.DocumentVersion?>()) {
      return (data != null ? _i15.DocumentVersion.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i16.DocumentVersionList?>()) {
      return (data != null ? _i16.DocumentVersionList.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i17.DocumentVersionListWithOperations?>()) {
      return (data != null
              ? _i17.DocumentVersionListWithOperations.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i18.DocumentVersionStatus?>()) {
      return (data != null ? _i18.DocumentVersionStatus.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i19.DocumentVersionWithOperations?>()) {
      return (data != null
              ? _i19.DocumentVersionWithOperations.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i20.MediaAsset?>()) {
      return (data != null ? _i20.MediaAsset.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i21.MediaAssetMetadataStatus?>()) {
      return (data != null
              ? _i21.MediaAssetMetadataStatus.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i22.MigrationHistory?>()) {
      return (data != null ? _i22.MigrationHistory.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i23.Project?>()) {
      return (data != null ? _i23.Project.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i24.ProjectList?>()) {
      return (data != null ? _i24.ProjectList.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i25.ProjectMember?>()) {
      return (data != null ? _i25.ProjectMember.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i26.ProjectRole?>()) {
      return (data != null ? _i26.ProjectRole.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i27.PublicDocument?>()) {
      return (data != null ? _i27.PublicDocument.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i28.User?>()) {
      return (data != null ? _i28.User.fromJson(data) : null) as T;
    }
    if (t == List<_i10.Document>) {
      return (data as List).map((e) => deserialize<_i10.Document>(e)).toList()
          as T;
    }
    if (t == List<_i15.DocumentVersion>) {
      return (data as List)
              .map((e) => deserialize<_i15.DocumentVersion>(e))
              .toList()
          as T;
    }
    if (t == List<_i19.DocumentVersionWithOperations>) {
      return (data as List)
              .map((e) => deserialize<_i19.DocumentVersionWithOperations>(e))
              .toList()
          as T;
    }
    if (t == List<_i11.DocumentCrdtOperation>) {
      return (data as List)
              .map((e) => deserialize<_i11.DocumentCrdtOperation>(e))
              .toList()
          as T;
    }
    if (t == List<_i23.Project>) {
      return (data as List).map((e) => deserialize<_i23.Project>(e)).toList()
          as T;
    }
    if (t == List<_i29.ApiToken>) {
      return (data as List).map((e) => deserialize<_i29.ApiToken>(e)).toList()
          as T;
    }
    if (t == List<_i30.Deployment>) {
      return (data as List).map((e) => deserialize<_i30.Deployment>(e)).toList()
          as T;
    }
    if (t == List<_i31.DocumentCrdtOperation>) {
      return (data as List)
              .map((e) => deserialize<_i31.DocumentCrdtOperation>(e))
              .toList()
          as T;
    }
    if (t == List<String>) {
      return (data as List).map((e) => deserialize<String>(e)).toList() as T;
    }
    if (t == List<_i32.MediaAsset>) {
      return (data as List).map((e) => deserialize<_i32.MediaAsset>(e)).toList()
          as T;
    }
    if (t == List<_i33.User>) {
      return (data as List).map((e) => deserialize<_i33.User>(e)).toList() as T;
    }
    if (t == List<_i34.MigrationHistory>) {
      return (data as List)
              .map((e) => deserialize<_i34.MigrationHistory>(e))
              .toList()
          as T;
    }
    if (t == List<_i35.ProjectMember>) {
      return (data as List)
              .map((e) => deserialize<_i35.ProjectMember>(e))
              .toList()
          as T;
    }
    if (t == Map<String, List<_i36.PublicDocument>>) {
      return (data as Map).map(
            (k, v) => MapEntry(
              deserialize<String>(k),
              deserialize<List<_i36.PublicDocument>>(v),
            ),
          )
          as T;
    }
    if (t == List<_i36.PublicDocument>) {
      return (data as List)
              .map((e) => deserialize<_i36.PublicDocument>(e))
              .toList()
          as T;
    }
    if (t == Map<String, _i36.PublicDocument>) {
      return (data as Map).map(
            (k, v) => MapEntry(
              deserialize<String>(k),
              deserialize<_i36.PublicDocument>(v),
            ),
          )
          as T;
    }
    try {
      return _i37.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _i38.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _i2.ApiException => 'ApiException',
      _i3.ApiToken => 'ApiToken',
      _i4.ApiTokenWithValue => 'ApiTokenWithValue',
      _i5.ClientRole => 'ClientRole',
      _i6.CmsClient => 'CmsClient',
      _i7.CrdtOperationType => 'CrdtOperationType',
      _i8.Deployment => 'Deployment',
      _i9.DeploymentStatus => 'DeploymentStatus',
      _i10.Document => 'Document',
      _i11.DocumentCrdtOperation => 'DocumentCrdtOperation',
      _i12.DocumentCrdtSnapshot => 'DocumentCrdtSnapshot',
      _i13.DocumentData => 'DocumentData',
      _i14.DocumentList => 'DocumentList',
      _i15.DocumentVersion => 'DocumentVersion',
      _i16.DocumentVersionList => 'DocumentVersionList',
      _i17.DocumentVersionListWithOperations =>
        'DocumentVersionListWithOperations',
      _i18.DocumentVersionStatus => 'DocumentVersionStatus',
      _i19.DocumentVersionWithOperations => 'DocumentVersionWithOperations',
      _i20.MediaAsset => 'MediaAsset',
      _i21.MediaAssetMetadataStatus => 'MediaAssetMetadataStatus',
      _i22.MigrationHistory => 'MigrationHistory',
      _i23.Project => 'Project',
      _i24.ProjectList => 'ProjectList',
      _i25.ProjectMember => 'ProjectMember',
      _i26.ProjectRole => 'ProjectRole',
      _i27.PublicDocument => 'PublicDocument',
      _i28.User => 'User',
      _ => null,
    };
  }

  @override
  String? getClassNameForObject(Object? data) {
    String? className = super.getClassNameForObject(data);
    if (className != null) return className;

    if (data is Map<String, dynamic> && data['__className__'] is String) {
      return (data['__className__'] as String).replaceFirst('dart_desk.', '');
    }

    switch (data) {
      case _i2.ApiException():
        return 'ApiException';
      case _i3.ApiToken():
        return 'ApiToken';
      case _i4.ApiTokenWithValue():
        return 'ApiTokenWithValue';
      case _i5.ClientRole():
        return 'ClientRole';
      case _i6.CmsClient():
        return 'CmsClient';
      case _i7.CrdtOperationType():
        return 'CrdtOperationType';
      case _i8.Deployment():
        return 'Deployment';
      case _i9.DeploymentStatus():
        return 'DeploymentStatus';
      case _i10.Document():
        return 'Document';
      case _i11.DocumentCrdtOperation():
        return 'DocumentCrdtOperation';
      case _i12.DocumentCrdtSnapshot():
        return 'DocumentCrdtSnapshot';
      case _i13.DocumentData():
        return 'DocumentData';
      case _i14.DocumentList():
        return 'DocumentList';
      case _i15.DocumentVersion():
        return 'DocumentVersion';
      case _i16.DocumentVersionList():
        return 'DocumentVersionList';
      case _i17.DocumentVersionListWithOperations():
        return 'DocumentVersionListWithOperations';
      case _i18.DocumentVersionStatus():
        return 'DocumentVersionStatus';
      case _i19.DocumentVersionWithOperations():
        return 'DocumentVersionWithOperations';
      case _i20.MediaAsset():
        return 'MediaAsset';
      case _i21.MediaAssetMetadataStatus():
        return 'MediaAssetMetadataStatus';
      case _i22.MigrationHistory():
        return 'MigrationHistory';
      case _i23.Project():
        return 'Project';
      case _i24.ProjectList():
        return 'ProjectList';
      case _i25.ProjectMember():
        return 'ProjectMember';
      case _i26.ProjectRole():
        return 'ProjectRole';
      case _i27.PublicDocument():
        return 'PublicDocument';
      case _i28.User():
        return 'User';
    }
    className = _i37.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod_auth_core.$className';
    }
    className = _i38.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod_auth_idp.$className';
    }
    return null;
  }

  @override
  dynamic deserializeByClassName(Map<String, dynamic> data) {
    var dataClassName = data['className'];
    if (dataClassName is! String) {
      return super.deserializeByClassName(data);
    }
    if (dataClassName == 'ApiException') {
      return deserialize<_i2.ApiException>(data['data']);
    }
    if (dataClassName == 'ApiToken') {
      return deserialize<_i3.ApiToken>(data['data']);
    }
    if (dataClassName == 'ApiTokenWithValue') {
      return deserialize<_i4.ApiTokenWithValue>(data['data']);
    }
    if (dataClassName == 'ClientRole') {
      return deserialize<_i5.ClientRole>(data['data']);
    }
    if (dataClassName == 'CmsClient') {
      return deserialize<_i6.CmsClient>(data['data']);
    }
    if (dataClassName == 'CrdtOperationType') {
      return deserialize<_i7.CrdtOperationType>(data['data']);
    }
    if (dataClassName == 'Deployment') {
      return deserialize<_i8.Deployment>(data['data']);
    }
    if (dataClassName == 'DeploymentStatus') {
      return deserialize<_i9.DeploymentStatus>(data['data']);
    }
    if (dataClassName == 'Document') {
      return deserialize<_i10.Document>(data['data']);
    }
    if (dataClassName == 'DocumentCrdtOperation') {
      return deserialize<_i11.DocumentCrdtOperation>(data['data']);
    }
    if (dataClassName == 'DocumentCrdtSnapshot') {
      return deserialize<_i12.DocumentCrdtSnapshot>(data['data']);
    }
    if (dataClassName == 'DocumentData') {
      return deserialize<_i13.DocumentData>(data['data']);
    }
    if (dataClassName == 'DocumentList') {
      return deserialize<_i14.DocumentList>(data['data']);
    }
    if (dataClassName == 'DocumentVersion') {
      return deserialize<_i15.DocumentVersion>(data['data']);
    }
    if (dataClassName == 'DocumentVersionList') {
      return deserialize<_i16.DocumentVersionList>(data['data']);
    }
    if (dataClassName == 'DocumentVersionListWithOperations') {
      return deserialize<_i17.DocumentVersionListWithOperations>(data['data']);
    }
    if (dataClassName == 'DocumentVersionStatus') {
      return deserialize<_i18.DocumentVersionStatus>(data['data']);
    }
    if (dataClassName == 'DocumentVersionWithOperations') {
      return deserialize<_i19.DocumentVersionWithOperations>(data['data']);
    }
    if (dataClassName == 'MediaAsset') {
      return deserialize<_i20.MediaAsset>(data['data']);
    }
    if (dataClassName == 'MediaAssetMetadataStatus') {
      return deserialize<_i21.MediaAssetMetadataStatus>(data['data']);
    }
    if (dataClassName == 'MigrationHistory') {
      return deserialize<_i22.MigrationHistory>(data['data']);
    }
    if (dataClassName == 'Project') {
      return deserialize<_i23.Project>(data['data']);
    }
    if (dataClassName == 'ProjectList') {
      return deserialize<_i24.ProjectList>(data['data']);
    }
    if (dataClassName == 'ProjectMember') {
      return deserialize<_i25.ProjectMember>(data['data']);
    }
    if (dataClassName == 'ProjectRole') {
      return deserialize<_i26.ProjectRole>(data['data']);
    }
    if (dataClassName == 'PublicDocument') {
      return deserialize<_i27.PublicDocument>(data['data']);
    }
    if (dataClassName == 'User') {
      return deserialize<_i28.User>(data['data']);
    }
    if (dataClassName.startsWith('serverpod_auth_core.')) {
      data['className'] = dataClassName.substring(20);
      return _i37.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_idp.')) {
      data['className'] = dataClassName.substring(19);
      return _i38.Protocol().deserializeByClassName(data);
    }
    return super.deserializeByClassName(data);
  }

  /// Maps any `Record`s known to this [Protocol] to their JSON representation
  ///
  /// Throws in case the record type is not known.
  ///
  /// This method will return `null` (only) for `null` inputs.
  Map<String, dynamic>? mapRecordToJson(Record? record) {
    if (record == null) {
      return null;
    }
    try {
      return _i37.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _i38.Protocol().mapRecordToJson(record);
    } catch (_) {}
    throw Exception('Unsupported record type ${record.runtimeType}');
  }
}
