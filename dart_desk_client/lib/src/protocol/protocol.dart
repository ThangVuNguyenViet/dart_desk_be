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
import 'api_key.dart' as _i3;
import 'api_key_with_value.dart' as _i4;
import 'client_role.dart' as _i5;
import 'client_with_role.dart' as _i6;
import 'cms_client.dart' as _i7;
import 'crdt_operation_type.dart' as _i8;
import 'deployment.dart' as _i9;
import 'deployment_status.dart' as _i10;
import 'document.dart' as _i11;
import 'document_crdt_operation.dart' as _i12;
import 'document_crdt_snapshot.dart' as _i13;
import 'document_data.dart' as _i14;
import 'document_version.dart' as _i15;
import 'document_version_list.dart' as _i16;
import 'document_version_status.dart' as _i17;
import 'invite.dart' as _i18;
import 'invite_preview.dart' as _i19;
import 'invite_result.dart' as _i20;
import 'media_asset.dart' as _i21;
import 'media_asset_metadata_status.dart' as _i22;
import 'migration_history.dart' as _i23;
import 'paginated_api_keys.dart' as _i24;
import 'paginated_document_versions.dart' as _i25;
import 'paginated_documents.dart' as _i26;
import 'paginated_media_assets.dart' as _i27;
import 'paginated_migration_histories.dart' as _i28;
import 'paginated_projects.dart' as _i29;
import 'paginated_users.dart' as _i30;
import 'project.dart' as _i31;
import 'project_member.dart' as _i32;
import 'project_role.dart' as _i33;
import 'public_document.dart' as _i34;
import 'published_document.dart' as _i35;
import 'user.dart' as _i36;
import 'package:dart_desk_client/src/protocol/client_with_role.dart' as _i37;
import 'package:dart_desk_client/src/protocol/api_key.dart' as _i38;
import 'package:dart_desk_client/src/protocol/deployment.dart' as _i39;
import 'package:dart_desk_client/src/protocol/document_crdt_operation.dart'
    as _i40;
