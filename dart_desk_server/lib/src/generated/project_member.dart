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
import 'project_role.dart' as _i2;

abstract class ProjectMember
    implements _i1.TableRow<_i1.UuidValue>, _i1.ProtocolSerialization {
  ProjectMember._({
    _i1.UuidValue? id,
    required this.userId,
    required this.projectId,
    required this.role,
    DateTime? createdAt,
  }) : id = id ?? const _i1.Uuid().v4obj(),
       createdAt = createdAt ?? DateTime.now();

  factory ProjectMember({
    _i1.UuidValue? id,
    required _i1.UuidValue userId,
    required _i1.UuidValue projectId,
    required _i2.ProjectRole role,
    DateTime? createdAt,
  }) = _ProjectMemberImpl;

  factory ProjectMember.fromJson(Map<String, dynamic> jsonSerialization) {
    return ProjectMember(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      userId: _i1.UuidValueJsonExtension.fromJson(jsonSerialization['userId']),
      projectId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['projectId'],
      ),
      role: _i2.ProjectRole.fromJson((jsonSerialization['role'] as String)),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  static final t = ProjectMemberTable();

  static const db = ProjectMemberRepository._();

  @override
  _i1.UuidValue id;

  _i1.UuidValue userId;

  _i1.UuidValue projectId;

  _i2.ProjectRole role;

  DateTime? createdAt;

  @override
  _i1.Table<_i1.UuidValue> get table => t;

  /// Returns a shallow copy of this [ProjectMember]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ProjectMember copyWith({
    _i1.UuidValue? id,
    _i1.UuidValue? userId,
    _i1.UuidValue? projectId,
    _i2.ProjectRole? role,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ProjectMember',
      'id': id.toJson(),
      'userId': userId.toJson(),
      'projectId': projectId.toJson(),
      'role': role.toJson(),
      if (createdAt != null) 'createdAt': createdAt?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'ProjectMember',
      'id': id.toJson(),
      'userId': userId.toJson(),
      'projectId': projectId.toJson(),
      'role': role.toJson(),
      if (createdAt != null) 'createdAt': createdAt?.toJson(),
    };
  }

  static ProjectMemberInclude include() {
    return ProjectMemberInclude._();
  }

  static ProjectMemberIncludeList includeList({
    _i1.WhereExpressionBuilder<ProjectMemberTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ProjectMemberTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ProjectMemberTable>? orderByList,
    ProjectMemberInclude? include,
  }) {
    return ProjectMemberIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ProjectMember.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(ProjectMember.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ProjectMemberImpl extends ProjectMember {
  _ProjectMemberImpl({
    _i1.UuidValue? id,
    required _i1.UuidValue userId,
    required _i1.UuidValue projectId,
    required _i2.ProjectRole role,
    DateTime? createdAt,
  }) : super._(
         id: id,
         userId: userId,
         projectId: projectId,
         role: role,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [ProjectMember]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ProjectMember copyWith({
    _i1.UuidValue? id,
    _i1.UuidValue? userId,
    _i1.UuidValue? projectId,
    _i2.ProjectRole? role,
    Object? createdAt = _Undefined,
  }) {
    return ProjectMember(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      projectId: projectId ?? this.projectId,
      role: role ?? this.role,
      createdAt: createdAt is DateTime? ? createdAt : this.createdAt,
    );
  }
}

class ProjectMemberUpdateTable extends _i1.UpdateTable<ProjectMemberTable> {
  ProjectMemberUpdateTable(super.table);

  _i1.ColumnValue<_i1.UuidValue, _i1.UuidValue> userId(_i1.UuidValue value) =>
      _i1.ColumnValue(
        table.userId,
        value,
      );

  _i1.ColumnValue<_i1.UuidValue, _i1.UuidValue> projectId(
    _i1.UuidValue value,
  ) => _i1.ColumnValue(
    table.projectId,
    value,
  );

  _i1.ColumnValue<_i2.ProjectRole, _i2.ProjectRole> role(
    _i2.ProjectRole value,
  ) => _i1.ColumnValue(
    table.role,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> createdAt(DateTime? value) =>
      _i1.ColumnValue(
        table.createdAt,
        value,
      );
}

class ProjectMemberTable extends _i1.Table<_i1.UuidValue> {
  ProjectMemberTable({super.tableRelation})
    : super(tableName: 'project_members') {
    updateTable = ProjectMemberUpdateTable(this);
    userId = _i1.ColumnUuid(
      'userId',
      this,
    );
    projectId = _i1.ColumnUuid(
      'projectId',
      this,
    );
    role = _i1.ColumnEnum(
      'role',
      this,
      _i1.EnumSerialization.byName,
    );
    createdAt = _i1.ColumnDateTime(
      'createdAt',
      this,
      hasDefault: true,
    );
  }

  late final ProjectMemberUpdateTable updateTable;

  late final _i1.ColumnUuid userId;

  late final _i1.ColumnUuid projectId;

  late final _i1.ColumnEnum<_i2.ProjectRole> role;

  late final _i1.ColumnDateTime createdAt;

  @override
  List<_i1.Column> get columns => [
    id,
    userId,
    projectId,
    role,
    createdAt,
  ];
}

class ProjectMemberInclude extends _i1.IncludeObject {
  ProjectMemberInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<_i1.UuidValue> get table => ProjectMember.t;
}

class ProjectMemberIncludeList extends _i1.IncludeList {
  ProjectMemberIncludeList._({
    _i1.WhereExpressionBuilder<ProjectMemberTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(ProjectMember.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<_i1.UuidValue> get table => ProjectMember.t;
}

class ProjectMemberRepository {
  const ProjectMemberRepository._();

  /// Returns a list of [ProjectMember]s matching the given query parameters.
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
  Future<List<ProjectMember>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<ProjectMemberTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ProjectMemberTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ProjectMemberTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<ProjectMember>(
      where: where?.call(ProjectMember.t),
      orderBy: orderBy?.call(ProjectMember.t),
      orderByList: orderByList?.call(ProjectMember.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [ProjectMember] matching the given query parameters.
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
  Future<ProjectMember?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<ProjectMemberTable>? where,
    int? offset,
    _i1.OrderByBuilder<ProjectMemberTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ProjectMemberTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<ProjectMember>(
      where: where?.call(ProjectMember.t),
      orderBy: orderBy?.call(ProjectMember.t),
      orderByList: orderByList?.call(ProjectMember.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [ProjectMember] by its [id] or null if no such row exists.
  Future<ProjectMember?> findById(
    _i1.DatabaseSession session,
    _i1.UuidValue id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<ProjectMember>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [ProjectMember]s in the list and returns the inserted rows.
  ///
  /// The returned [ProjectMember]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<ProjectMember>> insert(
    _i1.DatabaseSession session,
    List<ProjectMember> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<ProjectMember>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [ProjectMember] and returns the inserted row.
  ///
  /// The returned [ProjectMember] will have its `id` field set.
  Future<ProjectMember> insertRow(
    _i1.DatabaseSession session,
    ProjectMember row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<ProjectMember>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [ProjectMember]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<ProjectMember>> update(
    _i1.DatabaseSession session,
    List<ProjectMember> rows, {
    _i1.ColumnSelections<ProjectMemberTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<ProjectMember>(
      rows,
      columns: columns?.call(ProjectMember.t),
      transaction: transaction,
    );
  }

  /// Updates a single [ProjectMember]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<ProjectMember> updateRow(
    _i1.DatabaseSession session,
    ProjectMember row, {
    _i1.ColumnSelections<ProjectMemberTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<ProjectMember>(
      row,
      columns: columns?.call(ProjectMember.t),
      transaction: transaction,
    );
  }

  /// Updates a single [ProjectMember] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<ProjectMember?> updateById(
    _i1.DatabaseSession session,
    _i1.UuidValue id, {
    required _i1.ColumnValueListBuilder<ProjectMemberUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<ProjectMember>(
      id,
      columnValues: columnValues(ProjectMember.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [ProjectMember]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<ProjectMember>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<ProjectMemberUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<ProjectMemberTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ProjectMemberTable>? orderBy,
    _i1.OrderByListBuilder<ProjectMemberTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<ProjectMember>(
      columnValues: columnValues(ProjectMember.t.updateTable),
      where: where(ProjectMember.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ProjectMember.t),
      orderByList: orderByList?.call(ProjectMember.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [ProjectMember]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<ProjectMember>> delete(
    _i1.DatabaseSession session,
    List<ProjectMember> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<ProjectMember>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [ProjectMember].
  Future<ProjectMember> deleteRow(
    _i1.DatabaseSession session,
    ProjectMember row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<ProjectMember>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<ProjectMember>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<ProjectMemberTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<ProjectMember>(
      where: where(ProjectMember.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<ProjectMemberTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<ProjectMember>(
      where: where?.call(ProjectMember.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [ProjectMember] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<ProjectMemberTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<ProjectMember>(
      where: where(ProjectMember.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
