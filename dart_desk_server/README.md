# dart_desk_server

Serverpod backend server for [Dart Desk](https://github.com/ThangVuNguyenViet/dart_desk_be), a headless CMS with CRDT collaboration, media management, and versioned content.

## Prerequisites

- Dart SDK >= 3.5.0
- Docker (for PostgreSQL and Redis)

## Getting Started

1. Start the database and cache:

```bash
docker compose up --build --detach
```

2. Run the server:

```bash
dart bin/main.dart
```

3. Stop services when finished:

```bash
docker compose stop
```

## Configuration

Server configuration is in the `config/` directory:
- `development.yaml` - local development settings
- `production.yaml` - production settings
- `passwords.yaml` - secrets (not committed)

## Features

- Document CRUD with versioning and status workflows
- CRDT-based real-time collaborative editing
- Media upload with automatic metadata extraction (EXIF, blur hash, palette)
- Authentication via Serverpod IDP (Google, email/password)
- API token management for programmatic access

## License

Business Source License 1.1 - see [LICENSE](LICENSE) for details.