import 'package:dart_desk_client/src/protocol/media_asset.dart' as _i41;
import 'package:dart_desk_client/src/protocol/user.dart' as _i42;
import 'package:dart_desk_client/src/protocol/invite.dart' as _i43;
import 'package:dart_desk_client/src/protocol/migration_history.dart' as _i44;
import 'package:dart_desk_client/src/protocol/project_member.dart' as _i45;
import 'package:dart_desk_client/src/protocol/public_document.dart' as _i46;
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _i47;
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    as _i48;
export 'api_exception.dart';
export 'api_key.dart';
export 'api_key_with_value.dart';
export 'client_role.dart';
export 'client_with_role.dart';
export 'cms_client.dart';
export 'crdt_operation_type.dart';
export 'deployment.dart';
export 'deployment_status.dart';
export 'document.dart';
export 'document_crdt_operation.dart';
export 'document_crdt_snapshot.dart';
export 'document_data.dart';
export 'document_version.dart';
export 'document_version_list.dart';
export 'document_version_status.dart';
export 'invite.dart';
export 'invite_preview.dart';
export 'invite_result.dart';
export 'media_asset.dart';
export 'media_asset_metadata_status.dart';
export 'migration_history.dart';
export 'paginated_api_keys.dart';
export 'paginated_document_versions.dart';
export 'paginated_documents.dart';
export 'paginated_media_assets.dart';
export 'paginated_migration_histories.dart';
export 'paginated_projects.dart';
export 'paginated_users.dart';
export 'project.dart';
export 'project_member.dart';
export 'project_role.dart';
export 'public_document.dart';
export 'published_document.dart';
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
    if (t == _i3.ApiKey) {
      return _i3.ApiKey.fromJson(data) as T;
    }
    if (t == _i4.ApiKeyWithValue) {
      return _i4.ApiKeyWithValue.fromJson(data) as T;
    }
    if (t == _i5.ClientRole) {
      return _i5.ClientRole.fromJson(data) as T;
    }
    if (t == _i6.ClientWithRole) {
      return _i6.ClientWithRole.fromJson(data) as T;
    }
    if (t == _i7.CmsClient) {
      return _i7.CmsClient.fromJson(data) as T;
    }
    if (t == _i8.CrdtOperationType) {
      return _i8.CrdtOperationType.fromJson(data) as T;
    }
    if (t == _i9.Deployment) {
      return _i9.Deployment.fromJson(data) as T;
    }
    if (t == _i10.DeploymentStatus) {
      return _i10.DeploymentStatus.fromJson(data) as T;
    }
    if (t == _i11.Document) {
      return _i11.Document.fromJson(data) as T;
    }
    if (t == _i12.DocumentCrdtOperation) {
      return _i12.DocumentCrdtOperation.fromJson(data) as T;
    }
    if (t == _i13.DocumentCrdtSnapshot) {
      return _i13.DocumentCrdtSnapshot.fromJson(data) as T;
    }
    if (t == _i14.DocumentData) {
      return _i14.DocumentData.fromJson(data) as T;
    }
    if (t == _i15.DocumentVersion) {
      return _i15.DocumentVersion.fromJson(data) as T;
    }
    if (t == _i16.DocumentVersionList) {
      return _i16.DocumentVersionList.fromJson(data) as T;
    }
    if (t == _i17.DocumentVersionStatus) {
      return _i17.DocumentVersionStatus.fromJson(data) as T;
    }
    if (t == _i18.Invite) {
      return _i18.Invite.fromJson(data) as T;
    }
    if (t == _i19.InvitePreview) {
      return _i19.InvitePreview.fromJson(data) as T;
    }
    if (t == _i20.InviteResult) {
      return _i20.InviteResult.fromJson(data) as T;
    }
    if (t == _i21.MediaAsset) {
      return _i21.MediaAsset.fromJson(data) as T;
    }
    if (t == _i22.MediaAssetMetadataStatus) {
      return _i22.MediaAssetMetadataStatus.fromJson(data) as T;
    }
    if (t == _i23.MigrationHistory) {
      return _i23.MigrationHistory.fromJson(data) as T;
    }
    if (t == _i24.PaginatedApiKeys) {
      return _i24.PaginatedApiKeys.fromJson(data) as T;
    }
    if (t == _i25.PaginatedDocumentVersions) {
      return _i25.PaginatedDocumentVersions.fromJson(data) as T;
    }
    if (t == _i26.PaginatedDocuments) {
      return _i26.PaginatedDocuments.fromJson(data) as T;
    }
    if (t == _i27.PaginatedMediaAssets) {
      return _i27.PaginatedMediaAssets.fromJson(data) as T;
    }
    if (t == _i28.PaginatedMigrationHistories) {
      return _i28.PaginatedMigrationHistories.fromJson(data) as T;
    }
    if (t == _i29.PaginatedProjects) {
      return _i29.PaginatedProjects.fromJson(data) as T;
    }
    if (t == _i30.PaginatedUsers) {
      return _i30.PaginatedUsers.fromJson(data) as T;
    }
    if (t == _i31.Project) {
      return _i31.Project.fromJson(data) as T;
    }
    if (t == _i32.ProjectMember) {
      return _i32.ProjectMember.fromJson(data) as T;
    }
    if (t == _i33.ProjectRole) {
      return _i33.ProjectRole.fromJson(data) as T;
    }
    if (t == _i34.PublicDocument) {
      return _i34.PublicDocument.fromJson(data) as T;
    }
    if (t == _i35.PublishedDocument) {
      return _i35.PublishedDocument.fromJson(data) as T;
    }
    if (t == _i36.User) {
      return _i36.User.fromJson(data) as T;
    }
    if (t == _i1.getType<_i2.ApiException?>()) {
      return (data != null ? _i2.ApiException.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i3.ApiKey?>()) {
      return (data != null ? _i3.ApiKey.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i4.ApiKeyWithValue?>()) {
      return (data != null ? _i4.ApiKeyWithValue.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i5.ClientRole?>()) {
      return (data != null ? _i5.ClientRole.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i6.ClientWithRole?>()) {
      return (data != null ? _i6.ClientWithRole.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i7.CmsClient?>()) {
      return (data != null ? _i7.CmsClient.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i8.CrdtOperationType?>()) {
      return (data != null ? _i8.CrdtOperationType.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i9.Deployment?>()) {
      return (data != null ? _i9.Deployment.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i10.DeploymentStatus?>()) {
      return (data != null ? _i10.DeploymentStatus.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i11.Document?>()) {
      return (data != null ? _i11.Document.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i12.DocumentCrdtOperation?>()) {
      return (data != null ? _i12.DocumentCrdtOperation.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i13.DocumentCrdtSnapshot?>()) {
      return (data != null ? _i13.DocumentCrdtSnapshot.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i14.DocumentData?>()) {
      return (data != null ? _i14.DocumentData.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i15.DocumentVersion?>()) {
      return (data != null ? _i15.DocumentVersion.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i16.DocumentVersionList?>()) {
      return (data != null ? _i16.DocumentVersionList.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i17.DocumentVersionStatus?>()) {
      return (data != null ? _i17.DocumentVersionStatus.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i18.Invite?>()) {
      return (data != null ? _i18.Invite.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i19.InvitePreview?>()) {
      return (data != null ? _i19.InvitePreview.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i20.InviteResult?>()) {
      return (data != null ? _i20.InviteResult.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i21.MediaAsset?>()) {
      return (data != null ? _i21.MediaAsset.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i22.MediaAssetMetadataStatus?>()) {
      return (data != null
              ? _i22.MediaAssetMetadataStatus.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i23.MigrationHistory?>()) {
      return (data != null ? _i23.MigrationHistory.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i24.PaginatedApiKeys?>()) {
      return (data != null ? _i24.PaginatedApiKeys.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i25.PaginatedDocumentVersions?>()) {
      return (data != null
              ? _i25.PaginatedDocumentVersions.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i26.PaginatedDocuments?>()) {
      return (data != null ? _i26.PaginatedDocuments.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i27.PaginatedMediaAssets?>()) {
      return (data != null ? _i27.PaginatedMediaAssets.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i28.PaginatedMigrationHistories?>()) {
      return (data != null
              ? _i28.PaginatedMigrationHistories.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i29.PaginatedProjects?>()) {
      return (data != null ? _i29.PaginatedProjects.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i30.PaginatedUsers?>()) {
      return (data != null ? _i30.PaginatedUsers.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i31.Project?>()) {
      return (data != null ? _i31.Project.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i32.ProjectMember?>()) {
      return (data != null ? _i32.ProjectMember.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i33.ProjectRole?>()) {
      return (data != null ? _i33.ProjectRole.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i34.PublicDocument?>()) {
      return (data != null ? _i34.PublicDocument.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i35.PublishedDocument?>()) {
      return (data != null ? _i35.PublishedDocument.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i36.User?>()) {
      return (data != null ? _i36.User.fromJson(data) : null) as T;
    }
    if (t == List<_i15.DocumentVersion>) {
      return (data as List)
              .map((e) => deserialize<_i15.DocumentVersion>(e))
              .toList()
          as T;
    }
    if (t == List<_i3.ApiKey>) {
      return (data as List).map((e) => deserialize<_i3.ApiKey>(e)).toList()
          as T;
    }
    if (t == List<_i11.Document>) {
      return (data as List).map((e) => deserialize<_i11.Document>(e)).toList()
          as T;
    }
    if (t == List<_i21.MediaAsset>) {
      return (data as List).map((e) => deserialize<_i21.MediaAsset>(e)).toList()
          as T;
    }
    if (t == List<_i23.MigrationHistory>) {
      return (data as List)
              .map((e) => deserialize<_i23.MigrationHistory>(e))
              .toList()
          as T;
    }
    if (t == List<_i31.Project>) {
      return (data as List).map((e) => deserialize<_i31.Project>(e)).toList()
          as T;
    }
    if (t == List<_i36.User>) {
      return (data as List).map((e) => deserialize<_i36.User>(e)).toList() as T;
    }
    if (t == List<_i37.ClientWithRole>) {
      return (data as List)
              .map((e) => deserialize<_i37.ClientWithRole>(e))
              .toList()
          as T;
    }
    if (t == List<_i38.ApiKey>) {
      return (data as List).map((e) => deserialize<_i38.ApiKey>(e)).toList()
          as T;
    }
    if (t == List<_i39.Deployment>) {
      return (data as List).map((e) => deserialize<_i39.Deployment>(e)).toList()
          as T;
    }
    if (t == List<_i40.DocumentCrdtOperation>) {
      return (data as List)
              .map((e) => deserialize<_i40.DocumentCrdtOperation>(e))
              .toList()
          as T;
    }
    if (t == List<String>) {
      return (data as List).map((e) => deserialize<String>(e)).toList() as T;
    }
    if (t == List<_i41.MediaAsset>) {
      return (data as List).map((e) => deserialize<_i41.MediaAsset>(e)).toList()
          as T;
    }
    if (t == List<_i42.User>) {
      return (data as List).map((e) => deserialize<_i42.User>(e)).toList() as T;
    }
    if (t == List<_i43.Invite>) {
      return (data as List).map((e) => deserialize<_i43.Invite>(e)).toList()
          as T;
    }
    if (t == List<_i44.MigrationHistory>) {
      return (data as List)
              .map((e) => deserialize<_i44.MigrationHistory>(e))
              .toList()
          as T;
    }
    if (t == List<_i45.ProjectMember>) {
      return (data as List)
              .map((e) => deserialize<_i45.ProjectMember>(e))
              .toList()
          as T;
    }
    if (t == Map<String, List<_i46.PublicDocument>>) {
      return (data as Map).map(
            (k, v) => MapEntry(
              deserialize<String>(k),
              deserialize<List<_i46.PublicDocument>>(v),
            ),
          )
          as T;
    }
    if (t == List<_i46.PublicDocument>) {
      return (data as List)
              .map((e) => deserialize<_i46.PublicDocument>(e))
              .toList()
          as T;
    }
    if (t == Map<String, _i46.PublicDocument>) {
      return (data as Map).map(
            (k, v) => MapEntry(
              deserialize<String>(k),
              deserialize<_i46.PublicDocument>(v),
            ),
          )
          as T;
    }
    try {
      return _i47.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _i48.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _i2.ApiException => 'ApiException',
      _i3.ApiKey => 'ApiKey',
      _i4.ApiKeyWithValue => 'ApiKeyWithValue',
      _i5.ClientRole => 'ClientRole',
      _i6.ClientWithRole => 'ClientWithRole',
      _i7.CmsClient => 'CmsClient',
      _i8.CrdtOperationType => 'CrdtOperationType',
      _i9.Deployment => 'Deployment',
      _i10.DeploymentStatus => 'DeploymentStatus',
      _i11.Document => 'Document',
      _i12.DocumentCrdtOperation => 'DocumentCrdtOperation',
      _i13.DocumentCrdtSnapshot => 'DocumentCrdtSnapshot',
      _i14.DocumentData => 'DocumentData',
      _i15.DocumentVersion => 'DocumentVersion',
      _i16.DocumentVersionList => 'DocumentVersionList',
      _i17.DocumentVersionStatus => 'DocumentVersionStatus',
      _i18.Invite => 'Invite',
      _i19.InvitePreview => 'InvitePreview',
      _i20.InviteResult => 'InviteResult',
      _i21.MediaAsset => 'MediaAsset',
      _i22.MediaAssetMetadataStatus => 'MediaAssetMetadataStatus',
      _i23.MigrationHistory => 'MigrationHistory',
      _i24.PaginatedApiKeys => 'PaginatedApiKeys',
      _i25.PaginatedDocumentVersions => 'PaginatedDocumentVersions',
      _i26.PaginatedDocuments => 'PaginatedDocuments',
      _i27.PaginatedMediaAssets => 'PaginatedMediaAssets',
      _i28.PaginatedMigrationHistories => 'PaginatedMigrationHistories',
      _i29.PaginatedProjects => 'PaginatedProjects',
      _i30.PaginatedUsers => 'PaginatedUsers',
      _i31.Project => 'Project',
      _i32.ProjectMember => 'ProjectMember',
      _i33.ProjectRole => 'ProjectRole',
      _i34.PublicDocument => 'PublicDocument',
      _i35.PublishedDocument => 'PublishedDocument',
      _i36.User => 'User',
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
      case _i3.ApiKey():
        return 'ApiKey';
      case _i4.ApiKeyWithValue():
        return 'ApiKeyWithValue';
      case _i5.ClientRole():
        return 'ClientRole';
      case _i6.ClientWithRole():
        return 'ClientWithRole';
      case _i7.CmsClient():
        return 'CmsClient';
      case _i8.CrdtOperationType():
        return 'CrdtOperationType';
      case _i9.Deployment():
        return 'Deployment';
      case _i10.DeploymentStatus():
        return 'DeploymentStatus';
      case _i11.Document():
        return 'Document';
      case _i12.DocumentCrdtOperation():
        return 'DocumentCrdtOperation';
      case _i13.DocumentCrdtSnapshot():
        return 'DocumentCrdtSnapshot';
      case _i14.DocumentData():
        return 'DocumentData';
      case _i15.DocumentVersion():
        return 'DocumentVersion';
      case _i16.DocumentVersionList():
        return 'DocumentVersionList';
      case _i17.DocumentVersionStatus():
        return 'DocumentVersionStatus';
      case _i18.Invite():
        return 'Invite';
      case _i19.InvitePreview():
        return 'InvitePreview';
      case _i20.InviteResult():
        return 'InviteResult';
      case _i21.MediaAsset():
        return 'MediaAsset';
      case _i22.MediaAssetMetadataStatus():
        return 'MediaAssetMetadataStatus';
      case _i23.MigrationHistory():
        return 'MigrationHistory';
      case _i24.PaginatedApiKeys():
        return 'PaginatedApiKeys';
      case _i25.PaginatedDocumentVersions():
        return 'PaginatedDocumentVersions';
      case _i26.PaginatedDocuments():
        return 'PaginatedDocuments';
      case _i27.PaginatedMediaAssets():
        return 'PaginatedMediaAssets';
      case _i28.PaginatedMigrationHistories():
        return 'PaginatedMigrationHistories';
      case _i29.PaginatedProjects():
        return 'PaginatedProjects';
      case _i30.PaginatedUsers():
        return 'PaginatedUsers';
      case _i31.Project():
        return 'Project';
      case _i32.ProjectMember():
        return 'ProjectMember';
      case _i33.ProjectRole():
        return 'ProjectRole';
      case _i34.PublicDocument():
        return 'PublicDocument';
      case _i35.PublishedDocument():
        return 'PublishedDocument';
      case _i36.User():
        return 'User';
    }
    className = _i47.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod_auth_core.$className';
    }
    className = _i48.Protocol().getClassNameForObject(data);
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
    if (dataClassName == 'ApiKey') {
      return deserialize<_i3.ApiKey>(data['data']);
    }
    if (dataClassName == 'ApiKeyWithValue') {
      return deserialize<_i4.ApiKeyWithValue>(data['data']);
    }
    if (dataClassName == 'ClientRole') {
      return deserialize<_i5.ClientRole>(data['data']);
    }
    if (dataClassName == 'ClientWithRole') {
      return deserialize<_i6.ClientWithRole>(data['data']);
    }
    if (dataClassName == 'CmsClient') {
      return deserialize<_i7.CmsClient>(data['data']);
    }
    if (dataClassName == 'CrdtOperationType') {
      return deserialize<_i8.CrdtOperationType>(data['data']);
    }
    if (dataClassName == 'Deployment') {
      return deserialize<_i9.Deployment>(data['data']);
    }
    if (dataClassName == 'DeploymentStatus') {
      return deserialize<_i10.DeploymentStatus>(data['data']);
    }
    if (dataClassName == 'Document') {
      return deserialize<_i11.Document>(data['data']);
    }
    if (dataClassName == 'DocumentCrdtOperation') {
      return deserialize<_i12.DocumentCrdtOperation>(data['data']);
    }
    if (dataClassName == 'DocumentCrdtSnapshot') {
      return deserialize<_i13.DocumentCrdtSnapshot>(data['data']);
    }
    if (dataClassName == 'DocumentData') {
      return deserialize<_i14.DocumentData>(data['data']);
    }
    if (dataClassName == 'DocumentVersion') {
      return deserialize<_i15.DocumentVersion>(data['data']);
    }
    if (dataClassName == 'DocumentVersionList') {
      return deserialize<_i16.DocumentVersionList>(data['data']);
    }
    if (dataClassName == 'DocumentVersionStatus') {
      return deserialize<_i17.DocumentVersionStatus>(data['data']);
    }
    if (dataClassName == 'Invite') {
      return deserialize<_i18.Invite>(data['data']);
    }
    if (dataClassName == 'InvitePreview') {
      return deserialize<_i19.InvitePreview>(data['data']);
    }
    if (dataClassName == 'InviteResult') {
      return deserialize<_i20.InviteResult>(data['data']);
    }
    if (dataClassName == 'MediaAsset') {
      return deserialize<_i21.MediaAsset>(data['data']);
    }
    if (dataClassName == 'MediaAssetMetadataStatus') {
      return deserialize<_i22.MediaAssetMetadataStatus>(data['data']);
    }
    if (dataClassName == 'MigrationHistory') {
      return deserialize<_i23.MigrationHistory>(data['data']);
    }
    if (dataClassName == 'PaginatedApiKeys') {
      return deserialize<_i24.PaginatedApiKeys>(data['data']);
    }
    if (dataClassName == 'PaginatedDocumentVersions') {
      return deserialize<_i25.PaginatedDocumentVersions>(data['data']);
    }
    if (dataClassName == 'PaginatedDocuments') {
      return deserialize<_i26.PaginatedDocuments>(data['data']);
    }
    if (dataClassName == 'PaginatedMediaAssets') {
      return deserialize<_i27.PaginatedMediaAssets>(data['data']);
    }
    if (dataClassName == 'PaginatedMigrationHistories') {
      return deserialize<_i28.PaginatedMigrationHistories>(data['data']);
    }
    if (dataClassName == 'PaginatedProjects') {
      return deserialize<_i29.PaginatedProjects>(data['data']);
    }
    if (dataClassName == 'PaginatedUsers') {
      return deserialize<_i30.PaginatedUsers>(data['data']);
    }
    if (dataClassName == 'Project') {
      return deserialize<_i31.Project>(data['data']);
    }
    if (dataClassName == 'ProjectMember') {
      return deserialize<_i32.ProjectMember>(data['data']);
    }
    if (dataClassName == 'ProjectRole') {
      return deserialize<_i33.ProjectRole>(data['data']);
    }
    if (dataClassName == 'PublicDocument') {
      return deserialize<_i34.PublicDocument>(data['data']);
    }
    if (dataClassName == 'PublishedDocument') {
      return deserialize<_i35.PublishedDocument>(data['data']);
    }
    if (dataClassName == 'User') {
      return deserialize<_i36.User>(data['data']);
    }
    if (dataClassName.startsWith('serverpod_auth_core.')) {
      data['className'] = dataClassName.substring(20);
      return _i47.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_idp.')) {
      data['className'] = dataClassName.substring(19);
      return _i48.Protocol().deserializeByClassName(data);
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
      return _i47.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _i48.Protocol().mapRecordToJson(record);
    } catch (_) {}
    throw Exception('Unsupported record type ${record.runtimeType}');
  }
}
