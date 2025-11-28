# Flutter CMS Backend - Requirements Document

## Project Overview

This document defines the requirements for transforming the Flutter CMS backend from a single-tenant system into a multi-tenant Content Management System with comprehensive version control capabilities.

## Business Requirements

### Multi-Tenancy

**Requirement**: The backend must support multiple clients (tenants) with complete data isolation.

**Details**:
- The system handles multiple "clients" (terminology for tenants)
- Each client represents an independent organization using the CMS
- All data must be completely isolated between clients
- No cross-client data access is permitted

**Sub-Requirements**:
- One client can have multiple users
- Users can have different roles within a client (viewer, editor, admin, owner)
- Users may potentially belong to multiple clients (agency/consultant use case)

### Document Type Management

**Requirement**: Document types must be dynamically defined and stored in the database.

**Details**:
- Document types represent different content structures (e.g., HomeScreenConfig, BlogPost, ProductPage)
- Each client can define their own document types
- Document types are stored in database, not hardcoded
- Example: The `home_screen_config.dart` in the flutter_cms UI package represents one document type

**Sub-Requirements**:
- Document types should have:
  - Unique name and slug (URL-safe identifier)
  - Optional JSON Schema for data validation
  - Metadata (description, icon, color)
  - Configuration (e.g., allowMultiple flag)
- Document types can be created, updated, and deleted via API
- Deletion should be prevented if documents exist

### Document Management

**Requirement**: The system must support flexible document creation and management.

**Details**:
- One document type can have many documents
- Documents store their data as JSON for flexibility
- Documents have metadata (title, slug, timestamps, creators)
- Documents belong to exactly one client and one document type

**Sub-Requirements**:
- Documents can be created, read, updated, and deleted
- Documents support search and filtering
- Documents can be paginated for list views
- Documents track who created and last modified them

### Version Control

**Requirement**: Every document must have complete version history with draft/publish workflow.

**Details**:
- One document can have multiple versions over time
- Each version stores a complete copy of the document data
- Versions are immutable - editing creates a new version
- Full audit trail of all changes

**Sub-Requirements**:

#### Version Statuses
Documents must support four version statuses:

1. **Draft**: Work-in-progress version, not visible to end users
   - Can be edited (by creating new draft version)
   - Multiple drafts can exist for a document
   - Drafts are only visible to authenticated CMS users

2. **Published**: Live version visible to end users
   - Only ONE version can be published per document at a time
   - Publishing a new version automatically archives the previous published version
   - Published versions are immutable
   - Published versions have a `publishedAt` timestamp

3. **Archived**: Historical versions no longer active
   - Old published versions automatically become archived
   - Preserved for audit trail and potential rollback
   - Archived versions have an `archivedAt` timestamp

4. **Scheduled**: Versions scheduled to publish at a future date/time
   - Have a `scheduledAt` timestamp
   - Automatically published by background job when time arrives
   - Only one scheduled version per document at a time

#### Version Workflow
The typical version lifecycle:
```
Draft → Published → Archived
      ↓
   Scheduled (auto-publishes at specified time) → Published → Archived
```

#### Live Version
**Critical Requirement**: One document can only have ONE live version at a time.
- The live version is the latest published version
- Referenced via `Document.currentVersionId`
- This is the version served to end users

### User Management

**Requirement**: Users must belong to clients with role-based access control.

**Details**:
- Users are associated with one or more clients
- Each user has a role that determines their permissions
- For now, roles are not a priority but the model should support them

**Sub-Requirements**:

#### Roles (Priority: Low for MVP)
Four role levels planned:
1. **Viewer**: Read-only access to documents
2. **Editor**: Can create and edit drafts, cannot publish
3. **Admin**: Can publish documents, manage document types
4. **Owner**: Full access including client settings and user management

#### Authentication
- Use Serverpod's built-in authentication module
- Prepare models for future auth integration
- Add `serverpodUserId` field to link CMS users to auth users

### Media File Management

**Requirement**: Media files must be isolated per client with metadata support.

**Details**:
- Images and files are uploaded and stored per client
- Files have metadata (filename, type, size, storage path, public URL)
- Files support accessibility (alt text) and extended metadata

**Sub-Requirements**:
- Support image uploads (jpg, png, gif, webp)
- Support file uploads (pdf, doc, txt, csv, xlsx)
- 10MB file size limit
- Files stored at `storage/public/{clientId}/{fileId}`
- Track who uploaded each file

## Functional Requirements

### FR-1: Client Management
- **FR-1.1**: Create a new client with name, slug, and settings
- **FR-1.2**: Retrieve client information by ID or slug
- **FR-1.3**: List all clients (admin functionality)
- **FR-1.4**: Update client settings
- **FR-1.5**: Deactivate/activate clients (soft delete)

