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
import 'package:serverpod/serverpod.dart' as _i1;
import 'package:serverpod/protocol.dart' as _i2;
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart'
    as _i3;
import 'package:serverpod_auth_idp_server/serverpod_auth_idp_server.dart'
    as _i4;
import 'api_exception.dart' as _i5;
import 'api_token.dart' as _i6;
import 'api_token_with_value.dart' as _i7;
import 'client_role.dart' as _i8;
import 'client_with_role.dart' as _i9;
import 'cms_client.dart' as _i10;
import 'crdt_operation_type.dart' as _i11;
import 'deployment.dart' as _i12;
import 'deployment_status.dart' as _i13;
import 'document.dart' as _i14;
import 'document_crdt_operation.dart' as _i15;
import 'document_crdt_snapshot.dart' as _i16;
import 'document_data.dart' as _i17;
import 'document_version.dart' as _i18;
import 'document_version_list_with_operations.dart' as _i19;
import 'document_version_status.dart' as _i20;
import 'document_version_with_operations.dart' as _i21;
import 'media_asset.dart' as _i22;
import 'media_asset_metadata_status.dart' as _i23;
import 'migration_history.dart' as _i24;
import 'paginated_api_tokens.dart' as _i25;
import 'paginated_document_versions.dart' as _i26;
import 'paginated_documents.dart' as _i27;
import 'paginated_media_assets.dart' as _i28;
import 'paginated_migration_histories.dart' as _i29;
import 'paginated_projects.dart' as _i30;
import 'paginated_users.dart' as _i31;
import 'project.dart' as _i32;
import 'project_member.dart' as _i33;
import 'project_role.dart' as _i34;
import 'public_document.dart' as _i35;
import 'published_document.dart' as _i36;
import 'user.dart' as _i37;
import 'package:dart_desk_server/src/generated/client_with_role.dart' as _i38;
import 'package:dart_desk_server/src/generated/api_token.dart' as _i39;
import 'package:dart_desk_server/src/generated/deployment.dart' as _i40;
import 'package:dart_desk_server/src/generated/document_crdt_operation.dart'
    as _i41;
import 'package:dart_desk_server/src/generated/media_asset.dart' as _i42;
import 'package:dart_desk_server/src/generated/user.dart' as _i43;
import 'package:dart_desk_server/src/generated/migration_history.dart' as _i44;
import 'package:dart_desk_server/src/generated/project_member.dart' as _i45;
import 'package:dart_desk_server/src/generated/public_document.dart' as _i46;
export 'api_exception.dart';
export 'api_token.dart';
export 'api_token_with_value.dart';
export 'client_role.dart';
export 'client_with_role.dart';
export 'cms_client.dart';
export 'crdt_operation_type.dart';
export 'deployment.dart';
export 'deployment_status.dart';
export 'document.dart';
export 'document_crdt_operation.dart';
export 'document_crdt_snapshot.dart';
export 'document_data.dart';
export 'document_version.dart';
export 'document_version_list_with_operations.dart';
export 'document_version_status.dart';
export 'document_version_with_operations.dart';
export 'media_asset.dart';
export 'media_asset_metadata_status.dart';
export 'migration_history.dart';
export 'paginated_api_tokens.dart';
export 'paginated_document_versions.dart';
export 'paginated_documents.dart';
export 'paginated_media_assets.dart';
export 'paginated_migration_histories.dart';
export 'paginated_projects.dart';
export 'paginated_users.dart';
export 'project.dart';
export 'project_member.dart';
export 'project_role.dart';
export 'public_document.dart';
export 'published_document.dart';
export 'user.dart';

class Protocol extends _i1.DatabaseSerializationManager {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._();

