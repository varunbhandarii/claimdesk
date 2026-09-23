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
import 'package:serverpod_client/serverpod_client.dart' as _isc;

abstract class ReleaseRecord
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
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
    _isc.UuidValue? id,
    required _isc.UuidValue venueId,
    required _isc.UuidValue itemId,
    _isc.UuidValue? reportId,
    required String claimantName,
    required String idTypeSeen,
    required int detailsMatched,
    required bool describedBeforeViewing,
    String? thirdPartyAuthorisationNote,
    String? signaturePath,
    required _isc.UuidValue releasedByAuthUserId,
    DateTime? releasedAt,
  }) = _ReleaseRecordImpl;

  factory ReleaseRecord.fromJson(Map<String, dynamic> jsonSerialization) {
    return ReleaseRecord(
      id: jsonSerialization['id'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      venueId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['venueId'],
      ),
      itemId: _isc.UuidValueJsonExtension.fromJson(jsonSerialization['itemId']),
      reportId: jsonSerialization['reportId'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(jsonSerialization['reportId']),
      claimantName: jsonSerialization['claimantName'] as String,
      idTypeSeen: jsonSerialization['idTypeSeen'] as String,
      detailsMatched: jsonSerialization['detailsMatched'] as int,
      describedBeforeViewing: _isc.BoolJsonExtension.fromJson(
        jsonSerialization['describedBeforeViewing'],
      ),
      thirdPartyAuthorisationNote:
          jsonSerialization['thirdPartyAuthorisationNote'] as String?,
      signaturePath: jsonSerialization['signaturePath'] as String?,
      releasedByAuthUserId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['releasedByAuthUserId'],
      ),
      releasedAt: jsonSerialization['releasedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['releasedAt'],
            ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  _isc.UuidValue? id;

  _isc.UuidValue venueId;

  _isc.UuidValue itemId;

  _isc.UuidValue? reportId;

  String claimantName;

  String idTypeSeen;

  int detailsMatched;

  bool describedBeforeViewing;

  String? thirdPartyAuthorisationNote;

  String? signaturePath;

  _isc.UuidValue releasedByAuthUserId;

  DateTime releasedAt;

  /// Returns a shallow copy of this [ReleaseRecord]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  ReleaseRecord copyWith({
    _isc.UuidValue? id,
    _isc.UuidValue? venueId,
    _isc.UuidValue? itemId,
    _isc.UuidValue? reportId,
    String? claimantName,
    String? idTypeSeen,
    int? detailsMatched,
    bool? describedBeforeViewing,
    String? thirdPartyAuthorisationNote,
    String? signaturePath,
    _isc.UuidValue? releasedByAuthUserId,
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

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ReleaseRecordImpl extends ReleaseRecord {
  _ReleaseRecordImpl({
    _isc.UuidValue? id,
    required _isc.UuidValue venueId,
    required _isc.UuidValue itemId,
    _isc.UuidValue? reportId,
    required String claimantName,
    required String idTypeSeen,
    required int detailsMatched,
    required bool describedBeforeViewing,
    String? thirdPartyAuthorisationNote,
    String? signaturePath,
    required _isc.UuidValue releasedByAuthUserId,
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
  @_isc.useResult
  @override
  ReleaseRecord copyWith({
    Object? id = _Undefined,
    _isc.UuidValue? venueId,
    _isc.UuidValue? itemId,
    Object? reportId = _Undefined,
    String? claimantName,
    String? idTypeSeen,
    int? detailsMatched,
    bool? describedBeforeViewing,
    Object? thirdPartyAuthorisationNote = _Undefined,
    Object? signaturePath = _Undefined,
    _isc.UuidValue? releasedByAuthUserId,
    DateTime? releasedAt,
  }) {
    return ReleaseRecord(
      id: id is _isc.UuidValue? ? id : this.id,
      venueId: venueId ?? this.venueId,
      itemId: itemId ?? this.itemId,
      reportId: reportId is _isc.UuidValue? ? reportId : this.reportId,
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