### FR-2: Document Type Management
- **FR-2.1**: Create document type with name, slug, schema, and metadata
- **FR-2.2**: List all document types for a client
- **FR-2.3**: Retrieve document type by ID or slug
- **FR-2.4**: Update document type definition
- **FR-2.5**: Delete document type (only if no documents exist)

### FR-3: Document Management
- **FR-3.1**: Create document with title and initial draft version
- **FR-3.2**: Retrieve document by ID with current published version
- **FR-3.3**: List documents filtered by client and document type
- **FR-3.4**: Search documents by title or metadata
- **FR-3.5**: Delete document and all its versions

### FR-4: Version Management
- **FR-4.1**: Create new draft version for a document
- **FR-4.2**: Update draft version (creates new version)
- **FR-4.3**: Publish draft version (archives current published)
- **FR-4.4**: Schedule version for future publishing
- **FR-4.5**: Archive a version manually
- **FR-4.6**: List all versions for a document with pagination
- **FR-4.7**: Compare two versions (show differences)
- **FR-4.8**: Revert to previous version (create new draft from old version)

### FR-5: User Management
- **FR-5.1**: Create user and assign to client
- **FR-5.2**: List users for a client
- **FR-5.3**: Update user role
- **FR-5.4**: Add existing user to another client
- **FR-5.5**: Remove user from client
- **FR-5.6**: Deactivate/activate user

### FR-6: Media Management
- **FR-6.1**: Upload image file
- **FR-6.2**: Upload document file
- **FR-6.3**: List media files for client with pagination
- **FR-6.4**: Retrieve media file metadata by ID
- **FR-6.5**: Update media metadata (alt text)
- **FR-6.6**: Delete media file

### FR-7: Background Jobs
- **FR-7.1**: Scheduled publishing job runs every minute
- **FR-7.2**: Finds versions with status='scheduled' and scheduledAt <= now
- **FR-7.3**: Publishes scheduled versions automatically

## Non-Functional Requirements

### NFR-1: Performance
- **NFR-1.1**: API response time p95 < 200ms
- **NFR-1.2**: Support 100 concurrent users
- **NFR-1.3**: Database queries optimized with proper indexes
- **NFR-1.4**: Handle 10,000+ documents per client efficiently

### NFR-2: Security
- **NFR-2.1**: Complete data isolation between clients (no cross-client access)
- **NFR-2.2**: All queries must filter by clientId
- **NFR-2.3**: Role-based access control enforced on all endpoints
- **NFR-2.4**: File storage isolated per client
- **NFR-2.5**: SQL injection prevention via parameterized queries
- **NFR-2.6**: Audit trail for all document changes (who/when)

### NFR-3: Scalability
- **NFR-3.1**: Support 1000+ clients in single database
- **NFR-3.2**: Horizontal scaling via connection pooling
- **NFR-3.3**: Database designed for potential sharding in future

### NFR-4: Reliability
- **NFR-4.1**: Database migrations are reversible
- **NFR-4.2**: Data integrity maintained with foreign key constraints
- **NFR-4.3**: Immutable version history prevents data loss
- **NFR-4.4**: Backup and restore procedures documented

### NFR-5: Maintainability
- **NFR-5.1**: Code follows Serverpod best practices
- **NFR-5.2**: All models documented with clear relationships
- **NFR-5.3**: API endpoints documented with examples
- **NFR-5.4**: Comprehensive test coverage (unit + integration)

## Data Models Summary

### Core Entities

1. **Client**: Multi-tenancy root (name, slug, settings)
2. **CmsUser**: Users belonging to clients (email, role, clientId)
3. **DocumentType**: Dynamic document type definitions (name, slug, schema)
4. **Document**: Master document record (title, type, currentVersionId)
5. **DocumentVersion**: Version history (versionNumber, status, data)
6. **MediaFile**: Uploaded files (filename, storagePath, clientId)
7. **ClientUser**: Junction table for multi-client users (optional)

### Relationships

- Client (1) → (*) CmsUser
- Client (1) → (*) DocumentType
- Client (1) → (*) Document
- Client (1) → (*) MediaFile
- DocumentType (1) → (*) Document
- Document (1) → (*) DocumentVersion
- Document (1) → (1) DocumentVersion (current/live reference)

## API Endpoints Summary

### Clients
- `POST /client/create` - Create client
- `GET /client/get` - Get client
- `GET /client/list` - List clients

### Document Types
- `POST /documentType/create` - Create type
- `GET /documentType/list` - List types
- `PUT /documentType/update` - Update type
- `DELETE /documentType/delete` - Delete type

### Documents
- `POST /document/create` - Create document + draft
- `GET /document/get` - Get document with live version
- `GET /document/list` - List documents
- `DELETE /document/delete` - Delete document

### Versions
- `POST /version/createDraft` - Create new draft
- `POST /version/publish` - Publish draft
- `POST /version/schedule` - Schedule for publishing
- `GET /version/list` - List versions
- `GET /version/compare` - Compare two versions

