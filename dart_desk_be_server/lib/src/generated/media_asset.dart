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
import 'media_asset_metadata_status.dart' as _i2;

abstract class MediaAsset
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  MediaAsset._({
    this.id,
    required this.clientId,
    required this.assetId,
    required this.fileName,
    required this.mimeType,
    required this.fileSize,
    required this.storagePath,
    required this.publicUrl,
    required this.width,
    required this.height,
    required this.hasAlpha,
    required this.blurHash,
    this.lqip,
    this.paletteJson,
    this.exifJson,
    this.locationLat,
    this.locationLng,
    this.uploadedByUserId,
    required this.metadataStatus,
  });

  factory MediaAsset({
    int? id,
    required int clientId,
    required String assetId,
    required String fileName,
    required String mimeType,
    required int fileSize,
    required String storagePath,
    required String publicUrl,
    required int width,
    required int height,
    required bool hasAlpha,
    required String blurHash,
    String? lqip,
    String? paletteJson,
    String? exifJson,
    double? locationLat,
    double? locationLng,
    int? uploadedByUserId,
    required _i2.MediaAssetMetadataStatus metadataStatus,
  }) = _MediaAssetImpl;

  factory MediaAsset.fromJson(Map<String, dynamic> jsonSerialization) {
    return MediaAsset(
      id: jsonSerialization['id'] as int?,
      clientId: jsonSerialization['clientId'] as int,
      assetId: jsonSerialization['assetId'] as String,
      fileName: jsonSerialization['fileName'] as String,
      mimeType: jsonSerialization['mimeType'] as String,
      fileSize: jsonSerialization['fileSize'] as int,
      storagePath: jsonSerialization['storagePath'] as String,
      publicUrl: jsonSerialization['publicUrl'] as String,
      width: jsonSerialization['width'] as int,
      height: jsonSerialization['height'] as int,
      hasAlpha: _i1.BoolJsonExtension.fromJson(jsonSerialization['hasAlpha']),
      blurHash: jsonSerialization['blurHash'] as String,
      lqip: jsonSerialization['lqip'] as String?,
      paletteJson: jsonSerialization['paletteJson'] as String?,
      exifJson: jsonSerialization['exifJson'] as String?,
      locationLat: (jsonSerialization['locationLat'] as num?)?.toDouble(),
      locationLng: (jsonSerialization['locationLng'] as num?)?.toDouble(),
      uploadedByUserId: jsonSerialization['uploadedByUserId'] as int?,
      metadataStatus: _i2.MediaAssetMetadataStatus.fromJson(
        (jsonSerialization['metadataStatus'] as String),
      ),
    );
  }

  static final t = MediaAssetTable();

  static const db = MediaAssetRepository._();

  @override
  int? id;

  int clientId;

  String assetId;

  String fileName;

  String mimeType;

  int fileSize;

  String storagePath;

  String publicUrl;

  int width;

  int height;

  bool hasAlpha;

  String blurHash;

  String? lqip;

  String? paletteJson;

  String? exifJson;

  double? locationLat;

  double? locationLng;

  int? uploadedByUserId;

  _i2.MediaAssetMetadataStatus metadataStatus;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [MediaAsset]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  MediaAsset copyWith({
    int? id,
    int? clientId,
    String? assetId,
    String? fileName,
    String? mimeType,
    int? fileSize,
    String? storagePath,
    String? publicUrl,
    int? width,
    int? height,
    bool? hasAlpha,
    String? blurHash,
    String? lqip,
    String? paletteJson,
    String? exifJson,
    double? locationLat,
    double? locationLng,
    int? uploadedByUserId,
    _i2.MediaAssetMetadataStatus? metadataStatus,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'MediaAsset',
      if (id != null) 'id': id,
      'clientId': clientId,
      'assetId': assetId,
      'fileName': fileName,
      'mimeType': mimeType,
      'fileSize': fileSize,
      'storagePath': storagePath,
      'publicUrl': publicUrl,
      'width': width,
      'height': height,
      'hasAlpha': hasAlpha,
      'blurHash': blurHash,
      if (lqip != null) 'lqip': lqip,
      if (paletteJson != null) 'paletteJson': paletteJson,
      if (exifJson != null) 'exifJson': exifJson,
      if (locationLat != null) 'locationLat': locationLat,
      if (locationLng != null) 'locationLng': locationLng,
      if (uploadedByUserId != null) 'uploadedByUserId': uploadedByUserId,
      'metadataStatus': metadataStatus.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'MediaAsset',
      if (id != null) 'id': id,
      'clientId': clientId,
      'assetId': assetId,
      'fileName': fileName,
      'mimeType': mimeType,
      'fileSize': fileSize,
      'storagePath': storagePath,
      'publicUrl': publicUrl,
      'width': width,
      'height': height,
      'hasAlpha': hasAlpha,
      'blurHash': blurHash,
      if (lqip != null) 'lqip': lqip,
      if (paletteJson != null) 'paletteJson': paletteJson,
      if (exifJson != null) 'exifJson': exifJson,
      if (locationLat != null) 'locationLat': locationLat,
      if (locationLng != null) 'locationLng': locationLng,
      if (uploadedByUserId != null) 'uploadedByUserId': uploadedByUserId,
      'metadataStatus': metadataStatus.toJson(),
    };
  }

  static MediaAssetInclude include() {
    return MediaAssetInclude._();
  }

  static MediaAssetIncludeList includeList({
    _i1.WhereExpressionBuilder<MediaAssetTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<MediaAssetTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<MediaAssetTable>? orderByList,
    MediaAssetInclude? include,
  }) {
    return MediaAssetIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(MediaAsset.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(MediaAsset.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _MediaAssetImpl extends MediaAsset {
  _MediaAssetImpl({
    int? id,
    required int clientId,
    required String assetId,
    required String fileName,
    required String mimeType,
    required int fileSize,
    required String storagePath,
    required String publicUrl,
    required int width,
    required int height,
    required bool hasAlpha,
    required String blurHash,
    String? lqip,
    String? paletteJson,
    String? exifJson,
    double? locationLat,
    double? locationLng,
    int? uploadedByUserId,
    required _i2.MediaAssetMetadataStatus metadataStatus,
  }) : super._(
         id: id,
         clientId: clientId,
         assetId: assetId,
         fileName: fileName,
         mimeType: mimeType,
         fileSize: fileSize,
         storagePath: storagePath,
         publicUrl: publicUrl,
         width: width,
         height: height,
         hasAlpha: hasAlpha,
         blurHash: blurHash,
         lqip: lqip,
         paletteJson: paletteJson,
         exifJson: exifJson,
         locationLat: locationLat,
         locationLng: locationLng,
         uploadedByUserId: uploadedByUserId,
         metadataStatus: metadataStatus,
       );

  /// Returns a shallow copy of this [MediaAsset]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  MediaAsset copyWith({
    Object? id = _Undefined,
    int? clientId,
    String? assetId,
    String? fileName,
    String? mimeType,
    int? fileSize,
    String? storagePath,
    String? publicUrl,
    int? width,
    int? height,
    bool? hasAlpha,
    String? blurHash,
    Object? lqip = _Undefined,
    Object? paletteJson = _Undefined,
    Object? exifJson = _Undefined,
    Object? locationLat = _Undefined,
    Object? locationLng = _Undefined,
    Object? uploadedByUserId = _Undefined,
    _i2.MediaAssetMetadataStatus? metadataStatus,
  }) {
    return MediaAsset(
      id: id is int? ? id : this.id,
      clientId: clientId ?? this.clientId,
      assetId: assetId ?? this.assetId,
      fileName: fileName ?? this.fileName,
      mimeType: mimeType ?? this.mimeType,
      fileSize: fileSize ?? this.fileSize,
      storagePath: storagePath ?? this.storagePath,
      publicUrl: publicUrl ?? this.publicUrl,
      width: width ?? this.width,
      height: height ?? this.height,
      hasAlpha: hasAlpha ?? this.hasAlpha,
      blurHash: blurHash ?? this.blurHash,
      lqip: lqip is String? ? lqip : this.lqip,
      paletteJson: paletteJson is String? ? paletteJson : this.paletteJson,
      exifJson: exifJson is String? ? exifJson : this.exifJson,
      locationLat: locationLat is double? ? locationLat : this.locationLat,
      locationLng: locationLng is double? ? locationLng : this.locationLng,
      uploadedByUserId: uploadedByUserId is int?
          ? uploadedByUserId
          : this.uploadedByUserId,
      metadataStatus: metadataStatus ?? this.metadataStatus,
    );
  }
}

class MediaAssetUpdateTable extends _i1.UpdateTable<MediaAssetTable> {
  MediaAssetUpdateTable(super.table);

  _i1.ColumnValue<int, int> clientId(int value) => _i1.ColumnValue(
    table.clientId,
    value,
  );

  _i1.ColumnValue<String, String> assetId(String value) => _i1.ColumnValue(
    table.assetId,
    value,
  );

  _i1.ColumnValue<String, String> fileName(String value) => _i1.ColumnValue(
    table.fileName,
    value,
  );

  _i1.ColumnValue<String, String> mimeType(String value) => _i1.ColumnValue(
    table.mimeType,
    value,
  );

  _i1.ColumnValue<int, int> fileSize(int value) => _i1.ColumnValue(
    table.fileSize,
    value,
  );

  _i1.ColumnValue<String, String> storagePath(String value) => _i1.ColumnValue(
    table.storagePath,
    value,
  );

  _i1.ColumnValue<String, String> publicUrl(String value) => _i1.ColumnValue(
    table.publicUrl,
    value,
  );

  _i1.ColumnValue<int, int> width(int value) => _i1.ColumnValue(
    table.width,
    value,
  );

  _i1.ColumnValue<int, int> height(int value) => _i1.ColumnValue(
    table.height,
    value,
  );

  _i1.ColumnValue<bool, bool> hasAlpha(bool value) => _i1.ColumnValue(
    table.hasAlpha,
    value,
  );

  _i1.ColumnValue<String, String> blurHash(String value) => _i1.ColumnValue(
    table.blurHash,
    value,
  );

  _i1.ColumnValue<String, String> lqip(String? value) => _i1.ColumnValue(
    table.lqip,
    value,
  );

  _i1.ColumnValue<String, String> paletteJson(String? value) => _i1.ColumnValue(
    table.paletteJson,
    value,
  );

  _i1.ColumnValue<String, String> exifJson(String? value) => _i1.ColumnValue(
    table.exifJson,
    value,
  );

  _i1.ColumnValue<double, double> locationLat(double? value) => _i1.ColumnValue(
    table.locationLat,
    value,
  );

  _i1.ColumnValue<double, double> locationLng(double? value) => _i1.ColumnValue(
    table.locationLng,
    value,
  );

  _i1.ColumnValue<int, int> uploadedByUserId(int? value) => _i1.ColumnValue(
    table.uploadedByUserId,
    value,
  );

  _i1.ColumnValue<_i2.MediaAssetMetadataStatus, _i2.MediaAssetMetadataStatus>
  metadataStatus(_i2.MediaAssetMetadataStatus value) => _i1.ColumnValue(
    table.metadataStatus,
    value,
  );
}

class MediaAssetTable extends _i1.Table<int?> {
  MediaAssetTable({super.tableRelation}) : super(tableName: 'media_assets') {
    updateTable = MediaAssetUpdateTable(this);
    clientId = _i1.ColumnInt(
      'clientId',
      this,
    );
    assetId = _i1.ColumnString(
      'assetId',
      this,
    );
    fileName = _i1.ColumnString(
      'fileName',
      this,
    );
    mimeType = _i1.ColumnString(
      'mimeType',
      this,
    );
    fileSize = _i1.ColumnInt(
      'fileSize',
      this,
    );
    storagePath = _i1.ColumnString(
      'storagePath',
      this,
    );
    publicUrl = _i1.ColumnString(
      'publicUrl',
      this,
    );
    width = _i1.ColumnInt(
      'width',
      this,
    );
    height = _i1.ColumnInt(
      'height',
      this,
    );
    hasAlpha = _i1.ColumnBool(
      'hasAlpha',
      this,
    );
    blurHash = _i1.ColumnString(
      'blurHash',
      this,
    );
    lqip = _i1.ColumnString(
      'lqip',
      this,
    );
    paletteJson = _i1.ColumnString(
      'paletteJson',
      this,
    );
    exifJson = _i1.ColumnString(
      'exifJson',
      this,
    );
    locationLat = _i1.ColumnDouble(
      'locationLat',
      this,
    );
    locationLng = _i1.ColumnDouble(
      'locationLng',
      this,
    );
    uploadedByUserId = _i1.ColumnInt(
      'uploadedByUserId',
      this,
    );
    metadataStatus = _i1.ColumnEnum(
      'metadataStatus',
      this,
      _i1.EnumSerialization.byName,
    );
  }

  late final MediaAssetUpdateTable updateTable;

  late final _i1.ColumnInt clientId;

  late final _i1.ColumnString assetId;

  late final _i1.ColumnString fileName;

  late final _i1.ColumnString mimeType;

  late final _i1.ColumnInt fileSize;

  late final _i1.ColumnString storagePath;

  late final _i1.ColumnString publicUrl;

  late final _i1.ColumnInt width;

  late final _i1.ColumnInt height;

  late final _i1.ColumnBool hasAlpha;

  late final _i1.ColumnString blurHash;

  late final _i1.ColumnString lqip;

  late final _i1.ColumnString paletteJson;

  late final _i1.ColumnString exifJson;

  late final _i1.ColumnDouble locationLat;

  late final _i1.ColumnDouble locationLng;

  late final _i1.ColumnInt uploadedByUserId;

  late final _i1.ColumnEnum<_i2.MediaAssetMetadataStatus> metadataStatus;

  @override
  List<_i1.Column> get columns => [
    id,
    clientId,
    assetId,
    fileName,
    mimeType,
    fileSize,
    storagePath,
    publicUrl,
    width,
    height,
    hasAlpha,
    blurHash,
    lqip,
    paletteJson,
    exifJson,
    locationLat,
    locationLng,
    uploadedByUserId,
    metadataStatus,
  ];
}

class MediaAssetInclude extends _i1.IncludeObject {
  MediaAssetInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => MediaAsset.t;
}

class MediaAssetIncludeList extends _i1.IncludeList {
  MediaAssetIncludeList._({
    _i1.WhereExpressionBuilder<MediaAssetTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(MediaAsset.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => MediaAsset.t;
}

class MediaAssetRepository {
  const MediaAssetRepository._();

  /// Returns a list of [MediaAsset]s matching the given query parameters.
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
  Future<List<MediaAsset>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<MediaAssetTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<MediaAssetTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<MediaAssetTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<MediaAsset>(
      where: where?.call(MediaAsset.t),
      orderBy: orderBy?.call(MediaAsset.t),
      orderByList: orderByList?.call(MediaAsset.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [MediaAsset] matching the given query parameters.
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
  Future<MediaAsset?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<MediaAssetTable>? where,
    int? offset,
    _i1.OrderByBuilder<MediaAssetTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<MediaAssetTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<MediaAsset>(
      where: where?.call(MediaAsset.t),
      orderBy: orderBy?.call(MediaAsset.t),
      orderByList: orderByList?.call(MediaAsset.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [MediaAsset] by its [id] or null if no such row exists.
  Future<MediaAsset?> findById(
    _i1.DatabaseSession session,
    int id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<MediaAsset>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [MediaAsset]s in the list and returns the inserted rows.
  ///
  /// The returned [MediaAsset]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<MediaAsset>> insert(
    _i1.DatabaseSession session,
    List<MediaAsset> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<MediaAsset>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [MediaAsset] and returns the inserted row.
  ///
  /// The returned [MediaAsset] will have its `id` field set.
  Future<MediaAsset> insertRow(
    _i1.DatabaseSession session,
    MediaAsset row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<MediaAsset>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [MediaAsset]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<MediaAsset>> update(
    _i1.DatabaseSession session,
    List<MediaAsset> rows, {
    _i1.ColumnSelections<MediaAssetTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<MediaAsset>(
      rows,
      columns: columns?.call(MediaAsset.t),
      transaction: transaction,
    );
  }

  /// Updates a single [MediaAsset]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<MediaAsset> updateRow(
    _i1.DatabaseSession session,
    MediaAsset row, {
    _i1.ColumnSelections<MediaAssetTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<MediaAsset>(
      row,
      columns: columns?.call(MediaAsset.t),
      transaction: transaction,
    );
  }

  /// Updates a single [MediaAsset] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<MediaAsset?> updateById(
    _i1.DatabaseSession session,
    int id, {
    required _i1.ColumnValueListBuilder<MediaAssetUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<MediaAsset>(
      id,
      columnValues: columnValues(MediaAsset.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [MediaAsset]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<MediaAsset>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<MediaAssetUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<MediaAssetTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<MediaAssetTable>? orderBy,
    _i1.OrderByListBuilder<MediaAssetTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<MediaAsset>(
      columnValues: columnValues(MediaAsset.t.updateTable),
      where: where(MediaAsset.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(MediaAsset.t),
      orderByList: orderByList?.call(MediaAsset.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [MediaAsset]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<MediaAsset>> delete(
    _i1.DatabaseSession session,
    List<MediaAsset> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<MediaAsset>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [MediaAsset].
  Future<MediaAsset> deleteRow(
    _i1.DatabaseSession session,
    MediaAsset row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<MediaAsset>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<MediaAsset>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<MediaAssetTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<MediaAsset>(
      where: where(MediaAsset.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<MediaAssetTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<MediaAsset>(
      where: where?.call(MediaAsset.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [MediaAsset] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<MediaAssetTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<MediaAsset>(
      where: where(MediaAsset.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
