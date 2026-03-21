import 'dart:convert';
import 'dart:typed_data';

import 'package:dart_desk_be_server/server.dart' as server;
import 'package:dart_desk_be_server/src/generated/protocol.dart';
import 'package:dart_desk_be_server/src/services/document_crdt_service.dart';

import '../test_tools/serverpod_test_tools.dart';

class TestDataFactory {
  final TestSessionBuilder sessionBuilder;
  final TestEndpoints endpoints;

  TestDataFactory({
    required this.sessionBuilder,
    required this.endpoints,
  });

  static void initializeCrdtService() {
    server.documentCrdtService = DocumentCrdtService('test-node');
  }

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

  /// Ensures a User record exists for the authenticated test user.
  /// Inserts directly since ensureUser endpoint was removed.
  Future<User> ensureTestUser({
    String userIdentifier = 'test-user-1',
    String email = 'test@example.com',
    String name = 'Test User',
    String role = 'viewer',
  }) async {
    final authed = authenticatedSession(userIdentifier: userIdentifier);

    // Check if user already exists via getCurrentUser
    final existing = await endpoints.user.getCurrentUser(authed);
    if (existing != null) return existing;

    // Insert directly for testing (since DartDeskAuth.authenticateRequest
    // via Serverpod IDP path only finds existing users, doesn't create)
    final session = sessionBuilder.build();
    final user = await User.db.insertRow(
      session,
      User(
        tenantId: null,
        email: email,
        name: name,
        role: role,
        isActive: true,
        serverpodUserId: userIdentifier,
      ),
    );
    return user;
  }

  Future<Document> createTestDocument({
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

  Future<MediaAsset> uploadTestImage({
    String fileName = 'test_image.png',
  }) async {
    final authed = authenticatedSession();
    final pngBytes = <int>[
      0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A,
      0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52,
      0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
      0x08, 0x02, 0x00, 0x00, 0x00, 0x90, 0x77, 0x53,
      0xDE, 0x00, 0x00, 0x00, 0x0C, 0x49, 0x44, 0x41,
      0x54, 0x08, 0xD7, 0x63, 0xF8, 0xCF, 0xC0, 0x00,
      0x00, 0x00, 0x02, 0x00, 0x01, 0xE2, 0x21, 0xBC,
      0x33, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E,
      0x44, 0xAE, 0x42, 0x60, 0x82,
    ];
    final byteData = ByteData.sublistView(Uint8List.fromList(pngBytes));
    return await endpoints.media.uploadImage(
      authed, fileName, byteData, 1, 1, false, 'L00000fQfQfQfQfQfQfQfQfQfQ', 'testhash',
    );
  }

  Future<MediaAsset> uploadTestFile({
    String fileName = 'test_file.txt',
    String content = 'test file content',
  }) async {
    final authed = authenticatedSession();
    final bytes = utf8.encode(content);
    final byteData = ByteData.sublistView(Uint8List.fromList(bytes));
    return await endpoints.media.uploadFile(authed, fileName, byteData);
  }
}
