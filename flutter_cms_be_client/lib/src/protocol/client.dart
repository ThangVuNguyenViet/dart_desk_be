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
import 'package:flutter_cms_be_client/src/protocol/document_crdt_operation.dart'
    as _i3;
import 'package:flutter_cms_be_client/src/protocol/cms_document.dart' as _i4;
import 'package:flutter_cms_be_client/src/protocol/document_list.dart' as _i5;
import 'package:flutter_cms_be_client/src/protocol/document_version_list.dart'
    as _i6;
import 'package:flutter_cms_be_client/src/protocol/document_version.dart'
    as _i7;
import 'package:flutter_cms_be_client/src/protocol/document_version_status.dart'
    as _i8;
import 'package:flutter_cms_be_client/src/protocol/upload_response.dart' as _i9;
import 'dart:typed_data' as _i10;
import 'package:flutter_cms_be_client/src/protocol/media_file.dart' as _i11;
import 'package:serverpod_auth_client/serverpod_auth_client.dart' as _i12;
import 'protocol.dart' as _i13;

/// Endpoint for real-time document collaboration features
/// Provides operation polling, edit submission, and presence tracking
/// {@category Endpoint}
class EndpointDocumentCollaboration extends _i1.EndpointRef {
  EndpointDocumentCollaboration(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'documentCollaboration';

  /// Get CRDT operations since a specific HLC timestamp
  /// Used for polling updates from other users
  _i2.Future<List<_i3.DocumentCrdtOperation>> getOperationsSince(
    int documentId,
    String sinceHlc, {
    required int limit,
  }) =>
      caller.callServerEndpoint<List<_i3.DocumentCrdtOperation>>(
        'documentCollaboration',
        'getOperationsSince',
        {
          'documentId': documentId,
          'sinceHlc': sinceHlc,
          'limit': limit,
        },
      );

  /// Submit an edit (partial field updates) for collaborative editing
  _i2.Future<_i4.CmsDocument> submitEdit(
    int documentId,
    String sessionId,
    Map<String, dynamic> fieldUpdates,
  ) =>
      caller.callServerEndpoint<_i4.CmsDocument>(
        'documentCollaboration',
        'submitEdit',
        {
          'documentId': documentId,
          'sessionId': sessionId,
          'fieldUpdates': fieldUpdates,
        },
      );

  /// Get list of users currently editing this document
  /// Based on recent operation activity (last 5 minutes)
  _i2.Future<List<Map<String, dynamic>>> getActiveEditors(int documentId) =>
      caller.callServerEndpoint<List<Map<String, dynamic>>>(
        'documentCollaboration',
        'getActiveEditors',
        {'documentId': documentId},
      );

  /// Get the current HLC for a document
  /// Useful for clients to know where they are in the operation log
  _i2.Future<String?> getCurrentHlc(int documentId) =>
      caller.callServerEndpoint<String?>(
        'documentCollaboration',
        'getCurrentHlc',
        {'documentId': documentId},
      );

  /// Get operation count for a document
  /// Useful for monitoring and deciding when to compact
  _i2.Future<int> getOperationCount(int documentId) =>
      caller.callServerEndpoint<int>(
        'documentCollaboration',
        'getOperationCount',
        {'documentId': documentId},
      );

  /// Manually trigger operation compaction
  /// Creates a snapshot and cleans up old operations
  _i2.Future<void> compactOperations(int documentId) =>
      caller.callServerEndpoint<void>(
        'documentCollaboration',
        'compactOperations',
        {'documentId': documentId},
      );
}

/// Endpoint for managing CMS documents
/// All write operations require authentication
/// {@category Endpoint}
class EndpointDocument extends _i1.EndpointRef {
  EndpointDocument(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'document';

  /// Get all documents for a specific document type with pagination
  _i2.Future<_i5.DocumentList> getDocuments(
    String documentType, {
    String? search,
    required int limit,
    required int offset,
  }) =>
      caller.callServerEndpoint<_i5.DocumentList>(
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

  /// Get a document by slug
  _i2.Future<_i4.CmsDocument?> getDocumentBySlug(String slug) =>
      caller.callServerEndpoint<_i4.CmsDocument?>(
        'document',
        'getDocumentBySlug',
        {'slug': slug},
      );

  /// Get the default document for a document type
  _i2.Future<_i4.CmsDocument?> getDefaultDocument(String documentType) =>
      caller.callServerEndpoint<_i4.CmsDocument?>(
        'document',
        'getDefaultDocument',
        {'documentType': documentType},
      );

  /// Create a new document with an initial version
  /// This creates both the CmsDocument and its first DocumentVersion
  _i2.Future<_i4.CmsDocument> createDocument(
    String documentType,
    String title,
    Map<String, dynamic> data, {
    String? slug,
    required bool isDefault,
  }) =>
      caller.callServerEndpoint<_i4.CmsDocument>(
        'document',
        'createDocument',
        {
          'documentType': documentType,
          'title': title,
          'data': data,
          'slug': slug,
          'isDefault': isDefault,
        },
      );

  /// Update document data using CRDT operations (partial updates)
  /// Only changed fields need to be provided - they will be merged automatically
  _i2.Future<_i4.CmsDocument> updateDocumentData(
    int documentId,
    Map<String, dynamic> updates, {
    String? sessionId,
  }) =>
      caller.callServerEndpoint<_i4.CmsDocument>(
        'document',
        'updateDocumentData',
        {
          'documentId': documentId,
          'updates': updates,
          'sessionId': sessionId,
        },
      );

  /// Update document metadata (title, slug, isDefault)
  /// To update document data, use updateDocumentData instead
  _i2.Future<_i4.CmsDocument?> updateDocument(
    int documentId, {
    String? title,
    String? slug,
    bool? isDefault,
  }) =>
      caller.callServerEndpoint<_i4.CmsDocument?>(
        'document',
        'updateDocument',
        {
          'documentId': documentId,
          'title': title,
          'slug': slug,
          'isDefault': isDefault,
        },
      );

  /// Delete a document
  _i2.Future<bool> deleteDocument(int documentId) =>
      caller.callServerEndpoint<bool>(
        'document',
        'deleteDocument',
        {'documentId': documentId},
      );

  /// Get all document types (unique document type names)
  _i2.Future<List<String>> getDocumentTypes() =>
      caller.callServerEndpoint<List<String>>(
        'document',
        'getDocumentTypes',
        {},
      );

  /// Get all versions for a document with pagination
  _i2.Future<_i6.DocumentVersionList> getDocumentVersions(
    int documentId, {
    required int limit,
    required int offset,
  }) =>
      caller.callServerEndpoint<_i6.DocumentVersionList>(
        'document',
        'getDocumentVersions',
        {
          'documentId': documentId,
          'limit': limit,
          'offset': offset,
        },
      );

  /// Get a single version by ID
  _i2.Future<_i7.DocumentVersion?> getDocumentVersion(int versionId) =>
      caller.callServerEndpoint<_i7.DocumentVersion?>(
        'document',
        'getDocumentVersion',
        {'versionId': versionId},
      );

  /// Get the document data for a specific version
  /// Reconstructs the data from CRDT operations at the version's HLC snapshot
  _i2.Future<Map<String, dynamic>?> getDocumentVersionData(int versionId) =>
      caller.callServerEndpoint<Map<String, dynamic>?>(
        'document',
        'getDocumentVersionData',
        {'versionId': versionId},
      );

  /// Create a new version for a document
  /// Captures the current CRDT state as a version snapshot
  _i2.Future<_i7.DocumentVersion> createDocumentVersion(
    int documentId, {
    required _i8.DocumentVersionStatus status,
    String? changeLog,
  }) =>
      caller.callServerEndpoint<_i7.DocumentVersion>(
        'document',
        'createDocumentVersion',
        {
          'documentId': documentId,
          'status': status,
          'changeLog': changeLog,
        },
      );

  /// Publish a version (set status to 'published' and set publishedAt timestamp)
  _i2.Future<_i7.DocumentVersion?> publishDocumentVersion(int versionId) =>
      caller.callServerEndpoint<_i7.DocumentVersion?>(
        'document',
        'publishDocumentVersion',
        {'versionId': versionId},
      );

  /// Archive a version (set status to 'archived' and set archivedAt timestamp)
  _i2.Future<_i7.DocumentVersion?> archiveDocumentVersion(int versionId) =>
      caller.callServerEndpoint<_i7.DocumentVersion?>(
        'document',
        'archiveDocumentVersion',
        {'versionId': versionId},
      );

  /// Delete a version
  _i2.Future<bool> deleteDocumentVersion(int versionId) =>
      caller.callServerEndpoint<bool>(
        'document',
        'deleteDocumentVersion',
        {'versionId': versionId},
      );
}

/// Endpoint for managing media files and uploads
/// All operations require authentication
/// {@category Endpoint}
class EndpointMedia extends _i1.EndpointRef {
  EndpointMedia(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'media';

  /// Upload an image file
  /// Returns the public URL and file ID
  _i2.Future<_i9.UploadResponse> uploadImage(
    String fileName,
    _i10.ByteData fileData,
  ) =>
      caller.callServerEndpoint<_i9.UploadResponse>(
        'media',
        'uploadImage',
        {
          'fileName': fileName,
          'fileData': fileData,
        },
      );

  /// Upload a general file (PDF, documents, etc.)
  /// Returns the public URL, file ID, and filename
  _i2.Future<_i9.UploadResponse> uploadFile(
    String fileName,
    _i10.ByteData fileData,
  ) =>
      caller.callServerEndpoint<_i9.UploadResponse>(
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
  _i2.Future<_i11.MediaFile?> getMedia(int fileId) =>
      caller.callServerEndpoint<_i11.MediaFile?>(
        'media',
        'getMedia',
        {'fileId': fileId},
      );

  /// List all media files with pagination
  _i2.Future<List<_i11.MediaFile>> listMedia({
    required int limit,
    required int offset,
  }) =>
      caller.callServerEndpoint<List<_i11.MediaFile>>(
        'media',
        'listMedia',
        {
          'limit': limit,
          'offset': offset,
        },
      );
}

class Modules {
  Modules(Client client) {
    auth = _i12.Caller(client);
  }

  late final _i12.Caller auth;
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
          _i13.Protocol(),
          securityContext: securityContext,
          authenticationKeyManager: authenticationKeyManager,
          streamingConnectionTimeout: streamingConnectionTimeout,
          connectionTimeout: connectionTimeout,
          onFailedCall: onFailedCall,
          onSucceededCall: onSucceededCall,
          disconnectStreamsOnLostInternetConnection:
              disconnectStreamsOnLostInternetConnection,
        ) {
    documentCollaboration = EndpointDocumentCollaboration(this);
    document = EndpointDocument(this);
    media = EndpointMedia(this);
    modules = Modules(this);
  }

  late final EndpointDocumentCollaboration documentCollaboration;

  late final EndpointDocument document;

  late final EndpointMedia media;

  late final Modules modules;

  @override
  Map<String, _i1.EndpointRef> get endpointRefLookup => {
        'documentCollaboration': documentCollaboration,
        'document': document,
        'media': media,
      };

  @override
  Map<String, _i1.ModuleEndpointCaller> get moduleLookup =>
      {'auth': modules.auth};
}
