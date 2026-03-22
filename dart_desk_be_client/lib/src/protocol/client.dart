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
import 'dart:async' as _i2;
import 'package:dart_desk_be_client/src/protocol/api_token.dart' as _i3;
import 'package:dart_desk_be_client/src/protocol/api_token_with_value.dart'
    as _i4;
import 'package:dart_desk_be_client/src/protocol/deployment.dart' as _i5;
import 'package:dart_desk_be_client/src/protocol/document_crdt_operation.dart'
    as _i6;
import 'package:dart_desk_be_client/src/protocol/document.dart' as _i7;
import 'package:dart_desk_be_client/src/protocol/document_list.dart' as _i8;
import 'package:dart_desk_be_client/src/protocol/document_version_list_with_operations.dart'
    as _i9;
import 'package:dart_desk_be_client/src/protocol/document_version.dart' as _i10;
import 'package:dart_desk_be_client/src/protocol/document_version_status.dart'
    as _i11;
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    as _i12;
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _i13;
import 'package:dart_desk_be_client/src/protocol/media_asset.dart' as _i14;
import 'dart:typed_data' as _i15;
import 'package:dart_desk_be_client/src/protocol/project_list.dart' as _i16;
import 'package:dart_desk_be_client/src/protocol/project.dart' as _i17;
import 'package:dart_desk_be_client/src/protocol/user.dart' as _i18;
import 'protocol.dart' as _i19;