### Users
- `POST /user/create` - Create user
- `GET /user/list` - List users
- `PUT /user/updateRole` - Update role

### Media
- `POST /media/uploadImage` - Upload image
- `POST /media/uploadFile` - Upload file
- `GET /media/list` - List media
- `DELETE /media/delete` - Delete file

## Migration Strategy

### Phase 1: New Tables (Non-Breaking)
- Create Client, DocumentType, Document, DocumentVersion tables
- Create default "System" client
- Create ClientUser junction table

### Phase 2: Data Migration
- Migrate existing CmsDocument → Document + DocumentVersion
- Add clientId to CmsUser and MediaFile
- Create DocumentType records from unique document types

### Phase 3: Endpoint Updates
- Update all endpoints to use new models
- Add client isolation to all queries
- Implement role-based access control

### Phase 4: Cleanup
- Deprecate and drop old CmsDocument table
- Validate data integrity
- Update documentation

## Success Criteria

### Must Have (MVP)
- ✅ Multi-tenant data isolation working
- ✅ Document types stored in database
- ✅ Version control with draft/published workflow
- ✅ One live version per document
- ✅ Basic role-based access control
- ✅ Media files isolated per client
- ✅ Scheduled publishing working

### Should Have (Post-MVP)
- Integration with Serverpod Auth
- Document templates
- Workflow approvals
- Webhooks for events
- Full-text search

### Could Have (Future)
- Document relationships
- Advanced analytics
- Asset management (folders, tags)
- Image transformations

## Constraints

### Technical Constraints
- Must use Serverpod 2.9.2 framework
- PostgreSQL database
- Single shared database for all clients (row-level isolation)
- JSON storage for document data (flexible schema)

### Business Constraints
- Roles are defined but not priority for MVP
- Authentication integration deferred to post-MVP
- Initially support single client, then migrate existing data

## Assumptions

1. Clients are created manually (not self-service signup initially)
2. Users authenticate via future Serverpod Auth integration
3. Document types are managed via API (not UI initially)
4. File storage uses Serverpod's built-in storage system
5. Scheduled publishing runs every 1 minute (configurable)
6. Version numbers are sequential integers (not semantic versioning)

## Risks

### Technical Risks
- **Risk**: Cross-client data leakage if queries miss clientId filter
  - **Mitigation**: Mandatory middleware, comprehensive testing

- **Risk**: Database performance with large version history
  - **Mitigation**: Proper indexing, potential archival strategy

- **Risk**: Migration complexity from old to new structure
  - **Mitigation**: Thorough testing, rollback plan, keep old tables temporarily

### Business Risks
- **Risk**: Breaking changes to existing API
  - **Mitigation**: Versioned APIs or parallel endpoints during transition

- **Risk**: Data loss during migration
  - **Mitigation**: Full database backup, reversible migrations, validation

## Acceptance Criteria

### Multi-Tenancy
- [ ] Client can be created with unique slug
- [ ] All data queries filtered by clientId
- [ ] User in Client A cannot access Client B's data
- [ ] Files stored with client-specific paths

### Version Control
- [ ] Creating document creates initial draft version (v1)
- [ ] Editing draft creates new version (v2, v3, etc.)
- [ ] Publishing draft makes it live and archives previous
- [ ] Only one published version exists per document
- [ ] Version history preserved for all changes

### Document Types
- [ ] Document types can be created via API
- [ ] Documents reference their type
- [ ] Types can have JSON Schema validation
- [ ] Cannot delete type with existing documents

### Scheduled Publishing
- [ ] Version can be scheduled with future timestamp
- [ ] Background job publishes on schedule
- [ ] Scheduled version becomes published automatically

### Security
- [ ] Editor cannot publish (only admin+)
- [ ] Viewer cannot create drafts (read-only)
- [ ] Owner can manage users and settings
- [ ] File URLs validate client access

## Timeline

**Estimated Duration**: 11-15 days (experienced Serverpod developer)

**Phases**:
1. Models + Migrations: 2-3 days
2. Endpoints: 4-5 days
3. Middleware + RBAC: 2 days
4. Testing: 2-3 days
5. Documentation: 1-2 days

## Stakeholders

- **Developer**: Implementing the backend changes
- **UI Team**: Will consume new API endpoints
- **Clients**: End users managing their content
- **Admin**: Platform administrators managing clients

## Glossary

- **Client**: A tenant/organization using the CMS system
- **Document Type**: A schema defining a type of content (e.g., HomeScreenConfig)
- **Document**: An instance of a document type with data
- **Version**: A historical snapshot of a document's data
- **Draft**: Unpublished version being edited
- **Published**: Live version visible to end users
- **Archived**: Historical version no longer active
- **Scheduled**: Version set to publish automatically in future
- **Live Version**: The current published version (only one per document)
