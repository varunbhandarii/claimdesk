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

abstract class ReleaseRecord
    implements _is.TableRow<_is.UuidValue?>, _is.ProtocolSerialization {
  ReleaseRecord._({
    this.id,
    required this.venueId,
    required this.itemId,
    this.reportId,
    required this.claimantName,
    required this.idTypeSeen,
    required this.detailsMatched,
    required this.describedBeforeViewing,
    this.thirdPartyAuthorisationNote,
    this.signaturePath,
    required this.releasedByAuthUserId,
    DateTime? releasedAt,
  }) : releasedAt = releasedAt ?? DateTime.now();

  factory ReleaseRecord({
    _is.UuidValue? id,
    required _is.UuidValue venueId,
    required _is.UuidValue itemId,
    _is.UuidValue? reportId,
    required String claimantName,
    required String idTypeSeen,
    required int detailsMatched,
    required bool describedBeforeViewing,
    String? thirdPartyAuthorisationNote,
    String? signaturePath,
    required _is.UuidValue releasedByAuthUserId,
    DateTime? releasedAt,
  }) = _ReleaseRecordImpl;

  factory ReleaseRecord.fromJson(Map<String, dynamic> jsonSerialization) {
    return ReleaseRecord(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      venueId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['venueId'],
      ),
      itemId: _is.UuidValueJsonExtension.fromJson(jsonSerialization['itemId']),
      reportId: jsonSerialization['reportId'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['reportId']),
      claimantName: jsonSerialization['claimantName'] as String,
      idTypeSeen: jsonSerialization['idTypeSeen'] as String,
      detailsMatched: jsonSerialization['detailsMatched'] as int,
      describedBeforeViewing: _is.BoolJsonExtension.fromJson(
        jsonSerialization['describedBeforeViewing'],
      ),
      thirdPartyAuthorisationNote:
          jsonSerialization['thirdPartyAuthorisationNote'] as String?,
      signaturePath: jsonSerialization['signaturePath'] as String?,
      releasedByAuthUserId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['releasedByAuthUserId'],
      ),
      releasedAt: jsonSerialization['releasedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['releasedAt']),
    );
  }

  static final t = ReleaseRecordTable();

  static const db = ReleaseRecordRepository._();

  @override
  _is.UuidValue? id;

  _is.UuidValue venueId;

  _is.UuidValue itemId;

  _is.UuidValue? reportId;

  String claimantName;

  String idTypeSeen;

  int detailsMatched;

  bool describedBeforeViewing;

  String? thirdPartyAuthorisationNote;

  String? signaturePath;

  _is.UuidValue releasedByAuthUserId;

  DateTime releasedAt;

  @override
  _is.Table<_is.UuidValue?> get table => t;

  /// Returns a shallow copy of this [ReleaseRecord]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  ReleaseRecord copyWith({
    _is.UuidValue? id,
    _is.UuidValue? venueId,
    _is.UuidValue? itemId,
    _is.UuidValue? reportId,
    String? claimantName,
    String? idTypeSeen,
    int? detailsMatched,
    bool? describedBeforeViewing,
    String? thirdPartyAuthorisationNote,
    String? signaturePath,
    _is.UuidValue? releasedByAuthUserId,
    DateTime? releasedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ReleaseRecord',
      if (id != null) 'id': id?.toJson(),
      'venueId': venueId.toJson(),
      'itemId': itemId.toJson(),
      if (reportId != null) 'reportId': reportId?.toJson(),
      'claimantName': claimantName,
      'idTypeSeen': idTypeSeen,
      'detailsMatched': detailsMatched,
      'describedBeforeViewing': describedBeforeViewing,
      if (thirdPartyAuthorisationNote != null)
        'thirdPartyAuthorisationNote': thirdPartyAuthorisationNote,
      if (signaturePath != null) 'signaturePath': signaturePath,
      'releasedByAuthUserId': releasedByAuthUserId.toJson(),
      'releasedAt': releasedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'ReleaseRecord',
      if (id != null) 'id': id?.toJson(),
      'venueId': venueId.toJson(),
      'itemId': itemId.toJson(),
      if (reportId != null) 'reportId': reportId?.toJson(),
      'claimantName': claimantName,
      'idTypeSeen': idTypeSeen,
      'detailsMatched': detailsMatched,
      'describedBeforeViewing': describedBeforeViewing,
      if (thirdPartyAuthorisationNote != null)
        'thirdPartyAuthorisationNote': thirdPartyAuthorisationNote,
      if (signaturePath != null) 'signaturePath': signaturePath,
      'releasedByAuthUserId': releasedByAuthUserId.toJson(),
      'releasedAt': releasedAt.toJson(),
    };
  }

  static ReleaseRecordInclude include() {
    return ReleaseRecordInclude._();
  }

  static ReleaseRecordIncludeList includeList({
    _is.WhereExpressionBuilder<ReleaseRecordTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ReleaseRecordTable>? orderBy,
    _is.OrderByListBuilder<ReleaseRecordTable>? orderByList,
    ReleaseRecordInclude? include,
  }) {
    return ReleaseRecordIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ReleaseRecord.t),
      orderByList: orderByList?.call(ReleaseRecord.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ReleaseRecordImpl extends ReleaseRecord {
  _ReleaseRecordImpl({
    _is.UuidValue? id,
    required _is.UuidValue venueId,
    required _is.UuidValue itemId,
    _is.UuidValue? reportId,
    required String claimantName,
    required String idTypeSeen,
    required int detailsMatched,
    required bool describedBeforeViewing,
    String? thirdPartyAuthorisationNote,
    String? signaturePath,
    required _is.UuidValue releasedByAuthUserId,
    DateTime? releasedAt,
  }) : super._(
         id: id,
         venueId: venueId,
         itemId: itemId,
         reportId: reportId,
         claimantName: claimantName,
         idTypeSeen: idTypeSeen,
         detailsMatched: detailsMatched,
         describedBeforeViewing: describedBeforeViewing,
         thirdPartyAuthorisationNote: thirdPartyAuthorisationNote,
         signaturePath: signaturePath,
         releasedByAuthUserId: releasedByAuthUserId,
         releasedAt: releasedAt,
       );

  /// Returns a shallow copy of this [ReleaseRecord]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  ReleaseRecord copyWith({
    Object? id = _Undefined,
    _is.UuidValue? venueId,
    _is.UuidValue? itemId,
    Object? reportId = _Undefined,
    String? claimantName,
    String? idTypeSeen,
    int? detailsMatched,
    bool? describedBeforeViewing,
    Object? thirdPartyAuthorisationNote = _Undefined,
    Object? signaturePath = _Undefined,
    _is.UuidValue? releasedByAuthUserId,
    DateTime? releasedAt,
  }) {
    return ReleaseRecord(
      id: id is _is.UuidValue? ? id : this.id,
      venueId: venueId ?? this.venueId,
      itemId: itemId ?? this.itemId,
      reportId: reportId is _is.UuidValue? ? reportId : this.reportId,
      claimantName: claimantName ?? this.claimantName,
      idTypeSeen: idTypeSeen ?? this.idTypeSeen,
      detailsMatched: detailsMatched ?? this.detailsMatched,
      describedBeforeViewing:
          describedBeforeViewing ?? this.describedBeforeViewing,
      thirdPartyAuthorisationNote: thirdPartyAuthorisationNote is String?
          ? thirdPartyAuthorisationNote
          : this.thirdPartyAuthorisationNote,
      signaturePath: signaturePath is String?
          ? signaturePath
          : this.signaturePath,
      releasedByAuthUserId: releasedByAuthUserId ?? this.releasedByAuthUserId,
      releasedAt: releasedAt ?? this.releasedAt,
    );
  }
}

