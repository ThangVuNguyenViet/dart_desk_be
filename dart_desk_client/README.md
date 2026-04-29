# dart_desk_client

Dart client SDK for the [Dart Desk](https://github.com/ThangVuNguyenViet/dart_desk_be) headless CMS backend. Generated from the Serverpod protocol.

> ⚠️ **Rapid development.** APIs may shift between minor versions.
> Bug reports and feature requests are very welcome — please open an issue at
> [github.com/ThangVuNguyenViet/dart_desk_be/issues](https://github.com/ThangVuNguyenViet/dart_desk_be/issues).

## Installation

```yaml
dependencies:
  dart_desk_client: ^0.2.0
```

## Public read API (consumer apps)

Most consumer apps only need the public read API on `client.publicContent`. No auth is required for default content.

```dart
import 'dart:convert';
import 'package:dart_desk_client/dart_desk_client.dart';

final client = Client('https://your-project.dartdesk.dev/');

final docs = await client.publicContent.getDefaultContents();
// Map<String, PublicDocument> — one default per document type.

final raw = docs['storefront']!.data; // JSON string
final config = jsonDecode(raw) as Map<String, dynamic>;
// Decode with dart_mappable, freezed, or your serializer of choice.
```

Other public methods:

| Method | Returns | Use for |
|--------|---------|---------|
| `getDefaultContent(documentType)` | `PublicDocument?` | Fetch a single type |
| `getContentsByDataContains(dataContainsJson)` | `Map<String, PublicDocument>` | JSONB containment lookup, default-flagged matches |
| `getAllContentsByDataContains(dataContainsJson)` | `Map<String, List<PublicDocument>>` | All matches — used for device-group / segment routing |

## Authenticated / admin API

Studio apps and back-office tools use the authenticated endpoints with a Serverpod auth key manager.

```dart
import 'package:dart_desk_client/dart_desk_client.dart';
import 'package:serverpod_flutter/serverpod_flutter.dart';

final client = Client('https://your-project.dartdesk.dev/')
  ..authKeyProvider = DartDeskAuthKeyProvider(apiKey: '<api-token>')
  ..connectivityMonitor = FlutterConnectivityMonitor();

// CRUD documents
final docs = await client.document.getDocuments('storefront');

// Upload media (server fills in EXIF, BlurHash, palette, content hash)
final asset = await client.media.uploadImage(fileName, data, /* ... */);
```

## Endpoints

| Endpoint | Auth | Description |
|----------|------|-------------|
| `client.publicContent` | none | Public read API for consumer apps |
| `client.document` | required | CRUD for documents, versions, document types |
| `client.documentCollaboration` | required | Real-time CRDT collaboration |
| `client.media` | required | Media upload, listing, management |
| `client.user` | required | User management |
| `client.apiToken` | required | API token management |

## License

Business Source License 1.1 — see [LICENSE](LICENSE).
