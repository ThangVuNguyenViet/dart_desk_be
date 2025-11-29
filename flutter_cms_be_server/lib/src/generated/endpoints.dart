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
import '../endpoints/document_collaboration_endpoint.dart' as _i2;
import '../endpoints/document_endpoint.dart' as _i3;
import '../endpoints/media_endpoint.dart' as _i4;
import 'package:flutter_cms_be_server/src/generated/document_version_status.dart'
    as _i5;
import 'dart:typed_data' as _i6;
import 'package:serverpod_auth_server/serverpod_auth_server.dart' as _i7;

class Endpoints extends _i1.EndpointDispatch {
  @override
  void initializeEndpoints(_i1.Server server) {
    var endpoints = <String, _i1.Endpoint>{
      'documentCollaboration': _i2.DocumentCollaborationEndpoint()
        ..initialize(
          server,
          'documentCollaboration',
          null,
        ),
      'document': _i3.DocumentEndpoint()
        ..initialize(
          server,
          'document',
          null,
        ),
      'media': _i4.MediaEndpoint()
        ..initialize(
          server,
          'media',
          null,
        ),
    };
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
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['documentCollaboration']
                      as _i2.DocumentCollaborationEndpoint)
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
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['documentCollaboration']
                      as _i2.DocumentCollaborationEndpoint)
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
            )
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['documentCollaboration']
                      as _i2.DocumentCollaborationEndpoint)
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
            )
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['documentCollaboration']
                      as _i2.DocumentCollaborationEndpoint)
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
            )
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['documentCollaboration']
                      as _i2.DocumentCollaborationEndpoint)
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
            )
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['documentCollaboration']
                      as _i2.DocumentCollaborationEndpoint)
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
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['document'] as _i3.DocumentEndpoint).getDocuments(
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
            )
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['document'] as _i3.DocumentEndpoint).getDocument(
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
            )
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['document'] as _i3.DocumentEndpoint).getDocumentBySlug(
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
            )
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['document'] as _i3.DocumentEndpoint)
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
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['document'] as _i3.DocumentEndpoint).createDocument(
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
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['document'] as _i3.DocumentEndpoint)
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
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['document'] as _i3.DocumentEndpoint).updateDocument(
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
            )
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['document'] as _i3.DocumentEndpoint).deleteDocument(
            session,
            params['documentId'],
          ),
        ),
        'getDocumentTypes': _i1.MethodConnector(
          name: 'getDocumentTypes',
          params: {},
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['document'] as _i3.DocumentEndpoint)
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
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['document'] as _i3.DocumentEndpoint)
                  .getDocumentVersions(
            session,
            params['documentId'],
            limit: params['limit'],
            offset: params['offset'],
          ),
        ),
        'getDocumentVersion': _i1.MethodConnector(
          name: 'getDocumentVersion',
          params: {
            'versionId': _i1.ParameterDescription(
              name: 'versionId',
              type: _i1.getType<int>(),
              nullable: false,
            )
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['document'] as _i3.DocumentEndpoint)
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
            )
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['document'] as _i3.DocumentEndpoint)
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
              type: _i1.getType<_i5.DocumentVersionStatus>(),
              nullable: false,
            ),
            'changeLog': _i1.ParameterDescription(
              name: 'changeLog',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['document'] as _i3.DocumentEndpoint)
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
            )
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['document'] as _i3.DocumentEndpoint)
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
            )
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['document'] as _i3.DocumentEndpoint)
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
            )
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['document'] as _i3.DocumentEndpoint)
                  .deleteDocumentVersion(
            session,
            params['versionId'],
          ),
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
              type: _i1.getType<_i6.ByteData>(),
              nullable: false,
            ),
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['media'] as _i4.MediaEndpoint).uploadImage(
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
              type: _i1.getType<_i6.ByteData>(),
              nullable: false,
            ),
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['media'] as _i4.MediaEndpoint).uploadFile(
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
            )
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['media'] as _i4.MediaEndpoint).deleteMedia(
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
            )
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['media'] as _i4.MediaEndpoint).getMedia(
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
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['media'] as _i4.MediaEndpoint).listMedia(
            session,
            limit: params['limit'],
            offset: params['offset'],
          ),
        ),
      },
    );
    modules['serverpod_auth'] = _i7.Endpoints()..initializeEndpoints(server);
  }
}
