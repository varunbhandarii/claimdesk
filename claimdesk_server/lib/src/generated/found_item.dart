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
import 'package:claimdesk_server/src/generated/protocol.dart' as _ii1g677k;
import 'package:serverpod/serverpod.dart' as _is;
import 'item_attributes.dart' as _i43d0yeo;
import 'item_status.dart' as _ibbyonnn;
import 'value_band.dart' as _iphilgki;

abstract class FoundItem
    implements _is.TableRow<_is.UuidValue?>, _is.ProtocolSerialization {
  FoundItem._({
    this.id,
    required this.venueId,
    this.zoneId,
    _ibbyonnn.ItemStatus? status,
    required this.refCode,
    this.photoPath,
    this.thumbPath,
    bool? restricted,
    this.attributes,
    this.captionText,
    this.embedding,
    this.embeddingModel,
    _iphilgki.ValueBand? valueBand,
    this.storageBin,
    this.privateNotes,
    this.finderName,
    DateTime? foundAt,
    required this.loggedByAuthUserId,
    this.holdUntil,
    this.handoffDueAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : status = status ?? _ibbyonnn.ItemStatus.intake,
       restricted = restricted ?? false,
       valueBand = valueBand ?? _iphilgki.ValueBand.under20,
       foundAt = foundAt ?? DateTime.now(),
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory FoundItem({
    _is.UuidValue? id,
    required _is.UuidValue venueId,
    _is.UuidValue? zoneId,
    _ibbyonnn.ItemStatus? status,
    required String refCode,
    String? photoPath,
    String? thumbPath,
    bool? restricted,
    _i43d0yeo.ItemAttributes? attributes,
    String? captionText,
    _is.Vector? embedding,
    String? embeddingModel,
    _iphilgki.ValueBand? valueBand,
    String? storageBin,
    String? privateNotes,
    String? finderName,
    DateTime? foundAt,
    required _is.UuidValue loggedByAuthUserId,
    DateTime? holdUntil,
    DateTime? handoffDueAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _FoundItemImpl;

  factory FoundItem.fromJson(Map<String, dynamic> jsonSerialization) {
    return FoundItem(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      venueId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['venueId'],
      ),
      zoneId: jsonSerialization['zoneId'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['zoneId']),
      status: jsonSerialization['status'] == null
          ? null
          : _ibbyonnn.ItemStatus.fromJson(
              (jsonSerialization['status'] as String),
            ),
      refCode: jsonSerialization['refCode'] as String,
      photoPath: jsonSerialization['photoPath'] as String?,
      thumbPath: jsonSerialization['thumbPath'] as String?,
      restricted: jsonSerialization['restricted'] == null
          ? null
          : _is.BoolJsonExtension.fromJson(jsonSerialization['restricted']),
      attributes: jsonSerialization['attributes'] == null
          ? null
          : _ii1g677k.Protocol().deserialize<_i43d0yeo.ItemAttributes>(
              jsonSerialization['attributes'],
            ),
      captionText: jsonSerialization['captionText'] as String?,
      embedding: jsonSerialization['embedding'] == null
          ? null
          : _is.VectorJsonExtension.fromJson(jsonSerialization['embedding']),
      embeddingModel: jsonSerialization['embeddingModel'] as String?,
      valueBand: jsonSerialization['valueBand'] == null
          ? null
          : _iphilgki.ValueBand.fromJson(
              (jsonSerialization['valueBand'] as String),
            ),
      storageBin: jsonSerialization['storageBin'] as String?,
      privateNotes: jsonSerialization['privateNotes'] as String?,
      finderName: jsonSerialization['finderName'] as String?,
      foundAt: jsonSerialization['foundAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['foundAt']),
      loggedByAuthUserId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['loggedByAuthUserId'],
      ),
      holdUntil: jsonSerialization['holdUntil'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['holdUntil']),
      handoffDueAt: jsonSerialization['handoffDueAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(
              jsonSerialization['handoffDueAt'],
            ),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
    );
  }

  static final t = FoundItemTable();

  static const db = FoundItemRepository._();

  @override
  _is.UuidValue? id;

  _is.UuidValue venueId;

  _is.UuidValue? zoneId;

  _ibbyonnn.ItemStatus status;

  String refCode;

  String? photoPath;

  String? thumbPath;

  bool restricted;

  _i43d0yeo.ItemAttributes? attributes;

  String? captionText;

  _is.Vector? embedding;

  String? embeddingModel;

  _iphilgki.ValueBand valueBand;

  String? storageBin;

  String? privateNotes;

  String? finderName;

  DateTime foundAt;

  _is.UuidValue loggedByAuthUserId;

  DateTime? holdUntil;

  DateTime? handoffDueAt;

  DateTime createdAt;

  DateTime updatedAt;

  @override
  _is.Table<_is.UuidValue?> get table => t;

  /// Returns a shallow copy of this [FoundItem]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  FoundItem copyWith({
    _is.UuidValue? id,
    _is.UuidValue? venueId,
    _is.UuidValue? zoneId,
    _ibbyonnn.ItemStatus? status,
    String? refCode,
    String? photoPath,
    String? thumbPath,
    bool? restricted,
    _i43d0yeo.ItemAttributes? attributes,
    String? captionText,
    _is.Vector? embedding,
    String? embeddingModel,
    _iphilgki.ValueBand? valueBand,
    String? storageBin,
    String? privateNotes,
    String? finderName,
    DateTime? foundAt,
    _is.UuidValue? loggedByAuthUserId,
    DateTime? holdUntil,
    DateTime? handoffDueAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'FoundItem',
      if (id != null) 'id': id?.toJson(),
      'venueId': venueId.toJson(),
      if (zoneId != null) 'zoneId': zoneId?.toJson(),
      'status': status.toJson(),
      'refCode': refCode,
      if (photoPath != null) 'photoPath': photoPath,
      if (thumbPath != null) 'thumbPath': thumbPath,
      'restricted': restricted,
      if (attributes != null) 'attributes': attributes?.toJson(),
      if (captionText != null) 'captionText': captionText,
      if (embedding != null) 'embedding': embedding?.toJson(),
      if (embeddingModel != null) 'embeddingModel': embeddingModel,
      'valueBand': valueBand.toJson(),
      if (storageBin != null) 'storageBin': storageBin,
      if (privateNotes != null) 'privateNotes': privateNotes,
      if (finderName != null) 'finderName': finderName,
      'foundAt': foundAt.toJson(),
      'loggedByAuthUserId': loggedByAuthUserId.toJson(),
      if (holdUntil != null) 'holdUntil': holdUntil?.toJson(),
      if (handoffDueAt != null) 'handoffDueAt': handoffDueAt?.toJson(),
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'FoundItem',
      if (id != null) 'id': id?.toJson(),
      'venueId': venueId.toJson(),
      if (zoneId != null) 'zoneId': zoneId?.toJson(),
      'status': status.toJson(),
      'refCode': refCode,
      if (photoPath != null) 'photoPath': photoPath,
      if (thumbPath != null) 'thumbPath': thumbPath,
      'restricted': restricted,
      if (attributes != null) 'attributes': attributes?.toJsonForProtocol(),
      if (captionText != null) 'captionText': captionText,
      if (embedding != null) 'embedding': embedding?.toJson(),
      if (embeddingModel != null) 'embeddingModel': embeddingModel,
      'valueBand': valueBand.toJson(),
      if (storageBin != null) 'storageBin': storageBin,
      if (privateNotes != null) 'privateNotes': privateNotes,
      if (finderName != null) 'finderName': finderName,
      'foundAt': foundAt.toJson(),
      'loggedByAuthUserId': loggedByAuthUserId.toJson(),
      if (holdUntil != null) 'holdUntil': holdUntil?.toJson(),
      if (handoffDueAt != null) 'handoffDueAt': handoffDueAt?.toJson(),
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  static FoundItemInclude include() {
    return FoundItemInclude._();
  }

  static FoundItemIncludeList includeList({
    _is.WhereExpressionBuilder<FoundItemTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<FoundItemTable>? orderBy,
    _is.OrderByListBuilder<FoundItemTable>? orderByList,
    FoundItemInclude? include,
  }) {
    return FoundItemIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(FoundItem.t),
      orderByList: orderByList?.call(FoundItem.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _FoundItemImpl extends FoundItem {
  _FoundItemImpl({
    _is.UuidValue? id,
    required _is.UuidValue venueId,
    _is.UuidValue? zoneId,
    _ibbyonnn.ItemStatus? status,
    required String refCode,
    String? photoPath,
    String? thumbPath,
    bool? restricted,
    _i43d0yeo.ItemAttributes? attributes,
    String? captionText,
    _is.Vector? embedding,
    String? embeddingModel,
    _iphilgki.ValueBand? valueBand,
    String? storageBin,
    String? privateNotes,
    String? finderName,
    DateTime? foundAt,
    required _is.UuidValue loggedByAuthUserId,
    DateTime? holdUntil,
    DateTime? handoffDueAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : super._(
         id: id,
         venueId: venueId,
         zoneId: zoneId,
         status: status,
         refCode: refCode,
         photoPath: photoPath,
         thumbPath: thumbPath,
         restricted: restricted,
         attributes: attributes,
         captionText: captionText,
         embedding: embedding,
         embeddingModel: embeddingModel,
         valueBand: valueBand,
         storageBin: storageBin,
         privateNotes: privateNotes,
         finderName: finderName,
         foundAt: foundAt,
         loggedByAuthUserId: loggedByAuthUserId,
         holdUntil: holdUntil,
         handoffDueAt: handoffDueAt,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [FoundItem]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  FoundItem copyWith({
    Object? id = _Undefined,
    _is.UuidValue? venueId,
    Object? zoneId = _Undefined,
    _ibbyonnn.ItemStatus? status,
    String? refCode,
    Object? photoPath = _Undefined,
    Object? thumbPath = _Undefined,
    bool? restricted,
    Object? attributes = _Undefined,
    Object? captionText = _Undefined,
    Object? embedding = _Undefined,
    Object? embeddingModel = _Undefined,
    _iphilgki.ValueBand? valueBand,
    Object? storageBin = _Undefined,
    Object? privateNotes = _Undefined,
    Object? finderName = _Undefined,
    DateTime? foundAt,
    _is.UuidValue? loggedByAuthUserId,
    Object? holdUntil = _Undefined,
    Object? handoffDueAt = _Undefined,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FoundItem(
      id: id is _is.UuidValue? ? id : this.id,
      venueId: venueId ?? this.venueId,
      zoneId: zoneId is _is.UuidValue? ? zoneId : this.zoneId,
      status: status ?? this.status,
      refCode: refCode ?? this.refCode,
      photoPath: photoPath is String? ? photoPath : this.photoPath,
      thumbPath: thumbPath is String? ? thumbPath : this.thumbPath,
      restricted: restricted ?? this.restricted,
      attributes: attributes is _i43d0yeo.ItemAttributes?
          ? attributes
          : this.attributes?.copyWith(),
      captionText: captionText is String? ? captionText : this.captionText,
      embedding: embedding is _is.Vector? ? embedding : this.embedding?.clone(),
      embeddingModel: embeddingModel is String?
          ? embeddingModel
          : this.embeddingModel,
      valueBand: valueBand ?? this.valueBand,
      storageBin: storageBin is String? ? storageBin : this.storageBin,
      privateNotes: privateNotes is String? ? privateNotes : this.privateNotes,
      finderName: finderName is String? ? finderName : this.finderName,
      foundAt: foundAt ?? this.foundAt,
      loggedByAuthUserId: loggedByAuthUserId ?? this.loggedByAuthUserId,
      holdUntil: holdUntil is DateTime? ? holdUntil : this.holdUntil,
      handoffDueAt: handoffDueAt is DateTime?
          ? handoffDueAt
          : this.handoffDueAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class FoundItemUpdateTable extends _is.UpdateTable<FoundItemTable> {
  FoundItemUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> venueId(_is.UuidValue value) =>
      _is.ColumnValue(
        table.venueId,
        value,
      );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> zoneId(_is.UuidValue? value) =>
      _is.ColumnValue(
        table.zoneId,
        value,
      );

  _is.ColumnValue<_ibbyonnn.ItemStatus, _ibbyonnn.ItemStatus> status(
    _ibbyonnn.ItemStatus value,
  ) => _is.ColumnValue(
    table.status,
    value,
  );

  _is.ColumnValue<String, String> refCode(String value) => _is.ColumnValue(
    table.refCode,
    value,
  );

  _is.ColumnValue<String, String> photoPath(String? value) => _is.ColumnValue(
    table.photoPath,
    value,
  );

  _is.ColumnValue<String, String> thumbPath(String? value) => _is.ColumnValue(
    table.thumbPath,
    value,
  );

  _is.ColumnValue<bool, bool> restricted(bool value) => _is.ColumnValue(
    table.restricted,
    value,
  );

  _is.ColumnValue<_i43d0yeo.ItemAttributes, _i43d0yeo.ItemAttributes>
  attributes(_i43d0yeo.ItemAttributes? value) => _is.ColumnValue(
    table.attributes,
    value,
  );

  _is.ColumnValue<String, String> captionText(String? value) => _is.ColumnValue(
    table.captionText,
    value,
  );

  _is.ColumnValue<_is.Vector, _is.Vector> embedding(_is.Vector? value) =>
      _is.ColumnValue(
        table.embedding,
        value,
      );

  _is.ColumnValue<String, String> embeddingModel(String? value) =>
      _is.ColumnValue(
        table.embeddingModel,
        value,
      );

  _is.ColumnValue<_iphilgki.ValueBand, _iphilgki.ValueBand> valueBand(
    _iphilgki.ValueBand value,
  ) => _is.ColumnValue(
    table.valueBand,
    value,
  );

  _is.ColumnValue<String, String> storageBin(String? value) => _is.ColumnValue(
    table.storageBin,
    value,
  );

  _is.ColumnValue<String, String> privateNotes(String? value) =>
      _is.ColumnValue(
        table.privateNotes,
        value,
      );

  _is.ColumnValue<String, String> finderName(String? value) => _is.ColumnValue(
    table.finderName,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> foundAt(DateTime value) =>
      _is.ColumnValue(
        table.foundAt,
        value,
      );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> loggedByAuthUserId(
    _is.UuidValue value,
  ) => _is.ColumnValue(
    table.loggedByAuthUserId,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> holdUntil(DateTime? value) =>
      _is.ColumnValue(
        table.holdUntil,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> handoffDueAt(DateTime? value) =>
      _is.ColumnValue(
        table.handoffDueAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> updatedAt(DateTime value) =>
      _is.ColumnValue(
        table.updatedAt,
        value,
      );
}

class FoundItemTable extends _is.Table<_is.UuidValue?> {
  FoundItemTable({super.tableRelation}) : super(tableName: 'found_item') {
    updateTable = FoundItemUpdateTable(this);
    venueId = _is.ColumnUuid(
      'venueId',
      this,
    );
    zoneId = _is.ColumnUuid(
      'zoneId',
      this,
    );
    status = _is.ColumnEnum(
      'status',
      this,
      _is.EnumSerialization.byName,
      hasDefault: true,
    );
    refCode = _is.ColumnString(
      'refCode',
      this,
    );
    photoPath = _is.ColumnString(
      'photoPath',
      this,
    );
    thumbPath = _is.ColumnString(
      'thumbPath',
      this,
    );
    restricted = _is.ColumnBool(
      'restricted',
      this,
      hasDefault: true,
    );
    attributes = _is.ColumnStructured<_i43d0yeo.ItemAttributes>(
      'attributes',
      this,
    );
    captionText = _is.ColumnString(
      'captionText',
      this,
    );
    embedding = _is.ColumnVector(
      'embedding',
      this,
      dimension: 1536,
    );
    embeddingModel = _is.ColumnString(
      'embeddingModel',
      this,
    );
    valueBand = _is.ColumnEnum(
      'valueBand',
      this,
      _is.EnumSerialization.byName,
      hasDefault: true,
    );
    storageBin = _is.ColumnString(
      'storageBin',
      this,
    );
    privateNotes = _is.ColumnString(
      'privateNotes',
      this,
    );
    finderName = _is.ColumnString(
      'finderName',
      this,
    );
    foundAt = _is.ColumnDateTime(
      'foundAt',
      this,
      hasDefault: true,
    );
    loggedByAuthUserId = _is.ColumnUuid(
      'loggedByAuthUserId',
      this,
    );
    holdUntil = _is.ColumnDateTime(
      'holdUntil',
      this,
    );
    handoffDueAt = _is.ColumnDateTime(
      'handoffDueAt',
      this,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
      hasDefault: true,
    );
    updatedAt = _is.ColumnDateTime(
      'updatedAt',
      this,
      hasDefault: true,
    );
  }

  late final FoundItemUpdateTable updateTable;

  late final _is.ColumnUuid venueId;

  late final _is.ColumnUuid zoneId;

  late final _is.ColumnEnum<_ibbyonnn.ItemStatus> status;

  late final _is.ColumnString refCode;

  late final _is.ColumnString photoPath;

  late final _is.ColumnString thumbPath;

  late final _is.ColumnBool restricted;

  late final _is.ColumnStructured<_i43d0yeo.ItemAttributes> attributes;

  late final _is.ColumnString captionText;

  late final _is.ColumnVector embedding;

  late final _is.ColumnString embeddingModel;

  late final _is.ColumnEnum<_iphilgki.ValueBand> valueBand;

  late final _is.ColumnString storageBin;

  late final _is.ColumnString privateNotes;

  late final _is.ColumnString finderName;

  late final _is.ColumnDateTime foundAt;

  late final _is.ColumnUuid loggedByAuthUserId;

  late final _is.ColumnDateTime holdUntil;

  late final _is.ColumnDateTime handoffDueAt;

  late final _is.ColumnDateTime createdAt;

  late final _is.ColumnDateTime updatedAt;

  @override
  List<_is.Column> get columns => [
    id,
    venueId,
    zoneId,
    status,
    refCode,
    photoPath,
    thumbPath,
    restricted,
    attributes,
    captionText,
    embedding,
    embeddingModel,
    valueBand,
    storageBin,
    privateNotes,
    finderName,
    foundAt,
    loggedByAuthUserId,
    holdUntil,
    handoffDueAt,
    createdAt,
    updatedAt,
  ];
}

class FoundItemInclude extends _is.IncludeObject {
  FoundItemInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue?> get table => FoundItem.t;
}

class FoundItemIncludeList extends _is.IncludeList {
  FoundItemIncludeList._({
    _is.WhereExpressionBuilder<FoundItemTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(FoundItem.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue?> get table => FoundItem.t;
}

class FoundItemRepository {
  const FoundItemRepository._();

  /// Returns a list of [FoundItem]s matching the given query parameters.
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
  Future<List<FoundItem>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<FoundItemTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<FoundItemTable>? orderBy,
    _is.OrderByListBuilder<FoundItemTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<FoundItem>(
      where: where?.call(FoundItem.t),
      orderBy: orderBy?.call(FoundItem.t),
      orderByList: orderByList?.call(FoundItem.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [FoundItem] matching the given query parameters.
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
  Future<FoundItem?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<FoundItemTable>? where,
    int? offset,
    _is.OrderByBuilder<FoundItemTable>? orderBy,
    _is.OrderByListBuilder<FoundItemTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<FoundItem>(
      where: where?.call(FoundItem.t),
      orderBy: orderBy?.call(FoundItem.t),
      orderByList: orderByList?.call(FoundItem.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [FoundItem] by its [id] or null if no such row exists.
  Future<FoundItem?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<FoundItem>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [FoundItem]s in the list and returns the inserted rows.
  ///
  /// The returned [FoundItem]s will have their `id` fields set.
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
  Future<List<FoundItem>> insert(
    _is.DatabaseSession session,
    List<FoundItem> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<FoundItem>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [FoundItem] and returns the inserted row.
  ///
  /// The returned [FoundItem] will have its `id` field set.
  Future<FoundItem> insertRow(
    _is.DatabaseSession session,
    FoundItem row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<FoundItem>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [FoundItem]s in the list and returns the resulting rows.
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
  /// The returned [FoundItem]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<FoundItem>> upsert(
    _is.DatabaseSession session,
    List<FoundItem> rows, {
    required _is.ColumnSelections<FoundItemTable> conflictColumns,
    _is.ColumnSelections<FoundItemTable>? updateColumns,
    _is.WhereExpressionBuilder<FoundItemTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<FoundItem>(
      rows,
      conflictColumns: conflictColumns(FoundItem.t),
      updateColumns: updateColumns?.call(FoundItem.t),
      updateWhere: updateWhere?.call(FoundItem.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [FoundItem] and returns the resulting row.
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
  /// The returned [FoundItem] will have its `id` field set.
  Future<FoundItem?> upsertRow(
    _is.DatabaseSession session,
    FoundItem row, {
    required _is.ColumnSelections<FoundItemTable> conflictColumns,
    _is.ColumnSelections<FoundItemTable>? updateColumns,
    _is.WhereExpressionBuilder<FoundItemTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<FoundItem>(
      row,
      conflictColumns: conflictColumns(FoundItem.t),
      updateColumns: updateColumns?.call(FoundItem.t),
      updateWhere: updateWhere?.call(FoundItem.t),
      transaction: transaction,
    );
  }

  /// Updates all [FoundItem]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<FoundItem>> update(
    _is.DatabaseSession session,
    List<FoundItem> rows, {
    _is.ColumnSelections<FoundItemTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<FoundItem>(
      rows,
      columns: columns?.call(FoundItem.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [FoundItem]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<FoundItem> updateRow(
    _is.DatabaseSession session,
    FoundItem row, {
    _is.ColumnSelections<FoundItemTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<FoundItem>(
      row,
      columns: columns?.call(FoundItem.t),
      transaction: transaction,
    );
  }

  /// Updates a single [FoundItem] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<FoundItem?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<FoundItemUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<FoundItem>(
      id,
      columnValues: columnValues(FoundItem.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [FoundItem]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<FoundItem>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<FoundItemUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<FoundItemTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<FoundItemTable>? orderBy,
    _is.OrderByListBuilder<FoundItemTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<FoundItem>(
      columnValues: columnValues(FoundItem.t.updateTable),
      where: where(FoundItem.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(FoundItem.t),
      orderByList: orderByList?.call(FoundItem.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [FoundItem]s in the list and returns the deleted rows.
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
  Future<List<FoundItem>> delete(
    _is.DatabaseSession session,
    List<FoundItem> rows, {
    _is.OrderByBuilder<FoundItemTable>? orderBy,
    _is.OrderByListBuilder<FoundItemTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<FoundItem>(
      rows,
      orderBy: orderBy?.call(FoundItem.t),
      orderByList: orderByList?.call(FoundItem.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [FoundItem].
  Future<FoundItem> deleteRow(
    _is.DatabaseSession session,
    FoundItem row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<FoundItem>(
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
  Future<List<FoundItem>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<FoundItemTable> where,
    _is.OrderByBuilder<FoundItemTable>? orderBy,
    _is.OrderByListBuilder<FoundItemTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<FoundItem>(
      where: where(FoundItem.t),
      orderBy: orderBy?.call(FoundItem.t),
      orderByList: orderByList?.call(FoundItem.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<FoundItemTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<FoundItem>(
      where: where?.call(FoundItem.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [FoundItem] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<FoundItemTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<FoundItem>(
      where: where(FoundItem.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
