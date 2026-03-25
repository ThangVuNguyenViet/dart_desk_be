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

abstract class Deployment
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  Deployment._({
    this.id,
    required this.projectId,
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

  factory Deployment({
    int? id,
    required int projectId,
    required int version,
    required _i2.DeploymentStatus status,
    required String filePath,
    int? fileSize,
    int? uploadedByUserId,
    String? commitHash,
    String? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _DeploymentImpl;

  factory Deployment.fromJson(Map<String, dynamic> jsonSerialization) {
    return Deployment(
      id: jsonSerialization['id'] as int?,
      projectId: jsonSerialization['projectId'] as int,
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

  static final t = DeploymentTable();

  static const db = DeploymentRepository._();

  @override
  int? id;

  int projectId;

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

  /// Returns a shallow copy of this [Deployment]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  Deployment copyWith({
    int? id,
    int? projectId,
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
      '__className__': 'Deployment',
      if (id != null) 'id': id,
      'projectId': projectId,
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
      '__className__': 'Deployment',
      if (id != null) 'id': id,
      'projectId': projectId,
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

  static DeploymentInclude include() {
    return DeploymentInclude._();
  }

  static DeploymentIncludeList includeList({
    _i1.WhereExpressionBuilder<DeploymentTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<DeploymentTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<DeploymentTable>? orderByList,
    DeploymentInclude? include,
  }) {
    return DeploymentIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Deployment.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(Deployment.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _DeploymentImpl extends Deployment {
  _DeploymentImpl({
    int? id,
    required int projectId,
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
         projectId: projectId,
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

  /// Returns a shallow copy of this [Deployment]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  Deployment copyWith({
    Object? id = _Undefined,
    int? projectId,
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
    return Deployment(
      id: id is int? ? id : this.id,
      projectId: projectId ?? this.projectId,
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

class DeploymentUpdateTable extends _i1.UpdateTable<DeploymentTable> {
  DeploymentUpdateTable(super.table);

  _i1.ColumnValue<int, int> projectId(int value) => _i1.ColumnValue(
    table.projectId,
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

class DeploymentTable extends _i1.Table<int?> {
  DeploymentTable({super.tableRelation}) : super(tableName: 'deployments') {
    updateTable = DeploymentUpdateTable(this);
    projectId = _i1.ColumnInt(
      'projectId',
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

  late final DeploymentUpdateTable updateTable;

  late final _i1.ColumnInt projectId;

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
    projectId,
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

class DeploymentInclude extends _i1.IncludeObject {
  DeploymentInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => Deployment.t;
}

class DeploymentIncludeList extends _i1.IncludeList {
  DeploymentIncludeList._({
    _i1.WhereExpressionBuilder<DeploymentTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(Deployment.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => Deployment.t;
}

class DeploymentRepository {
  const DeploymentRepository._();

  /// Returns a list of [Deployment]s matching the given query parameters.
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
  Future<List<Deployment>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<DeploymentTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<DeploymentTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<DeploymentTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<Deployment>(
      where: where?.call(Deployment.t),
      orderBy: orderBy?.call(Deployment.t),
      orderByList: orderByList?.call(Deployment.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [Deployment] matching the given query parameters.
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
  Future<Deployment?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<DeploymentTable>? where,
    int? offset,
    _i1.OrderByBuilder<DeploymentTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<DeploymentTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<Deployment>(
      where: where?.call(Deployment.t),
      orderBy: orderBy?.call(Deployment.t),
      orderByList: orderByList?.call(Deployment.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [Deployment] by its [id] or null if no such row exists.
  Future<Deployment?> findById(
    _i1.DatabaseSession session,
    int id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<Deployment>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [Deployment]s in the list and returns the inserted rows.
  ///
  /// The returned [Deployment]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<Deployment>> insert(
    _i1.DatabaseSession session,
    List<Deployment> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<Deployment>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [Deployment] and returns the inserted row.
  ///
  /// The returned [Deployment] will have its `id` field set.
  Future<Deployment> insertRow(
    _i1.DatabaseSession session,
    Deployment row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<Deployment>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [Deployment]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<Deployment>> update(
    _i1.DatabaseSession session,
    List<Deployment> rows, {
    _i1.ColumnSelections<DeploymentTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<Deployment>(
      rows,
      columns: columns?.call(Deployment.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Deployment]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<Deployment> updateRow(
    _i1.DatabaseSession session,
    Deployment row, {
    _i1.ColumnSelections<DeploymentTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<Deployment>(
      row,
      columns: columns?.call(Deployment.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Deployment] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<Deployment?> updateById(
    _i1.DatabaseSession session,
    int id, {
    required _i1.ColumnValueListBuilder<DeploymentUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<Deployment>(
      id,
      columnValues: columnValues(Deployment.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [Deployment]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<Deployment>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<DeploymentUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<DeploymentTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<DeploymentTable>? orderBy,
    _i1.OrderByListBuilder<DeploymentTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<Deployment>(
      columnValues: columnValues(Deployment.t.updateTable),
      where: where(Deployment.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Deployment.t),
      orderByList: orderByList?.call(Deployment.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [Deployment]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<Deployment>> delete(
    _i1.DatabaseSession session,
    List<Deployment> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<Deployment>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [Deployment].
  Future<Deployment> deleteRow(
    _i1.DatabaseSession session,
    Deployment row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<Deployment>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<Deployment>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<DeploymentTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<Deployment>(
      where: where(Deployment.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<DeploymentTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<Deployment>(
      where: where?.call(Deployment.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [Deployment] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<DeploymentTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<Deployment>(
      where: where(Deployment.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
