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
import 'package:flutter_cms_be_client/src/protocol/cms_api_token.dart' as _i3;
import 'package:flutter_cms_be_client/src/protocol/cms_api_token_with_value.dart'
    as _i4;
import 'package:flutter_cms_be_client/src/protocol/cms_client_list.dart' as _i5;
import 'package:flutter_cms_be_client/src/protocol/cms_client.dart' as _i6;
import 'package:flutter_cms_be_client/src/protocol/client_with_token.dart'
    as _i7;
import 'package:flutter_cms_be_client/src/protocol/document_crdt_operation.dart'
    as _i8;
import 'package:flutter_cms_be_client/src/protocol/cms_document.dart' as _i9;
import 'package:flutter_cms_be_client/src/protocol/document_list.dart' as _i10;
import 'package:flutter_cms_be_client/src/protocol/document_version_list_with_operations.dart'
    as _i11;
import 'package:flutter_cms_be_client/src/protocol/document_version.dart'
    as _i12;
import 'package:flutter_cms_be_client/src/protocol/document_version_status.dart'
    as _i13;
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    as _i14;
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _i15;
import 'package:flutter_cms_be_client/src/protocol/upload_response.dart'
    as _i16;
import 'dart:typed_data' as _i17;
import 'package:flutter_cms_be_client/src/protocol/media_file.dart' as _i18;
import 'package:flutter_cms_be_client/src/protocol/cms_user.dart' as _i19;
import 'package:serverpod_admin_client/serverpod_admin_client.dart' as _i20;
import 'protocol.dart' as _i21;

