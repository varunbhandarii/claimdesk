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

abstract class ReportAnswer
    implements _is.TableRow<_is.UuidValue?>, _is.ProtocolSerialization {
  ReportAnswer._({
    this.id,
    required this.venueId,
    required this.reportId,
    required this.matchId,
    required this.question,
    required this.answer,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory ReportAnswer({
    _is.UuidValue? id,
    required _is.UuidValue venueId,
    required _is.UuidValue reportId,
    required _is.UuidValue matchId,
    required String question,
    required String answer,
    DateTime? createdAt,
  }) = _ReportAnswerImpl;

  factory ReportAnswer.fromJson(Map<String, dynamic> jsonSerialization) {
    return ReportAnswer(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      venueId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['venueId'],
      ),
      reportId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['reportId'],
      ),
      matchId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['matchId'],
      ),
      question: jsonSerialization['question'] as String,
      answer: jsonSerialization['answer'] as String,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  static final t = ReportAnswerTable();

  static const db = ReportAnswerRepository._();

  @override
  _is.UuidValue? id;

  _is.UuidValue venueId;

  _is.UuidValue reportId;

  _is.UuidValue matchId;

  String question;

  String answer;

  DateTime createdAt;

  @override
  _is.Table<_is.UuidValue?> get table => t;

  /// Returns a shallow copy of this [ReportAnswer]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  ReportAnswer copyWith({
    _is.UuidValue? id,
    _is.UuidValue? venueId,
    _is.UuidValue? reportId,
    _is.UuidValue? matchId,
    String? question,
    String? answer,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ReportAnswer',
      if (id != null) 'id': id?.toJson(),
      'venueId': venueId.toJson(),
      'reportId': reportId.toJson(),
      'matchId': matchId.toJson(),
      'question': question,
      'answer': answer,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'ReportAnswer',
      if (id != null) 'id': id?.toJson(),
      'venueId': venueId.toJson(),
      'reportId': reportId.toJson(),
      'matchId': matchId.toJson(),
      'question': question,
      'answer': answer,
      'createdAt': createdAt.toJson(),
    };
  }

  static ReportAnswerInclude include() {
    return ReportAnswerInclude._();
  }

  static ReportAnswerIncludeList includeList({
    _is.WhereExpressionBuilder<ReportAnswerTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ReportAnswerTable>? orderBy,
    _is.OrderByListBuilder<ReportAnswerTable>? orderByList,
    ReportAnswerInclude? include,
  }) {
    return ReportAnswerIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ReportAnswer.t),
      orderByList: orderByList?.call(ReportAnswer.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ReportAnswerImpl extends ReportAnswer {
  _ReportAnswerImpl({
    _is.UuidValue? id,
    required _is.UuidValue venueId,
    required _is.UuidValue reportId,
    required _is.UuidValue matchId,
    required String question,
    required String answer,
    DateTime? createdAt,
  }) : super._(
         id: id,
         venueId: venueId,
         reportId: reportId,
         matchId: matchId,
         question: question,
         answer: answer,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [ReportAnswer]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  ReportAnswer copyWith({
    Object? id = _Undefined,
    _is.UuidValue? venueId,
    _is.UuidValue? reportId,
    _is.UuidValue? matchId,
    String? question,
    String? answer,
    DateTime? createdAt,
  }) {
    return ReportAnswer(
      id: id is _is.UuidValue? ? id : this.id,
      venueId: venueId ?? this.venueId,
      reportId: reportId ?? this.reportId,
      matchId: matchId ?? this.matchId,
      question: question ?? this.question,
      answer: answer ?? this.answer,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class ReportAnswerUpdateTable extends _is.UpdateTable<ReportAnswerTable> {
  ReportAnswerUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> venueId(_is.UuidValue value) =>
      _is.ColumnValue(
        table.venueId,
        value,
      );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> reportId(_is.UuidValue value) =>
      _is.ColumnValue(
        table.reportId,
        value,
      );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> matchId(_is.UuidValue value) =>
      _is.ColumnValue(
        table.matchId,
        value,
      );

  _is.ColumnValue<String, String> question(String value) => _is.ColumnValue(
    table.question,
    value,
  );

  _is.ColumnValue<String, String> answer(String value) => _is.ColumnValue(
    table.answer,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );
}

class ReportAnswerTable extends _is.Table<_is.UuidValue?> {
  ReportAnswerTable({super.tableRelation}) : super(tableName: 'report_answer') {
    updateTable = ReportAnswerUpdateTable(this);
    venueId = _is.ColumnUuid(
      'venueId',
      this,
    );
    reportId = _is.ColumnUuid(
      'reportId',
      this,
    );
    matchId = _is.ColumnUuid(
      'matchId',
      this,
    );
    question = _is.ColumnString(
      'question',
      this,
    );
    answer = _is.ColumnString(
      'answer',
      this,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
      hasDefault: true,
    );
  }

  late final ReportAnswerUpdateTable updateTable;

  late final _is.ColumnUuid venueId;

  late final _is.ColumnUuid reportId;

  late final _is.ColumnUuid matchId;

  late final _is.ColumnString question;

  late final _is.ColumnString answer;

  late final _is.ColumnDateTime createdAt;

  @override
  List<_is.Column> get columns => [
    id,
    venueId,
    reportId,
    matchId,
    question,
    answer,
    createdAt,
  ];
}

class ReportAnswerInclude extends _is.IncludeObject {
  ReportAnswerInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue?> get table => ReportAnswer.t;
}

class ReportAnswerIncludeList extends _is.IncludeList {
  ReportAnswerIncludeList._({
    _is.WhereExpressionBuilder<ReportAnswerTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(ReportAnswer.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue?> get table => ReportAnswer.t;
}

class ReportAnswerRepository {
  const ReportAnswerRepository._();

  /// Returns a list of [ReportAnswer]s matching the given query parameters.
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
  Future<List<ReportAnswer>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ReportAnswerTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ReportAnswerTable>? orderBy,
    _is.OrderByListBuilder<ReportAnswerTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<ReportAnswer>(
      where: where?.call(ReportAnswer.t),
      orderBy: orderBy?.call(ReportAnswer.t),
      orderByList: orderByList?.call(ReportAnswer.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [ReportAnswer] matching the given query parameters.
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
  Future<ReportAnswer?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ReportAnswerTable>? where,
    int? offset,
    _is.OrderByBuilder<ReportAnswerTable>? orderBy,
    _is.OrderByListBuilder<ReportAnswerTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<ReportAnswer>(
      where: where?.call(ReportAnswer.t),
      orderBy: orderBy?.call(ReportAnswer.t),
      orderByList: orderByList?.call(ReportAnswer.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [ReportAnswer] by its [id] or null if no such row exists.
  Future<ReportAnswer?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<ReportAnswer>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [ReportAnswer]s in the list and returns the inserted rows.
  ///
  /// The returned [ReportAnswer]s will have their `id` fields set.
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
  Future<List<ReportAnswer>> insert(
    _is.DatabaseSession session,
    List<ReportAnswer> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<ReportAnswer>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [ReportAnswer] and returns the inserted row.
  ///
  /// The returned [ReportAnswer] will have its `id` field set.
  Future<ReportAnswer> insertRow(
    _is.DatabaseSession session,
    ReportAnswer row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<ReportAnswer>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [ReportAnswer]s in the list and returns the resulting rows.
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
  /// The returned [ReportAnswer]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ReportAnswer>> upsert(
    _is.DatabaseSession session,
    List<ReportAnswer> rows, {
    required _is.ColumnSelections<ReportAnswerTable> conflictColumns,
    _is.ColumnSelections<ReportAnswerTable>? updateColumns,
    _is.WhereExpressionBuilder<ReportAnswerTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<ReportAnswer>(
      rows,
      conflictColumns: conflictColumns(ReportAnswer.t),
      updateColumns: updateColumns?.call(ReportAnswer.t),
      updateWhere: updateWhere?.call(ReportAnswer.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [ReportAnswer] and returns the resulting row.
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
  /// The returned [ReportAnswer] will have its `id` field set.
  Future<ReportAnswer?> upsertRow(
    _is.DatabaseSession session,
    ReportAnswer row, {
    required _is.ColumnSelections<ReportAnswerTable> conflictColumns,
    _is.ColumnSelections<ReportAnswerTable>? updateColumns,
    _is.WhereExpressionBuilder<ReportAnswerTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<ReportAnswer>(
      row,
      conflictColumns: conflictColumns(ReportAnswer.t),
      updateColumns: updateColumns?.call(ReportAnswer.t),
      updateWhere: updateWhere?.call(ReportAnswer.t),
      transaction: transaction,
    );
  }

  /// Updates all [ReportAnswer]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ReportAnswer>> update(
    _is.DatabaseSession session,
    List<ReportAnswer> rows, {
    _is.ColumnSelections<ReportAnswerTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<ReportAnswer>(
      rows,
      columns: columns?.call(ReportAnswer.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [ReportAnswer]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<ReportAnswer> updateRow(
    _is.DatabaseSession session,
    ReportAnswer row, {
    _is.ColumnSelections<ReportAnswerTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<ReportAnswer>(
      row,
      columns: columns?.call(ReportAnswer.t),
      transaction: transaction,
    );
  }

  /// Updates a single [ReportAnswer] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<ReportAnswer?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<ReportAnswerUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<ReportAnswer>(
      id,
      columnValues: columnValues(ReportAnswer.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [ReportAnswer]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ReportAnswer>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<ReportAnswerUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<ReportAnswerTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ReportAnswerTable>? orderBy,
    _is.OrderByListBuilder<ReportAnswerTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<ReportAnswer>(
      columnValues: columnValues(ReportAnswer.t.updateTable),
      where: where(ReportAnswer.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ReportAnswer.t),
      orderByList: orderByList?.call(ReportAnswer.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [ReportAnswer]s in the list and returns the deleted rows.
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
  Future<List<ReportAnswer>> delete(
    _is.DatabaseSession session,
    List<ReportAnswer> rows, {
    _is.OrderByBuilder<ReportAnswerTable>? orderBy,
    _is.OrderByListBuilder<ReportAnswerTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<ReportAnswer>(
      rows,
      orderBy: orderBy?.call(ReportAnswer.t),
      orderByList: orderByList?.call(ReportAnswer.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [ReportAnswer].
  Future<ReportAnswer> deleteRow(
    _is.DatabaseSession session,
    ReportAnswer row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<ReportAnswer>(
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
  Future<List<ReportAnswer>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<ReportAnswerTable> where,
    _is.OrderByBuilder<ReportAnswerTable>? orderBy,
    _is.OrderByListBuilder<ReportAnswerTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<ReportAnswer>(
      where: where(ReportAnswer.t),
      orderBy: orderBy?.call(ReportAnswer.t),
      orderByList: orderByList?.call(ReportAnswer.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ReportAnswerTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<ReportAnswer>(
      where: where?.call(ReportAnswer.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [ReportAnswer] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<ReportAnswerTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<ReportAnswer>(
      where: where(ReportAnswer.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
