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
import '../endpoints/client_endpoint.dart' as _i2;
import '../endpoints/cms_api_key_endpoint.dart' as _i3;
import '../endpoints/deployment_endpoint.dart' as _i4;
import '../endpoints/document_collaboration_endpoint.dart' as _i5;
import '../endpoints/document_endpoint.dart' as _i6;
import '../endpoints/email_idp_endpoint.dart' as _i7;
import '../endpoints/google_idp_endpoint.dart' as _i8;
import '../endpoints/health_endpoint.dart' as _i9;
import '../endpoints/media_endpoint.dart' as _i10;
import '../endpoints/member_endpoint.dart' as _i11;
import '../endpoints/migration_endpoint.dart' as _i12;
import '../endpoints/project_endpoint.dart' as _i13;
import '../endpoints/project_member_endpoint.dart' as _i14;
import '../endpoints/public_content_endpoint.dart' as _i15;
import '../endpoints/refresh_jwt_tokens_endpoint.dart' as _i16;
import '../endpoints/restore_endpoint.dart' as _i17;
import '../endpoints/studio_config_endpoint.dart' as _i18;
import '../endpoints/user_endpoint.dart' as _i19;
import 'package:dart_desk_server/src/generated/document_version_status.dart'
    as _i20;
import 'dart:typed_data' as _i21;
import 'package:dart_desk_server/src/generated/client_role.dart' as _i22;
import 'package:dart_desk_server/src/generated/project_role.dart' as _i23;
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart'
    as _i24;
import 'package:serverpod_auth_idp_server/serverpod_auth_idp_server.dart'
    as _i25;

