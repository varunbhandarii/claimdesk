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
import 'package:serverpod/serverpod.dart' as _is;

abstract class CaptionRun
    implements _is.TableRow<_is.UuidValue?>, _is.ProtocolSerialization {
  CaptionRun._({
    this.id,
    required this.venueId,
    required this.itemId,
    required this.provider,
    required this.modelId,
    required this.promptVersion,
    required this.outcome,
    required this.latencyMs,
    this.inputTokens,
    this.outputTokens,
    this.errorMessage,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory CaptionRun({
    _is.UuidValue? id,
    required _is.UuidValue venueId,
    required _is.UuidValue itemId,
    required String provider,
    required String modelId,
    required String promptVersion,
    required String outcome,
    required int latencyMs,
    int? inputTokens,
    int? outputTokens,
    String? errorMessage,
    DateTime? createdAt,
  }) = _CaptionRunImpl;

  factory CaptionRun.fromJson(Map<String, dynamic> jsonSerialization) {
    return CaptionRun(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      venueId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['venueId'],
      ),
      itemId: _is.UuidValueJsonExtension.fromJson(jsonSerialization['itemId']),
      provider: jsonSerialization['provider'] as String,
      modelId: jsonSerialization['modelId'] as String,
      promptVersion: jsonSerialization['promptVersion'] as String,
      outcome: jsonSerialization['outcome'] as String,
      latencyMs: jsonSerialization['latencyMs'] as int,
      inputTokens: jsonSerialization['inputTokens'] as int?,
      outputTokens: jsonSerialization['outputTokens'] as int?,
      errorMessage: jsonSerialization['errorMessage'] as String?,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  static final t = CaptionRunTable();

  static const db = CaptionRunRepository._();

  @override
  _is.UuidValue? id;

  _is.UuidValue venueId;

  _is.UuidValue itemId;

  String provider;

  String modelId;

  String promptVersion;

  String outcome;

  int latencyMs;

  int? inputTokens;

  int? outputTokens;

  String? errorMessage;

  DateTime createdAt;

  @override
  _is.Table<_is.UuidValue?> get table => t;

  /// Returns a shallow copy of this [CaptionRun]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CaptionRun copyWith({
    _is.UuidValue? id,
    _is.UuidValue? venueId,
    _is.UuidValue? itemId,
    String? provider,
    String? modelId,
    String? promptVersion,
    String? outcome,
    int? latencyMs,
    int? inputTokens,
    int? outputTokens,
    String? errorMessage,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'CaptionRun',
      if (id != null) 'id': id?.toJson(),
      'venueId': venueId.toJson(),
      'itemId': itemId.toJson(),
      'provider': provider,
      'modelId': modelId,
      'promptVersion': promptVersion,
      'outcome': outcome,
      'latencyMs': latencyMs,
      if (inputTokens != null) 'inputTokens': inputTokens,
      if (outputTokens != null) 'outputTokens': outputTokens,
      if (errorMessage != null) 'errorMessage': errorMessage,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'CaptionRun',
      if (id != null) 'id': id?.toJson(),
      'venueId': venueId.toJson(),
      'itemId': itemId.toJson(),
      'provider': provider,
      'modelId': modelId,
      'promptVersion': promptVersion,
      'outcome': outcome,
      'latencyMs': latencyMs,
      if (inputTokens != null) 'inputTokens': inputTokens,
      if (outputTokens != null) 'outputTokens': outputTokens,
      if (errorMessage != null) 'errorMessage': errorMessage,
      'createdAt': createdAt.toJson(),
    };
  }

  static CaptionRunInclude include() {
    return CaptionRunInclude._();
  }

  static CaptionRunIncludeList includeList({
    _is.WhereExpressionBuilder<CaptionRunTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CaptionRunTable>? orderBy,
    _is.OrderByListBuilder<CaptionRunTable>? orderByList,
    CaptionRunInclude? include,
  }) {
    return CaptionRunIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CaptionRun.t),
      orderByList: orderByList?.call(CaptionRun.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CaptionRunImpl extends CaptionRun {
  _CaptionRunImpl({
    _is.UuidValue? id,
    required _is.UuidValue venueId,
    required _is.UuidValue itemId,
    required String provider,
    required String modelId,
    required String promptVersion,
    required String outcome,
    required int latencyMs,
    int? inputTokens,
    int? outputTokens,
    String? errorMessage,
    DateTime? createdAt,
  }) : super._(
         id: id,
         venueId: venueId,
         itemId: itemId,
         provider: provider,
         modelId: modelId,
         promptVersion: promptVersion,
         outcome: outcome,
         latencyMs: latencyMs,
         inputTokens: inputTokens,
         outputTokens: outputTokens,
         errorMessage: errorMessage,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [CaptionRun]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CaptionRun copyWith({
    Object? id = _Undefined,
    _is.UuidValue? venueId,
    _is.UuidValue? itemId,
    String? provider,
    String? modelId,
    String? promptVersion,
    String? outcome,
    int? latencyMs,
    Object? inputTokens = _Undefined,
    Object? outputTokens = _Undefined,
    Object? errorMessage = _Undefined,
    DateTime? createdAt,
  }) {
    return CaptionRun(
      id: id is _is.UuidValue? ? id : this.id,
      venueId: venueId ?? this.venueId,
      itemId: itemId ?? this.itemId,
      provider: provider ?? this.provider,
      modelId: modelId ?? this.modelId,
      promptVersion: promptVersion ?? this.promptVersion,
      outcome: outcome ?? this.outcome,
      latencyMs: latencyMs ?? this.latencyMs,
      inputTokens: inputTokens is int? ? inputTokens : this.inputTokens,
      outputTokens: outputTokens is int? ? outputTokens : this.outputTokens,
      errorMessage: errorMessage is String? ? errorMessage : this.errorMessage,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class CaptionRunUpdateTable extends _is.UpdateTable<CaptionRunTable> {
  CaptionRunUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> venueId(_is.UuidValue value) =>
      _is.ColumnValue(
        table.venueId,
        value,
      );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> itemId(_is.UuidValue value) =>
      _is.ColumnValue(
        table.itemId,
        value,
      );

  _is.ColumnValue<String, String> provider(String value) => _is.ColumnValue(
    table.provider,
    value,
  );

  _is.ColumnValue<String, String> modelId(String value) => _is.ColumnValue(
    table.modelId,
    value,
  );

  _is.ColumnValue<String, String> promptVersion(String value) =>
      _is.ColumnValue(
        table.promptVersion,
        value,
      );

  _is.ColumnValue<String, String> outcome(String value) => _is.ColumnValue(
    table.outcome,
    value,
  );

  _is.ColumnValue<int, int> latencyMs(int value) => _is.ColumnValue(
    table.latencyMs,
    value,
  );

  _is.ColumnValue<int, int> inputTokens(int? value) => _is.ColumnValue(
    table.inputTokens,
    value,
  );

  _is.ColumnValue<int, int> outputTokens(int? value) => _is.ColumnValue(
    table.outputTokens,
    value,
  );

  _is.ColumnValue<String, String> errorMessage(String? value) =>
      _is.ColumnValue(
        table.errorMessage,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );
}

class CaptionRunTable extends _is.Table<_is.UuidValue?> {
  CaptionRunTable({super.tableRelation}) : super(tableName: 'caption_run') {
    updateTable = CaptionRunUpdateTable(this);
    venueId = _is.ColumnUuid(
      'venueId',
      this,
    );
    itemId = _is.ColumnUuid(
      'itemId',
      this,
    );
    provider = _is.ColumnString(
      'provider',
      this,
    );
    modelId = _is.ColumnString(
      'modelId',
      this,
    );
    promptVersion = _is.ColumnString(
      'promptVersion',
      this,
    );
    outcome = _is.ColumnString(
      'outcome',
      this,
    );
    latencyMs = _is.ColumnInt(
      'latencyMs',
      this,
    );
    inputTokens = _is.ColumnInt(
      'inputTokens',
      this,
    );
    outputTokens = _is.ColumnInt(
      'outputTokens',
      this,
    );
    errorMessage = _is.ColumnString(
      'errorMessage',
      this,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
      hasDefault: true,
    );
  }

  late final CaptionRunUpdateTable updateTable;

  late final _is.ColumnUuid venueId;

  late final _is.ColumnUuid itemId;

  late final _is.ColumnString provider;

  late final _is.ColumnString modelId;

  late final _is.ColumnString promptVersion;

  late final _is.ColumnString outcome;

  late final _is.ColumnInt latencyMs;

  late final _is.ColumnInt inputTokens;

  late final _is.ColumnInt outputTokens;

  late final _is.ColumnString errorMessage;

  late final _is.ColumnDateTime createdAt;

  @override
  List<_is.Column> get columns => [
    id,
    venueId,
    itemId,
    provider,
    modelId,
    promptVersion,
    outcome,
    latencyMs,
    inputTokens,
    outputTokens,
    errorMessage,
    createdAt,
  ];
}

class CaptionRunInclude extends _is.IncludeObject {
  CaptionRunInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue?> get table => CaptionRun.t;
}

class CaptionRunIncludeList extends _is.IncludeList {
  CaptionRunIncludeList._({
    _is.WhereExpressionBuilder<CaptionRunTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(CaptionRun.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue?> get table => CaptionRun.t;
}

class CaptionRunRepository {
  const CaptionRunRepository._();

  /// Returns a list of [CaptionRun]s matching the given query parameters.
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
  Future<List<CaptionRun>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CaptionRunTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CaptionRunTable>? orderBy,
    _is.OrderByListBuilder<CaptionRunTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<CaptionRun>(
      where: where?.call(CaptionRun.t),
      orderBy: orderBy?.call(CaptionRun.t),
      orderByList: orderByList?.call(CaptionRun.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [CaptionRun] matching the given query parameters.
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
  Future<CaptionRun?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CaptionRunTable>? where,
    int? offset,
    _is.OrderByBuilder<CaptionRunTable>? orderBy,
    _is.OrderByListBuilder<CaptionRunTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<CaptionRun>(
      where: where?.call(CaptionRun.t),
      orderBy: orderBy?.call(CaptionRun.t),
      orderByList: orderByList?.call(CaptionRun.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [CaptionRun] by its [id] or null if no such row exists.
  Future<CaptionRun?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<CaptionRun>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [CaptionRun]s in the list and returns the inserted rows.
  ///
  /// The returned [CaptionRun]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  ///
  /// If [noReturn] is set to `true`, the inserted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CaptionRun>> insert(
    _is.DatabaseSession session,
    List<CaptionRun> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<CaptionRun>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [CaptionRun] and returns the inserted row.
  ///
  /// The returned [CaptionRun] will have its `id` field set.
  Future<CaptionRun> insertRow(
    _is.DatabaseSession session,
    CaptionRun row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<CaptionRun>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [CaptionRun]s in the list and returns the resulting rows.
  ///
  /// If a row conflicts on the given [conflictColumns], the existing row is
  /// updated with the new values. Otherwise, a new row is inserted.
  ///
  /// If [updateColumns] is provided, only those columns will be updated on
  /// conflict. If null, all non-conflict, non-id columns are updated.
  ///
  /// If [updateWhere] is provided, the update only applies to rows matching the
  /// given expression. Conflicting rows that don't match are skipped and not
  /// returned, so the resulting list may be shorter than [rows].
  ///
  /// The returned [CaptionRun]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CaptionRun>> upsert(
    _is.DatabaseSession session,
    List<CaptionRun> rows, {
    required _is.ColumnSelections<CaptionRunTable> conflictColumns,
    _is.ColumnSelections<CaptionRunTable>? updateColumns,
    _is.WhereExpressionBuilder<CaptionRunTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<CaptionRun>(
      rows,
      conflictColumns: conflictColumns(CaptionRun.t),
      updateColumns: updateColumns?.call(CaptionRun.t),
      updateWhere: updateWhere?.call(CaptionRun.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [CaptionRun] and returns the resulting row.
  ///
  /// If the row conflicts on the given [conflictColumns], the existing row is
  /// updated. Otherwise, a new row is inserted.
  ///
  /// If [updateColumns] is provided, only those columns will be updated on
  /// conflict. If null, all non-conflict, non-id columns are updated.
  ///
  /// If [updateWhere] is provided, the update only applies when the existing
  /// row matches the expression. Returns `null` if no row was affected — for
  /// example when [updateWhere] does not match the conflicting row.
  ///
  /// The returned [CaptionRun] will have its `id` field set.
  Future<CaptionRun?> upsertRow(
    _is.DatabaseSession session,
    CaptionRun row, {
    required _is.ColumnSelections<CaptionRunTable> conflictColumns,
    _is.ColumnSelections<CaptionRunTable>? updateColumns,
    _is.WhereExpressionBuilder<CaptionRunTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<CaptionRun>(
      row,
      conflictColumns: conflictColumns(CaptionRun.t),
      updateColumns: updateColumns?.call(CaptionRun.t),
      updateWhere: updateWhere?.call(CaptionRun.t),
      transaction: transaction,
    );
  }

  /// Updates all [CaptionRun]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CaptionRun>> update(
    _is.DatabaseSession session,
    List<CaptionRun> rows, {
    _is.ColumnSelections<CaptionRunTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<CaptionRun>(
      rows,
      columns: columns?.call(CaptionRun.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [CaptionRun]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<CaptionRun> updateRow(
    _is.DatabaseSession session,
    CaptionRun row, {
    _is.ColumnSelections<CaptionRunTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<CaptionRun>(
      row,
      columns: columns?.call(CaptionRun.t),
      transaction: transaction,
    );
  }

  /// Updates a single [CaptionRun] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<CaptionRun?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<CaptionRunUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<CaptionRun>(
      id,
      columnValues: columnValues(CaptionRun.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [CaptionRun]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CaptionRun>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<CaptionRunUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<CaptionRunTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CaptionRunTable>? orderBy,
    _is.OrderByListBuilder<CaptionRunTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<CaptionRun>(
      columnValues: columnValues(CaptionRun.t.updateTable),
      where: where(CaptionRun.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CaptionRun.t),
      orderByList: orderByList?.call(CaptionRun.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [CaptionRun]s in the list and returns the deleted rows.
  ///
  /// To specify the order of the returned rows use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  ///
  /// If [noReturn] is set to `true`, the deleted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CaptionRun>> delete(
    _is.DatabaseSession session,
    List<CaptionRun> rows, {
    _is.OrderByBuilder<CaptionRunTable>? orderBy,
    _is.OrderByListBuilder<CaptionRunTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<CaptionRun>(
      rows,
      orderBy: orderBy?.call(CaptionRun.t),
      orderByList: orderByList?.call(CaptionRun.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [CaptionRun].
  Future<CaptionRun> deleteRow(
    _is.DatabaseSession session,
    CaptionRun row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<CaptionRun>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  ///
  /// To specify the order of the returned rows use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// If [noReturn] is set to `true`, the deleted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CaptionRun>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<CaptionRunTable> where,
    _is.OrderByBuilder<CaptionRunTable>? orderBy,
    _is.OrderByListBuilder<CaptionRunTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<CaptionRun>(
      where: where(CaptionRun.t),
      orderBy: orderBy?.call(CaptionRun.t),
      orderByList: orderByList?.call(CaptionRun.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CaptionRunTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<CaptionRun>(
      where: where?.call(CaptionRun.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [CaptionRun] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<CaptionRunTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<CaptionRun>(
      where: where(CaptionRun.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
