## 0.1.1

- feat: add ApiException for client-visible errors
- feat: implement CompoundTokenParser for JWT and API key parsing
- feat: add MigrationEndpoint, MigrationService, and MigrationHistory model
- fix: api token parser
- fix: use ApiException in resolveUser for client-visible errors
- fix: await SMTP send in registration/reset callbacks
- fix: update Dart SDK from 3.5.0 to 3.11.3
- chore: add melos workspace, harden .pubignore

## 0.1.0

- Initial release
- Document CRUD with versioning and status workflows
- CRDT-based collaborative editing
- Media upload with metadata extraction
- Authentication via Serverpod IDP (Google, email/password)
- API token management