class ReleaseRecordUpdateTable extends _is.UpdateTable<ReleaseRecordTable> {
  ReleaseRecordUpdateTable(super.table);

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

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> reportId(
    _is.UuidValue? value,
  ) => _is.ColumnValue(
    table.reportId,
    value,
  );

  _is.ColumnValue<String, String> claimantName(String value) => _is.ColumnValue(
    table.claimantName,
    value,
  );

  _is.ColumnValue<String, String> idTypeSeen(String value) => _is.ColumnValue(
    table.idTypeSeen,
    value,
  );

  _is.ColumnValue<int, int> detailsMatched(int value) => _is.ColumnValue(
    table.detailsMatched,
    value,
  );

  _is.ColumnValue<bool, bool> describedBeforeViewing(bool value) =>
      _is.ColumnValue(
        table.describedBeforeViewing,
        value,
      );

  _is.ColumnValue<String, String> thirdPartyAuthorisationNote(String? value) =>
      _is.ColumnValue(
        table.thirdPartyAuthorisationNote,
        value,
      );

  _is.ColumnValue<String, String> signaturePath(String? value) =>
      _is.ColumnValue(
        table.signaturePath,
        value,
      );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> releasedByAuthUserId(
    _is.UuidValue value,
  ) => _is.ColumnValue(
    table.releasedByAuthUserId,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> releasedAt(DateTime value) =>
      _is.ColumnValue(
        table.releasedAt,
        value,
      );
}

class ReleaseRecordTable extends _is.Table<_is.UuidValue?> {
  ReleaseRecordTable({super.tableRelation})
    : super(tableName: 'release_record') {
    updateTable = ReleaseRecordUpdateTable(this);
    venueId = _is.ColumnUuid(
      'venueId',
      this,
    );
    itemId = _is.ColumnUuid(
      'itemId',
      this,
    );
    reportId = _is.ColumnUuid(
      'reportId',
      this,
    );
    claimantName = _is.ColumnString(
      'claimantName',
      this,
    );
    idTypeSeen = _is.ColumnString(
      'idTypeSeen',
      this,
    );
    detailsMatched = _is.ColumnInt(
      'detailsMatched',
      this,
    );
    describedBeforeViewing = _is.ColumnBool(
      'describedBeforeViewing',
      this,
    );
    thirdPartyAuthorisationNote = _is.ColumnString(
      'thirdPartyAuthorisationNote',
      this,
    );
    signaturePath = _is.ColumnString(
      'signaturePath',
      this,
    );
    releasedByAuthUserId = _is.ColumnUuid(
      'releasedByAuthUserId',
      this,
    );
    releasedAt = _is.ColumnDateTime(
      'releasedAt',
      this,
      hasDefault: true,
    );
  }

