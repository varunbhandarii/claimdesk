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
import 'report_status.dart' as _i8pcsu0p;

abstract class LostReport
    implements _is.TableRow<_is.UuidValue?>, _is.ProtocolSerialization {
  LostReport._({
    this.id,
    required this.venueId,
    _i8pcsu0p.ReportStatus? status,
    required this.refCode,
    required this.publicToken,
    required this.rawText,
    this.categoryHint,
    required this.colourHints,
    this.brandHint,
    this.zoneId,
    this.whereText,
    this.lostAt,
    int? lostAtFuzzyDays,
    this.ownerOnlyDetails,
    this.contactEmail,
    this.ownerName,
    this.attributes,
    this.embedding,
    this.embeddingModel,
    this.duplicateOfReportId,
    this.ipHash,
    this.closedAt,
    this.contactPurgedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : status = status ?? _i8pcsu0p.ReportStatus.received,
       lostAtFuzzyDays = lostAtFuzzyDays ?? 0,
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory LostReport({
    _is.UuidValue? id,
    required _is.UuidValue venueId,
    _i8pcsu0p.ReportStatus? status,
    required String refCode,
    required String publicToken,
    required String rawText,
    String? categoryHint,
    required List<String> colourHints,
    String? brandHint,
    _is.UuidValue? zoneId,
    String? whereText,
    DateTime? lostAt,
    int? lostAtFuzzyDays,
    String? ownerOnlyDetails,
    String? contactEmail,
    String? ownerName,
    _i43d0yeo.ItemAttributes? attributes,
    _is.Vector? embedding,
    String? embeddingModel,
    _is.UuidValue? duplicateOfReportId,
    String? ipHash,
    DateTime? closedAt,
    DateTime? contactPurgedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _LostReportImpl;

  factory LostReport.fromJson(Map<String, dynamic> jsonSerialization) {
    return LostReport(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      venueId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['venueId'],
      ),
      status: jsonSerialization['status'] == null
          ? null
          : _i8pcsu0p.ReportStatus.fromJson(
              (jsonSerialization['status'] as String),
            ),
      refCode: jsonSerialization['refCode'] as String,
      publicToken: jsonSerialization['publicToken'] as String,
      rawText: jsonSerialization['rawText'] as String,
      categoryHint: jsonSerialization['categoryHint'] as String?,
      colourHints: _ii1g677k.Protocol().deserialize<List<String>>(
        jsonSerialization['colourHints'],
      ),
      brandHint: jsonSerialization['brandHint'] as String?,
      zoneId: jsonSerialization['zoneId'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['zoneId']),
      whereText: jsonSerialization['whereText'] as String?,
      lostAt: jsonSerialization['lostAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['lostAt']),
      lostAtFuzzyDays: jsonSerialization['lostAtFuzzyDays'] as int?,
      ownerOnlyDetails: jsonSerialization['ownerOnlyDetails'] as String?,
      contactEmail: jsonSerialization['contactEmail'] as String?,
      ownerName: jsonSerialization['ownerName'] as String?,
      attributes: jsonSerialization['attributes'] == null
          ? null
          : _ii1g677k.Protocol().deserialize<_i43d0yeo.ItemAttributes>(
              jsonSerialization['attributes'],
            ),
      embedding: jsonSerialization['embedding'] == null
          ? null
          : _is.VectorJsonExtension.fromJson(jsonSerialization['embedding']),
      embeddingModel: jsonSerialization['embeddingModel'] as String?,
      duplicateOfReportId: jsonSerialization['duplicateOfReportId'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(
              jsonSerialization['duplicateOfReportId'],
            ),
      ipHash: jsonSerialization['ipHash'] as String?,
      closedAt: jsonSerialization['closedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['closedAt']),
      contactPurgedAt: jsonSerialization['contactPurgedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(
              jsonSerialization['contactPurgedAt'],
            ),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
    );
  }

  static final t = LostReportTable();

  static const db = LostReportRepository._();

  @override
  _is.UuidValue? id;

  _is.UuidValue venueId;

  _i8pcsu0p.ReportStatus status;

  String refCode;

  String publicToken;

  String rawText;

  String? categoryHint;

  List<String> colourHints;

  String? brandHint;

  _is.UuidValue? zoneId;

  String? whereText;

  DateTime? lostAt;

  int lostAtFuzzyDays;

  String? ownerOnlyDetails;

  String? contactEmail;

  String? ownerName;

  _i43d0yeo.ItemAttributes? attributes;

  _is.Vector? embedding;

  String? embeddingModel;

  _is.UuidValue? duplicateOfReportId;

  String? ipHash;

  DateTime? closedAt;

  DateTime? contactPurgedAt;

  DateTime createdAt;

  DateTime updatedAt;

  @override
  _is.Table<_is.UuidValue?> get table => t;

  /// Returns a shallow copy of this [LostReport]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  LostReport copyWith({
    _is.UuidValue? id,
    _is.UuidValue? venueId,
    _i8pcsu0p.ReportStatus? status,
    String? refCode,
    String? publicToken,
    String? rawText,
    String? categoryHint,
    List<String>? colourHints,
    String? brandHint,
    _is.UuidValue? zoneId,
    String? whereText,
    DateTime? lostAt,
    int? lostAtFuzzyDays,
    String? ownerOnlyDetails,
    String? contactEmail,
    String? ownerName,
    _i43d0yeo.ItemAttributes? attributes,
    _is.Vector? embedding,
    String? embeddingModel,
    _is.UuidValue? duplicateOfReportId,
    String? ipHash,
    DateTime? closedAt,
    DateTime? contactPurgedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'LostReport',
      if (id != null) 'id': id?.toJson(),
      'venueId': venueId.toJson(),
      'status': status.toJson(),
      'refCode': refCode,
      'publicToken': publicToken,
      'rawText': rawText,
      if (categoryHint != null) 'categoryHint': categoryHint,
      'colourHints': colourHints.toJson(),
      if (brandHint != null) 'brandHint': brandHint,
      if (zoneId != null) 'zoneId': zoneId?.toJson(),
      if (whereText != null) 'whereText': whereText,
      if (lostAt != null) 'lostAt': lostAt?.toJson(),
      'lostAtFuzzyDays': lostAtFuzzyDays,
      if (ownerOnlyDetails != null) 'ownerOnlyDetails': ownerOnlyDetails,
      if (contactEmail != null) 'contactEmail': contactEmail,
      if (ownerName != null) 'ownerName': ownerName,
      if (attributes != null) 'attributes': attributes?.toJson(),
      if (embedding != null) 'embedding': embedding?.toJson(),
      if (embeddingModel != null) 'embeddingModel': embeddingModel,
      if (duplicateOfReportId != null)
        'duplicateOfReportId': duplicateOfReportId?.toJson(),
      if (ipHash != null) 'ipHash': ipHash,
      if (closedAt != null) 'closedAt': closedAt?.toJson(),
      if (contactPurgedAt != null) 'contactPurgedAt': contactPurgedAt?.toJson(),
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'LostReport',
      if (id != null) 'id': id?.toJson(),
      'venueId': venueId.toJson(),
      'status': status.toJson(),
      'refCode': refCode,
      'publicToken': publicToken,
      'rawText': rawText,
      if (categoryHint != null) 'categoryHint': categoryHint,
      'colourHints': colourHints.toJson(),
      if (brandHint != null) 'brandHint': brandHint,
      if (zoneId != null) 'zoneId': zoneId?.toJson(),
      if (whereText != null) 'whereText': whereText,
      if (lostAt != null) 'lostAt': lostAt?.toJson(),
      'lostAtFuzzyDays': lostAtFuzzyDays,
      if (ownerOnlyDetails != null) 'ownerOnlyDetails': ownerOnlyDetails,
      if (contactEmail != null) 'contactEmail': contactEmail,
      if (ownerName != null) 'ownerName': ownerName,
      if (attributes != null) 'attributes': attributes?.toJsonForProtocol(),
      if (embedding != null) 'embedding': embedding?.toJson(),
      if (embeddingModel != null) 'embeddingModel': embeddingModel,
      if (duplicateOfReportId != null)
        'duplicateOfReportId': duplicateOfReportId?.toJson(),
      if (ipHash != null) 'ipHash': ipHash,
      if (closedAt != null) 'closedAt': closedAt?.toJson(),
      if (contactPurgedAt != null) 'contactPurgedAt': contactPurgedAt?.toJson(),
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  static LostReportInclude include() {
    return LostReportInclude._();
  }

  static LostReportIncludeList includeList({
    _is.WhereExpressionBuilder<LostReportTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<LostReportTable>? orderBy,
    _is.OrderByListBuilder<LostReportTable>? orderByList,
    LostReportInclude? include,
  }) {
    return LostReportIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(LostReport.t),
      orderByList: orderByList?.call(LostReport.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _LostReportImpl extends LostReport {
  _LostReportImpl({
    _is.UuidValue? id,
    required _is.UuidValue venueId,
    _i8pcsu0p.ReportStatus? status,
    required String refCode,
    required String publicToken,
    required String rawText,
    String? categoryHint,
    required List<String> colourHints,
    String? brandHint,
    _is.UuidValue? zoneId,
    String? whereText,
    DateTime? lostAt,
    int? lostAtFuzzyDays,
    String? ownerOnlyDetails,
    String? contactEmail,
    String? ownerName,
    _i43d0yeo.ItemAttributes? attributes,
    _is.Vector? embedding,
    String? embeddingModel,
    _is.UuidValue? duplicateOfReportId,
    String? ipHash,
    DateTime? closedAt,
    DateTime? contactPurgedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : super._(
         id: id,
         venueId: venueId,
         status: status,
         refCode: refCode,
         publicToken: publicToken,
         rawText: rawText,
         categoryHint: categoryHint,
         colourHints: colourHints,
         brandHint: brandHint,
         zoneId: zoneId,
         whereText: whereText,
         lostAt: lostAt,
         lostAtFuzzyDays: lostAtFuzzyDays,
         ownerOnlyDetails: ownerOnlyDetails,
         contactEmail: contactEmail,
         ownerName: ownerName,
         attributes: attributes,
         embedding: embedding,
         embeddingModel: embeddingModel,
         duplicateOfReportId: duplicateOfReportId,
         ipHash: ipHash,
         closedAt: closedAt,
         contactPurgedAt: contactPurgedAt,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [LostReport]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  LostReport copyWith({
    Object? id = _Undefined,
    _is.UuidValue? venueId,
    _i8pcsu0p.ReportStatus? status,
    String? refCode,
    String? publicToken,
    String? rawText,
    Object? categoryHint = _Undefined,
    List<String>? colourHints,
    Object? brandHint = _Undefined,
    Object? zoneId = _Undefined,
    Object? whereText = _Undefined,
    Object? lostAt = _Undefined,
    int? lostAtFuzzyDays,
    Object? ownerOnlyDetails = _Undefined,
    Object? contactEmail = _Undefined,
    Object? ownerName = _Undefined,
    Object? attributes = _Undefined,
    Object? embedding = _Undefined,
    Object? embeddingModel = _Undefined,
    Object? duplicateOfReportId = _Undefined,
    Object? ipHash = _Undefined,
    Object? closedAt = _Undefined,
    Object? contactPurgedAt = _Undefined,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LostReport(
      id: id is _is.UuidValue? ? id : this.id,
      venueId: venueId ?? this.venueId,
      status: status ?? this.status,
      refCode: refCode ?? this.refCode,
      publicToken: publicToken ?? this.publicToken,
      rawText: rawText ?? this.rawText,
      categoryHint: categoryHint is String? ? categoryHint : this.categoryHint,
      colourHints: colourHints ?? this.colourHints.map((e0) => e0).toList(),
      brandHint: brandHint is String? ? brandHint : this.brandHint,
      zoneId: zoneId is _is.UuidValue? ? zoneId : this.zoneId,
      whereText: whereText is String? ? whereText : this.whereText,
      lostAt: lostAt is DateTime? ? lostAt : this.lostAt,
      lostAtFuzzyDays: lostAtFuzzyDays ?? this.lostAtFuzzyDays,
      ownerOnlyDetails: ownerOnlyDetails is String?
          ? ownerOnlyDetails
          : this.ownerOnlyDetails,
      contactEmail: contactEmail is String? ? contactEmail : this.contactEmail,
      ownerName: ownerName is String? ? ownerName : this.ownerName,
      attributes: attributes is _i43d0yeo.ItemAttributes?
          ? attributes
          : this.attributes?.copyWith(),
      embedding: embedding is _is.Vector? ? embedding : this.embedding?.clone(),
      embeddingModel: embeddingModel is String?
          ? embeddingModel
          : this.embeddingModel,
      duplicateOfReportId: duplicateOfReportId is _is.UuidValue?
          ? duplicateOfReportId
          : this.duplicateOfReportId,
      ipHash: ipHash is String? ? ipHash : this.ipHash,
      closedAt: closedAt is DateTime? ? closedAt : this.closedAt,
      contactPurgedAt: contactPurgedAt is DateTime?
          ? contactPurgedAt
          : this.contactPurgedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class LostReportUpdateTable extends _is.UpdateTable<LostReportTable> {
  LostReportUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> venueId(_is.UuidValue value) =>
      _is.ColumnValue(
        table.venueId,
        value,
      );

  _is.ColumnValue<_i8pcsu0p.ReportStatus, _i8pcsu0p.ReportStatus> status(
    _i8pcsu0p.ReportStatus value,
  ) => _is.ColumnValue(
    table.status,
    value,
  );

  _is.ColumnValue<String, String> refCode(String value) => _is.ColumnValue(
    table.refCode,
    value,
  );

  _is.ColumnValue<String, String> publicToken(String value) => _is.ColumnValue(
    table.publicToken,
    value,
  );

  _is.ColumnValue<String, String> rawText(String value) => _is.ColumnValue(
    table.rawText,
    value,
  );

  _is.ColumnValue<String, String> categoryHint(String? value) =>
      _is.ColumnValue(
        table.categoryHint,
        value,
      );

  _is.ColumnValue<List<String>, List<String>> colourHints(List<String> value) =>
      _is.ColumnValue(
        table.colourHints,
        value,
      );

  _is.ColumnValue<String, String> brandHint(String? value) => _is.ColumnValue(
    table.brandHint,
    value,
  );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> zoneId(_is.UuidValue? value) =>
      _is.ColumnValue(
        table.zoneId,
        value,
      );

  _is.ColumnValue<String, String> whereText(String? value) => _is.ColumnValue(
    table.whereText,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> lostAt(DateTime? value) =>
      _is.ColumnValue(
        table.lostAt,
        value,
      );

  _is.ColumnValue<int, int> lostAtFuzzyDays(int value) => _is.ColumnValue(
    table.lostAtFuzzyDays,
    value,
  );

  _is.ColumnValue<String, String> ownerOnlyDetails(String? value) =>
      _is.ColumnValue(
        table.ownerOnlyDetails,
        value,
      );

  _is.ColumnValue<String, String> contactEmail(String? value) =>
      _is.ColumnValue(
        table.contactEmail,
        value,
      );

  _is.ColumnValue<String, String> ownerName(String? value) => _is.ColumnValue(
    table.ownerName,
    value,
  );

  _is.ColumnValue<_i43d0yeo.ItemAttributes, _i43d0yeo.ItemAttributes>
  attributes(_i43d0yeo.ItemAttributes? value) => _is.ColumnValue(
    table.attributes,
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

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> duplicateOfReportId(
    _is.UuidValue? value,
  ) => _is.ColumnValue(
    table.duplicateOfReportId,
    value,
  );

  _is.ColumnValue<String, String> ipHash(String? value) => _is.ColumnValue(
    table.ipHash,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> closedAt(DateTime? value) =>
      _is.ColumnValue(
        table.closedAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> contactPurgedAt(DateTime? value) =>
      _is.ColumnValue(
        table.contactPurgedAt,
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

class LostReportTable extends _is.Table<_is.UuidValue?> {
  LostReportTable({super.tableRelation}) : super(tableName: 'lost_report') {
    updateTable = LostReportUpdateTable(this);
    venueId = _is.ColumnUuid(
      'venueId',
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
    publicToken = _is.ColumnString(
      'publicToken',
      this,
    );
    rawText = _is.ColumnString(
      'rawText',
      this,
    );
    categoryHint = _is.ColumnString(
      'categoryHint',
      this,
    );
    colourHints = _is.ColumnSerializable<List<String>>(
      'colourHints',
      this,
    );
    brandHint = _is.ColumnString(
      'brandHint',
      this,
    );
    zoneId = _is.ColumnUuid(
      'zoneId',
      this,
    );
    whereText = _is.ColumnString(
      'whereText',
      this,
    );
    lostAt = _is.ColumnDateTime(
      'lostAt',
      this,
    );
    lostAtFuzzyDays = _is.ColumnInt(
      'lostAtFuzzyDays',
      this,
      hasDefault: true,
    );
    ownerOnlyDetails = _is.ColumnString(
      'ownerOnlyDetails',
      this,
    );
    contactEmail = _is.ColumnString(
      'contactEmail',
      this,
    );
    ownerName = _is.ColumnString(
      'ownerName',
      this,
    );
    attributes = _is.ColumnStructured<_i43d0yeo.ItemAttributes>(
      'attributes',
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
    duplicateOfReportId = _is.ColumnUuid(
      'duplicateOfReportId',
      this,
    );
    ipHash = _is.ColumnString(
      'ipHash',
      this,
    );
    closedAt = _is.ColumnDateTime(
      'closedAt',
      this,
    );
    contactPurgedAt = _is.ColumnDateTime(
      'contactPurgedAt',
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

  late final LostReportUpdateTable updateTable;

  late final _is.ColumnUuid venueId;

  late final _is.ColumnEnum<_i8pcsu0p.ReportStatus> status;

  late final _is.ColumnString refCode;

  late final _is.ColumnString publicToken;

  late final _is.ColumnString rawText;

  late final _is.ColumnString categoryHint;

  late final _is.ColumnSerializable<List<String>> colourHints;

  late final _is.ColumnString brandHint;

  late final _is.ColumnUuid zoneId;

  late final _is.ColumnString whereText;

  late final _is.ColumnDateTime lostAt;

  late final _is.ColumnInt lostAtFuzzyDays;

  late final _is.ColumnString ownerOnlyDetails;

  late final _is.ColumnString contactEmail;

  late final _is.ColumnString ownerName;

  late final _is.ColumnStructured<_i43d0yeo.ItemAttributes> attributes;

  late final _is.ColumnVector embedding;

  late final _is.ColumnString embeddingModel;

  late final _is.ColumnUuid duplicateOfReportId;

  late final _is.ColumnString ipHash;

  late final _is.ColumnDateTime closedAt;

  late final _is.ColumnDateTime contactPurgedAt;

  late final _is.ColumnDateTime createdAt;

  late final _is.ColumnDateTime updatedAt;

  @override
  List<_is.Column> get columns => [
    id,
    venueId,
    status,
    refCode,
    publicToken,
    rawText,
    categoryHint,
    colourHints,
    brandHint,
    zoneId,
    whereText,
    lostAt,
    lostAtFuzzyDays,
    ownerOnlyDetails,
    contactEmail,
    ownerName,
    attributes,
    embedding,
    embeddingModel,
    duplicateOfReportId,
    ipHash,
    closedAt,
    contactPurgedAt,
    createdAt,
    updatedAt,
  ];
}

class LostReportInclude extends _is.IncludeObject {
  LostReportInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue?> get table => LostReport.t;
}

class LostReportIncludeList extends _is.IncludeList {
  LostReportIncludeList._({
    _is.WhereExpressionBuilder<LostReportTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(LostReport.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue?> get table => LostReport.t;
}

class LostReportRepository {
  const LostReportRepository._();

  /// Returns a list of [LostReport]s matching the given query parameters.
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
  Future<List<LostReport>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<LostReportTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<LostReportTable>? orderBy,
    _is.OrderByListBuilder<LostReportTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<LostReport>(
      where: where?.call(LostReport.t),
      orderBy: orderBy?.call(LostReport.t),
      orderByList: orderByList?.call(LostReport.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [LostReport] matching the given query parameters.
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
  Future<LostReport?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<LostReportTable>? where,
    int? offset,
    _is.OrderByBuilder<LostReportTable>? orderBy,
    _is.OrderByListBuilder<LostReportTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<LostReport>(
      where: where?.call(LostReport.t),
      orderBy: orderBy?.call(LostReport.t),
      orderByList: orderByList?.call(LostReport.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [LostReport] by its [id] or null if no such row exists.
  Future<LostReport?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<LostReport>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [LostReport]s in the list and returns the inserted rows.
  ///
  /// The returned [LostReport]s will have their `id` fields set.
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
  Future<List<LostReport>> insert(
    _is.DatabaseSession session,
    List<LostReport> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<LostReport>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [LostReport] and returns the inserted row.
  ///
  /// The returned [LostReport] will have its `id` field set.
  Future<LostReport> insertRow(
    _is.DatabaseSession session,
    LostReport row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<LostReport>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [LostReport]s in the list and returns the resulting rows.
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
  /// The returned [LostReport]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<LostReport>> upsert(
    _is.DatabaseSession session,
    List<LostReport> rows, {
    required _is.ColumnSelections<LostReportTable> conflictColumns,
    _is.ColumnSelections<LostReportTable>? updateColumns,
    _is.WhereExpressionBuilder<LostReportTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<LostReport>(
      rows,
      conflictColumns: conflictColumns(LostReport.t),
      updateColumns: updateColumns?.call(LostReport.t),
      updateWhere: updateWhere?.call(LostReport.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [LostReport] and returns the resulting row.
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
  /// The returned [LostReport] will have its `id` field set.
  Future<LostReport?> upsertRow(
    _is.DatabaseSession session,
    LostReport row, {
    required _is.ColumnSelections<LostReportTable> conflictColumns,
    _is.ColumnSelections<LostReportTable>? updateColumns,
    _is.WhereExpressionBuilder<LostReportTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<LostReport>(
      row,
      conflictColumns: conflictColumns(LostReport.t),
      updateColumns: updateColumns?.call(LostReport.t),
      updateWhere: updateWhere?.call(LostReport.t),
      transaction: transaction,
    );
  }

  /// Updates all [LostReport]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<LostReport>> update(
    _is.DatabaseSession session,
    List<LostReport> rows, {
    _is.ColumnSelections<LostReportTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<LostReport>(
      rows,
      columns: columns?.call(LostReport.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [LostReport]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<LostReport> updateRow(
    _is.DatabaseSession session,
    LostReport row, {
    _is.ColumnSelections<LostReportTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<LostReport>(
      row,
      columns: columns?.call(LostReport.t),
      transaction: transaction,
    );
  }

  /// Updates a single [LostReport] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<LostReport?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<LostReportUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<LostReport>(
      id,
      columnValues: columnValues(LostReport.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [LostReport]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<LostReport>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<LostReportUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<LostReportTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<LostReportTable>? orderBy,
    _is.OrderByListBuilder<LostReportTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<LostReport>(
      columnValues: columnValues(LostReport.t.updateTable),
      where: where(LostReport.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(LostReport.t),
      orderByList: orderByList?.call(LostReport.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [LostReport]s in the list and returns the deleted rows.
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
  Future<List<LostReport>> delete(
    _is.DatabaseSession session,
    List<LostReport> rows, {
    _is.OrderByBuilder<LostReportTable>? orderBy,
    _is.OrderByListBuilder<LostReportTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<LostReport>(
      rows,
      orderBy: orderBy?.call(LostReport.t),
      orderByList: orderByList?.call(LostReport.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [LostReport].
  Future<LostReport> deleteRow(
    _is.DatabaseSession session,
    LostReport row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<LostReport>(
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
  Future<List<LostReport>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<LostReportTable> where,
    _is.OrderByBuilder<LostReportTable>? orderBy,
    _is.OrderByListBuilder<LostReportTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<LostReport>(
      where: where(LostReport.t),
      orderBy: orderBy?.call(LostReport.t),
      orderByList: orderByList?.call(LostReport.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<LostReportTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<LostReport>(
      where: where?.call(LostReport.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [LostReport] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<LostReportTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<LostReport>(
      where: where(LostReport.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
