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
import 'dart:async' as _i2;
import 'package:flutter_cms_be_client/src/protocol/document_list_response.dart'
    as _i3;
import 'package:flutter_cms_be_client/src/protocol/cms_document.dart' as _i4;
import 'package:flutter_cms_be_client/src/protocol/upload_response.dart' as _i5;
import 'dart:typed_data' as _i6;
import 'package:flutter_cms_be_client/src/protocol/media_file.dart' as _i7;
import 'protocol.dart' as _i8;

/// Endpoint for managing CMS documents
/// {@category Endpoint}
class EndpointDocument extends _i1.EndpointRef {
  EndpointDocument(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'document';

  /// Get all documents for a specific document type with pagination
  _i2.Future<_i3.DocumentListResponse> getDocuments(
    String documentType, {
    String? search,
    required int limit,
    required int offset,
  }) =>
      caller.callServerEndpoint<_i3.DocumentListResponse>(
        'document',
        'getDocuments',
        {
          'documentType': documentType,
          'search': search,
          'limit': limit,
          'offset': offset,
        },
      );

  /// Get a single document by ID
  _i2.Future<_i4.CmsDocument?> getDocument(int documentId) =>
      caller.callServerEndpoint<_i4.CmsDocument?>(
        'document',
        'getDocument',
        {'documentId': documentId},
      );

  /// Get a document by document type and ID
  _i2.Future<_i4.CmsDocument?> getDocumentByType(
    String documentType,
    int documentId,
  ) =>
      caller.callServerEndpoint<_i4.CmsDocument?>(
        'document',
        'getDocumentByType',
        {
          'documentType': documentType,
          'documentId': documentId,
        },
      );

  /// Create a new document
  _i2.Future<_i4.CmsDocument> createDocument(
    String documentType,
    Map<String, dynamic> data,
  ) =>
      caller.callServerEndpoint<_i4.CmsDocument>(
        'document',
        'createDocument',
        {
          'documentType': documentType,
          'data': data,
        },
      );

  /// Update an existing document
  _i2.Future<_i4.CmsDocument?> updateDocument(
    int documentId,
    Map<String, dynamic> data,
  ) =>
      caller.callServerEndpoint<_i4.CmsDocument?>(
        'document',
        'updateDocument',
        {
          'documentId': documentId,
          'data': data,
        },
      );

  /// Update a document by document type and ID
  _i2.Future<_i4.CmsDocument?> updateDocumentByType(
    String documentType,
    int documentId,
    Map<String, dynamic> data,
  ) =>
      caller.callServerEndpoint<_i4.CmsDocument?>(
        'document',
        'updateDocumentByType',
        {
          'documentType': documentType,
          'documentId': documentId,
          'data': data,
        },
      );

  /// Delete a document
  _i2.Future<bool> deleteDocument(int documentId) =>
      caller.callServerEndpoint<bool>(
        'document',
        'deleteDocument',
        {'documentId': documentId},
      );

  /// Delete a document by document type and ID
  _i2.Future<bool> deleteDocumentByType(
    String documentType,
    int documentId,
  ) =>
      caller.callServerEndpoint<bool>(
        'document',
        'deleteDocumentByType',
        {
          'documentType': documentType,
          'documentId': documentId,
        },
      );

  /// Get all document types (unique document type names)
  _i2.Future<List<String>> getDocumentTypes() =>
      caller.callServerEndpoint<List<String>>(
        'document',
        'getDocumentTypes',
        {},
      );
}

/// Endpoint for managing media files and uploads
/// {@category Endpoint}
class EndpointMedia extends _i1.EndpointRef {
  EndpointMedia(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'media';

  /// Upload an image file
  /// Returns the public URL and file ID
  _i2.Future<_i5.UploadResponse> uploadImage(
    String fileName,
    _i6.ByteData fileData,
  ) =>
      caller.callServerEndpoint<_i5.UploadResponse>(
        'media',
        'uploadImage',
        {
          'fileName': fileName,
          'fileData': fileData,
        },
      );

  /// Upload a general file (PDF, documents, etc.)
  /// Returns the public URL, file ID, and filename
  _i2.Future<_i5.UploadResponse> uploadFile(
    String fileName,
    _i6.ByteData fileData,
  ) =>
      caller.callServerEndpoint<_i5.UploadResponse>(
        'media',
        'uploadFile',
        {
          'fileName': fileName,
          'fileData': fileData,
        },
      );

  /// Delete a media file by ID
  _i2.Future<bool> deleteMedia(int fileId) => caller.callServerEndpoint<bool>(
        'media',
        'deleteMedia',
        {'fileId': fileId},
      );

  /// Get media file metadata by ID
  _i2.Future<_i7.MediaFile?> getMedia(int fileId) =>
      caller.callServerEndpoint<_i7.MediaFile?>(
        'media',
        'getMedia',
        {'fileId': fileId},
      );

  /// List all media files with pagination
  _i2.Future<List<_i7.MediaFile>> listMedia({
    required int limit,
    required int offset,
  }) =>
      caller.callServerEndpoint<List<_i7.MediaFile>>(
        'media',
        'listMedia',
        {
          'limit': limit,
          'offset': offset,
        },
      );
}

class Client extends _i1.ServerpodClientShared {
  Client(
    String host, {
    dynamic securityContext,
    _i1.AuthenticationKeyManager? authenticationKeyManager,
    Duration? streamingConnectionTimeout,
    Duration? connectionTimeout,
    Function(
      _i1.MethodCallContext,
      Object,
      StackTrace,
    )? onFailedCall,
    Function(_i1.MethodCallContext)? onSucceededCall,
    bool? disconnectStreamsOnLostInternetConnection,
  }) : super(
          host,
          _i8.Protocol(),
          securityContext: securityContext,
          authenticationKeyManager: authenticationKeyManager,
          streamingConnectionTimeout: streamingConnectionTimeout,
          connectionTimeout: connectionTimeout,
          onFailedCall: onFailedCall,
          onSucceededCall: onSucceededCall,
          disconnectStreamsOnLostInternetConnection:
              disconnectStreamsOnLostInternetConnection,
        ) {
    document = EndpointDocument(this);
    media = EndpointMedia(this);
  }

  late final EndpointDocument document;

  late final EndpointMedia media;

  @override
  Map<String, _i1.EndpointRef> get endpointRefLookup => {
        'document': document,
        'media': media,
      };

  @override
  Map<String, _i1.ModuleEndpointCaller> get moduleLookup => {};
}
