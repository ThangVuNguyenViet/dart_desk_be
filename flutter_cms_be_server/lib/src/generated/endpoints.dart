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
import '../endpoints/document_endpoint.dart' as _i2;
import '../endpoints/media_endpoint.dart' as _i3;
import 'dart:typed_data' as _i4;
import 'package:serverpod_auth_server/serverpod_auth_server.dart' as _i5;

class Endpoints extends _i1.EndpointDispatch {
  @override
  void initializeEndpoints(_i1.Server server) {
    var endpoints = <String, _i1.Endpoint>{
      'document': _i2.DocumentEndpoint()
        ..initialize(
          server,
          'document',
          null,
        ),
      'media': _i3.MediaEndpoint()
        ..initialize(
          server,
          'media',
          null,
        ),
    };
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
              (endpoints['document'] as _i2.DocumentEndpoint).getDocuments(
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
              (endpoints['document'] as _i2.DocumentEndpoint).getDocument(
            session,
            params['documentId'],
          ),
        ),
        'getDocumentByType': _i1.MethodConnector(
          name: 'getDocumentByType',
          params: {
            'documentType': _i1.ParameterDescription(
              name: 'documentType',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'documentId': _i1.ParameterDescription(
              name: 'documentId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['document'] as _i2.DocumentEndpoint).getDocumentByType(
            session,
            params['documentType'],
            params['documentId'],
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
            'data': _i1.ParameterDescription(
              name: 'data',
              type: _i1.getType<Map<String, dynamic>>(),
              nullable: false,
            ),
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['document'] as _i2.DocumentEndpoint).createDocument(
            session,
            params['documentType'],
            params['data'],
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
            'data': _i1.ParameterDescription(
              name: 'data',
              type: _i1.getType<Map<String, dynamic>>(),
              nullable: false,
            ),
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['document'] as _i2.DocumentEndpoint).updateDocument(
            session,
            params['documentId'],
            params['data'],
          ),
        ),
        'updateDocumentByType': _i1.MethodConnector(
          name: 'updateDocumentByType',
          params: {
            'documentType': _i1.ParameterDescription(
              name: 'documentType',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'documentId': _i1.ParameterDescription(
              name: 'documentId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'data': _i1.ParameterDescription(
              name: 'data',
              type: _i1.getType<Map<String, dynamic>>(),
              nullable: false,
            ),
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['document'] as _i2.DocumentEndpoint)
                  .updateDocumentByType(
            session,
            params['documentType'],
            params['documentId'],
            params['data'],
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
              (endpoints['document'] as _i2.DocumentEndpoint).deleteDocument(
            session,
            params['documentId'],
          ),
        ),
        'deleteDocumentByType': _i1.MethodConnector(
          name: 'deleteDocumentByType',
          params: {
            'documentType': _i1.ParameterDescription(
              name: 'documentType',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'documentId': _i1.ParameterDescription(
              name: 'documentId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['document'] as _i2.DocumentEndpoint)
                  .deleteDocumentByType(
            session,
            params['documentType'],
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
              (endpoints['document'] as _i2.DocumentEndpoint)
                  .getDocumentTypes(session),
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
              type: _i1.getType<_i4.ByteData>(),
              nullable: false,
            ),
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['media'] as _i3.MediaEndpoint).uploadImage(
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
              type: _i1.getType<_i4.ByteData>(),
              nullable: false,
            ),
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['media'] as _i3.MediaEndpoint).uploadFile(
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
              (endpoints['media'] as _i3.MediaEndpoint).deleteMedia(
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
              (endpoints['media'] as _i3.MediaEndpoint).getMedia(
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
              (endpoints['media'] as _i3.MediaEndpoint).listMedia(
            session,
            limit: params['limit'],
            offset: params['offset'],
          ),
        ),
      },
    );
    modules['serverpod_auth'] = _i5.Endpoints()..initializeEndpoints(server);
  }
}