  late final ReleaseRecordUpdateTable updateTable;

  late final _is.ColumnUuid venueId;

  late final _is.ColumnUuid itemId;

  late final _is.ColumnUuid reportId;

  late final _is.ColumnString claimantName;

  late final _is.ColumnString idTypeSeen;

  late final _is.ColumnInt detailsMatched;

  late final _is.ColumnBool describedBeforeViewing;

  late final _is.ColumnString thirdPartyAuthorisationNote;

  late final _is.ColumnString signaturePath;

  late final _is.ColumnUuid releasedByAuthUserId;

  late final _is.ColumnDateTime releasedAt;

  @override
  List<_is.Column> get columns => [
    id,
    venueId,
    itemId,
    reportId,
    claimantName,
    idTypeSeen,
    detailsMatched,
    describedBeforeViewing,
    thirdPartyAuthorisationNote,
    signaturePath,
    releasedByAuthUserId,
    releasedAt,
  ];
}

class ReleaseRecordInclude extends _is.IncludeObject {
  ReleaseRecordInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue?> get table => ReleaseRecord.t;
}

class ReleaseRecordIncludeList extends _is.IncludeList {
  ReleaseRecordIncludeList._({
    _is.WhereExpressionBuilder<ReleaseRecordTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(ReleaseRecord.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue?> get table => ReleaseRecord.t;
}

class ReleaseRecordRepository {
  const ReleaseRecordRepository._();

  /// Returns a list of [ReleaseRecord]s matching the given query parameters.
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
  Future<List<ReleaseRecord>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ReleaseRecordTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ReleaseRecordTable>? orderBy,
    _is.OrderByListBuilder<ReleaseRecordTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<ReleaseRecord>(
      where: where?.call(ReleaseRecord.t),
      orderBy: orderBy?.call(ReleaseRecord.t),
      orderByList: orderByList?.call(ReleaseRecord.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [ReleaseRecord] matching the given query parameters.
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
  Future<ReleaseRecord?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ReleaseRecordTable>? where,
    int? offset,
    _is.OrderByBuilder<ReleaseRecordTable>? orderBy,
    _is.OrderByListBuilder<ReleaseRecordTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<ReleaseRecord>(
      where: where?.call(ReleaseRecord.t),
      orderBy: orderBy?.call(ReleaseRecord.t),
      orderByList: orderByList?.call(ReleaseRecord.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [ReleaseRecord] by its [id] or null if no such row exists.
  Future<ReleaseRecord?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<ReleaseRecord>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [ReleaseRecord]s in the list and returns the inserted rows.
  ///
  /// The returned [ReleaseRecord]s will have their `id` fields set.
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
  Future<List<ReleaseRecord>> insert(
    _is.DatabaseSession session,
    List<ReleaseRecord> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<ReleaseRecord>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [ReleaseRecord] and returns the inserted row.
  ///
  /// The returned [ReleaseRecord] will have its `id` field set.
  Future<ReleaseRecord> insertRow(
    _is.DatabaseSession session,
    ReleaseRecord row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<ReleaseRecord>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [ReleaseRecord]s in the list and returns the resulting rows.
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
  /// The returned [ReleaseRecord]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ReleaseRecord>> upsert(
    _is.DatabaseSession session,
    List<ReleaseRecord> rows, {
    required _is.ColumnSelections<ReleaseRecordTable> conflictColumns,
    _is.ColumnSelections<ReleaseRecordTable>? updateColumns,
    _is.WhereExpressionBuilder<ReleaseRecordTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<ReleaseRecord>(
      rows,
      conflictColumns: conflictColumns(ReleaseRecord.t),
      updateColumns: updateColumns?.call(ReleaseRecord.t),
      updateWhere: updateWhere?.call(ReleaseRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [ReleaseRecord] and returns the resulting row.
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
  /// The returned [ReleaseRecord] will have its `id` field set.
  Future<ReleaseRecord?> upsertRow(
    _is.DatabaseSession session,
    ReleaseRecord row, {
    required _is.ColumnSelections<ReleaseRecordTable> conflictColumns,
    _is.ColumnSelections<ReleaseRecordTable>? updateColumns,
    _is.WhereExpressionBuilder<ReleaseRecordTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<ReleaseRecord>(
      row,
      conflictColumns: conflictColumns(ReleaseRecord.t),
      updateColumns: updateColumns?.call(ReleaseRecord.t),
      updateWhere: updateWhere?.call(ReleaseRecord.t),
      transaction: transaction,
    );
  }

  /// Updates all [ReleaseRecord]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ReleaseRecord>> update(
    _is.DatabaseSession session,
    List<ReleaseRecord> rows, {
    _is.ColumnSelections<ReleaseRecordTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<ReleaseRecord>(
      rows,
      columns: columns?.call(ReleaseRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [ReleaseRecord]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<ReleaseRecord> updateRow(
    _is.DatabaseSession session,
    ReleaseRecord row, {
    _is.ColumnSelections<ReleaseRecordTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<ReleaseRecord>(
      row,
      columns: columns?.call(ReleaseRecord.t),
      transaction: transaction,
    );
  }

  /// Updates a single [ReleaseRecord] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<ReleaseRecord?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<ReleaseRecordUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<ReleaseRecord>(
      id,
      columnValues: columnValues(ReleaseRecord.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [ReleaseRecord]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ReleaseRecord>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<ReleaseRecordUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<ReleaseRecordTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ReleaseRecordTable>? orderBy,
    _is.OrderByListBuilder<ReleaseRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<ReleaseRecord>(
      columnValues: columnValues(ReleaseRecord.t.updateTable),
      where: where(ReleaseRecord.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ReleaseRecord.t),
      orderByList: orderByList?.call(ReleaseRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [ReleaseRecord]s in the list and returns the deleted rows.
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
  Future<List<ReleaseRecord>> delete(
    _is.DatabaseSession session,
    List<ReleaseRecord> rows, {
    _is.OrderByBuilder<ReleaseRecordTable>? orderBy,
    _is.OrderByListBuilder<ReleaseRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<ReleaseRecord>(
      rows,
      orderBy: orderBy?.call(ReleaseRecord.t),
      orderByList: orderByList?.call(ReleaseRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [ReleaseRecord].
  Future<ReleaseRecord> deleteRow(
    _is.DatabaseSession session,
    ReleaseRecord row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<ReleaseRecord>(
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
  Future<List<ReleaseRecord>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<ReleaseRecordTable> where,
    _is.OrderByBuilder<ReleaseRecordTable>? orderBy,
    _is.OrderByListBuilder<ReleaseRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<ReleaseRecord>(
      where: where(ReleaseRecord.t),
      orderBy: orderBy?.call(ReleaseRecord.t),
      orderByList: orderByList?.call(ReleaseRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ReleaseRecordTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<ReleaseRecord>(
      where: where?.call(ReleaseRecord.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [ReleaseRecord] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<ReleaseRecordTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<ReleaseRecord>(
      where: where(ReleaseRecord.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
