import 'dart:convert';
import 'dart:typed_data';

import 'package:dart_desk_be_server/server.dart' as server;
import 'package:dart_desk_be_server/src/generated/protocol.dart';
import 'package:dart_desk_be_server/src/services/document_crdt_service.dart';

import '../test_tools/serverpod_test_tools.dart';

/// Factory for creating test entities via real endpoint calls.
/// Requires an authenticated session — use [authenticatedSession] helper.
class TestDataFactory {
  final TestSessionBuilder sessionBuilder;
  final TestEndpoints endpoints;

  TestDataFactory({
    required this.sessionBuilder,
    required this.endpoints,
  });

  /// Initializes the global CRDT service used by document endpoints.
  /// Must be called before any test that creates or updates documents.
  static void initializeCrdtService() {
    server.documentCrdtService = DocumentCrdtService('test-node');
  }

  /// Creates an authenticated session builder.
  /// withServerpod sessions are unauthenticated by default.
  TestSessionBuilder authenticatedSession({
    String userIdentifier = 'test-user-1',
  }) {
    return sessionBuilder.copyWith(
      authentication: AuthenticationOverride.authenticationInfo(
        userIdentifier,
        {},
      ),
    );
  }

  /// Creates a CmsClient and returns it with its plaintext API token.
  Future<ClientWithToken> createTestClient({
    String name = 'Test Client',
    String slug = 'test-client',
    String? description,
  }) async {
    final authed = authenticatedSession();
    return await endpoints.cmsClient.createClient(
      authed,
      name,
      slug,
      description: description,
    );
  }

  /// Creates a document via the document endpoint.
  /// Requires a CmsClient and CmsUser to exist for the authenticated user.
  /// The endpoint derives clientId from the user's CmsUser.clientId.
  Future<CmsDocument> createTestDocument({
    String documentType = 'test_type',
    String title = 'Test Document',
    Map<String, dynamic> data = const {'field1': 'value1'},
    String? slug,
    bool isDefault = false,
  }) async {
    final authed = authenticatedSession();
    return await endpoints.document.createDocument(
      authed,
      documentType,
      title,
      data,
      slug: slug,
      isDefault: isDefault,
    );
  }

  /// Creates a document version.
  Future<DocumentVersion> createTestVersion(
    int documentId, {
    DocumentVersionStatus status = DocumentVersionStatus.draft,
    String? changeLog,
  }) async {
    final authed = authenticatedSession();
    return await endpoints.document.createDocumentVersion(
      authed,
      documentId,
      status: status,
      changeLog: changeLog,
    );
  }

  /// Rich test data with mixed types for verifying `Map<String, dynamic>` round-trips.
  static Map<String, dynamic> get complexTestData => {
        'title': 'Test Page',
        'isActive': true,
        'count': 42,
        'rating': 4.5,
        'tags': ['alpha', 'beta', 'gamma'],
        'metadata': {
          'author': 'Jane',
          'version': 3,
          'published': true,
        },
        'items': [
          {'name': 'Item 1', 'price': 9.99},
          {'name': 'Item 2', 'price': 19.99},
        ],
        'emptyList': <dynamic>[],
        'emptyMap': <String, dynamic>{},
        'nullableField': null,
      };

  /// Uploads a minimal test PNG image (1x1 pixel).
  Future<UploadResponse> uploadTestImage({
    String fileName = 'test_image.png',
  }) async {
    final authed = authenticatedSession();
    // Minimal valid 1x1 PNG file (67 bytes)
    final pngBytes = <int>[
      0x89,
      0x50,
      0x4E,
      0x47,
      0x0D,
      0x0A,
      0x1A,
      0x0A,
      0x00,
      0x00,
      0x00,
      0x0D,
      0x49,
      0x48,
      0x44,
      0x52,
      0x00,
      0x00,
      0x00,
      0x01,
      0x00,
      0x00,
      0x00,
      0x01,
      0x08,
      0x02,
      0x00,
      0x00,
      0x00,
      0x90,
      0x77,
      0x53,
      0xDE,
      0x00,
      0x00,
      0x00,
      0x0C,
      0x49,
      0x44,
      0x41,
      0x54,
      0x08,
      0xD7,
      0x63,
      0xF8,
      0xCF,
      0xC0,
      0x00,
      0x00,
      0x00,
      0x02,
      0x00,
      0x01,
      0xE2,
      0x21,
      0xBC,
      0x33,
      0x00,
      0x00,
      0x00,
      0x00,
      0x49,
      0x45,
      0x4E,
      0x44,
      0xAE,
      0x42,
      0x60,
      0x82,
    ];
    final byteData = ByteData.sublistView(Uint8List.fromList(pngBytes));
    return await endpoints.media.uploadImage(authed, fileName, byteData);
  }

  /// Uploads a minimal test text file.
  Future<UploadResponse> uploadTestFile({
    String fileName = 'test_file.txt',
    String content = 'test file content',
  }) async {
    final authed = authenticatedSession();
    final bytes = utf8.encode(content);
    final byteData = ByteData.sublistView(Uint8List.fromList(bytes));
    return await endpoints.media.uploadFile(authed, fileName, byteData);
  }
}
