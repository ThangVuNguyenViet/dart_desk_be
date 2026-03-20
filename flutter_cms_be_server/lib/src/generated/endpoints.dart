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
import '../endpoints/cms_api_token_endpoint.dart' as _i2;
import '../endpoints/cms_client_endpoint.dart' as _i3;
import '../endpoints/deployment_endpoint.dart' as _i4;
import '../endpoints/document_collaboration_endpoint.dart' as _i5;
import '../endpoints/document_endpoint.dart' as _i6;
import '../endpoints/email_idp_endpoint.dart' as _i7;
import '../endpoints/google_idp_endpoint.dart' as _i8;
import '../endpoints/media_endpoint.dart' as _i9;
import '../endpoints/refresh_jwt_tokens_endpoint.dart' as _i10;
import '../endpoints/user_endpoint.dart' as _i11;
import 'package:flutter_cms_be_server/src/generated/document_version_status.dart'
    as _i12;
import 'dart:typed_data' as _i13;
import 'package:serverpod_auth_idp_server/serverpod_auth_idp_server.dart'
    as _i14;
import 'package:serverpod_admin_server/serverpod_admin_server.dart' as _i15;
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart'
    as _i16;

class Endpoints extends _i1.EndpointDispatch {
  @override
  void initializeEndpoints(_i1.Server server) {
    var endpoints = <String, _i1.Endpoint>{
      'cmsApiToken': _i2.CmsApiTokenEndpoint()
        ..initialize(
          server,
          'cmsApiToken',
          null,
        ),
      'cmsClient': _i3.CmsClientEndpoint()
        ..initialize(
          server,
          'cmsClient',
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
      'media': _i9.MediaEndpoint()
        ..initialize(
          server,
          'media',
          null,
        ),
      'refreshJwtTokens': _i10.RefreshJwtTokensEndpoint()
        ..initialize(
          server,
          'refreshJwtTokens',
          null,
        ),
      'user': _i11.UserEndpoint()
        ..initialize(
          server,
          'user',
          null,
        ),
    };
    connectors['cmsApiToken'] = _i1.EndpointConnector(
      name: 'cmsApiToken',
      endpoint: endpoints['cmsApiToken']!,
      methodConnectors: {
        'getTokens': _i1.MethodConnector(
          name: 'getTokens',
          params: {
            'clientId': _i1.ParameterDescription(
              name: 'clientId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['cmsApiToken'] as _i2.CmsApiTokenEndpoint)
                  .getTokens(
                    session,
                    params['clientId'],
                  ),
        ),
        'createToken': _i1.MethodConnector(
          name: 'createToken',
          params: {
            'clientId': _i1.ParameterDescription(
              name: 'clientId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
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
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['cmsApiToken'] as _i2.CmsApiTokenEndpoint)
                  .createToken(
                    session,
                    params['clientId'],
                    params['name'],
                    params['role'],
                    params['expiresAt'],
                  ),
        ),
        'updateToken': _i1.MethodConnector(
          name: 'updateToken',
          params: {
            'tokenId': _i1.ParameterDescription(
              name: 'tokenId',
              type: _i1.getType<int>(),
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
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['cmsApiToken'] as _i2.CmsApiTokenEndpoint)
                  .updateToken(
                    session,
                    params['tokenId'],
                    params['name'],
                    params['isActive'],
                    params['expiresAt'],
                  ),
        ),
        'regenerateToken': _i1.MethodConnector(
          name: 'regenerateToken',
          params: {
            'tokenId': _i1.ParameterDescription(
              name: 'tokenId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['cmsApiToken'] as _i2.CmsApiTokenEndpoint)
                  .regenerateToken(
                    session,
                    params['tokenId'],
                  ),
        ),
        'deleteToken': _i1.MethodConnector(
          name: 'deleteToken',
          params: {
            'tokenId': _i1.ParameterDescription(
              name: 'tokenId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['cmsApiToken'] as _i2.CmsApiTokenEndpoint)
                  .deleteToken(
                    session,
                    params['tokenId'],
                  ),
        ),
      },
    );
    connectors['cmsClient'] = _i1.EndpointConnector(
      name: 'cmsClient',
      endpoint: endpoints['cmsClient']!,
      methodConnectors: {
        'getClients': _i1.MethodConnector(
          name: 'getClients',
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
                  (endpoints['cmsClient'] as _i3.CmsClientEndpoint).getClients(
                    session,
                    search: params['search'],
                    limit: params['limit'],
                    offset: params['offset'],
                  ),
        ),
        'getClientBySlug': _i1.MethodConnector(
          name: 'getClientBySlug',
          params: {
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
              ) async => (endpoints['cmsClient'] as _i3.CmsClientEndpoint)
                  .getClientBySlug(
                    session,
                    params['slug'],
                  ),
        ),
        'getClient': _i1.MethodConnector(
          name: 'getClient',
          params: {
            'clientId': _i1.ParameterDescription(
              name: 'clientId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['cmsClient'] as _i3.CmsClientEndpoint).getClient(
                    session,
                    params['clientId'],
                  ),
        ),
        'createClient': _i1.MethodConnector(
          name: 'createClient',
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
              ) async => (endpoints['cmsClient'] as _i3.CmsClientEndpoint)
                  .createClient(
                    session,
                    params['name'],
                    params['slug'],
                    description: params['description'],
                    settings: params['settings'],
                  ),
        ),
        'updateClient': _i1.MethodConnector(
          name: 'updateClient',
          params: {
            'clientId': _i1.ParameterDescription(
              name: 'clientId',
              type: _i1.getType<int>(),
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
              ) async => (endpoints['cmsClient'] as _i3.CmsClientEndpoint)
                  .updateClient(
                    session,
                    params['clientId'],
                    name: params['name'],
                    description: params['description'],
                    isActive: params['isActive'],
                    settings: params['settings'],
                  ),
        ),
        'regenerateApiToken': _i1.MethodConnector(
          name: 'regenerateApiToken',
          params: {
            'clientId': _i1.ParameterDescription(
              name: 'clientId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['cmsClient'] as _i3.CmsClientEndpoint)
                  .regenerateApiToken(
                    session,
                    params['clientId'],
                  ),
        ),
        'deleteClient': _i1.MethodConnector(
          name: 'deleteClient',
          params: {
            'clientId': _i1.ParameterDescription(
              name: 'clientId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['cmsClient'] as _i3.CmsClientEndpoint)
                  .deleteClient(
                    session,
                    params['clientId'],
                  ),
        ),
        'createClientWithOwner': _i1.MethodConnector(
          name: 'createClientWithOwner',
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
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['cmsClient'] as _i3.CmsClientEndpoint)
                  .createClientWithOwner(
                    session,
                    name: params['name'],
                    slug: params['slug'],
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
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['deployment'] as _i4.DeploymentEndpoint).list(
                    session,
                    params['clientSlug'],
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
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['deployment'] as _i4.DeploymentEndpoint).getActive(
                    session,
                    params['clientSlug'],
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
              type: _i1.getType<int>(),
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
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'sessionId': _i1.ParameterDescription(
              name: 'sessionId',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'fieldUpdates': _i1.ParameterDescription(
              name: 'fieldUpdates',
              type: _i1.getType<Map<String, dynamic>>(),
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
                        params['fieldUpdates'],
                      ),
        ),
        'getActiveEditors': _i1.MethodConnector(
          name: 'getActiveEditors',
          params: {
            'documentId': _i1.ParameterDescription(
              name: 'documentId',
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
              type: _i1.getType<int>(),
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
        'getDocumentBySlug': _i1.MethodConnector(
          name: 'getDocumentBySlug',
          params: {
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
              ) async => (endpoints['document'] as _i6.DocumentEndpoint)
                  .getDocumentBySlug(
                    session,
                    params['slug'],
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
            'data': _i1.ParameterDescription(
              name: 'data',
              type: _i1.getType<Map<String, dynamic>>(),
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
                    params['data'],
                    slug: params['slug'],
                    isDefault: params['isDefault'],
                  ),
        ),
        'updateDocumentData': _i1.MethodConnector(
          name: 'updateDocumentData',
          params: {
            'documentId': _i1.ParameterDescription(
              name: 'documentId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'updates': _i1.ParameterDescription(
              name: 'updates',
              type: _i1.getType<Map<String, dynamic>>(),
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
                    params['updates'],
                    sessionId: params['sessionId'],
                  ),
        ),
        'updateDocument': _i1.MethodConnector(
          name: 'updateDocument',
          params: {
            'documentId': _i1.ParameterDescription(
              name: 'documentId',
              type: _i1.getType<int>(),
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
        'deleteDocument': _i1.MethodConnector(
          name: 'deleteDocument',
          params: {
            'documentId': _i1.ParameterDescription(
              name: 'documentId',
              type: _i1.getType<int>(),
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
              type: _i1.getType<int>(),
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
              type: _i1.getType<int>(),
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
              type: _i1.getType<int>(),
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
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'status': _i1.ParameterDescription(
              name: 'status',
              type: _i1.getType<_i12.DocumentVersionStatus>(),
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
        'publishDocumentVersion': _i1.MethodConnector(
          name: 'publishDocumentVersion',
          params: {
            'versionId': _i1.ParameterDescription(
              name: 'versionId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['document'] as _i6.DocumentEndpoint)
                  .publishDocumentVersion(
                    session,
                    params['versionId'],
                  ),
        ),
        'archiveDocumentVersion': _i1.MethodConnector(
          name: 'archiveDocumentVersion',
          params: {
            'versionId': _i1.ParameterDescription(
              name: 'versionId',
              type: _i1.getType<int>(),
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
              type: _i1.getType<int>(),
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
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['document'] as _i6.DocumentEndpoint)
                  .getDocumentCount(session),
        ),
      },
    );
    connectors['emailIdp'] = _i1.EndpointConnector(
      name: 'emailIdp',
      endpoint: endpoints['emailIdp']!,
      methodConnectors: {
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
              type: _i1.getType<_i13.ByteData>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['media'] as _i9.MediaEndpoint).uploadImage(
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
              type: _i1.getType<_i13.ByteData>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['media'] as _i9.MediaEndpoint).uploadFile(
                session,
                params['fileName'],
                params['fileData'],
              ),
        ),
        'deleteMedia': _i1.MethodConnector(
          name: 'deleteMedia',
          params: {
            'fileId': _i1.ParameterDescription(
              name: 'fileId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['media'] as _i9.MediaEndpoint).deleteMedia(
                session,
                params['fileId'],
              ),
        ),
        'getMedia': _i1.MethodConnector(
          name: 'getMedia',
          params: {
            'fileId': _i1.ParameterDescription(
              name: 'fileId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['media'] as _i9.MediaEndpoint).getMedia(
                session,
                params['fileId'],
              ),
        ),
        'listMedia': _i1.MethodConnector(
          name: 'listMedia',
          params: {
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
              ) async => (endpoints['media'] as _i9.MediaEndpoint).listMedia(
                session,
                limit: params['limit'],
                offset: params['offset'],
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
                          as _i10.RefreshJwtTokensEndpoint)
                      .refreshAccessToken(
                        session,
                        refreshToken: params['refreshToken'],
                      ),
        ),
      },
    );
    connectors['user'] = _i1.EndpointConnector(
      name: 'user',
      endpoint: endpoints['user']!,
      methodConnectors: {
        'ensureUser': _i1.MethodConnector(
          name: 'ensureUser',
          params: {
            'clientSlug': _i1.ParameterDescription(
              name: 'clientSlug',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'apiToken': _i1.ParameterDescription(
              name: 'apiToken',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['user'] as _i11.UserEndpoint).ensureUser(
                session,
                params['clientSlug'],
                params['apiToken'],
              ),
        ),
        'getCurrentUser': _i1.MethodConnector(
          name: 'getCurrentUser',
          params: {
            'clientSlug': _i1.ParameterDescription(
              name: 'clientSlug',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'apiToken': _i1.ParameterDescription(
              name: 'apiToken',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['user'] as _i11.UserEndpoint).getCurrentUser(
                    session,
                    params['clientSlug'],
                    params['apiToken'],
                  ),
        ),
        'getUserClients': _i1.MethodConnector(
          name: 'getUserClients',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['user'] as _i11.UserEndpoint)
                  .getUserClients(session),
        ),
        'getCurrentUserBySlug': _i1.MethodConnector(
          name: 'getCurrentUserBySlug',
          params: {
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
              ) async =>
                  (endpoints['user'] as _i11.UserEndpoint).getCurrentUserBySlug(
                    session,
                    params['clientSlug'],
                  ),
        ),
        'getClientUserCount': _i1.MethodConnector(
          name: 'getClientUserCount',
          params: {
            'clientId': _i1.ParameterDescription(
              name: 'clientId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['user'] as _i11.UserEndpoint).getClientUserCount(
                    session,
                    params['clientId'],
                  ),
        ),
      },
    );
    modules['serverpod_auth_idp'] = _i14.Endpoints()
      ..initializeEndpoints(server);
    modules['serverpod_admin'] = _i15.Endpoints()..initializeEndpoints(server);
    modules['serverpod_auth_core'] = _i16.Endpoints()
      ..initializeEndpoints(server);
  }
}