class Endpoints extends _i1.EndpointDispatch {
  @override
  void initializeEndpoints(_i1.Server server) {
    var endpoints = <String, _i1.Endpoint>{
      'client': _i2.ClientEndpoint()
        ..initialize(
          server,
          'client',
          null,
        ),
      'apiKey': _i3.ApiKeyEndpoint()
        ..initialize(
          server,
          'apiKey',
          null,
        ),
      'deployment': _i4.DeploymentEndpoint()
        ..initialize(
          server,
          'deployment',
          null,
        ),
      'documentCollaboration': _i5.DocumentCollaborationEndpoint()
        ..initialize(
          server,
          'documentCollaboration',
          null,
        ),
      'document': _i6.DocumentEndpoint()
        ..initialize(
          server,
          'document',
          null,
        ),
      'emailIdp': _i7.EmailIdpEndpoint()
        ..initialize(
          server,
          'emailIdp',
          null,
        ),
      'googleIdp': _i8.GoogleIdpEndpoint()
        ..initialize(
          server,
          'googleIdp',
          null,
        ),
      'health': _i9.HealthEndpoint()
        ..initialize(
          server,
          'health',
          null,
        ),
      'media': _i10.MediaEndpoint()
        ..initialize(
          server,
          'media',
          null,
        ),
      'member': _i11.MemberEndpoint()
        ..initialize(
          server,
          'member',
          null,
        ),
      'migration': _i12.MigrationEndpoint()
        ..initialize(
          server,
          'migration',
          null,
        ),
      'project': _i13.ProjectEndpoint()
        ..initialize(
          server,
          'project',
          null,
        ),
      'projectMember': _i14.ProjectMemberEndpoint()
        ..initialize(
          server,
          'projectMember',
          null,
        ),
      'publicContent': _i15.PublicContentEndpoint()
        ..initialize(
          server,
          'publicContent',
          null,
        ),
      'refreshJwtTokens': _i16.RefreshJwtTokensEndpoint()
        ..initialize(
          server,
          'refreshJwtTokens',
          null,
        ),
      'restore': _i17.RestoreEndpoint()
        ..initialize(
          server,
          'restore',
          null,
        ),
      'studioConfig': _i18.StudioConfigEndpoint()
        ..initialize(
          server,
          'studioConfig',
          null,
        ),
      'user': _i19.UserEndpoint()
        ..initialize(
          server,
          'user',
          null,
        ),
    };
    connectors['client'] = _i1.EndpointConnector(
      name: 'client',
      endpoint: endpoints['client']!,
      methodConnectors: {
        'getClientsForUser': _i1.MethodConnector(
          name: 'getClientsForUser',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['client'] as _i2.ClientEndpoint)
                  .getClientsForUser(session),
        ),
      },
    );
    connectors['apiKey'] = _i1.EndpointConnector(
      name: 'apiKey',
      endpoint: endpoints['apiKey']!,
      methodConnectors: {
        'getKeys': _i1.MethodConnector(
          name: 'getKeys',
          params: {
            'projectId': _i1.ParameterDescription(
              name: 'projectId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['apiKey'] as _i3.ApiKeyEndpoint).getKeys(
                session,
                projectId: params['projectId'],
              ),
        ),
        'createKey': _i1.MethodConnector(
          name: 'createKey',
          params: {
            'name': _i1.ParameterDescription(
              name: 'name',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'role': _i1.ParameterDescription(
              name: 'role',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'expiresAt': _i1.ParameterDescription(
              name: 'expiresAt',
              type: _i1.getType<DateTime?>(),
              nullable: true,
            ),
            'projectId': _i1.ParameterDescription(
              name: 'projectId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['apiKey'] as _i3.ApiKeyEndpoint).createKey(
                session,
                params['name'],
                params['role'],
                params['expiresAt'],
                projectId: params['projectId'],
              ),
        ),
        'updateKey': _i1.MethodConnector(
          name: 'updateKey',
          params: {
            'keyId': _i1.ParameterDescription(
              name: 'keyId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'name': _i1.ParameterDescription(
              name: 'name',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'isActive': _i1.ParameterDescription(
              name: 'isActive',
              type: _i1.getType<bool?>(),
              nullable: true,
            ),
            'expiresAt': _i1.ParameterDescription(
              name: 'expiresAt',
              type: _i1.getType<DateTime?>(),
              nullable: true,
            ),
            'projectId': _i1.ParameterDescription(
              name: 'projectId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['apiKey'] as _i3.ApiKeyEndpoint).updateKey(
                session,
                params['keyId'],
                params['name'],
                params['isActive'],
                params['expiresAt'],
                projectId: params['projectId'],
              ),
        ),
        'regenerateKey': _i1.MethodConnector(
          name: 'regenerateKey',
          params: {
            'keyId': _i1.ParameterDescription(
              name: 'keyId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'projectId': _i1.ParameterDescription(
              name: 'projectId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['apiKey'] as _i3.ApiKeyEndpoint).regenerateKey(
                    session,
                    params['keyId'],
                    projectId: params['projectId'],
                  ),
        ),
        'deleteKey': _i1.MethodConnector(
          name: 'deleteKey',
          params: {
            'keyId': _i1.ParameterDescription(
              name: 'keyId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'projectId': _i1.ParameterDescription(
              name: 'projectId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['apiKey'] as _i3.ApiKeyEndpoint).deleteKey(
                session,
                params['keyId'],
                projectId: params['projectId'],
              ),
        ),
      },
    );
    connectors['deployment'] = _i1.EndpointConnector(
      name: 'deployment',
      endpoint: endpoints['deployment']!,
      methodConnectors: {
        'list': _i1.MethodConnector(
          name: 'list',
          params: {
            'clientSlug': _i1.ParameterDescription(
              name: 'clientSlug',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'projectSlug': _i1.ParameterDescription(
              name: 'projectSlug',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['deployment'] as _i4.DeploymentEndpoint).list(
                    session,
                    params['clientSlug'],
                    params['projectSlug'],
                  ),
        ),
        'getActive': _i1.MethodConnector(
          name: 'getActive',
          params: {
            'clientSlug': _i1.ParameterDescription(
              name: 'clientSlug',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'projectSlug': _i1.ParameterDescription(
              name: 'projectSlug',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['deployment'] as _i4.DeploymentEndpoint).getActive(
                    session,
                    params['clientSlug'],
                    params['projectSlug'],
                  ),
        ),
        'activate': _i1.MethodConnector(
          name: 'activate',
          params: {
            'clientSlug': _i1.ParameterDescription(
              name: 'clientSlug',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'projectSlug': _i1.ParameterDescription(
              name: 'projectSlug',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'version': _i1.ParameterDescription(
              name: 'version',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['deployment'] as _i4.DeploymentEndpoint).activate(
                    session,
                    params['clientSlug'],
                    params['projectSlug'],
                    params['version'],
                  ),
        ),
        'delete': _i1.MethodConnector(
          name: 'delete',
          params: {
            'clientSlug': _i1.ParameterDescription(
              name: 'clientSlug',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'projectSlug': _i1.ParameterDescription(
              name: 'projectSlug',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'version': _i1.ParameterDescription(
              name: 'version',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['deployment'] as _i4.DeploymentEndpoint).delete(
                    session,
                    params['clientSlug'],
                    params['projectSlug'],
                    params['version'],
                  ),
        ),
      },
    );
    connectors['documentCollaboration'] = _i1.EndpointConnector(
      name: 'documentCollaboration',
      endpoint: endpoints['documentCollaboration']!,
      methodConnectors: {
        'getOperationsSince': _i1.MethodConnector(
          name: 'getOperationsSince',
          params: {
            'documentId': _i1.ParameterDescription(
              name: 'documentId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'sinceHlc': _i1.ParameterDescription(
              name: 'sinceHlc',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'limit': _i1.ParameterDescription(
              name: 'limit',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['documentCollaboration']
                          as _i5.DocumentCollaborationEndpoint)
                      .getOperationsSince(
                        session,
                        params['documentId'],
                        params['sinceHlc'],
                        limit: params['limit'],
                      ),
        ),
        'submitEdit': _i1.MethodConnector(
          name: 'submitEdit',
          params: {
            'documentId': _i1.ParameterDescription(
              name: 'documentId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'sessionId': _i1.ParameterDescription(
              name: 'sessionId',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'fieldUpdatesJson': _i1.ParameterDescription(
              name: 'fieldUpdatesJson',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['documentCollaboration']
                          as _i5.DocumentCollaborationEndpoint)
                      .submitEdit(
                        session,
                        params['documentId'],
                        params['sessionId'],
                        params['fieldUpdatesJson'],
                      ),
        ),
        'getActiveEditors': _i1.MethodConnector(
          name: 'getActiveEditors',
          params: {
            'documentId': _i1.ParameterDescription(
              name: 'documentId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['documentCollaboration']
                          as _i5.DocumentCollaborationEndpoint)
                      .getActiveEditors(
                        session,
                        params['documentId'],
                      ),
        ),
        'getCurrentHlc': _i1.MethodConnector(
          name: 'getCurrentHlc',
          params: {
            'documentId': _i1.ParameterDescription(
              name: 'documentId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['documentCollaboration']
                          as _i5.DocumentCollaborationEndpoint)
                      .getCurrentHlc(
                        session,
                        params['documentId'],
                      ),
        ),
        'getOperationCount': _i1.MethodConnector(
          name: 'getOperationCount',
          params: {
            'documentId': _i1.ParameterDescription(
              name: 'documentId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['documentCollaboration']
                          as _i5.DocumentCollaborationEndpoint)
                      .getOperationCount(
                        session,
                        params['documentId'],
                      ),
        ),
        'compactOperations': _i1.MethodConnector(
          name: 'compactOperations',
          params: {
            'documentId': _i1.ParameterDescription(
              name: 'documentId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['documentCollaboration']
                          as _i5.DocumentCollaborationEndpoint)
                      .compactOperations(
                        session,
                        params['documentId'],
                      ),
        ),
      },
    );
    connectors['document'] = _i1.EndpointConnector(
      name: 'document',
      endpoint: endpoints['document']!,
      methodConnectors: {
        'getDocuments': _i1.MethodConnector(
          name: 'getDocuments',
          params: {
            'documentType': _i1.ParameterDescription(
              name: 'documentType',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'search': _i1.ParameterDescription(
              name: 'search',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'limit': _i1.ParameterDescription(
              name: 'limit',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'offset': _i1.ParameterDescription(
              name: 'offset',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['document'] as _i6.DocumentEndpoint).getDocuments(
                    session,
                    params['documentType'],
                    search: params['search'],
                    limit: params['limit'],
                    offset: params['offset'],
                  ),
        ),
        'getDocument': _i1.MethodConnector(
          name: 'getDocument',
          params: {
            'documentId': _i1.ParameterDescription(
              name: 'documentId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['document'] as _i6.DocumentEndpoint).getDocument(
                    session,
                    params['documentId'],
                  ),
        ),
        'getDefaultDocument': _i1.MethodConnector(
          name: 'getDefaultDocument',
          params: {
            'documentType': _i1.ParameterDescription(
              name: 'documentType',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['document'] as _i6.DocumentEndpoint)
                  .getDefaultDocument(
                    session,
                    params['documentType'],
                  ),
        ),
        'createDocument': _i1.MethodConnector(
          name: 'createDocument',
          params: {
            'documentType': _i1.ParameterDescription(
              name: 'documentType',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'title': _i1.ParameterDescription(
              name: 'title',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'dataJson': _i1.ParameterDescription(
              name: 'dataJson',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'slug': _i1.ParameterDescription(
              name: 'slug',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'isDefault': _i1.ParameterDescription(
              name: 'isDefault',
              type: _i1.getType<bool>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['document'] as _i6.DocumentEndpoint)
                  .createDocument(
                    session,
                    params['documentType'],
                    params['title'],
                    params['dataJson'],
                    slug: params['slug'],
                    isDefault: params['isDefault'],
                  ),
        ),
        'updateDocumentData': _i1.MethodConnector(
          name: 'updateDocumentData',
          params: {
            'documentId': _i1.ParameterDescription(
              name: 'documentId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'updatesJson': _i1.ParameterDescription(
              name: 'updatesJson',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'sessionId': _i1.ParameterDescription(
              name: 'sessionId',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['document'] as _i6.DocumentEndpoint)
                  .updateDocumentData(
                    session,
                    params['documentId'],
                    params['updatesJson'],
                    sessionId: params['sessionId'],
                  ),
        ),
        'updateDocument': _i1.MethodConnector(
          name: 'updateDocument',
          params: {
            'documentId': _i1.ParameterDescription(
              name: 'documentId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'title': _i1.ParameterDescription(
              name: 'title',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'slug': _i1.ParameterDescription(
              name: 'slug',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'isDefault': _i1.ParameterDescription(
              name: 'isDefault',
              type: _i1.getType<bool?>(),
              nullable: true,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['document'] as _i6.DocumentEndpoint)
                  .updateDocument(
                    session,
                    params['documentId'],
                    title: params['title'],
                    slug: params['slug'],
                    isDefault: params['isDefault'],
                  ),
        ),
        'setDefaultDocument': _i1.MethodConnector(
          name: 'setDefaultDocument',
          params: {
            'documentTypeSlug': _i1.ParameterDescription(
              name: 'documentTypeSlug',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'documentId': _i1.ParameterDescription(
              name: 'documentId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['document'] as _i6.DocumentEndpoint)
                  .setDefaultDocument(
                    session,
                    params['documentTypeSlug'],
                    params['documentId'],
                  ),
        ),
        'deleteDocument': _i1.MethodConnector(
          name: 'deleteDocument',
          params: {
            'documentId': _i1.ParameterDescription(
              name: 'documentId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['document'] as _i6.DocumentEndpoint)
                  .deleteDocument(
                    session,
                    params['documentId'],
                  ),
        ),
        'suggestSlug': _i1.MethodConnector(
          name: 'suggestSlug',
          params: {
            'title': _i1.ParameterDescription(
              name: 'title',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'documentType': _i1.ParameterDescription(
              name: 'documentType',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['document'] as _i6.DocumentEndpoint).suggestSlug(
                    session,
                    params['title'],
                    params['documentType'],
                  ),
        ),
        'getDocumentTypes': _i1.MethodConnector(
          name: 'getDocumentTypes',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['document'] as _i6.DocumentEndpoint)
                  .getDocumentTypes(session),
        ),
        'getDocumentVersions': _i1.MethodConnector(
          name: 'getDocumentVersions',
          params: {
            'documentId': _i1.ParameterDescription(
              name: 'documentId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'limit': _i1.ParameterDescription(
              name: 'limit',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'offset': _i1.ParameterDescription(
              name: 'offset',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'includeOperations': _i1.ParameterDescription(
              name: 'includeOperations',
              type: _i1.getType<bool>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['document'] as _i6.DocumentEndpoint)
                  .getDocumentVersions(
                    session,
                    params['documentId'],
                    limit: params['limit'],
                    offset: params['offset'],
                    includeOperations: params['includeOperations'],
                  ),
        ),
        'getDocumentVersion': _i1.MethodConnector(
          name: 'getDocumentVersion',
          params: {
            'versionId': _i1.ParameterDescription(
              name: 'versionId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['document'] as _i6.DocumentEndpoint)
                  .getDocumentVersion(
                    session,
                    params['versionId'],
                  ),
        ),
        'getDocumentVersionData': _i1.MethodConnector(
          name: 'getDocumentVersionData',
          params: {
            'versionId': _i1.ParameterDescription(
              name: 'versionId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['document'] as _i6.DocumentEndpoint)
                  .getDocumentVersionData(
                    session,
                    params['versionId'],
                  ),
        ),
        'createDocumentVersion': _i1.MethodConnector(
          name: 'createDocumentVersion',
          params: {
            'documentId': _i1.ParameterDescription(
              name: 'documentId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'status': _i1.ParameterDescription(
              name: 'status',
              type: _i1.getType<_i20.DocumentVersionStatus>(),
              nullable: false,
            ),
            'changeLog': _i1.ParameterDescription(
              name: 'changeLog',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['document'] as _i6.DocumentEndpoint)
                  .createDocumentVersion(
                    session,
                    params['documentId'],
                    status: params['status'],
                    changeLog: params['changeLog'],
                  ),
        ),
        'publishCurrentVersion': _i1.MethodConnector(
          name: 'publishCurrentVersion',
          params: {
            'documentId': _i1.ParameterDescription(
              name: 'documentId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['document'] as _i6.DocumentEndpoint)
                  .publishCurrentVersion(
                    session,
                    params['documentId'],
                  ),
        ),
        'archiveDocumentVersion': _i1.MethodConnector(
          name: 'archiveDocumentVersion',
          params: {
            'versionId': _i1.ParameterDescription(
              name: 'versionId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['document'] as _i6.DocumentEndpoint)
                  .archiveDocumentVersion(
                    session,
                    params['versionId'],
                  ),
        ),
        'deleteDocumentVersion': _i1.MethodConnector(
          name: 'deleteDocumentVersion',
          params: {
            'versionId': _i1.ParameterDescription(
              name: 'versionId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['document'] as _i6.DocumentEndpoint)
                  .deleteDocumentVersion(
                    session,
                    params['versionId'],
                  ),
        ),
        'getDocumentCount': _i1.MethodConnector(
          name: 'getDocumentCount',
          params: {
            'projectId': _i1.ParameterDescription(
              name: 'projectId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['document'] as _i6.DocumentEndpoint)
                  .getDocumentCount(
                    session,
                    projectId: params['projectId'],
                  ),
        ),
      },
    );
    connectors['emailIdp'] = _i1.EndpointConnector(
      name: 'emailIdp',
      endpoint: endpoints['emailIdp']!,
      methodConnectors: {
        'finishRegistration': _i1.MethodConnector(
          name: 'finishRegistration',
          params: {
            'registrationToken': _i1.ParameterDescription(
              name: 'registrationToken',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'password': _i1.ParameterDescription(
              name: 'password',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _i7.EmailIdpEndpoint)
                  .finishRegistration(
                    session,
                    registrationToken: params['registrationToken'],
                    password: params['password'],
                  ),
        ),
        'login': _i1.MethodConnector(
          name: 'login',
          params: {
            'email': _i1.ParameterDescription(
              name: 'email',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'password': _i1.ParameterDescription(
              name: 'password',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _i7.EmailIdpEndpoint).login(
                session,
                email: params['email'],
                password: params['password'],
              ),
        ),
        'startRegistration': _i1.MethodConnector(
          name: 'startRegistration',
          params: {
            'email': _i1.ParameterDescription(
              name: 'email',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _i7.EmailIdpEndpoint)
                  .startRegistration(
                    session,
                    email: params['email'],
                  ),
        ),
        'verifyRegistrationCode': _i1.MethodConnector(
          name: 'verifyRegistrationCode',
          params: {
            'accountRequestId': _i1.ParameterDescription(
              name: 'accountRequestId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'verificationCode': _i1.ParameterDescription(
              name: 'verificationCode',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _i7.EmailIdpEndpoint)
                  .verifyRegistrationCode(
                    session,
                    accountRequestId: params['accountRequestId'],
                    verificationCode: params['verificationCode'],
                  ),
        ),
        'startPasswordReset': _i1.MethodConnector(
          name: 'startPasswordReset',
          params: {
            'email': _i1.ParameterDescription(
              name: 'email',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _i7.EmailIdpEndpoint)
                  .startPasswordReset(
                    session,
                    email: params['email'],
                  ),
        ),
        'verifyPasswordResetCode': _i1.MethodConnector(
          name: 'verifyPasswordResetCode',
          params: {
            'passwordResetRequestId': _i1.ParameterDescription(
              name: 'passwordResetRequestId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'verificationCode': _i1.ParameterDescription(
              name: 'verificationCode',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _i7.EmailIdpEndpoint)
                  .verifyPasswordResetCode(
                    session,
                    passwordResetRequestId: params['passwordResetRequestId'],
                    verificationCode: params['verificationCode'],
                  ),
        ),
        'finishPasswordReset': _i1.MethodConnector(
          name: 'finishPasswordReset',
          params: {
            'finishPasswordResetToken': _i1.ParameterDescription(
              name: 'finishPasswordResetToken',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'newPassword': _i1.ParameterDescription(
              name: 'newPassword',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _i7.EmailIdpEndpoint)
                  .finishPasswordReset(
                    session,
                    finishPasswordResetToken:
                        params['finishPasswordResetToken'],
                    newPassword: params['newPassword'],
                  ),
        ),
        'hasAccount': _i1.MethodConnector(
          name: 'hasAccount',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _i7.EmailIdpEndpoint)
                  .hasAccount(session),
        ),
      },
    );
    connectors['googleIdp'] = _i1.EndpointConnector(
      name: 'googleIdp',
      endpoint: endpoints['googleIdp']!,
      methodConnectors: {
        'login': _i1.MethodConnector(
          name: 'login',
          params: {
            'idToken': _i1.ParameterDescription(
              name: 'idToken',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'accessToken': _i1.ParameterDescription(
              name: 'accessToken',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['googleIdp'] as _i8.GoogleIdpEndpoint).login(
                    session,
                    idToken: params['idToken'],
                    accessToken: params['accessToken'],
                  ),
        ),
        'hasAccount': _i1.MethodConnector(
          name: 'hasAccount',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['googleIdp'] as _i8.GoogleIdpEndpoint)
                  .hasAccount(session),
        ),
      },
    );
    connectors['health'] = _i1.EndpointConnector(
      name: 'health',
      endpoint: endpoints['health']!,
      methodConnectors: {
        'check': _i1.MethodConnector(
          name: 'check',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['health'] as _i9.HealthEndpoint).check(session),
        ),
      },
    );
    connectors['media'] = _i1.EndpointConnector(
      name: 'media',
      endpoint: endpoints['media']!,
      methodConnectors: {
        'uploadImage': _i1.MethodConnector(
          name: 'uploadImage',
          params: {
            'fileName': _i1.ParameterDescription(
              name: 'fileName',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'fileData': _i1.ParameterDescription(
              name: 'fileData',
              type: _i1.getType<_i21.ByteData>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['media'] as _i10.MediaEndpoint).uploadImage(
                session,
                params['fileName'],
                params['fileData'],
              ),
        ),
        'uploadFile': _i1.MethodConnector(
          name: 'uploadFile',
          params: {
            'fileName': _i1.ParameterDescription(
              name: 'fileName',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'fileData': _i1.ParameterDescription(
              name: 'fileData',
              type: _i1.getType<_i21.ByteData>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['media'] as _i10.MediaEndpoint).uploadFile(
                session,
                params['fileName'],
                params['fileData'],
              ),
        ),
        'deleteMedia': _i1.MethodConnector(
          name: 'deleteMedia',
          params: {
            'assetId': _i1.ParameterDescription(
              name: 'assetId',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['media'] as _i10.MediaEndpoint).deleteMedia(
                session,
                params['assetId'],
              ),
        ),
        'getMedia': _i1.MethodConnector(
          name: 'getMedia',
          params: {
            'assetId': _i1.ParameterDescription(
              name: 'assetId',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['media'] as _i10.MediaEndpoint).getMedia(
                session,
                params['assetId'],
              ),
        ),
        'listMedia': _i1.MethodConnector(
          name: 'listMedia',
          params: {
            'search': _i1.ParameterDescription(
              name: 'search',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'mimeTypePrefix': _i1.ParameterDescription(
              name: 'mimeTypePrefix',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'sortBy': _i1.ParameterDescription(
              name: 'sortBy',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'limit': _i1.ParameterDescription(
              name: 'limit',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'offset': _i1.ParameterDescription(
              name: 'offset',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['media'] as _i10.MediaEndpoint).listMedia(
                session,
                search: params['search'],
                mimeTypePrefix: params['mimeTypePrefix'],
                sortBy: params['sortBy'],
                limit: params['limit'],
                offset: params['offset'],
              ),
        ),
        'listMediaCount': _i1.MethodConnector(
          name: 'listMediaCount',
          params: {
            'search': _i1.ParameterDescription(
              name: 'search',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'mimeTypePrefix': _i1.ParameterDescription(
              name: 'mimeTypePrefix',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['media'] as _i10.MediaEndpoint).listMediaCount(
                    session,
                    search: params['search'],
                    mimeTypePrefix: params['mimeTypePrefix'],
                  ),
        ),
        'getMediaUsageCount': _i1.MethodConnector(
          name: 'getMediaUsageCount',
          params: {
            'assetId': _i1.ParameterDescription(
              name: 'assetId',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['media'] as _i10.MediaEndpoint).getMediaUsageCount(
                    session,
                    params['assetId'],
                  ),
        ),
        'updateMediaAsset': _i1.MethodConnector(
          name: 'updateMediaAsset',
          params: {
            'assetId': _i1.ParameterDescription(
              name: 'assetId',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'fileName': _i1.ParameterDescription(
              name: 'fileName',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['media'] as _i10.MediaEndpoint).updateMediaAsset(
                    session,
                    params['assetId'],
                    fileName: params['fileName'],
                  ),
        ),
      },
    );
    connectors['member'] = _i1.EndpointConnector(
      name: 'member',
      endpoint: endpoints['member']!,
      methodConnectors: {
        'listMembers': _i1.MethodConnector(
          name: 'listMembers',
          params: {
            'clientId': _i1.ParameterDescription(
              name: 'clientId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['member'] as _i11.MemberEndpoint).listMembers(
                    session,
                    clientId: params['clientId'],
                  ),
        ),
        'inviteMember': _i1.MethodConnector(
          name: 'inviteMember',
          params: {
            'clientId': _i1.ParameterDescription(
              name: 'clientId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'email': _i1.ParameterDescription(
              name: 'email',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'role': _i1.ParameterDescription(
              name: 'role',
              type: _i1.getType<_i22.ClientRole>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['member'] as _i11.MemberEndpoint).inviteMember(
                    session,
                    clientId: params['clientId'],
                    email: params['email'],
                    role: params['role'],
                  ),
        ),
        'updateMemberRole': _i1.MethodConnector(
          name: 'updateMemberRole',
          params: {
            'clientId': _i1.ParameterDescription(
              name: 'clientId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'userId': _i1.ParameterDescription(
              name: 'userId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'role': _i1.ParameterDescription(
              name: 'role',
              type: _i1.getType<_i22.ClientRole>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['member'] as _i11.MemberEndpoint).updateMemberRole(
                    session,
                    clientId: params['clientId'],
                    userId: params['userId'],
                    role: params['role'],
                  ),
        ),
        'removeMember': _i1.MethodConnector(
          name: 'removeMember',
          params: {
            'clientId': _i1.ParameterDescription(
              name: 'clientId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'userId': _i1.ParameterDescription(
              name: 'userId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['member'] as _i11.MemberEndpoint).removeMember(
                    session,
                    clientId: params['clientId'],
                    userId: params['userId'],
                  ),
        ),
      },
    );
    connectors['migration'] = _i1.EndpointConnector(
      name: 'migration',
      endpoint: endpoints['migration']!,
      methodConnectors: {
        'runMigration': _i1.MethodConnector(
          name: 'runMigration',
          params: {
            'title': _i1.ParameterDescription(
              name: 'title',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'documentType': _i1.ParameterDescription(
              name: 'documentType',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'operationsJson': _i1.ParameterDescription(
              name: 'operationsJson',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'dryRun': _i1.ParameterDescription(
              name: 'dryRun',
              type: _i1.getType<bool>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['migration'] as _i12.MigrationEndpoint)
                  .runMigration(
                    session,
                    params['title'],
                    params['documentType'],
                    params['operationsJson'],
                    params['dryRun'],
                  ),
        ),
        'listMigrations': _i1.MethodConnector(
          name: 'listMigrations',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['migration'] as _i12.MigrationEndpoint)
                  .listMigrations(session),
        ),
      },
    );
    connectors['project'] = _i1.EndpointConnector(
      name: 'project',
      endpoint: endpoints['project']!,
      methodConnectors: {
        'getProjects': _i1.MethodConnector(
          name: 'getProjects',
          params: {
            'search': _i1.ParameterDescription(
              name: 'search',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'limit': _i1.ParameterDescription(
              name: 'limit',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'offset': _i1.ParameterDescription(
              name: 'offset',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['project'] as _i13.ProjectEndpoint).getProjects(
                    session,
                    search: params['search'],
                    limit: params['limit'],
                    offset: params['offset'],
                  ),
        ),
        'getProject': _i1.MethodConnector(
          name: 'getProject',
          params: {
            'projectId': _i1.ParameterDescription(
              name: 'projectId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['project'] as _i13.ProjectEndpoint).getProject(
                    session,
                    params['projectId'],
                  ),
        ),
        'createProject': _i1.MethodConnector(
          name: 'createProject',
          params: {
            'name': _i1.ParameterDescription(
              name: 'name',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'slug': _i1.ParameterDescription(
              name: 'slug',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'description': _i1.ParameterDescription(
              name: 'description',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'settings': _i1.ParameterDescription(
              name: 'settings',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['project'] as _i13.ProjectEndpoint).createProject(
                    session,
                    params['name'],
                    params['slug'],
                    description: params['description'],
                    settings: params['settings'],
                  ),
        ),
        'updateProject': _i1.MethodConnector(
          name: 'updateProject',
          params: {
            'projectId': _i1.ParameterDescription(
              name: 'projectId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'name': _i1.ParameterDescription(
              name: 'name',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'description': _i1.ParameterDescription(
              name: 'description',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'isActive': _i1.ParameterDescription(
              name: 'isActive',
              type: _i1.getType<bool?>(),
              nullable: true,
            ),
            'settings': _i1.ParameterDescription(
              name: 'settings',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['project'] as _i13.ProjectEndpoint).updateProject(
                    session,
                    params['projectId'],
                    name: params['name'],
                    description: params['description'],
                    isActive: params['isActive'],
                    settings: params['settings'],
                  ),
        ),
        'updateDeployHostname': _i1.MethodConnector(
          name: 'updateDeployHostname',
          params: {
            'projectId': _i1.ParameterDescription(
              name: 'projectId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'newHostname': _i1.ParameterDescription(
              name: 'newHostname',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['project'] as _i13.ProjectEndpoint)
                  .updateDeployHostname(
                    session,
                    params['projectId'],
                    params['newHostname'],
                  ),
        ),
        'deleteProject': _i1.MethodConnector(
          name: 'deleteProject',
          params: {
            'projectId': _i1.ParameterDescription(
              name: 'projectId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['project'] as _i13.ProjectEndpoint).deleteProject(
                    session,
                    params['projectId'],
                  ),
        ),
        'createClientWithOwner': _i1.MethodConnector(
          name: 'createClientWithOwner',
          params: {
            'clientName': _i1.ParameterDescription(
              name: 'clientName',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'clientSlug': _i1.ParameterDescription(
              name: 'clientSlug',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['project'] as _i13.ProjectEndpoint)
                  .createClientWithOwner(
                    session,
                    clientName: params['clientName'],
                    clientSlug: params['clientSlug'],
                  ),
        ),
      },
    );
    connectors['projectMember'] = _i1.EndpointConnector(
      name: 'projectMember',
      endpoint: endpoints['projectMember']!,
      methodConnectors: {
        'listProjectMembers': _i1.MethodConnector(
          name: 'listProjectMembers',
          params: {
            'projectId': _i1.ParameterDescription(
              name: 'projectId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['projectMember'] as _i14.ProjectMemberEndpoint)
                      .listProjectMembers(
                        session,
                        projectId: params['projectId'],
                      ),
        ),
        'addProjectMember': _i1.MethodConnector(
          name: 'addProjectMember',
          params: {
            'projectId': _i1.ParameterDescription(
              name: 'projectId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'userId': _i1.ParameterDescription(
              name: 'userId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'role': _i1.ParameterDescription(
              name: 'role',
              type: _i1.getType<_i23.ProjectRole>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['projectMember'] as _i14.ProjectMemberEndpoint)
                      .addProjectMember(
                        session,
                        projectId: params['projectId'],
                        userId: params['userId'],
                        role: params['role'],
                      ),
        ),
        'updateProjectMemberRole': _i1.MethodConnector(
          name: 'updateProjectMemberRole',
          params: {
            'projectId': _i1.ParameterDescription(
              name: 'projectId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'userId': _i1.ParameterDescription(
              name: 'userId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'role': _i1.ParameterDescription(
              name: 'role',
              type: _i1.getType<_i23.ProjectRole>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['projectMember'] as _i14.ProjectMemberEndpoint)
                      .updateProjectMemberRole(
                        session,
                        projectId: params['projectId'],
                        userId: params['userId'],
                        role: params['role'],
                      ),
        ),
        'removeProjectMember': _i1.MethodConnector(
          name: 'removeProjectMember',
          params: {
            'projectId': _i1.ParameterDescription(
              name: 'projectId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'userId': _i1.ParameterDescription(
              name: 'userId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['projectMember'] as _i14.ProjectMemberEndpoint)
                      .removeProjectMember(
                        session,
                        projectId: params['projectId'],
                        userId: params['userId'],
                      ),
        ),
      },
    );
    connectors['publicContent'] = _i1.EndpointConnector(
      name: 'publicContent',
      endpoint: endpoints['publicContent']!,
      methodConnectors: {
        'getAllContents': _i1.MethodConnector(
          name: 'getAllContents',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['publicContent'] as _i15.PublicContentEndpoint)
                      .getAllContents(session),
        ),
        'getDefaultContents': _i1.MethodConnector(
          name: 'getDefaultContents',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['publicContent'] as _i15.PublicContentEndpoint)
                      .getDefaultContents(session),
        ),
        'getContentsByType': _i1.MethodConnector(
          name: 'getContentsByType',
          params: {
            'documentType': _i1.ParameterDescription(
              name: 'documentType',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['publicContent'] as _i15.PublicContentEndpoint)
                      .getContentsByType(
                        session,
                        params['documentType'],
                      ),
        ),
        'getDefaultContent': _i1.MethodConnector(
          name: 'getDefaultContent',
          params: {
            'documentType': _i1.ParameterDescription(
              name: 'documentType',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['publicContent'] as _i15.PublicContentEndpoint)
                      .getDefaultContent(
                        session,
                        params['documentType'],
                      ),
        ),
        'getContentBySlug': _i1.MethodConnector(
          name: 'getContentBySlug',
          params: {
            'documentType': _i1.ParameterDescription(
              name: 'documentType',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'slug': _i1.ParameterDescription(
              name: 'slug',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['publicContent'] as _i15.PublicContentEndpoint)
                      .getContentBySlug(
                        session,
                        params['documentType'],
                        params['slug'],
                      ),
        ),
        'getContentsByDataContains': _i1.MethodConnector(
          name: 'getContentsByDataContains',
          params: {
            'documentType': _i1.ParameterDescription(
              name: 'documentType',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'dataContainsJson': _i1.ParameterDescription(
              name: 'dataContainsJson',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['publicContent'] as _i15.PublicContentEndpoint)
                      .getContentsByDataContains(
                        session,
                        params['documentType'],
                        params['dataContainsJson'],
                      ),
        ),
        'getAllContentsByDataContains': _i1.MethodConnector(
          name: 'getAllContentsByDataContains',
          params: {
            'dataContainsJson': _i1.ParameterDescription(
              name: 'dataContainsJson',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['publicContent'] as _i15.PublicContentEndpoint)
                      .getAllContentsByDataContains(
                        session,
                        params['dataContainsJson'],
                      ),
        ),
      },
    );
    connectors['refreshJwtTokens'] = _i1.EndpointConnector(
      name: 'refreshJwtTokens',
      endpoint: endpoints['refreshJwtTokens']!,
      methodConnectors: {
        'refreshAccessToken': _i1.MethodConnector(
          name: 'refreshAccessToken',
          params: {
            'refreshToken': _i1.ParameterDescription(
              name: 'refreshToken',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['refreshJwtTokens']
                          as _i16.RefreshJwtTokensEndpoint)
                      .refreshAccessToken(
                        session,
                        refreshToken: params['refreshToken'],
                      ),
        ),
      },
    );
    connectors['restore'] = _i1.EndpointConnector(
      name: 'restore',
      endpoint: endpoints['restore']!,
      methodConnectors: {
        'restoreDocument': _i1.MethodConnector(
          name: 'restoreDocument',
          params: {
            'documentId': _i1.ParameterDescription(
              name: 'documentId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['restore'] as _i17.RestoreEndpoint)
                  .restoreDocument(
                    session,
                    params['documentId'],
                  ),
        ),
        'restoreProject': _i1.MethodConnector(
          name: 'restoreProject',
          params: {
            'projectId': _i1.ParameterDescription(
              name: 'projectId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['restore'] as _i17.RestoreEndpoint).restoreProject(
                    session,
                    params['projectId'],
                  ),
        ),
        'restoreUser': _i1.MethodConnector(
          name: 'restoreUser',
          params: {
            'userId': _i1.ParameterDescription(
              name: 'userId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['restore'] as _i17.RestoreEndpoint).restoreUser(
                    session,
                    params['userId'],
                  ),
        ),
      },
    );
    connectors['studioConfig'] = _i1.EndpointConnector(
      name: 'studioConfig',
      endpoint: endpoints['studioConfig']!,
      methodConnectors: {
        'getStudioUrlTemplate': _i1.MethodConnector(
          name: 'getStudioUrlTemplate',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['studioConfig'] as _i18.StudioConfigEndpoint)
                      .getStudioUrlTemplate(session),
        ),
      },
    );
    connectors['user'] = _i1.EndpointConnector(
      name: 'user',
      endpoint: endpoints['user']!,
      methodConnectors: {
        'getCurrentUser': _i1.MethodConnector(
          name: 'getCurrentUser',
          params: {
            'clientId': _i1.ParameterDescription(
              name: 'clientId',
              type: _i1.getType<_i1.UuidValue?>(),
              nullable: true,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['user'] as _i19.UserEndpoint).getCurrentUser(
                    session,
                    clientId: params['clientId'],
                  ),
        ),
        'getUserCount': _i1.MethodConnector(
          name: 'getUserCount',
          params: {
            'clientId': _i1.ParameterDescription(
              name: 'clientId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['user'] as _i19.UserEndpoint).getUserCount(
                session,
                clientId: params['clientId'],
              ),
        ),
      },
    );
    modules['serverpod_auth_core'] = _i24.Endpoints()
      ..initializeEndpoints(server);
    modules['serverpod_auth_idp'] = _i25.Endpoints()
      ..initializeEndpoints(server);
  }
}
