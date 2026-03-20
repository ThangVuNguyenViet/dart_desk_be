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
import 'deployment_status.dart' as _i2;

abstract class CmsDeployment
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  CmsDeployment._({
    this.id,
    required this.clientId,
    required this.version,
    required this.status,
    required this.filePath,
    this.fileSize,
    this.uploadedByUserId,
    this.commitHash,
    this.metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory CmsDeployment({
    int? id,
    required int clientId,
    required int version,
    required _i2.DeploymentStatus status,
    required String filePath,
    int? fileSize,
    int? uploadedByUserId,
    String? commitHash,
    String? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _CmsDeploymentImpl;

  factory CmsDeployment.fromJson(Map<String, dynamic> jsonSerialization) {
    return CmsDeployment(
      id: jsonSerialization['id'] as int?,
      clientId: jsonSerialization['clientId'] as int,
      version: jsonSerialization['version'] as int,
      status: _i2.DeploymentStatus.fromJson(
        (jsonSerialization['status'] as String),
      ),
      filePath: jsonSerialization['filePath'] as String,
      fileSize: jsonSerialization['fileSize'] as int?,
      uploadedByUserId: jsonSerialization['uploadedByUserId'] as int?,
      commitHash: jsonSerialization['commitHash'] as String?,
      metadata: jsonSerialization['metadata'] as String?,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
    );
  }

  static final t = CmsDeploymentTable();

  static const db = CmsDeploymentRepository._();

  @override
  int? id;

  int clientId;

  int version;

  _i2.DeploymentStatus status;

  String filePath;

  int? fileSize;

  int? uploadedByUserId;

  String? commitHash;

  String? metadata;

  DateTime? createdAt;

  DateTime? updatedAt;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [CmsDeployment]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  CmsDeployment copyWith({
    int? id,
    int? clientId,
    int? version,
    _i2.DeploymentStatus? status,
    String? filePath,
    int? fileSize,
    int? uploadedByUserId,
    String? commitHash,
    String? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'CmsDeployment',
      if (id != null) 'id': id,
      'clientId': clientId,
      'version': version,
      'status': status.toJson(),
      'filePath': filePath,
      if (fileSize != null) 'fileSize': fileSize,
      if (uploadedByUserId != null) 'uploadedByUserId': uploadedByUserId,
      if (commitHash != null) 'commitHash': commitHash,
      if (metadata != null) 'metadata': metadata,
      if (createdAt != null) 'createdAt': createdAt?.toJson(),
      if (updatedAt != null) 'updatedAt': updatedAt?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'CmsDeployment',
      if (id != null) 'id': id,
      'clientId': clientId,
      'version': version,
      'status': status.toJson(),
      'filePath': filePath,
      if (fileSize != null) 'fileSize': fileSize,
      if (uploadedByUserId != null) 'uploadedByUserId': uploadedByUserId,
      if (commitHash != null) 'commitHash': commitHash,
      if (metadata != null) 'metadata': metadata,
      if (createdAt != null) 'createdAt': createdAt?.toJson(),
      if (updatedAt != null) 'updatedAt': updatedAt?.toJson(),
    };
  }

  static CmsDeploymentInclude include() {
    return CmsDeploymentInclude._();
  }

  static CmsDeploymentIncludeList includeList({
    _i1.WhereExpressionBuilder<CmsDeploymentTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<CmsDeploymentTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<CmsDeploymentTable>? orderByList,
    CmsDeploymentInclude? include,
  }) {
    return CmsDeploymentIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CmsDeployment.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(CmsDeployment.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CmsDeploymentImpl extends CmsDeployment {
  _CmsDeploymentImpl({
    int? id,
    required int clientId,
    required int version,
    required _i2.DeploymentStatus status,
    required String filePath,
    int? fileSize,
    int? uploadedByUserId,
    String? commitHash,
    String? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : super._(
         id: id,
         clientId: clientId,
         version: version,
         status: status,
         filePath: filePath,
         fileSize: fileSize,
         uploadedByUserId: uploadedByUserId,
         commitHash: commitHash,
         metadata: metadata,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [CmsDeployment]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  CmsDeployment copyWith({
    Object? id = _Undefined,
    int? clientId,
    int? version,
    _i2.DeploymentStatus? status,
    String? filePath,
    Object? fileSize = _Undefined,
    Object? uploadedByUserId = _Undefined,
    Object? commitHash = _Undefined,
    Object? metadata = _Undefined,
    Object? createdAt = _Undefined,
    Object? updatedAt = _Undefined,
  }) {
    return CmsDeployment(
      id: id is int? ? id : this.id,
      clientId: clientId ?? this.clientId,
      version: version ?? this.version,
      status: status ?? this.status,
      filePath: filePath ?? this.filePath,
      fileSize: fileSize is int? ? fileSize : this.fileSize,
      uploadedByUserId: uploadedByUserId is int?
          ? uploadedByUserId
          : this.uploadedByUserId,
      commitHash: commitHash is String? ? commitHash : this.commitHash,
      metadata: metadata is String? ? metadata : this.metadata,
      createdAt: createdAt is DateTime? ? createdAt : this.createdAt,
      updatedAt: updatedAt is DateTime? ? updatedAt : this.updatedAt,
    );
  }
}

class CmsDeploymentUpdateTable extends _i1.UpdateTable<CmsDeploymentTable> {
  CmsDeploymentUpdateTable(super.table);

  _i1.ColumnValue<int, int> clientId(int value) => _i1.ColumnValue(
    table.clientId,
    value,
  );

  _i1.ColumnValue<int, int> version(int value) => _i1.ColumnValue(
    table.version,
    value,
  );

  _i1.ColumnValue<_i2.DeploymentStatus, _i2.DeploymentStatus> status(
    _i2.DeploymentStatus value,
  ) => _i1.ColumnValue(
    table.status,
    value,
  );

  _i1.ColumnValue<String, String> filePath(String value) => _i1.ColumnValue(
    table.filePath,
    value,
  );

  _i1.ColumnValue<int, int> fileSize(int? value) => _i1.ColumnValue(
    table.fileSize,
    value,
  );

  _i1.ColumnValue<int, int> uploadedByUserId(int? value) => _i1.ColumnValue(
    table.uploadedByUserId,
    value,
  );

  _i1.ColumnValue<String, String> commitHash(String? value) => _i1.ColumnValue(
    table.commitHash,
    value,
  );

  _i1.ColumnValue<String, String> metadata(String? value) => _i1.ColumnValue(
    table.metadata,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> createdAt(DateTime? value) =>
      _i1.ColumnValue(
        table.createdAt,
        value,
      );

  _i1.ColumnValue<DateTime, DateTime> updatedAt(DateTime? value) =>
      _i1.ColumnValue(
        table.updatedAt,
        value,
      );
}

class CmsDeploymentTable extends _i1.Table<int?> {
  CmsDeploymentTable({super.tableRelation})
    : super(tableName: 'cms_deployments') {
    updateTable = CmsDeploymentUpdateTable(this);
    clientId = _i1.ColumnInt(
      'clientId',
      this,
    );
    version = _i1.ColumnInt(
      'version',
      this,
    );
    status = _i1.ColumnEnum(
      'status',
      this,
      _i1.EnumSerialization.byName,
    );
    filePath = _i1.ColumnString(
      'filePath',
      this,
    );
    fileSize = _i1.ColumnInt(
      'fileSize',
      this,
    );
    uploadedByUserId = _i1.ColumnInt(
      'uploadedByUserId',
      this,
    );
    commitHash = _i1.ColumnString(
      'commitHash',
      this,
    );
    metadata = _i1.ColumnString(
      'metadata',
      this,
    );
    createdAt = _i1.ColumnDateTime(
      'createdAt',
      this,
      hasDefault: true,
    );
    updatedAt = _i1.ColumnDateTime(
      'updatedAt',
      this,
      hasDefault: true,
    );
  }

  late final CmsDeploymentUpdateTable updateTable;

  late final _i1.ColumnInt clientId;

  late final _i1.ColumnInt version;

  late final _i1.ColumnEnum<_i2.DeploymentStatus> status;

  late final _i1.ColumnString filePath;

  late final _i1.ColumnInt fileSize;

  late final _i1.ColumnInt uploadedByUserId;

  late final _i1.ColumnString commitHash;

  late final _i1.ColumnString metadata;

  late final _i1.ColumnDateTime createdAt;

  late final _i1.ColumnDateTime updatedAt;

  @override
  List<_i1.Column> get columns => [
    id,
    clientId,
    version,
    status,
    filePath,
    fileSize,
    uploadedByUserId,
    commitHash,
    metadata,
    createdAt,
    updatedAt,
  ];
}

class CmsDeploymentInclude extends _i1.IncludeObject {
  CmsDeploymentInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => CmsDeployment.t;
}

class CmsDeploymentIncludeList extends _i1.IncludeList {
  CmsDeploymentIncludeList._({
    _i1.WhereExpressionBuilder<CmsDeploymentTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(CmsDeployment.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => CmsDeployment.t;
}

class CmsDeploymentRepository {
  const CmsDeploymentRepository._();

  /// Returns a list of [CmsDeployment]s matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order of the items use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// The maximum number of items can be set by [limit]. If no limit is set,
  /// all items matching the query will be returned.
  ///
  /// [offset] defines how many items to skip, after which [limit] (or all)
  /// items are read from the database.
  ///
  /// ```dart
  /// var persons = await Persons.db.find(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.firstName,
  ///   limit: 100,
  /// );
  /// ```
  Future<List<CmsDeployment>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<CmsDeploymentTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<CmsDeploymentTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<CmsDeploymentTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<CmsDeployment>(
      where: where?.call(CmsDeployment.t),
      orderBy: orderBy?.call(CmsDeployment.t),
      orderByList: orderByList?.call(CmsDeployment.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [CmsDeployment] matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// [offset] defines how many items to skip, after which the next one will be picked.
  ///
  /// ```dart
  /// var youngestPerson = await Persons.db.findFirstRow(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.age,
  /// );
  /// ```
  Future<CmsDeployment?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<CmsDeploymentTable>? where,
    int? offset,
    _i1.OrderByBuilder<CmsDeploymentTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<CmsDeploymentTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<CmsDeployment>(
      where: where?.call(CmsDeployment.t),
      orderBy: orderBy?.call(CmsDeployment.t),
      orderByList: orderByList?.call(CmsDeployment.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [CmsDeployment] by its [id] or null if no such row exists.
  Future<CmsDeployment?> findById(
    _i1.DatabaseSession session,
    int id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<CmsDeployment>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [CmsDeployment]s in the list and returns the inserted rows.
  ///
  /// The returned [CmsDeployment]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<CmsDeployment>> insert(
    _i1.DatabaseSession session,
    List<CmsDeployment> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<CmsDeployment>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [CmsDeployment] and returns the inserted row.
  ///
  /// The returned [CmsDeployment] will have its `id` field set.
  Future<CmsDeployment> insertRow(
    _i1.DatabaseSession session,
    CmsDeployment row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<CmsDeployment>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [CmsDeployment]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<CmsDeployment>> update(
    _i1.DatabaseSession session,
    List<CmsDeployment> rows, {
    _i1.ColumnSelections<CmsDeploymentTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<CmsDeployment>(
      rows,
      columns: columns?.call(CmsDeployment.t),
      transaction: transaction,
    );
  }

  /// Updates a single [CmsDeployment]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<CmsDeployment> updateRow(
    _i1.DatabaseSession session,
    CmsDeployment row, {
    _i1.ColumnSelections<CmsDeploymentTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<CmsDeployment>(
      row,
      columns: columns?.call(CmsDeployment.t),
      transaction: transaction,
    );
  }

  /// Updates a single [CmsDeployment] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<CmsDeployment?> updateById(
    _i1.DatabaseSession session,
    int id, {
    required _i1.ColumnValueListBuilder<CmsDeploymentUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<CmsDeployment>(
      id,
      columnValues: columnValues(CmsDeployment.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [CmsDeployment]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<CmsDeployment>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<CmsDeploymentUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<CmsDeploymentTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<CmsDeploymentTable>? orderBy,
    _i1.OrderByListBuilder<CmsDeploymentTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<CmsDeployment>(
      columnValues: columnValues(CmsDeployment.t.updateTable),
      where: where(CmsDeployment.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CmsDeployment.t),
      orderByList: orderByList?.call(CmsDeployment.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [CmsDeployment]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<CmsDeployment>> delete(
    _i1.DatabaseSession session,
    List<CmsDeployment> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<CmsDeployment>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [CmsDeployment].
  Future<CmsDeployment> deleteRow(
    _i1.DatabaseSession session,
    CmsDeployment row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<CmsDeployment>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<CmsDeployment>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<CmsDeploymentTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<CmsDeployment>(
      where: where(CmsDeployment.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<CmsDeploymentTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<CmsDeployment>(
      where: where?.call(CmsDeployment.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [CmsDeployment] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<CmsDeploymentTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<CmsDeployment>(
      where: where(CmsDeployment.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