/// Endpoint for managing CMS API tokens.
/// All methods require Serverpod auth (session.authenticated).
/// Authorization: caller must be a User belonging to the resolved tenant.
/// {@category Endpoint}
class EndpointApiToken extends _i1.EndpointRef {
  EndpointApiToken(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'apiToken';

  /// List all tokens for the current tenant (metadata only, never the hash).
  _i2.Future<List<_i3.ApiToken>> getTokens() =>
      caller.callServerEndpoint<List<_i3.ApiToken>>(
        'apiToken',
        'getTokens',
        {},
      );

  /// Create a new named token. Returns plaintext token (shown once).
  _i2.Future<_i4.ApiTokenWithValue> createToken(
    String name,
    String role,
    DateTime? expiresAt,
  ) => caller.callServerEndpoint<_i4.ApiTokenWithValue>(
    'apiToken',
    'createToken',
    {
      'name': name,
      'role': role,
      'expiresAt': expiresAt,
    },
  );

  /// Update token metadata (name, isActive, expiresAt).
  _i2.Future<_i3.ApiToken> updateToken(
    int tokenId,
    String? name,
    bool? isActive,
    DateTime? expiresAt,
  ) => caller.callServerEndpoint<_i3.ApiToken>(
    'apiToken',
    'updateToken',
    {
      'tokenId': tokenId,
      'name': name,
      'isActive': isActive,
      'expiresAt': expiresAt,
    },
  );

  /// Regenerate token value. Returns new plaintext token (shown once).
  _i2.Future<_i4.ApiTokenWithValue> regenerateToken(int tokenId) =>
      caller.callServerEndpoint<_i4.ApiTokenWithValue>(
        'apiToken',
        'regenerateToken',
        {'tokenId': tokenId},
      );

  /// Delete a token permanently.
  _i2.Future<bool> deleteToken(int tokenId) => caller.callServerEndpoint<bool>(
    'apiToken',
    'deleteToken',
    {'tokenId': tokenId},
  );
}

/// Endpoint for managing deployments.
/// All methods require authenticated admin user.
/// {@category Endpoint}
class EndpointDeployment extends _i1.EndpointRef {
  EndpointDeployment(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'deployment';

  /// List all deployments for a project by slug.
  _i2.Future<List<_i5.Deployment>> list(String projectSlug) =>
      caller.callServerEndpoint<List<_i5.Deployment>>(
        'deployment',
        'list',
        {'projectSlug': projectSlug},
      );

  /// Get the currently active deployment for a project.
  _i2.Future<_i5.Deployment?> getActive(String projectSlug) =>
      caller.callServerEndpoint<_i5.Deployment?>(
        'deployment',
        'getActive',
        {'projectSlug': projectSlug},
      );

  /// Activate (rollback to) a specific version.
  _i2.Future<_i5.Deployment> activate(
    String projectSlug,
    int version,
  ) => caller.callServerEndpoint<_i5.Deployment>(
    'deployment',
    'activate',
    {
      'projectSlug': projectSlug,
      'version': version,
    },
  );

  /// Delete a deployment version.
  _i2.Future<bool> delete(
    String projectSlug,
    int version,
  ) => caller.callServerEndpoint<bool>(
    'deployment',
    'delete',
    {
      'projectSlug': projectSlug,
      'version': version,
    },
  );
}

/// Endpoint for real-time document collaboration features
/// Provides operation polling, edit submission, and presence tracking
/// {@category Endpoint}
class EndpointDocumentCollaboration extends _i1.EndpointRef {
  EndpointDocumentCollaboration(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'documentCollaboration';

  /// Get CRDT operations since a specific HLC timestamp
  /// Used for polling updates from other users
  _i2.Future<List<_i6.DocumentCrdtOperation>> getOperationsSince(
    int documentId,
    String sinceHlc, {
    required int limit,
  }) => caller.callServerEndpoint<List<_i6.DocumentCrdtOperation>>(
    'documentCollaboration',
    'getOperationsSince',
    {
      'documentId': documentId,
      'sinceHlc': sinceHlc,
      'limit': limit,
    },
  );

  /// Submit an edit (partial field updates) for collaborative editing
  _i2.Future<_i7.Document> submitEdit(
    int documentId,
    String sessionId,
    Map<String, dynamic> fieldUpdates,
  ) => caller.callServerEndpoint<_i7.Document>(
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
  _i2.Future<_i8.DocumentList> getDocuments(
    String documentType, {
    String? search,
    required int limit,
    required int offset,
  }) => caller.callServerEndpoint<_i8.DocumentList>(
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
  _i2.Future<_i7.Document?> getDocument(int documentId) =>
      caller.callServerEndpoint<_i7.Document?>(
        'document',
        'getDocument',
        {'documentId': documentId},
      );

  /// Get a document by slug
  _i2.Future<_i7.Document?> getDocumentBySlug(String slug) =>
      caller.callServerEndpoint<_i7.Document?>(
        'document',
        'getDocumentBySlug',
        {'slug': slug},
      );

  /// Get the default document for a document type
  _i2.Future<_i7.Document?> getDefaultDocument(String documentType) =>
      caller.callServerEndpoint<_i7.Document?>(
        'document',
        'getDefaultDocument',
        {'documentType': documentType},
      );

  /// Create a new document with an initial version
  /// This creates both the Document and its first DocumentVersion
  _i2.Future<_i7.Document> createDocument(
    String documentType,
    String title,
    Map<String, dynamic> data, {
    String? slug,
    required bool isDefault,
  }) => caller.callServerEndpoint<_i7.Document>(
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
  _i2.Future<_i7.Document> updateDocumentData(
    int documentId,
    Map<String, dynamic> updates, {
    String? sessionId,
  }) => caller.callServerEndpoint<_i7.Document>(
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
  _i2.Future<_i7.Document?> updateDocument(
    int documentId, {
    String? title,
    String? slug,
    bool? isDefault,
  }) => caller.callServerEndpoint<_i7.Document?>(
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

  /// Suggest a unique slug for a document based on its title.
  ///
  /// Generates a URL-friendly slug from the title and checks the database
  /// for duplicates. If a duplicate exists, appends a numeric suffix (e.g. -2, -3).
  _i2.Future<String> suggestSlug(
    String title,
    String documentType,
  ) => caller.callServerEndpoint<String>(
    'document',
    'suggestSlug',
    {
      'title': title,
      'documentType': documentType,
    },
  );

  /// Get all document types (unique document type names)
  _i2.Future<List<String>> getDocumentTypes() =>
      caller.callServerEndpoint<List<String>>(
        'document',
        'getDocumentTypes',
        {},
      );

  /// Get all versions for a document with pagination
  /// Optionally includes CRDT operations between adjacent versions
  _i2.Future<_i9.DocumentVersionListWithOperations> getDocumentVersions(
    int documentId, {
    required int limit,
    required int offset,
    required bool includeOperations,
  }) => caller.callServerEndpoint<_i9.DocumentVersionListWithOperations>(
    'document',
    'getDocumentVersions',
    {
      'documentId': documentId,
      'limit': limit,
      'offset': offset,
      'includeOperations': includeOperations,
    },
  );

  /// Get a single version by ID
  _i2.Future<_i10.DocumentVersion?> getDocumentVersion(int versionId) =>
      caller.callServerEndpoint<_i10.DocumentVersion?>(
        'document',
        'getDocumentVersion',
        {'versionId': versionId},
      );

  /// Get the document data for a specific version.
  /// Reconstructs the data from CRDT operations at the version's HLC snapshot.
  _i2.Future<Map<String, dynamic>?> getDocumentVersionData(int versionId) =>
      caller.callServerEndpoint<Map<String, dynamic>?>(
        'document',
        'getDocumentVersionData',
        {'versionId': versionId},
      );

  /// Create a new version for a document
  /// Captures the current CRDT state as a version snapshot
  _i2.Future<_i10.DocumentVersion> createDocumentVersion(
    int documentId, {
    required _i11.DocumentVersionStatus status,
    String? changeLog,
  }) => caller.callServerEndpoint<_i10.DocumentVersion>(
    'document',
    'createDocumentVersion',
    {
      'documentId': documentId,
      'status': status,
      'changeLog': changeLog,
    },
  );

  /// Publish a version (set status to 'published' and set publishedAt timestamp)
  _i2.Future<_i10.DocumentVersion?> publishDocumentVersion(int versionId) =>
      caller.callServerEndpoint<_i10.DocumentVersion?>(
        'document',
        'publishDocumentVersion',
        {'versionId': versionId},
      );

  /// Archive a version (set status to 'archived' and set archivedAt timestamp)
  _i2.Future<_i10.DocumentVersion?> archiveDocumentVersion(int versionId) =>
      caller.callServerEndpoint<_i10.DocumentVersion?>(
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

  /// Get total document count for the authenticated user's client.
  _i2.Future<int> getDocumentCount() => caller.callServerEndpoint<int>(
    'document',
    'getDocumentCount',
    {},
  );
}

/// {@category Endpoint}
class EndpointEmailIdp extends _i12.EndpointEmailIdpBase {
  EndpointEmailIdp(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'emailIdp';

  /// Logs in the user and returns a new session.
  ///
  /// Throws an [EmailAccountLoginException] in case of errors, with reason:
  /// - [EmailAccountLoginExceptionReason.invalidCredentials] if the email or
  ///   password is incorrect.
  /// - [EmailAccountLoginExceptionReason.tooManyAttempts] if there have been
  ///   too many failed login attempts.
  ///
  /// Throws an [AuthUserBlockedException] if the auth user is blocked.
  @override
  _i2.Future<_i13.AuthSuccess> login({
    required String email,
    required String password,
  }) => caller.callServerEndpoint<_i13.AuthSuccess>(
    'emailIdp',
    'login',
    {
      'email': email,
      'password': password,
    },
  );

  /// Starts the registration for a new user account with an email-based login
  /// associated to it.
  ///
  /// Upon successful completion of this method, an email will have been
  /// sent to [email] with a verification link, which the user must open to
  /// complete the registration.
  ///
  /// Always returns a account request ID, which can be used to complete the
  /// registration. If the email is already registered, the returned ID will not
  /// be valid.
  @override
  _i2.Future<_i1.UuidValue> startRegistration({required String email}) =>
      caller.callServerEndpoint<_i1.UuidValue>(
        'emailIdp',
        'startRegistration',
        {'email': email},
      );

  /// Verifies an account request code and returns a token
  /// that can be used to complete the account creation.
  ///
  /// Throws an [EmailAccountRequestException] in case of errors, with reason:
  /// - [EmailAccountRequestExceptionReason.expired] if the account request has
  ///   already expired.
  /// - [EmailAccountRequestExceptionReason.policyViolation] if the password
  ///   does not comply with the password policy.
  /// - [EmailAccountRequestExceptionReason.invalid] if no request exists
  ///   for the given [accountRequestId] or [verificationCode] is invalid.
  @override
  _i2.Future<String> verifyRegistrationCode({
    required _i1.UuidValue accountRequestId,
    required String verificationCode,
  }) => caller.callServerEndpoint<String>(
    'emailIdp',
    'verifyRegistrationCode',
    {
      'accountRequestId': accountRequestId,
      'verificationCode': verificationCode,
    },
  );

  /// Completes a new account registration, creating a new auth user with a
  /// profile and attaching the given email account to it.
  ///
  /// Throws an [EmailAccountRequestException] in case of errors, with reason:
  /// - [EmailAccountRequestExceptionReason.expired] if the account request has
  ///   already expired.
  /// - [EmailAccountRequestExceptionReason.policyViolation] if the password
  ///   does not comply with the password policy.
  /// - [EmailAccountRequestExceptionReason.invalid] if the [registrationToken]
  ///   is invalid.
  ///
  /// Throws an [AuthUserBlockedException] if the auth user is blocked.
  ///
  /// Returns a session for the newly created user.
  @override
  _i2.Future<_i13.AuthSuccess> finishRegistration({
    required String registrationToken,
    required String password,
  }) => caller.callServerEndpoint<_i13.AuthSuccess>(
    'emailIdp',
    'finishRegistration',
    {
      'registrationToken': registrationToken,
      'password': password,
    },
  );

  /// Requests a password reset for [email].
  ///
  /// If the email address is registered, an email with reset instructions will
  /// be send out. If the email is unknown, this method will have no effect.
  ///
  /// Always returns a password reset request ID, which can be used to complete
  /// the reset. If the email is not registered, the returned ID will not be
  /// valid.
  ///
  /// Throws an [EmailAccountPasswordResetException] in case of errors, with reason:
  /// - [EmailAccountPasswordResetExceptionReason.tooManyAttempts] if the user has
  ///   made too many attempts trying to request a password reset.
  ///
  @override
  _i2.Future<_i1.UuidValue> startPasswordReset({required String email}) =>
      caller.callServerEndpoint<_i1.UuidValue>(
        'emailIdp',
        'startPasswordReset',
        {'email': email},
      );

  /// Verifies a password reset code and returns a finishPasswordResetToken
  /// that can be used to finish the password reset.
  ///
  /// Throws an [EmailAccountPasswordResetException] in case of errors, with reason:
  /// - [EmailAccountPasswordResetExceptionReason.expired] if the password reset
  ///   request has already expired.
  /// - [EmailAccountPasswordResetExceptionReason.tooManyAttempts] if the user has
  ///   made too many attempts trying to verify the password reset.
  /// - [EmailAccountPasswordResetExceptionReason.invalid] if no request exists
  ///   for the given [passwordResetRequestId] or [verificationCode] is invalid.
  ///
  /// If multiple steps are required to complete the password reset, this endpoint
  /// should be overridden to return credentials for the next step instead
  /// of the credentials for setting the password.
  @override
  _i2.Future<String> verifyPasswordResetCode({
    required _i1.UuidValue passwordResetRequestId,
    required String verificationCode,
  }) => caller.callServerEndpoint<String>(
    'emailIdp',
    'verifyPasswordResetCode',
    {
      'passwordResetRequestId': passwordResetRequestId,
      'verificationCode': verificationCode,
    },
  );

  /// Completes a password reset request by setting a new password.
  ///
  /// The [verificationCode] returned from [verifyPasswordResetCode] is used to
  /// validate the password reset request.
  ///
  /// Throws an [EmailAccountPasswordResetException] in case of errors, with reason:
  /// - [EmailAccountPasswordResetExceptionReason.expired] if the password reset
  ///   request has already expired.
  /// - [EmailAccountPasswordResetExceptionReason.policyViolation] if the new
  ///   password does not comply with the password policy.
  /// - [EmailAccountPasswordResetExceptionReason.invalid] if no request exists
  ///   for the given [passwordResetRequestId] or [verificationCode] is invalid.
  ///
  /// Throws an [AuthUserBlockedException] if the auth user is blocked.
  @override
  _i2.Future<void> finishPasswordReset({
    required String finishPasswordResetToken,
    required String newPassword,
  }) => caller.callServerEndpoint<void>(
    'emailIdp',
    'finishPasswordReset',
    {
      'finishPasswordResetToken': finishPasswordResetToken,
      'newPassword': newPassword,
    },
  );

  @override
  _i2.Future<bool> hasAccount() => caller.callServerEndpoint<bool>(
    'emailIdp',
    'hasAccount',
    {},
  );
}

/// {@category Endpoint}
class EndpointGoogleIdp extends _i12.EndpointGoogleIdpBase {
  EndpointGoogleIdp(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'googleIdp';

  /// Validates a Google ID token and either logs in the associated user or
  /// creates a new user account if the Google account ID is not yet known.
  ///
  /// If a new user is created an associated [UserProfile] is also created.
  @override
  _i2.Future<_i13.AuthSuccess> login({
    required String idToken,
    required String? accessToken,
  }) => caller.callServerEndpoint<_i13.AuthSuccess>(
    'googleIdp',
    'login',
    {
      'idToken': idToken,
      'accessToken': accessToken,
    },
  );

  @override
  _i2.Future<bool> hasAccount() => caller.callServerEndpoint<bool>(
    'googleIdp',
    'hasAccount',
    {},
  );
}

/// Endpoint for managing media assets (images and files).
/// All operations require authentication.
/// {@category Endpoint}
class EndpointMedia extends _i1.EndpointRef {
  EndpointMedia(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'media';

  /// Upload an image file with client-provided quick metadata.
  ///
  /// Performs deduplication based on content hash + dimensions + extension.
  /// If an identical asset already exists, returns the existing record.
  _i2.Future<_i14.MediaAsset> uploadImage(
    String fileName,
    _i15.ByteData fileData,
    int width,
    int height,
    bool hasAlpha,
    String blurHash,
    String contentHash,
  ) => caller.callServerEndpoint<_i14.MediaAsset>(
    'media',
    'uploadImage',
    {
      'fileName': fileName,
      'fileData': fileData,
      'width': width,
      'height': height,
      'hasAlpha': hasAlpha,
      'blurHash': blurHash,
      'contentHash': contentHash,
    },
  );

  /// Upload a non-image file.
  ///
  /// Content hash is computed server-side via SHA-256.
  _i2.Future<_i14.MediaAsset> uploadFile(
    String fileName,
    _i15.ByteData fileData,
  ) => caller.callServerEndpoint<_i14.MediaAsset>(
    'media',
    'uploadFile',
    {
      'fileName': fileName,
      'fileData': fileData,
    },
  );

  /// Delete a media asset by assetId.
  ///
  /// Refuses to delete if the asset is still referenced in any document.
  _i2.Future<bool> deleteMedia(String assetId) =>
      caller.callServerEndpoint<bool>(
        'media',
        'deleteMedia',
        {'assetId': assetId},
      );

  /// Get a single media asset by assetId.
  _i2.Future<_i14.MediaAsset?> getMedia(String assetId) =>
      caller.callServerEndpoint<_i14.MediaAsset?>(
        'media',
        'getMedia',
        {'assetId': assetId},
      );

  /// List media assets with search, filter, sort, and pagination.
  _i2.Future<List<_i14.MediaAsset>> listMedia({
    String? search,
    String? mimeTypePrefix,
    required String sortBy,
    required int limit,
    required int offset,
  }) => caller.callServerEndpoint<List<_i14.MediaAsset>>(
    'media',
    'listMedia',
    {
      'search': search,
      'mimeTypePrefix': mimeTypePrefix,
      'sortBy': sortBy,
      'limit': limit,
      'offset': offset,
    },
  );

  /// Count total media assets matching the given filters.
  _i2.Future<int> listMediaCount({
    String? search,
    String? mimeTypePrefix,
  }) => caller.callServerEndpoint<int>(
    'media',
    'listMediaCount',
    {
      'search': search,
      'mimeTypePrefix': mimeTypePrefix,
    },
  );

  /// Count how many distinct documents reference the given assetId.
  _i2.Future<int> getMediaUsageCount(String assetId) =>
      caller.callServerEndpoint<int>(
        'media',
        'getMediaUsageCount',
        {'assetId': assetId},
      );

  /// Update a media asset's metadata (currently supports renaming).
  _i2.Future<_i14.MediaAsset> updateMediaAsset(
    String assetId, {
    String? fileName,
  }) => caller.callServerEndpoint<_i14.MediaAsset>(
    'media',
    'updateMediaAsset',
    {
      'assetId': assetId,
      'fileName': fileName,
    },
  );
}

/// Endpoint for managing projects.
/// {@category Endpoint}
class EndpointProject extends _i1.EndpointRef {
  EndpointProject(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'project';

  /// Get all projects with pagination and optional search.
  _i2.Future<_i16.ProjectList> getProjects({
    String? search,
    required int limit,
    required int offset,
  }) => caller.callServerEndpoint<_i16.ProjectList>(
    'project',
    'getProjects',
    {
      'search': search,
      'limit': limit,
      'offset': offset,
    },
  );

  /// Get a project by slug.
  _i2.Future<_i17.Project?> getProjectBySlug(String slug) =>
      caller.callServerEndpoint<_i17.Project?>(
        'project',
        'getProjectBySlug',
        {'slug': slug},
      );

  /// Get a project by ID.
  _i2.Future<_i17.Project?> getProject(int projectId) =>
      caller.callServerEndpoint<_i17.Project?>(
        'project',
        'getProject',
        {'projectId': projectId},
      );

  /// Create a new project (requires authentication).
  _i2.Future<_i17.Project> createProject(
    String name,
    String slug, {
    String? description,
    String? settings,
  }) => caller.callServerEndpoint<_i17.Project>(
    'project',
    'createProject',
    {
      'name': name,
      'slug': slug,
      'description': description,
      'settings': settings,
    },
  );

  /// Update an existing project (requires authentication).
  _i2.Future<_i17.Project?> updateProject(
    int projectId, {
    String? name,
    String? description,
    bool? isActive,
    String? settings,
  }) => caller.callServerEndpoint<_i17.Project?>(
    'project',
    'updateProject',
    {
      'projectId': projectId,
      'name': name,
      'description': description,
      'isActive': isActive,
      'settings': settings,
    },
  );

  /// Delete a project (requires authentication).
  _i2.Future<bool> deleteProject(int projectId) =>
      caller.callServerEndpoint<bool>(
        'project',
        'deleteProject',
        {'projectId': projectId},
      );

  /// Create a new project and an admin User for the caller in one transaction.
  /// Used by the manage app's setup wizard for first-time users.
  _i2.Future<_i17.Project> createProjectWithOwner({
    required String name,
    required String slug,
  }) => caller.callServerEndpoint<_i17.Project>(
    'project',
    'createProjectWithOwner',
    {
      'name': name,
      'slug': slug,
    },
  );
}

/// {@category Endpoint}
class EndpointRefreshJwtTokens extends _i13.EndpointRefreshJwtTokens {
  EndpointRefreshJwtTokens(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'refreshJwtTokens';

  /// Creates a new token pair for the given [refreshToken].
  ///
  /// Can throw the following exceptions:
  /// -[RefreshTokenMalformedException]: refresh token is malformed and could
  ///   not be parsed. Not expected to happen for tokens issued by the server.
  /// -[RefreshTokenNotFoundException]: refresh token is unknown to the server.
  ///   Either the token was deleted or generated by a different server.
  /// -[RefreshTokenExpiredException]: refresh token has expired. Will happen
  ///   only if it has not been used within configured `refreshTokenLifetime`.
  /// -[RefreshTokenInvalidSecretException]: refresh token is incorrect, meaning
  ///   it does not refer to the current secret refresh token. This indicates
  ///   either a malfunctioning client or a malicious attempt by someone who has
  ///   obtained the refresh token. In this case the underlying refresh token
  ///   will be deleted, and access to it will expire fully when the last access
  ///   token is elapsed.
  ///
  /// This endpoint is unauthenticated, meaning the client won't include any
  /// authentication information with the call.
  @override
  _i2.Future<_i13.AuthSuccess> refreshAccessToken({
    required String refreshToken,
  }) => caller.callServerEndpoint<_i13.AuthSuccess>(
    'refreshJwtTokens',
    'refreshAccessToken',
    {'refreshToken': refreshToken},
    authenticated: false,
  );
}

/// {@category Endpoint}
class EndpointStudioConfig extends _i1.EndpointRef {
  EndpointStudioConfig(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'studioConfig';

  /// Returns the studio URL template.
  /// Contains `{slug}` placeholder for the client to substitute.
  /// Dev: http://localhost:8082/preview/{slug}/
  /// Prod: https://{slug}.app.dartdesk.dev
  _i2.Future<String> getStudioUrlTemplate() =>
      caller.callServerEndpoint<String>(
        'studioConfig',
        'getStudioUrlTemplate',
        {},
      );
}

/// Endpoint for managing users.
/// {@category Endpoint}
class EndpointUser extends _i1.EndpointRef {
  EndpointUser(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'user';

  /// Get the current authenticated user.
  /// For Serverpod IDP: returns existing User (must exist via seed or prior creation).
  /// For external auth: auto-creates User on first call.
  _i2.Future<_i18.User?> getCurrentUser() =>
      caller.callServerEndpoint<_i18.User?>(
        'user',
        'getCurrentUser',
        {},
      );

  /// Get count of active users in the current tenant.
  _i2.Future<int> getUserCount() => caller.callServerEndpoint<int>(
    'user',
    'getUserCount',
    {},
  );
}

class Modules {
  Modules(Client client) {
    serverpod_auth_core = _i13.Caller(client);
    serverpod_auth_idp = _i12.Caller(client);
  }

  late final _i13.Caller serverpod_auth_core;

  late final _i12.Caller serverpod_auth_idp;
}

class Client extends _i1.ServerpodClientShared {
  Client(
    String host, {
    dynamic securityContext,
    @Deprecated(
      'Use authKeyProvider instead. This will be removed in future releases.',
    )
    super.authenticationKeyManager,
    Duration? streamingConnectionTimeout,
    Duration? connectionTimeout,
    Function(
      _i1.MethodCallContext,
      Object,
      StackTrace,
    )?
    onFailedCall,
    Function(_i1.MethodCallContext)? onSucceededCall,
    bool? disconnectStreamsOnLostInternetConnection,
  }) : super(
         host,
         _i19.Protocol(),
         securityContext: securityContext,
         streamingConnectionTimeout: streamingConnectionTimeout,
         connectionTimeout: connectionTimeout,
         onFailedCall: onFailedCall,
         onSucceededCall: onSucceededCall,
         disconnectStreamsOnLostInternetConnection:
             disconnectStreamsOnLostInternetConnection,
       ) {
    apiToken = EndpointApiToken(this);
    deployment = EndpointDeployment(this);
    documentCollaboration = EndpointDocumentCollaboration(this);
    document = EndpointDocument(this);
    emailIdp = EndpointEmailIdp(this);
    googleIdp = EndpointGoogleIdp(this);
    media = EndpointMedia(this);
    project = EndpointProject(this);
    refreshJwtTokens = EndpointRefreshJwtTokens(this);
    studioConfig = EndpointStudioConfig(this);
    user = EndpointUser(this);
    modules = Modules(this);
  }

  late final EndpointApiToken apiToken;

  late final EndpointDeployment deployment;

  late final EndpointDocumentCollaboration documentCollaboration;

  late final EndpointDocument document;

  late final EndpointEmailIdp emailIdp;

  late final EndpointGoogleIdp googleIdp;

  late final EndpointMedia media;

  late final EndpointProject project;

  late final EndpointRefreshJwtTokens refreshJwtTokens;

  late final EndpointStudioConfig studioConfig;

  late final EndpointUser user;

  late final Modules modules;

  @override
  Map<String, _i1.EndpointRef> get endpointRefLookup => {
    'apiToken': apiToken,
    'deployment': deployment,
    'documentCollaboration': documentCollaboration,
    'document': document,
    'emailIdp': emailIdp,
    'googleIdp': googleIdp,
    'media': media,
    'project': project,
    'refreshJwtTokens': refreshJwtTokens,
    'studioConfig': studioConfig,
    'user': user,
  };

  @override
  Map<String, _i1.ModuleEndpointCaller> get moduleLookup => {
    'serverpod_auth_core': modules.serverpod_auth_core,
    'serverpod_auth_idp': modules.serverpod_auth_idp,
  };
}
