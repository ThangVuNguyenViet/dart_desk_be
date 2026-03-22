# dart_desk_be_client

Dart client SDK for the [Dart Desk](https://github.com/ThangVuNguyenViet/dart_desk_be) headless CMS backend.

This package provides typed API access to documents, media, collaboration, and versioning endpoints via the Serverpod protocol.

## Installation

```yaml
dependencies:
  dart_desk_be_client: ^0.1.0
```

## Usage

```dart
import 'package:dart_desk_be_client/dart_desk_be_client.dart';

final client = Client('http://localhost:8080/')
  ..authenticationKeyManager = myKeyManager;

// Fetch documents
final docs = await client.document.getDocuments('article');

// Upload media
final asset = await client.media.uploadImage(fileName, data, width, height, hasAlpha, blurHash, contentHash);
```

## Available Endpoints

| Endpoint | Description |
|----------|-------------|
| `client.document` | CRUD for documents, versions, and document types |
| `client.documentCollaboration` | Real-time CRDT collaboration |
| `client.media` | Media upload, listing, and management |
| `client.user` | User management |
| `client.apiToken` | API token management |

## License

Business Source License 1.1 - see [LICENSE](LICENSE) for details.
