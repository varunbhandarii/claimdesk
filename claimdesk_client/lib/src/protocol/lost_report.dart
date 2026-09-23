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
import 'package:claimdesk_client/src/protocol/protocol.dart' as _i3upg8fq;
import 'package:serverpod_client/serverpod_client.dart' as _isc;
import 'item_attributes.dart' as _i43d0yeo;
import 'report_status.dart' as _i8pcsu0p;

abstract class LostReport
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
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
    _isc.UuidValue? id,
    required _isc.UuidValue venueId,
    _i8pcsu0p.ReportStatus? status,
    required String refCode,
    required String publicToken,
    required String rawText,
    String? categoryHint,
    required List<String> colourHints,
    String? brandHint,
    _isc.UuidValue? zoneId,
    String? whereText,
    DateTime? lostAt,
    int? lostAtFuzzyDays,
    String? ownerOnlyDetails,
    String? contactEmail,
    String? ownerName,
    _i43d0yeo.ItemAttributes? attributes,
    _isc.Vector? embedding,
    String? embeddingModel,
    _isc.UuidValue? duplicateOfReportId,
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
          : _isc.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      venueId: _isc.UuidValueJsonExtension.fromJson(
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
      colourHints: _i3upg8fq.Protocol().deserialize<List<String>>(
        jsonSerialization['colourHints'],
      ),
      brandHint: jsonSerialization['brandHint'] as String?,
      zoneId: jsonSerialization['zoneId'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(jsonSerialization['zoneId']),
      whereText: jsonSerialization['whereText'] as String?,
      lostAt: jsonSerialization['lostAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['lostAt']),
      lostAtFuzzyDays: jsonSerialization['lostAtFuzzyDays'] as int?,
      ownerOnlyDetails: jsonSerialization['ownerOnlyDetails'] as String?,
      contactEmail: jsonSerialization['contactEmail'] as String?,
      ownerName: jsonSerialization['ownerName'] as String?,
      attributes: jsonSerialization['attributes'] == null
          ? null
          : _i3upg8fq.Protocol().deserialize<_i43d0yeo.ItemAttributes>(
              jsonSerialization['attributes'],
            ),
      embedding: jsonSerialization['embedding'] == null
          ? null
          : _isc.VectorJsonExtension.fromJson(jsonSerialization['embedding']),
      embeddingModel: jsonSerialization['embeddingModel'] as String?,
      duplicateOfReportId: jsonSerialization['duplicateOfReportId'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(
              jsonSerialization['duplicateOfReportId'],
            ),
      ipHash: jsonSerialization['ipHash'] as String?,
      closedAt: jsonSerialization['closedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['closedAt']),
      contactPurgedAt: jsonSerialization['contactPurgedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['contactPurgedAt'],
            ),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  _isc.UuidValue? id;

  _isc.UuidValue venueId;

  _i8pcsu0p.ReportStatus status;

  String refCode;

  String publicToken;

  String rawText;

  String? categoryHint;

  List<String> colourHints;

  String? brandHint;

  _isc.UuidValue? zoneId;

  String? whereText;

  DateTime? lostAt;

  int lostAtFuzzyDays;

  String? ownerOnlyDetails;

  String? contactEmail;

  String? ownerName;

  _i43d0yeo.ItemAttributes? attributes;

  _isc.Vector? embedding;

  String? embeddingModel;

  _isc.UuidValue? duplicateOfReportId;

  String? ipHash;

  DateTime? closedAt;

  DateTime? contactPurgedAt;

  DateTime createdAt;

  DateTime updatedAt;

  /// Returns a shallow copy of this [LostReport]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  LostReport copyWith({
    _isc.UuidValue? id,
    _isc.UuidValue? venueId,
    _i8pcsu0p.ReportStatus? status,
    String? refCode,
    String? publicToken,
    String? rawText,
    String? categoryHint,
    List<String>? colourHints,
    String? brandHint,
    _isc.UuidValue? zoneId,
    String? whereText,
    DateTime? lostAt,
    int? lostAtFuzzyDays,
    String? ownerOnlyDetails,
    String? contactEmail,
    String? ownerName,
    _i43d0yeo.ItemAttributes? attributes,
    _isc.Vector? embedding,
    String? embeddingModel,
    _isc.UuidValue? duplicateOfReportId,
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

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _LostReportImpl extends LostReport {
  _LostReportImpl({
    _isc.UuidValue? id,
    required _isc.UuidValue venueId,
    _i8pcsu0p.ReportStatus? status,
    required String refCode,
    required String publicToken,
    required String rawText,
    String? categoryHint,
    required List<String> colourHints,
    String? brandHint,
    _isc.UuidValue? zoneId,
    String? whereText,
    DateTime? lostAt,
    int? lostAtFuzzyDays,
    String? ownerOnlyDetails,
    String? contactEmail,
    String? ownerName,
    _i43d0yeo.ItemAttributes? attributes,
    _isc.Vector? embedding,
    String? embeddingModel,
    _isc.UuidValue? duplicateOfReportId,
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
  @_isc.useResult
  @override
  LostReport copyWith({
    Object? id = _Undefined,
    _isc.UuidValue? venueId,
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
      id: id is _isc.UuidValue? ? id : this.id,
      venueId: venueId ?? this.venueId,
      status: status ?? this.status,
      refCode: refCode ?? this.refCode,
      publicToken: publicToken ?? this.publicToken,
      rawText: rawText ?? this.rawText,
      categoryHint: categoryHint is String? ? categoryHint : this.categoryHint,
      colourHints: colourHints ?? this.colourHints.map((e0) => e0).toList(),
      brandHint: brandHint is String? ? brandHint : this.brandHint,
      zoneId: zoneId is _isc.UuidValue? ? zoneId : this.zoneId,
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
      embedding: embedding is _isc.Vector?
          ? embedding
          : this.embedding?.clone(),
      embeddingModel: embeddingModel is String?
          ? embeddingModel
          : this.embeddingModel,
      duplicateOfReportId: duplicateOfReportId is _isc.UuidValue?
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