  static final List<_i2.TableDefinition> targetTableDefinitions = [
    _i2.TableDefinition(
      name: 'api_tokens',
      dartName: 'ApiToken',
      schema: 'public',
      module: 'dart_desk',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
          columnDefault: 'random',
        ),
        _i2.ColumnDefinition(
          name: 'projectId',
          columnType: _i2.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _i2.ColumnDefinition(
          name: 'name',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'tokenHash',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'tokenPrefix',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'tokenSuffix',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'role',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'createdByUserId',
          columnType: _i2.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _i2.ColumnDefinition(
          name: 'lastUsedAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _i2.ColumnDefinition(
          name: 'expiresAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _i2.ColumnDefinition(
          name: 'isActive',
          columnType: _i2.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
          columnDefault: 'true',
        ),
        _i2.ColumnDefinition(
          name: 'createdAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
          columnDefault: 'now',
        ),
      ],
      foreignKeys: [
        _i2.ForeignKeyDefinition(
          constraintName: 'api_tokens_fk_0',
          columns: ['projectId'],
          referenceTable: 'projects',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _i2.ForeignKeyAction.noAction,
          onDelete: _i2.ForeignKeyAction.cascade,
          matchType: null,
        ),
        _i2.ForeignKeyDefinition(
          constraintName: 'api_tokens_fk_1',
          columns: ['createdByUserId'],
          referenceTable: 'users',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _i2.ForeignKeyAction.noAction,
          onDelete: _i2.ForeignKeyAction.setNull,
          matchType: null,
        ),
      ],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'api_token_project_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'projectId',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
        _i2.IndexDefinition(
          indexName: 'api_token_lookup_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'projectId',
            ),
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'tokenPrefix',
            ),
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'tokenSuffix',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _i2.IndexDefinition(
          indexName: 'api_token_prefix_suffix_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'tokenPrefix',
            ),
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'tokenSuffix',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _i2.TableDefinition(
      name: 'clients',
      dartName: 'CmsClient',
      schema: 'public',
      module: 'dart_desk',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
          columnDefault: 'random',
        ),
        _i2.ColumnDefinition(
          name: 'name',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'slug',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'description',
          columnType: _i2.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _i2.ColumnDefinition(
          name: 'isActive',
          columnType: _i2.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
          columnDefault: 'true',
        ),
        _i2.ColumnDefinition(
          name: 'settings',
          columnType: _i2.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _i2.ColumnDefinition(
          name: 'createdAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
          columnDefault: 'now',
        ),
        _i2.ColumnDefinition(
          name: 'updatedAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
          columnDefault: 'now',
        ),
        _i2.ColumnDefinition(
          name: 'deletedAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'clients_slug_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'slug',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
        _i2.IndexDefinition(
          indexName: 'clients_is_active_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'isActive',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _i2.TableDefinition(
      name: 'deployments',
      dartName: 'Deployment',
      schema: 'public',
      module: 'dart_desk',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
          columnDefault: 'random',
        ),
        _i2.ColumnDefinition(
          name: 'projectId',
          columnType: _i2.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _i2.ColumnDefinition(
          name: 'version',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _i2.ColumnDefinition(
          name: 'status',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:DeploymentStatus',
        ),
        _i2.ColumnDefinition(
          name: 'filePath',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'fileSize',
          columnType: _i2.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
        _i2.ColumnDefinition(
          name: 'uploadedByUserId',
          columnType: _i2.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _i2.ColumnDefinition(
          name: 'commitHash',
          columnType: _i2.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _i2.ColumnDefinition(
          name: 'metadata',
          columnType: _i2.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _i2.ColumnDefinition(
          name: 'createdAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
          columnDefault: 'now',
        ),
        _i2.ColumnDefinition(
          name: 'updatedAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
          columnDefault: 'now',
        ),
      ],
      foreignKeys: [
        _i2.ForeignKeyDefinition(
          constraintName: 'deployments_fk_0',
          columns: ['projectId'],
          referenceTable: 'projects',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _i2.ForeignKeyAction.noAction,
          onDelete: _i2.ForeignKeyAction.restrict,
          matchType: null,
        ),
        _i2.ForeignKeyDefinition(
          constraintName: 'deployments_fk_1',
          columns: ['uploadedByUserId'],
          referenceTable: 'users',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _i2.ForeignKeyAction.noAction,
          onDelete: _i2.ForeignKeyAction.setNull,
          matchType: null,
        ),
      ],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'deployment_project_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'projectId',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
        _i2.IndexDefinition(
          indexName: 'deployment_project_version_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'projectId',
            ),
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'version',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _i2.IndexDefinition(
          indexName: 'deployment_project_status_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'projectId',
            ),
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'status',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _i2.TableDefinition(
      name: 'document_crdt_operations',
      dartName: 'DocumentCrdtOperation',
      schema: 'public',
      module: 'dart_desk',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
          columnDefault: 'random',
        ),
        _i2.ColumnDefinition(
          name: 'documentId',
          columnType: _i2.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _i2.ColumnDefinition(
          name: 'hlc',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'nodeId',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'operationType',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:CrdtOperationType',
        ),
        _i2.ColumnDefinition(
          name: 'fieldPath',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'fieldValue',
          columnType: _i2.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _i2.ColumnDefinition(
          name: 'createdAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
          columnDefault: 'now',
        ),
        _i2.ColumnDefinition(
          name: 'createdByUserId',
          columnType: _i2.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
      ],
      foreignKeys: [
        _i2.ForeignKeyDefinition(
          constraintName: 'document_crdt_operations_fk_0',
          columns: ['documentId'],
          referenceTable: 'documents',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _i2.ForeignKeyAction.noAction,
          onDelete: _i2.ForeignKeyAction.cascade,
          matchType: null,
        ),
        _i2.ForeignKeyDefinition(
          constraintName: 'document_crdt_operations_fk_1',
          columns: ['createdByUserId'],
          referenceTable: 'users',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _i2.ForeignKeyAction.noAction,
          onDelete: _i2.ForeignKeyAction.setNull,
          matchType: null,
        ),
      ],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'document_crdt_operations_document_hlc_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'documentId',
            ),
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'hlc',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
        _i2.IndexDefinition(
          indexName: 'document_crdt_operations_document_id_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'documentId',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
        _i2.IndexDefinition(
          indexName: 'document_crdt_operations_created_at_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'createdAt',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _i2.TableDefinition(
      name: 'document_crdt_snapshots',
      dartName: 'DocumentCrdtSnapshot',
      schema: 'public',
      module: 'dart_desk',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
          columnDefault: 'random',
        ),
        _i2.ColumnDefinition(
          name: 'documentId',
          columnType: _i2.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _i2.ColumnDefinition(
          name: 'snapshotHlc',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'snapshotData',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'operationCountAtSnapshot',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _i2.ColumnDefinition(
          name: 'createdAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
          columnDefault: 'now',
        ),
      ],
      foreignKeys: [
        _i2.ForeignKeyDefinition(
          constraintName: 'document_crdt_snapshots_fk_0',
          columns: ['documentId'],
          referenceTable: 'documents',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _i2.ForeignKeyAction.noAction,
          onDelete: _i2.ForeignKeyAction.cascade,
          matchType: null,
        ),
      ],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'document_crdt_snapshots_document_hlc_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'documentId',
            ),
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'snapshotHlc',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _i2.IndexDefinition(
          indexName: 'document_crdt_snapshots_document_id_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'documentId',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _i2.TableDefinition(
      name: 'document_versions',
      dartName: 'DocumentVersion',
      schema: 'public',
      module: 'dart_desk',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
          columnDefault: 'random',
        ),
        _i2.ColumnDefinition(
          name: 'documentId',
          columnType: _i2.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _i2.ColumnDefinition(
          name: 'versionNumber',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _i2.ColumnDefinition(
          name: 'status',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:DocumentVersionStatus',
        ),
        _i2.ColumnDefinition(
          name: 'snapshotHlc',
          columnType: _i2.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _i2.ColumnDefinition(
          name: 'operationCount',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
          columnDefault: '0',
        ),
        _i2.ColumnDefinition(
          name: 'changeLog',
          columnType: _i2.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _i2.ColumnDefinition(
          name: 'publishedAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _i2.ColumnDefinition(
          name: 'scheduledAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _i2.ColumnDefinition(
          name: 'archivedAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _i2.ColumnDefinition(
          name: 'createdAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
          columnDefault: 'now',
        ),
        _i2.ColumnDefinition(
          name: 'createdByUserId',
          columnType: _i2.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _i2.ColumnDefinition(
          name: 'updatedByUserId',
          columnType: _i2.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _i2.ColumnDefinition(
          name: 'deletedAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
      ],
      foreignKeys: [
        _i2.ForeignKeyDefinition(
          constraintName: 'document_versions_fk_0',
          columns: ['documentId'],
          referenceTable: 'documents',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _i2.ForeignKeyAction.noAction,
          onDelete: _i2.ForeignKeyAction.cascade,
          matchType: null,
        ),
        _i2.ForeignKeyDefinition(
          constraintName: 'document_versions_fk_1',
          columns: ['createdByUserId'],
          referenceTable: 'users',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _i2.ForeignKeyAction.noAction,
          onDelete: _i2.ForeignKeyAction.setNull,
          matchType: null,
        ),
        _i2.ForeignKeyDefinition(
          constraintName: 'document_versions_fk_2',
          columns: ['updatedByUserId'],
          referenceTable: 'users',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _i2.ForeignKeyAction.noAction,
          onDelete: _i2.ForeignKeyAction.setNull,
          matchType: null,
        ),
      ],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'document_versions_document_id_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'documentId',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
        _i2.IndexDefinition(
          indexName: 'document_versions_document_version_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'documentId',
            ),
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'versionNumber',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _i2.IndexDefinition(
          indexName: 'document_versions_snapshot_hlc_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'documentId',
            ),
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'snapshotHlc',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
        _i2.IndexDefinition(
          indexName: 'document_versions_status_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'status',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
        _i2.IndexDefinition(
          indexName: 'document_versions_published_at_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'publishedAt',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
        _i2.IndexDefinition(
          indexName: 'document_versions_scheduled_at_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'scheduledAt',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
        _i2.IndexDefinition(
          indexName: 'document_versions_created_at_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'createdAt',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _i2.TableDefinition(
      name: 'documents',
      dartName: 'Document',
      schema: 'public',
      module: 'dart_desk',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
          columnDefault: 'random',
        ),
        _i2.ColumnDefinition(
          name: 'projectId',
          columnType: _i2.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _i2.ColumnDefinition(
          name: 'documentType',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'title',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'slug',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'isDefault',
          columnType: _i2.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
          columnDefault: 'false',
        ),
        _i2.ColumnDefinition(
          name: 'data',
          columnType: _i2.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _i2.ColumnDefinition(
          name: 'crdtNodeId',
          columnType: _i2.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _i2.ColumnDefinition(
          name: 'crdtHlc',
          columnType: _i2.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _i2.ColumnDefinition(
          name: 'publishedAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _i2.ColumnDefinition(
          name: 'createdAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
          columnDefault: 'now',
        ),
        _i2.ColumnDefinition(
          name: 'updatedAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
          columnDefault: 'now',
        ),
        _i2.ColumnDefinition(
          name: 'createdByUserId',
          columnType: _i2.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _i2.ColumnDefinition(
          name: 'updatedByUserId',
          columnType: _i2.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _i2.ColumnDefinition(
          name: 'deletedAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
      ],
      foreignKeys: [
        _i2.ForeignKeyDefinition(
          constraintName: 'documents_fk_0',
          columns: ['projectId'],
          referenceTable: 'projects',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _i2.ForeignKeyAction.noAction,
          onDelete: _i2.ForeignKeyAction.cascade,
          matchType: null,
        ),
        _i2.ForeignKeyDefinition(
          constraintName: 'documents_fk_1',
          columns: ['createdByUserId'],
          referenceTable: 'users',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _i2.ForeignKeyAction.noAction,
          onDelete: _i2.ForeignKeyAction.setNull,
          matchType: null,
        ),
        _i2.ForeignKeyDefinition(
          constraintName: 'documents_fk_2',
          columns: ['updatedByUserId'],
          referenceTable: 'users',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _i2.ForeignKeyAction.noAction,
          onDelete: _i2.ForeignKeyAction.setNull,
          matchType: null,
        ),
      ],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'documents_project_type_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'projectId',
            ),
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'documentType',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
        _i2.IndexDefinition(
          indexName: 'documents_project_type_slug_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'projectId',
            ),
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'documentType',
            ),
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'slug',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
        _i2.IndexDefinition(
          indexName: 'documents_type_default_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'documentType',
            ),
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'isDefault',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
        _i2.IndexDefinition(
          indexName: 'documents_created_at_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'createdAt',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
        _i2.IndexDefinition(
          indexName: 'documents_project_published_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'projectId',
            ),
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'publishedAt',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _i2.TableDefinition(
      name: 'documents_data',
      dartName: 'DocumentData',
      schema: 'public',
      module: 'dart_desk',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
          columnDefault: 'random',
        ),
        _i2.ColumnDefinition(
          name: 'documentType',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'data',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'createdAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
          columnDefault: 'now',
        ),
        _i2.ColumnDefinition(
          name: 'updatedAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
          columnDefault: 'now',
        ),
        _i2.ColumnDefinition(
          name: 'createdByUserId',
          columnType: _i2.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _i2.ColumnDefinition(
          name: 'updatedByUserId',
          columnType: _i2.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'documents_data_document_type_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'documentType',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
        _i2.IndexDefinition(
          indexName: 'documents_data_created_at_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'createdAt',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
        _i2.IndexDefinition(
          indexName: 'documents_data_updated_at_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'updatedAt',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _i2.TableDefinition(
      name: 'media_assets',
      dartName: 'MediaAsset',
      schema: 'public',
      module: 'dart_desk',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
          columnDefault: 'random',
        ),
        _i2.ColumnDefinition(
          name: 'projectId',
          columnType: _i2.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _i2.ColumnDefinition(
          name: 'assetId',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'fileName',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'mimeType',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'fileSize',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _i2.ColumnDefinition(
          name: 'storagePath',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'publicUrl',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'width',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _i2.ColumnDefinition(
          name: 'height',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _i2.ColumnDefinition(
          name: 'hasAlpha',
          columnType: _i2.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
        ),
        _i2.ColumnDefinition(
          name: 'blurHash',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'lqip',
          columnType: _i2.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _i2.ColumnDefinition(
          name: 'paletteJson',
          columnType: _i2.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _i2.ColumnDefinition(
          name: 'exifJson',
          columnType: _i2.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _i2.ColumnDefinition(
          name: 'locationLat',
          columnType: _i2.ColumnType.doublePrecision,
          isNullable: true,
          dartType: 'double?',
        ),
        _i2.ColumnDefinition(
          name: 'locationLng',
          columnType: _i2.ColumnType.doublePrecision,
          isNullable: true,
          dartType: 'double?',
        ),
        _i2.ColumnDefinition(
          name: 'uploadedByUserId',
          columnType: _i2.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _i2.ColumnDefinition(
          name: 'updatedByUserId',
          columnType: _i2.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _i2.ColumnDefinition(
          name: 'createdAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
          columnDefault: 'now',
        ),
        _i2.ColumnDefinition(
          name: 'metadataStatus',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:MediaAssetMetadataStatus',
        ),
      ],
      foreignKeys: [
        _i2.ForeignKeyDefinition(
          constraintName: 'media_assets_fk_0',
          columns: ['projectId'],
          referenceTable: 'projects',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _i2.ForeignKeyAction.noAction,
          onDelete: _i2.ForeignKeyAction.cascade,
          matchType: null,
        ),
      ],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'media_asset_project_id_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'projectId',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
        _i2.IndexDefinition(
          indexName: 'media_asset_asset_id_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'assetId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _i2.IndexDefinition(
          indexName: 'media_asset_file_name_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'fileName',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
        _i2.IndexDefinition(
          indexName: 'media_asset_mime_type_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'mimeType',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _i2.TableDefinition(
      name: 'migration_history',
      dartName: 'MigrationHistory',
      schema: 'public',
      module: 'dart_desk',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
          columnDefault: 'random',
        ),
        _i2.ColumnDefinition(
          name: 'projectId',
          columnType: _i2.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _i2.ColumnDefinition(
          name: 'name',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'documentType',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'appliedAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
        _i2.ColumnDefinition(
          name: 'operationsJson',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'report',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
      ],
      foreignKeys: [
        _i2.ForeignKeyDefinition(
          constraintName: 'migration_history_fk_0',
          columns: ['projectId'],
          referenceTable: 'projects',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _i2.ForeignKeyAction.noAction,
          onDelete: _i2.ForeignKeyAction.cascade,
          matchType: null,
        ),
      ],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'migration_history_project_name_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'projectId',
            ),
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'name',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _i2.TableDefinition(
      name: 'project_members',
      dartName: 'ProjectMember',
      schema: 'public',
      module: 'dart_desk',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
          columnDefault: 'random',
        ),
        _i2.ColumnDefinition(
          name: 'userId',
          columnType: _i2.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _i2.ColumnDefinition(
          name: 'projectId',
          columnType: _i2.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _i2.ColumnDefinition(
          name: 'role',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:ProjectRole',
        ),
        _i2.ColumnDefinition(
          name: 'createdAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
          columnDefault: 'now',
        ),
      ],
      foreignKeys: [
        _i2.ForeignKeyDefinition(
          constraintName: 'project_members_fk_0',
          columns: ['userId'],
          referenceTable: 'users',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _i2.ForeignKeyAction.noAction,
          onDelete: _i2.ForeignKeyAction.cascade,
          matchType: null,
        ),
        _i2.ForeignKeyDefinition(
          constraintName: 'project_members_fk_1',
          columns: ['projectId'],
          referenceTable: 'projects',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _i2.ForeignKeyAction.noAction,
          onDelete: _i2.ForeignKeyAction.cascade,
          matchType: null,
        ),
      ],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'project_member_unique',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'userId',
            ),
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'projectId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _i2.IndexDefinition(
          indexName: 'project_member_project_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'projectId',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _i2.TableDefinition(
      name: 'projects',
      dartName: 'Project',
      schema: 'public',
      module: 'dart_desk',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
          columnDefault: 'random',
        ),
        _i2.ColumnDefinition(
          name: 'clientId',
          columnType: _i2.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _i2.ColumnDefinition(
          name: 'name',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'slug',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'description',
          columnType: _i2.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _i2.ColumnDefinition(
          name: 'isActive',
          columnType: _i2.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
          columnDefault: 'true',
        ),
        _i2.ColumnDefinition(
          name: 'settings',
          columnType: _i2.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _i2.ColumnDefinition(
          name: 'createdAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
          columnDefault: 'now',
        ),
        _i2.ColumnDefinition(
          name: 'updatedAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
          columnDefault: 'now',
        ),
        _i2.ColumnDefinition(
          name: 'createdByUserId',
          columnType: _i2.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _i2.ColumnDefinition(
          name: 'updatedByUserId',
          columnType: _i2.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _i2.ColumnDefinition(
          name: 'deletedAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
      ],
      foreignKeys: [
        _i2.ForeignKeyDefinition(
          constraintName: 'projects_fk_0',
          columns: ['clientId'],
          referenceTable: 'clients',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _i2.ForeignKeyAction.noAction,
          onDelete: _i2.ForeignKeyAction.cascade,
          matchType: null,
        ),
        _i2.ForeignKeyDefinition(
          constraintName: 'projects_fk_1',
          columns: ['createdByUserId'],
          referenceTable: 'users',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _i2.ForeignKeyAction.noAction,
          onDelete: _i2.ForeignKeyAction.setNull,
          matchType: null,
        ),
        _i2.ForeignKeyDefinition(
          constraintName: 'projects_fk_2',
          columns: ['updatedByUserId'],
          referenceTable: 'users',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _i2.ForeignKeyAction.noAction,
          onDelete: _i2.ForeignKeyAction.setNull,
          matchType: null,
        ),
      ],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'projects_client_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'clientId',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
        _i2.IndexDefinition(
          indexName: 'projects_slug_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'slug',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
        _i2.IndexDefinition(
          indexName: 'projects_is_active_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'isActive',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _i2.TableDefinition(
      name: 'published_documents',
      dartName: 'PublishedDocument',
      schema: 'public',
      module: 'dart_desk',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
          columnDefault: 'random',
        ),
        _i2.ColumnDefinition(
          name: 'documentId',
          columnType: _i2.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _i2.ColumnDefinition(
          name: 'projectId',
          columnType: _i2.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _i2.ColumnDefinition(
          name: 'documentType',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'title',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'slug',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'isDefault',
          columnType: _i2.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
          columnDefault: 'false',
        ),
        _i2.ColumnDefinition(
          name: 'data',
          columnType: _i2.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _i2.ColumnDefinition(
          name: 'publishedAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _i2.ColumnDefinition(
          name: 'publishedVersionId',
          columnType: _i2.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _i2.ColumnDefinition(
          name: 'updatedAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
          columnDefault: 'now',
        ),
        _i2.ColumnDefinition(
          name: 'deletedAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
      ],
      foreignKeys: [
        _i2.ForeignKeyDefinition(
          constraintName: 'published_documents_fk_0',
          columns: ['documentId'],
          referenceTable: 'documents',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _i2.ForeignKeyAction.noAction,
          onDelete: _i2.ForeignKeyAction.cascade,
          matchType: null,
        ),
        _i2.ForeignKeyDefinition(
          constraintName: 'published_documents_fk_1',
          columns: ['projectId'],
          referenceTable: 'projects',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _i2.ForeignKeyAction.noAction,
          onDelete: _i2.ForeignKeyAction.cascade,
          matchType: null,
        ),
        _i2.ForeignKeyDefinition(
          constraintName: 'published_documents_fk_2',
          columns: ['publishedVersionId'],
          referenceTable: 'document_versions',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _i2.ForeignKeyAction.noAction,
          onDelete: _i2.ForeignKeyAction.restrict,
          matchType: null,
        ),
      ],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'published_docs_document_id_unique_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'documentId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _i2.IndexDefinition(
          indexName: 'published_docs_project_type_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'projectId',
            ),
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'documentType',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
        _i2.IndexDefinition(
          indexName: 'published_docs_project_type_slug_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'projectId',
            ),
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'documentType',
            ),
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'slug',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
        _i2.IndexDefinition(
          indexName: 'published_docs_type_default_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'documentType',
            ),
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'isDefault',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _i2.TableDefinition(
      name: 'users',
      dartName: 'User',
      schema: 'public',
      module: 'dart_desk',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
          columnDefault: 'random',
        ),
        _i2.ColumnDefinition(
          name: 'clientId',
          columnType: _i2.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _i2.ColumnDefinition(
          name: 'email',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'name',
          columnType: _i2.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _i2.ColumnDefinition(
          name: 'role',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:ClientRole',
          columnDefault: '\'viewer\'',
        ),
        _i2.ColumnDefinition(
          name: 'isActive',
          columnType: _i2.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
          columnDefault: 'true',
        ),
        _i2.ColumnDefinition(
          name: 'serverpodUserId',
          columnType: _i2.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _i2.ColumnDefinition(
          name: 'createdAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
          columnDefault: 'now',
        ),
        _i2.ColumnDefinition(
          name: 'updatedAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
          columnDefault: 'now',
        ),
        _i2.ColumnDefinition(
          name: 'deletedAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'users_client_email_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'clientId',
            ),
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'email',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
        _i2.IndexDefinition(
          indexName: 'users_client_id_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'clientId',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
        _i2.IndexDefinition(
          indexName: 'users_serverpod_user_id_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'serverpodUserId',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
        _i2.IndexDefinition(
          indexName: 'users_is_active_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'isActive',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    ..._i3.Protocol.targetTableDefinitions,
    ..._i4.Protocol.targetTableDefinitions,
    ..._i2.Protocol.targetTableDefinitions,
  ];

  static String? getClassNameFromObjectJson(dynamic data) {
    if (data is! Map) return null;
    final className = data['__className__'] as String?;
    return className;
  }

  @override
  T deserialize<T>(
    dynamic data, [
    Type? t,
  ]) {
    t ??= T;

    final dataClassName = getClassNameFromObjectJson(data);
    if (dataClassName != null && dataClassName != getClassNameForType(t)) {
      try {
        return deserializeByClassName({
          'className': dataClassName,
          'data': data,
        });
      } on FormatException catch (_) {
        // If the className is not recognized (e.g., older client receiving
        // data with a new subtype), fall back to deserializing without the
        // className, using the expected type T.
      }
    }

    if (t == _i5.ApiException) {
      return _i5.ApiException.fromJson(data) as T;
    }
    if (t == _i6.ApiToken) {
      return _i6.ApiToken.fromJson(data) as T;
    }
    if (t == _i7.ApiTokenWithValue) {
      return _i7.ApiTokenWithValue.fromJson(data) as T;
    }
    if (t == _i8.ClientRole) {
      return _i8.ClientRole.fromJson(data) as T;
    }
    if (t == _i9.ClientWithRole) {
      return _i9.ClientWithRole.fromJson(data) as T;
    }
    if (t == _i10.CmsClient) {
      return _i10.CmsClient.fromJson(data) as T;
    }
    if (t == _i11.CrdtOperationType) {
      return _i11.CrdtOperationType.fromJson(data) as T;
    }
    if (t == _i12.Deployment) {
      return _i12.Deployment.fromJson(data) as T;
    }
    if (t == _i13.DeploymentStatus) {
      return _i13.DeploymentStatus.fromJson(data) as T;
    }
    if (t == _i14.Document) {
      return _i14.Document.fromJson(data) as T;
    }
    if (t == _i15.DocumentCrdtOperation) {
      return _i15.DocumentCrdtOperation.fromJson(data) as T;
    }
    if (t == _i16.DocumentCrdtSnapshot) {
      return _i16.DocumentCrdtSnapshot.fromJson(data) as T;
    }
    if (t == _i17.DocumentData) {
      return _i17.DocumentData.fromJson(data) as T;
    }
    if (t == _i18.DocumentVersion) {
      return _i18.DocumentVersion.fromJson(data) as T;
    }
    if (t == _i19.DocumentVersionListWithOperations) {
      return _i19.DocumentVersionListWithOperations.fromJson(data) as T;
    }
    if (t == _i20.DocumentVersionStatus) {
      return _i20.DocumentVersionStatus.fromJson(data) as T;
    }
    if (t == _i21.DocumentVersionWithOperations) {
      return _i21.DocumentVersionWithOperations.fromJson(data) as T;
    }
    if (t == _i22.MediaAsset) {
      return _i22.MediaAsset.fromJson(data) as T;
    }
    if (t == _i23.MediaAssetMetadataStatus) {
      return _i23.MediaAssetMetadataStatus.fromJson(data) as T;
    }
    if (t == _i24.MigrationHistory) {
      return _i24.MigrationHistory.fromJson(data) as T;
    }
    if (t == _i25.PaginatedApiTokens) {
      return _i25.PaginatedApiTokens.fromJson(data) as T;
    }
    if (t == _i26.PaginatedDocumentVersions) {
      return _i26.PaginatedDocumentVersions.fromJson(data) as T;
    }
    if (t == _i27.PaginatedDocuments) {
      return _i27.PaginatedDocuments.fromJson(data) as T;
    }
    if (t == _i28.PaginatedMediaAssets) {
      return _i28.PaginatedMediaAssets.fromJson(data) as T;
    }
    if (t == _i29.PaginatedMigrationHistories) {
      return _i29.PaginatedMigrationHistories.fromJson(data) as T;
    }
    if (t == _i30.PaginatedProjects) {
      return _i30.PaginatedProjects.fromJson(data) as T;
    }
    if (t == _i31.PaginatedUsers) {
      return _i31.PaginatedUsers.fromJson(data) as T;
    }
    if (t == _i32.Project) {
      return _i32.Project.fromJson(data) as T;
    }
    if (t == _i33.ProjectMember) {
      return _i33.ProjectMember.fromJson(data) as T;
    }
    if (t == _i34.ProjectRole) {
      return _i34.ProjectRole.fromJson(data) as T;
    }
    if (t == _i35.PublicDocument) {
      return _i35.PublicDocument.fromJson(data) as T;
    }
    if (t == _i36.PublishedDocument) {
      return _i36.PublishedDocument.fromJson(data) as T;
    }
    if (t == _i37.User) {
      return _i37.User.fromJson(data) as T;
    }
    if (t == _i1.getType<_i5.ApiException?>()) {
      return (data != null ? _i5.ApiException.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i6.ApiToken?>()) {
      return (data != null ? _i6.ApiToken.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i7.ApiTokenWithValue?>()) {
      return (data != null ? _i7.ApiTokenWithValue.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i8.ClientRole?>()) {
      return (data != null ? _i8.ClientRole.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i9.ClientWithRole?>()) {
      return (data != null ? _i9.ClientWithRole.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i10.CmsClient?>()) {
      return (data != null ? _i10.CmsClient.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i11.CrdtOperationType?>()) {
      return (data != null ? _i11.CrdtOperationType.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i12.Deployment?>()) {
      return (data != null ? _i12.Deployment.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i13.DeploymentStatus?>()) {
      return (data != null ? _i13.DeploymentStatus.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i14.Document?>()) {
      return (data != null ? _i14.Document.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i15.DocumentCrdtOperation?>()) {
      return (data != null ? _i15.DocumentCrdtOperation.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i16.DocumentCrdtSnapshot?>()) {
      return (data != null ? _i16.DocumentCrdtSnapshot.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i17.DocumentData?>()) {
      return (data != null ? _i17.DocumentData.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i18.DocumentVersion?>()) {
      return (data != null ? _i18.DocumentVersion.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i19.DocumentVersionListWithOperations?>()) {
      return (data != null
              ? _i19.DocumentVersionListWithOperations.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i20.DocumentVersionStatus?>()) {
      return (data != null ? _i20.DocumentVersionStatus.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i21.DocumentVersionWithOperations?>()) {
      return (data != null
              ? _i21.DocumentVersionWithOperations.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i22.MediaAsset?>()) {
      return (data != null ? _i22.MediaAsset.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i23.MediaAssetMetadataStatus?>()) {
      return (data != null
              ? _i23.MediaAssetMetadataStatus.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i24.MigrationHistory?>()) {
      return (data != null ? _i24.MigrationHistory.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i25.PaginatedApiTokens?>()) {
      return (data != null ? _i25.PaginatedApiTokens.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i26.PaginatedDocumentVersions?>()) {
      return (data != null
              ? _i26.PaginatedDocumentVersions.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i27.PaginatedDocuments?>()) {
      return (data != null ? _i27.PaginatedDocuments.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i28.PaginatedMediaAssets?>()) {
      return (data != null ? _i28.PaginatedMediaAssets.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i29.PaginatedMigrationHistories?>()) {
      return (data != null
              ? _i29.PaginatedMigrationHistories.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i30.PaginatedProjects?>()) {
      return (data != null ? _i30.PaginatedProjects.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i31.PaginatedUsers?>()) {
      return (data != null ? _i31.PaginatedUsers.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i32.Project?>()) {
      return (data != null ? _i32.Project.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i33.ProjectMember?>()) {
      return (data != null ? _i33.ProjectMember.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i34.ProjectRole?>()) {
      return (data != null ? _i34.ProjectRole.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i35.PublicDocument?>()) {
      return (data != null ? _i35.PublicDocument.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i36.PublishedDocument?>()) {
      return (data != null ? _i36.PublishedDocument.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i37.User?>()) {
      return (data != null ? _i37.User.fromJson(data) : null) as T;
    }
    if (t == List<_i21.DocumentVersionWithOperations>) {
      return (data as List)
              .map((e) => deserialize<_i21.DocumentVersionWithOperations>(e))
              .toList()
          as T;
    }
    if (t == List<_i15.DocumentCrdtOperation>) {
      return (data as List)
              .map((e) => deserialize<_i15.DocumentCrdtOperation>(e))
              .toList()
          as T;
    }
    if (t == List<_i6.ApiToken>) {
      return (data as List).map((e) => deserialize<_i6.ApiToken>(e)).toList()
          as T;
    }
    if (t == List<_i18.DocumentVersion>) {
      return (data as List)
              .map((e) => deserialize<_i18.DocumentVersion>(e))
              .toList()
          as T;
    }
    if (t == List<_i14.Document>) {
      return (data as List).map((e) => deserialize<_i14.Document>(e)).toList()
          as T;
    }
    if (t == List<_i22.MediaAsset>) {
      return (data as List).map((e) => deserialize<_i22.MediaAsset>(e)).toList()
          as T;
    }
    if (t == List<_i24.MigrationHistory>) {
      return (data as List)
              .map((e) => deserialize<_i24.MigrationHistory>(e))
              .toList()
          as T;
    }
    if (t == List<_i32.Project>) {
      return (data as List).map((e) => deserialize<_i32.Project>(e)).toList()
          as T;
    }
    if (t == List<_i37.User>) {
      return (data as List).map((e) => deserialize<_i37.User>(e)).toList() as T;
    }
    if (t == List<_i38.ClientWithRole>) {
      return (data as List)
              .map((e) => deserialize<_i38.ClientWithRole>(e))
              .toList()
          as T;
    }
    if (t == List<_i39.ApiToken>) {
      return (data as List).map((e) => deserialize<_i39.ApiToken>(e)).toList()
          as T;
    }
    if (t == List<_i40.Deployment>) {
      return (data as List).map((e) => deserialize<_i40.Deployment>(e)).toList()
          as T;
    }
    if (t == List<_i41.DocumentCrdtOperation>) {
      return (data as List)
              .map((e) => deserialize<_i41.DocumentCrdtOperation>(e))
              .toList()
          as T;
    }
    if (t == List<String>) {
      return (data as List).map((e) => deserialize<String>(e)).toList() as T;
    }
    if (t == List<_i42.MediaAsset>) {
      return (data as List).map((e) => deserialize<_i42.MediaAsset>(e)).toList()
          as T;
    }
    if (t == List<_i43.User>) {
      return (data as List).map((e) => deserialize<_i43.User>(e)).toList() as T;
    }
    if (t == List<_i44.MigrationHistory>) {
      return (data as List)
              .map((e) => deserialize<_i44.MigrationHistory>(e))
              .toList()
          as T;
    }
    if (t == List<_i45.ProjectMember>) {
      return (data as List)
              .map((e) => deserialize<_i45.ProjectMember>(e))
              .toList()
          as T;
    }
    if (t == Map<String, List<_i46.PublicDocument>>) {
      return (data as Map).map(
            (k, v) => MapEntry(
              deserialize<String>(k),
              deserialize<List<_i46.PublicDocument>>(v),
            ),
          )
          as T;
    }
    if (t == List<_i46.PublicDocument>) {
      return (data as List)
              .map((e) => deserialize<_i46.PublicDocument>(e))
              .toList()
          as T;
    }
    if (t == Map<String, _i46.PublicDocument>) {
      return (data as Map).map(
            (k, v) => MapEntry(
              deserialize<String>(k),
              deserialize<_i46.PublicDocument>(v),
            ),
          )
          as T;
    }
    try {
      return _i3.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _i4.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _i2.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _i5.ApiException => 'ApiException',
      _i6.ApiToken => 'ApiToken',
      _i7.ApiTokenWithValue => 'ApiTokenWithValue',
      _i8.ClientRole => 'ClientRole',
      _i9.ClientWithRole => 'ClientWithRole',
      _i10.CmsClient => 'CmsClient',
      _i11.CrdtOperationType => 'CrdtOperationType',
      _i12.Deployment => 'Deployment',
      _i13.DeploymentStatus => 'DeploymentStatus',
      _i14.Document => 'Document',
      _i15.DocumentCrdtOperation => 'DocumentCrdtOperation',
      _i16.DocumentCrdtSnapshot => 'DocumentCrdtSnapshot',
      _i17.DocumentData => 'DocumentData',
      _i18.DocumentVersion => 'DocumentVersion',
      _i19.DocumentVersionListWithOperations =>
        'DocumentVersionListWithOperations',
      _i20.DocumentVersionStatus => 'DocumentVersionStatus',
      _i21.DocumentVersionWithOperations => 'DocumentVersionWithOperations',
      _i22.MediaAsset => 'MediaAsset',
      _i23.MediaAssetMetadataStatus => 'MediaAssetMetadataStatus',
      _i24.MigrationHistory => 'MigrationHistory',
      _i25.PaginatedApiTokens => 'PaginatedApiTokens',
      _i26.PaginatedDocumentVersions => 'PaginatedDocumentVersions',
      _i27.PaginatedDocuments => 'PaginatedDocuments',
      _i28.PaginatedMediaAssets => 'PaginatedMediaAssets',
      _i29.PaginatedMigrationHistories => 'PaginatedMigrationHistories',
      _i30.PaginatedProjects => 'PaginatedProjects',
      _i31.PaginatedUsers => 'PaginatedUsers',
      _i32.Project => 'Project',
      _i33.ProjectMember => 'ProjectMember',
      _i34.ProjectRole => 'ProjectRole',
      _i35.PublicDocument => 'PublicDocument',
      _i36.PublishedDocument => 'PublishedDocument',
      _i37.User => 'User',
      _ => null,
    };
  }

  @override
  String? getClassNameForObject(Object? data) {
    String? className = super.getClassNameForObject(data);
    if (className != null) return className;

    if (data is Map<String, dynamic> && data['__className__'] is String) {
      return (data['__className__'] as String).replaceFirst('dart_desk.', '');
    }

    switch (data) {
      case _i5.ApiException():
        return 'ApiException';
      case _i6.ApiToken():
        return 'ApiToken';
      case _i7.ApiTokenWithValue():
        return 'ApiTokenWithValue';
      case _i8.ClientRole():
        return 'ClientRole';
      case _i9.ClientWithRole():
        return 'ClientWithRole';
      case _i10.CmsClient():
        return 'CmsClient';
      case _i11.CrdtOperationType():
        return 'CrdtOperationType';
      case _i12.Deployment():
        return 'Deployment';
      case _i13.DeploymentStatus():
        return 'DeploymentStatus';
      case _i14.Document():
        return 'Document';
      case _i15.DocumentCrdtOperation():
        return 'DocumentCrdtOperation';
      case _i16.DocumentCrdtSnapshot():
        return 'DocumentCrdtSnapshot';
      case _i17.DocumentData():
        return 'DocumentData';
      case _i18.DocumentVersion():
        return 'DocumentVersion';
      case _i19.DocumentVersionListWithOperations():
        return 'DocumentVersionListWithOperations';
      case _i20.DocumentVersionStatus():
        return 'DocumentVersionStatus';
      case _i21.DocumentVersionWithOperations():
        return 'DocumentVersionWithOperations';
      case _i22.MediaAsset():
        return 'MediaAsset';
      case _i23.MediaAssetMetadataStatus():
        return 'MediaAssetMetadataStatus';
      case _i24.MigrationHistory():
        return 'MigrationHistory';
      case _i25.PaginatedApiTokens():
        return 'PaginatedApiTokens';
      case _i26.PaginatedDocumentVersions():
        return 'PaginatedDocumentVersions';
      case _i27.PaginatedDocuments():
        return 'PaginatedDocuments';
      case _i28.PaginatedMediaAssets():
        return 'PaginatedMediaAssets';
      case _i29.PaginatedMigrationHistories():
        return 'PaginatedMigrationHistories';
      case _i30.PaginatedProjects():
        return 'PaginatedProjects';
      case _i31.PaginatedUsers():
        return 'PaginatedUsers';
      case _i32.Project():
        return 'Project';
      case _i33.ProjectMember():
        return 'ProjectMember';
      case _i34.ProjectRole():
        return 'ProjectRole';
      case _i35.PublicDocument():
        return 'PublicDocument';
      case _i36.PublishedDocument():
        return 'PublishedDocument';
      case _i37.User():
        return 'User';
    }
    className = _i2.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod.$className';
    }
    className = _i3.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod_auth_core.$className';
    }
    className = _i4.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod_auth_idp.$className';
    }
    return null;
  }

  @override
  dynamic deserializeByClassName(Map<String, dynamic> data) {
    var dataClassName = data['className'];
    if (dataClassName is! String) {
      return super.deserializeByClassName(data);
    }
    if (dataClassName == 'ApiException') {
      return deserialize<_i5.ApiException>(data['data']);
    }
    if (dataClassName == 'ApiToken') {
      return deserialize<_i6.ApiToken>(data['data']);
    }
    if (dataClassName == 'ApiTokenWithValue') {
      return deserialize<_i7.ApiTokenWithValue>(data['data']);
    }
    if (dataClassName == 'ClientRole') {
      return deserialize<_i8.ClientRole>(data['data']);
    }
    if (dataClassName == 'ClientWithRole') {
      return deserialize<_i9.ClientWithRole>(data['data']);
    }
    if (dataClassName == 'CmsClient') {
      return deserialize<_i10.CmsClient>(data['data']);
    }
    if (dataClassName == 'CrdtOperationType') {
      return deserialize<_i11.CrdtOperationType>(data['data']);
    }
    if (dataClassName == 'Deployment') {
      return deserialize<_i12.Deployment>(data['data']);
    }
    if (dataClassName == 'DeploymentStatus') {
      return deserialize<_i13.DeploymentStatus>(data['data']);
    }
    if (dataClassName == 'Document') {
      return deserialize<_i14.Document>(data['data']);
    }
    if (dataClassName == 'DocumentCrdtOperation') {
      return deserialize<_i15.DocumentCrdtOperation>(data['data']);
    }
    if (dataClassName == 'DocumentCrdtSnapshot') {
      return deserialize<_i16.DocumentCrdtSnapshot>(data['data']);
    }
    if (dataClassName == 'DocumentData') {
      return deserialize<_i17.DocumentData>(data['data']);
    }
    if (dataClassName == 'DocumentVersion') {
      return deserialize<_i18.DocumentVersion>(data['data']);
    }
    if (dataClassName == 'DocumentVersionListWithOperations') {
      return deserialize<_i19.DocumentVersionListWithOperations>(data['data']);
    }
    if (dataClassName == 'DocumentVersionStatus') {
      return deserialize<_i20.DocumentVersionStatus>(data['data']);
    }
    if (dataClassName == 'DocumentVersionWithOperations') {
      return deserialize<_i21.DocumentVersionWithOperations>(data['data']);
    }
    if (dataClassName == 'MediaAsset') {
      return deserialize<_i22.MediaAsset>(data['data']);
    }
    if (dataClassName == 'MediaAssetMetadataStatus') {
      return deserialize<_i23.MediaAssetMetadataStatus>(data['data']);
    }
    if (dataClassName == 'MigrationHistory') {
      return deserialize<_i24.MigrationHistory>(data['data']);
    }
    if (dataClassName == 'PaginatedApiTokens') {
      return deserialize<_i25.PaginatedApiTokens>(data['data']);
    }
    if (dataClassName == 'PaginatedDocumentVersions') {
      return deserialize<_i26.PaginatedDocumentVersions>(data['data']);
    }
    if (dataClassName == 'PaginatedDocuments') {
      return deserialize<_i27.PaginatedDocuments>(data['data']);
    }
    if (dataClassName == 'PaginatedMediaAssets') {
      return deserialize<_i28.PaginatedMediaAssets>(data['data']);
    }
    if (dataClassName == 'PaginatedMigrationHistories') {
      return deserialize<_i29.PaginatedMigrationHistories>(data['data']);
    }
    if (dataClassName == 'PaginatedProjects') {
      return deserialize<_i30.PaginatedProjects>(data['data']);
    }
    if (dataClassName == 'PaginatedUsers') {
      return deserialize<_i31.PaginatedUsers>(data['data']);
    }
    if (dataClassName == 'Project') {
      return deserialize<_i32.Project>(data['data']);
    }
    if (dataClassName == 'ProjectMember') {
      return deserialize<_i33.ProjectMember>(data['data']);
    }
    if (dataClassName == 'ProjectRole') {
      return deserialize<_i34.ProjectRole>(data['data']);
    }
    if (dataClassName == 'PublicDocument') {
      return deserialize<_i35.PublicDocument>(data['data']);
    }
    if (dataClassName == 'PublishedDocument') {
      return deserialize<_i36.PublishedDocument>(data['data']);
    }
    if (dataClassName == 'User') {
      return deserialize<_i37.User>(data['data']);
    }
    if (dataClassName.startsWith('serverpod.')) {
      data['className'] = dataClassName.substring(10);
      return _i2.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_core.')) {
      data['className'] = dataClassName.substring(20);
      return _i3.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_idp.')) {
      data['className'] = dataClassName.substring(19);
      return _i4.Protocol().deserializeByClassName(data);
    }
    return super.deserializeByClassName(data);
  }

  @override
  _i1.Table? getTableForType(Type t) {
    {
      var table = _i3.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    {
      var table = _i4.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    {
      var table = _i2.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    switch (t) {
      case _i6.ApiToken:
        return _i6.ApiToken.t;
      case _i10.CmsClient:
        return _i10.CmsClient.t;
      case _i12.Deployment:
        return _i12.Deployment.t;
      case _i14.Document:
        return _i14.Document.t;
      case _i15.DocumentCrdtOperation:
        return _i15.DocumentCrdtOperation.t;
      case _i16.DocumentCrdtSnapshot:
        return _i16.DocumentCrdtSnapshot.t;
      case _i17.DocumentData:
        return _i17.DocumentData.t;
      case _i18.DocumentVersion:
        return _i18.DocumentVersion.t;
      case _i22.MediaAsset:
        return _i22.MediaAsset.t;
      case _i24.MigrationHistory:
        return _i24.MigrationHistory.t;
      case _i32.Project:
        return _i32.Project.t;
      case _i33.ProjectMember:
        return _i33.ProjectMember.t;
      case _i36.PublishedDocument:
        return _i36.PublishedDocument.t;
      case _i37.User:
        return _i37.User.t;
    }
    return null;
  }

  @override
  List<_i2.TableDefinition> getTargetTableDefinitions() =>
      targetTableDefinitions;

  @override
  String getModuleName() => 'dart_desk';

  /// Maps any `Record`s known to this [Protocol] to their JSON representation
  ///
  /// Throws in case the record type is not known.
  ///
  /// This method will return `null` (only) for `null` inputs.
  Map<String, dynamic>? mapRecordToJson(Record? record) {
    if (record == null) {
      return null;
    }
    try {
      return _i3.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _i4.Protocol().mapRecordToJson(record);
    } catch (_) {}
    throw Exception('Unsupported record type ${record.runtimeType}');
  }
}