/// Endpoint for managing CMS API tokens.
/// All methods require Serverpod auth (session.authenticated).
/// Authorization: caller must be a CmsUser belonging to the target client.
/// {@category Endpoint}
class EndpointCmsApiToken extends _i1.EndpointRef {
  EndpointCmsApiToken(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'cmsApiToken';

  /// List all tokens for a client (metadata only, never the hash).
  _i2.Future<List<_i3.CmsApiToken>> getTokens(int clientId) =>
      caller.callServerEndpoint<List<_i3.CmsApiToken>>(
        'cmsApiToken',
        'getTokens',
        {'clientId': clientId},
      );

  /// Create a new named token. Returns plaintext token (shown once).
  _i2.Future<_i4.CmsApiTokenWithValue> createToken(
    int clientId,
    String name,
    String role,
    DateTime? expiresAt,
  ) => caller.callServerEndpoint<_i4.CmsApiTokenWithValue>(
    'cmsApiToken',
    'createToken',
    {
      'clientId': clientId,
      'name': name,
      'role': role,
      'expiresAt': expiresAt,
    },
  );

  /// Update token metadata (name, isActive, expiresAt).
  _i2.Future<_i3.CmsApiToken> updateToken(
    int tokenId,
    String? name,
    bool? isActive,
    DateTime? expiresAt,
  ) => caller.callServerEndpoint<_i3.CmsApiToken>(
    'cmsApiToken',
    'updateToken',
    {
      'tokenId': tokenId,
      'name': name,
      'isActive': isActive,
      'expiresAt': expiresAt,
    },
  );

  /// Regenerate token value. Returns new plaintext token (shown once).
  _i2.Future<_i4.CmsApiTokenWithValue> regenerateToken(int tokenId) =>
      caller.callServerEndpoint<_i4.CmsApiTokenWithValue>(
        'cmsApiToken',
        'regenerateToken',
        {'tokenId': tokenId},
      );

  /// Delete a token permanently.
  _i2.Future<bool> deleteToken(int tokenId) => caller.callServerEndpoint<bool>(
    'cmsApiToken',
    'deleteToken',
    {'tokenId': tokenId},
  );
}

/// Endpoint for managing CMS clients
/// {@category Endpoint}
class EndpointCmsClient extends _i1.EndpointRef {
  EndpointCmsClient(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'cmsClient';

  /// Get all clients with pagination and optional search
  _i2.Future<_i5.CmsClientList> getClients({
    String? search,
    required int limit,
    required int offset,
  }) => caller.callServerEndpoint<_i5.CmsClientList>(
    'cmsClient',
    'getClients',
    {
      'search': search,
      'limit': limit,
      'offset': offset,
    },
  );

  /// Get a client by slug
  _i2.Future<_i6.CmsClient?> getClientBySlug(String slug) =>
      caller.callServerEndpoint<_i6.CmsClient?>(
        'cmsClient',
        'getClientBySlug',
        {'slug': slug},
      );

  /// Get a client by ID
  _i2.Future<_i6.CmsClient?> getClient(int clientId) =>
      caller.callServerEndpoint<_i6.CmsClient?>(
        'cmsClient',
        'getClient',
        {'clientId': clientId},
      );

  /// Create a new client (requires authentication).
  /// Generates a prefixed API token, stores its bcrypt hash.
  /// Returns the client and the raw token (shown once only).
  _i2.Future<_i7.ClientWithToken> createClient(
    String name,
    String slug, {
    String? description,
    String? settings,
  }) => caller.callServerEndpoint<_i7.ClientWithToken>(
    'cmsClient',
    'createClient',
    {
      'name': name,
      'slug': slug,
      'description': description,
      'settings': settings,
    },
  );

  /// Update an existing client (requires authentication).
  /// Note: apiTokenHash cannot be updated through this method — use regenerateApiToken.
  _i2.Future<_i6.CmsClient?> updateClient(
    int clientId, {
    String? name,
    String? description,
    bool? isActive,
    String? settings,
  }) => caller.callServerEndpoint<_i6.CmsClient?>(
    'cmsClient',
    'updateClient',
    {
      'clientId': clientId,
      'name': name,
      'description': description,
      'isActive': isActive,
      'settings': settings,
    },
  );

  /// Regenerate the API token for a client (requires authentication).
  /// Returns the client and the new raw token (shown once only).
  _i2.Future<_i7.ClientWithToken> regenerateApiToken(int clientId) =>
      caller.callServerEndpoint<_i7.ClientWithToken>(
        'cmsClient',
        'regenerateApiToken',
        {'clientId': clientId},
      );

  /// Delete a client (requires authentication)
  /// Will fail if client has associated users (FK restriction)
  _i2.Future<bool> deleteClient(int clientId) =>
      caller.callServerEndpoint<bool>(
        'cmsClient',
        'deleteClient',
        {'clientId': clientId},
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
  _i2.Future<List<_i8.DocumentCrdtOperation>> getOperationsSince(
    int documentId,
    String sinceHlc, {
    required int limit,
  }) => caller.callServerEndpoint<List<_i8.DocumentCrdtOperation>>(
    'documentCollaboration',
    'getOperationsSince',
    {
      'documentId': documentId,
      'sinceHlc': sinceHlc,
      'limit': limit,
    },
  );

  /// Submit an edit (partial field updates) for collaborative editing
  _i2.Future<_i9.CmsDocument> submitEdit(
    int documentId,
    String sessionId,
    Map<String, dynamic> fieldUpdates,
  ) => caller.callServerEndpoint<_i9.CmsDocument>(
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
  _i2.Future<_i10.DocumentList> getDocuments(
    String documentType, {
    String? search,
    required int limit,
    required int offset,
  }) => caller.callServerEndpoint<_i10.DocumentList>(
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
  _i2.Future<_i9.CmsDocument?> getDocument(int documentId) =>
      caller.callServerEndpoint<_i9.CmsDocument?>(
        'document',
        'getDocument',
        {'documentId': documentId},
      );

  /// Get a document by slug
  _i2.Future<_i9.CmsDocument?> getDocumentBySlug(String slug) =>
      caller.callServerEndpoint<_i9.CmsDocument?>(
        'document',
        'getDocumentBySlug',
        {'slug': slug},
      );

  /// Get the default document for a document type
  _i2.Future<_i9.CmsDocument?> getDefaultDocument(String documentType) =>
      caller.callServerEndpoint<_i9.CmsDocument?>(
        'document',
        'getDefaultDocument',
        {'documentType': documentType},
      );

  /// Create a new document with an initial version
  /// This creates both the CmsDocument and its first DocumentVersion
  _i2.Future<_i9.CmsDocument> createDocument(
    String documentType,
    String title,
    Map<String, dynamic> data, {
    String? slug,
    required bool isDefault,
  }) => caller.callServerEndpoint<_i9.CmsDocument>(
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
  _i2.Future<_i9.CmsDocument> updateDocumentData(
    int documentId,
    Map<String, dynamic> updates, {
    String? sessionId,
  }) => caller.callServerEndpoint<_i9.CmsDocument>(
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
  _i2.Future<_i9.CmsDocument?> updateDocument(
    int documentId, {
    String? title,
    String? slug,
    bool? isDefault,
  }) => caller.callServerEndpoint<_i9.CmsDocument?>(
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
  /// Optionally includes CRDT operations between adjacent versions
  _i2.Future<_i11.DocumentVersionListWithOperations> getDocumentVersions(
    int documentId, {
    required int limit,
    required int offset,
    required bool includeOperations,
  }) => caller.callServerEndpoint<_i11.DocumentVersionListWithOperations>(
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
  _i2.Future<_i12.DocumentVersion?> getDocumentVersion(int versionId) =>
      caller.callServerEndpoint<_i12.DocumentVersion?>(
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
  _i2.Future<_i12.DocumentVersion> createDocumentVersion(
    int documentId, {
    required _i13.DocumentVersionStatus status,
    String? changeLog,
  }) => caller.callServerEndpoint<_i12.DocumentVersion>(
    'document',
    'createDocumentVersion',
    {
      'documentId': documentId,
      'status': status,
      'changeLog': changeLog,
    },
  );

  /// Publish a version (set status to 'published' and set publishedAt timestamp)
  _i2.Future<_i12.DocumentVersion?> publishDocumentVersion(int versionId) =>
      caller.callServerEndpoint<_i12.DocumentVersion?>(
        'document',
        'publishDocumentVersion',
        {'versionId': versionId},
      );

  /// Archive a version (set status to 'archived' and set archivedAt timestamp)
  _i2.Future<_i12.DocumentVersion?> archiveDocumentVersion(int versionId) =>
      caller.callServerEndpoint<_i12.DocumentVersion?>(
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

/// {@category Endpoint}
class EndpointEmailIdp extends _i14.EndpointEmailIdpBase {
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
  _i2.Future<_i15.AuthSuccess> login({
    required String email,
    required String password,
  }) => caller.callServerEndpoint<_i15.AuthSuccess>(
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
  _i2.Future<_i15.AuthSuccess> finishRegistration({
    required String registrationToken,
    required String password,
  }) => caller.callServerEndpoint<_i15.AuthSuccess>(
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
class EndpointGoogleIdp extends _i14.EndpointGoogleIdpBase {
  EndpointGoogleIdp(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'googleIdp';

  /// Validates a Google ID token and either logs in the associated user or
  /// creates a new user account if the Google account ID is not yet known.
  ///
  /// If a new user is created an associated [UserProfile] is also created.
  @override
  _i2.Future<_i15.AuthSuccess> login({
    required String idToken,
    required String? accessToken,
  }) => caller.callServerEndpoint<_i15.AuthSuccess>(
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

/// Endpoint for managing media files and uploads
/// All operations require authentication
/// {@category Endpoint}
class EndpointMedia extends _i1.EndpointRef {
  EndpointMedia(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'media';

  /// Upload an image file
  /// Returns the public URL and file ID
  _i2.Future<_i16.UploadResponse> uploadImage(
    String fileName,
    _i17.ByteData fileData,
  ) => caller.callServerEndpoint<_i16.UploadResponse>(
    'media',
    'uploadImage',
    {
      'fileName': fileName,
      'fileData': fileData,
    },
  );

  /// Upload a general file (PDF, documents, etc.)
  /// Returns the public URL, file ID, and filename
  _i2.Future<_i16.UploadResponse> uploadFile(
    String fileName,
    _i17.ByteData fileData,
  ) => caller.callServerEndpoint<_i16.UploadResponse>(
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
  _i2.Future<_i18.MediaFile?> getMedia(int fileId) =>
      caller.callServerEndpoint<_i18.MediaFile?>(
        'media',
        'getMedia',
        {'fileId': fileId},
      );

  /// List all media files with pagination
  _i2.Future<List<_i18.MediaFile>> listMedia({
    required int limit,
    required int offset,
  }) => caller.callServerEndpoint<List<_i18.MediaFile>>(
    'media',
    'listMedia',
    {
      'limit': limit,
      'offset': offset,
    },
  );
}

/// {@category Endpoint}
class EndpointRefreshJwtTokens extends _i15.EndpointRefreshJwtTokens {
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
  _i2.Future<_i15.AuthSuccess> refreshAccessToken({
    required String refreshToken,
  }) => caller.callServerEndpoint<_i15.AuthSuccess>(
    'refreshJwtTokens',
    'refreshAccessToken',
    {'refreshToken': refreshToken},
    authenticated: false,
  );
}

/// Endpoint for managing CMS users
/// {@category Endpoint}
class EndpointUser extends _i1.EndpointRef {
  EndpointUser(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'user';

  /// Ensure a CMS user exists for the authenticated user in the given client.
  /// Creates one automatically on first login.
  /// Validates the API token (bcrypt) before creating the user.
  _i2.Future<_i19.CmsUser> ensureUser(
    String clientSlug,
    String apiToken,
  ) => caller.callServerEndpoint<_i19.CmsUser>(
    'user',
    'ensureUser',
    {
      'clientSlug': clientSlug,
      'apiToken': apiToken,
    },
  );

  /// Get the current CMS user for the authenticated user in a given client.
  /// Validates the API token.
  _i2.Future<_i19.CmsUser?> getCurrentUser(
    String clientSlug,
    String apiToken,
  ) => caller.callServerEndpoint<_i19.CmsUser?>(
    'user',
    'getCurrentUser',
    {
      'clientSlug': clientSlug,
      'apiToken': apiToken,
    },
  );

  /// Get all clients the authenticated user belongs to.
  /// Used by Manage app for client switcher.
  _i2.Future<List<_i6.CmsClient>> getUserClients() =>
      caller.callServerEndpoint<List<_i6.CmsClient>>(
        'user',
        'getUserClients',
        {},
      );

  /// Get the current CMS user by client slug (for Manage app — no API token needed).
  /// Authenticates via Serverpod auth session only.
  _i2.Future<_i19.CmsUser?> getCurrentUserBySlug(String clientSlug) =>
      caller.callServerEndpoint<_i19.CmsUser?>(
        'user',
        'getCurrentUserBySlug',
        {'clientSlug': clientSlug},
      );

  /// Get count of CmsUsers for a client (for Overview stats).
  _i2.Future<int> getClientUserCount(int clientId) =>
      caller.callServerEndpoint<int>(
        'user',
        'getClientUserCount',
        {'clientId': clientId},
      );
}

class Modules {
  Modules(Client client) {
    serverpod_auth_idp = _i14.Caller(client);
    serverpod_admin = _i20.Caller(client);
    serverpod_auth_core = _i15.Caller(client);
  }

  late final _i14.Caller serverpod_auth_idp;

  late final _i20.Caller serverpod_admin;

  late final _i15.Caller serverpod_auth_core;
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
         _i21.Protocol(),
         securityContext: securityContext,
         streamingConnectionTimeout: streamingConnectionTimeout,
         connectionTimeout: connectionTimeout,
         onFailedCall: onFailedCall,
         onSucceededCall: onSucceededCall,
         disconnectStreamsOnLostInternetConnection:
             disconnectStreamsOnLostInternetConnection,
       ) {
    cmsApiToken = EndpointCmsApiToken(this);
    cmsClient = EndpointCmsClient(this);
    documentCollaboration = EndpointDocumentCollaboration(this);
    document = EndpointDocument(this);
    emailIdp = EndpointEmailIdp(this);
    googleIdp = EndpointGoogleIdp(this);
    media = EndpointMedia(this);
    refreshJwtTokens = EndpointRefreshJwtTokens(this);
    user = EndpointUser(this);
    modules = Modules(this);
  }

  late final EndpointCmsApiToken cmsApiToken;

  late final EndpointCmsClient cmsClient;

  late final EndpointDocumentCollaboration documentCollaboration;

  late final EndpointDocument document;

  late final EndpointEmailIdp emailIdp;

  late final EndpointGoogleIdp googleIdp;

  late final EndpointMedia media;

  late final EndpointRefreshJwtTokens refreshJwtTokens;

  late final EndpointUser user;

  late final Modules modules;

  @override
  Map<String, _i1.EndpointRef> get endpointRefLookup => {
    'cmsApiToken': cmsApiToken,
    'cmsClient': cmsClient,
    'documentCollaboration': documentCollaboration,
    'document': document,
    'emailIdp': emailIdp,
    'googleIdp': googleIdp,
    'media': media,
    'refreshJwtTokens': refreshJwtTokens,
    'user': user,
  };

  @override
  Map<String, _i1.ModuleEndpointCaller> get moduleLookup => {
    'serverpod_auth_idp': modules.serverpod_auth_idp,
    'serverpod_admin': modules.serverpod_admin,
    'serverpod_auth_core': modules.serverpod_auth_core,
  };
}
