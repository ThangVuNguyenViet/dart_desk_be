import 'dart:convert';
import 'dart:typed_data';

import 'package:dart_desk_server/src/generated/protocol.dart';
import 'package:dart_desk_server/src/plugin/dart_desk_registry.dart';
import 'package:dart_desk_server/src/plugin/dart_desk_session.dart';
import 'package:dart_desk_server/src/services/document_crdt_service.dart';
import 'package:image/image.dart' as img;
import 'package:serverpod/serverpod.dart';

import '../test_tools/serverpod_test_tools.dart';

class TestDataFactory {
  static final testClientId =
      UuidValue.fromString('00000000-0000-4000-8000-000000000001');
  static final testProjectId =
      UuidValue.fromString('00000000-0000-4000-8000-000000000002');

  final TestSessionBuilder sessionBuilder;
  final TestEndpoints endpoints;

  TestDataFactory({
    required this.sessionBuilder,
    required this.endpoints,
  });

  static void initializeCrdtService() {
    final registry = DartDeskRegistry();
    registry.documentCrdtService = DocumentCrdtService('test-node');
    DartDeskSession.setRegistry(registry);
  }

  TestSessionBuilder authenticatedSession({
    String userIdentifier = 'test-user-1',
    UuidValue? clientId,
    UuidValue? projectId,
  }) {
    clientId ??= testClientId;
    projectId ??= testProjectId;
    return sessionBuilder.copyWith(
      authentication: AuthenticationOverride.authenticationInfo(
        userIdentifier,
        {
          Scope('client:$clientId'),
          Scope('project:$projectId'),
          Scope('project.read'),
          Scope('project.write'),
        },
      ),
    );
  }

  Future<CmsClient> ensureTestClient({
    UuidValue? clientId,
    String name = 'Test Client',
    String slug = 'test-client',
  }) async {
    clientId ??= testClientId;
    final session = sessionBuilder.build();
    final existing = await CmsClient.db.findById(session, clientId);
    if (existing != null) return existing;

    return CmsClient.db.insertRow(
      session,
      CmsClient(
        id: clientId,
        name: name,
        slug: slug,
        isActive: true,
      ),
    );
  }

  Future<Project> ensureTestProject({
    UuidValue? projectId,
    UuidValue? clientId,
    String name = 'Test Project',
    String slug = 'test-project',
  }) async {
    projectId ??= testProjectId;
    clientId ??= testClientId;
    final session = sessionBuilder.build();
    await ensureTestClient(clientId: clientId);

    final existing = await Project.db.findById(session, projectId);
    if (existing != null) return existing;

    return Project.db.insertRow(
      session,
      Project(
        id: projectId,
        clientId: clientId,
        name: name,
        slug: slug,
        deployHostname: 'test-$slug',
        isActive: true,
      ),
    );
  }

  /// Ensures a User record exists for the authenticated test user.
  /// Inserts directly to avoid endpoint calls that trigger concurrent
  /// DB operations unsupported in the Serverpod test transaction wrapper.
  Future<User> ensureTestUser({
    String userIdentifier = 'test-user-1',
    String? email,
    String name = 'Test User',
    ClientRole role = ClientRole.viewer,
    UuidValue? clientId,
  }) async {
    final resolvedClientId = clientId ?? testClientId;
    final session = sessionBuilder.build();
    await ensureTestClient(clientId: resolvedClientId);
    await ensureTestProject(clientId: resolvedClientId);

    // Check if user already exists
    final existing = await User.db.findFirstRow(
      session,
      where: (t) =>
          t.serverpodUserId.equals(userIdentifier) &
          t.clientId.equals(resolvedClientId),
    );
    if (existing != null) {
      // Update role if it doesn't match the requested role
      if (existing.role != role) {
        final updated = existing.copyWith(role: role);
        await User.db.updateRow(session, updated);
        return updated;
      }
      return existing;
    }

    // Insert directly for testing
    final user = await User.db.insertRow(
      session,
      User(
        clientId: resolvedClientId,
        email: email ?? '$userIdentifier@example.com',
        name: name,
        role: role,
        isActive: true,
        serverpodUserId: userIdentifier,
      ),
    );
    return user;
  }

  Future<ProjectMember> ensureTestProjectMember({
    required UuidValue userId,
    UuidValue? projectId,
    ProjectRole role = ProjectRole.editor,
  }) async {
    projectId ??= testProjectId;
    final session = sessionBuilder.build();
    final existing = await ProjectMember.db.findFirstRow(
      session,
      where: (t) => t.userId.equals(userId) & t.projectId.equals(projectId),
    );
    if (existing != null) return existing;

    return ProjectMember.db.insertRow(
      session,
      ProjectMember(
        userId: userId,
        projectId: projectId,
        role: role,
      ),
    );
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
      jsonEncode(data),
      slug: slug,
      isDefault: isDefault,
    );
  }

  Future<DocumentVersion> createTestVersion(
    UuidValue documentId, {
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
    // Generate a valid 4x4 red PNG at runtime to avoid checksum issues.
    final image = img.fill(
      img.Image(width: 4, height: 4),
      color: img.ColorRgb8(255, 0, 0),
    );
    final pngBytes = img.encodePng(image);
    final byteData = ByteData.sublistView(Uint8List.fromList(pngBytes));
    return await endpoints.media.uploadImage(
      authed,
      fileName,
      byteData,
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
