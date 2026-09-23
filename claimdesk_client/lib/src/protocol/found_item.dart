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
import 'item_status.dart' as _ibbyonnn;
import 'value_band.dart' as _iphilgki;

abstract class FoundItem
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
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
    _isc.UuidValue? id,
    required _isc.UuidValue venueId,
    _isc.UuidValue? zoneId,
    _ibbyonnn.ItemStatus? status,
    required String refCode,
    String? photoPath,
    String? thumbPath,
    bool? restricted,
    _i43d0yeo.ItemAttributes? attributes,
    String? captionText,
    _isc.Vector? embedding,
    String? embeddingModel,
    _iphilgki.ValueBand? valueBand,
    String? storageBin,
    String? privateNotes,
    String? finderName,
    DateTime? foundAt,
    required _isc.UuidValue loggedByAuthUserId,
    DateTime? holdUntil,
    DateTime? handoffDueAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _FoundItemImpl;

  factory FoundItem.fromJson(Map<String, dynamic> jsonSerialization) {
    return FoundItem(
      id: jsonSerialization['id'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      venueId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['venueId'],
      ),
      zoneId: jsonSerialization['zoneId'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(jsonSerialization['zoneId']),
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
          : _isc.BoolJsonExtension.fromJson(jsonSerialization['restricted']),
      attributes: jsonSerialization['attributes'] == null
          ? null
          : _i3upg8fq.Protocol().deserialize<_i43d0yeo.ItemAttributes>(
              jsonSerialization['attributes'],
            ),
      captionText: jsonSerialization['captionText'] as String?,
      embedding: jsonSerialization['embedding'] == null
          ? null
          : _isc.VectorJsonExtension.fromJson(jsonSerialization['embedding']),
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
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['foundAt']),
      loggedByAuthUserId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['loggedByAuthUserId'],
      ),
      holdUntil: jsonSerialization['holdUntil'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['holdUntil']),
      handoffDueAt: jsonSerialization['handoffDueAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['handoffDueAt'],
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

  _isc.UuidValue? zoneId;

  _ibbyonnn.ItemStatus status;

  String refCode;

  String? photoPath;

  String? thumbPath;

  bool restricted;

  _i43d0yeo.ItemAttributes? attributes;

  String? captionText;

  _isc.Vector? embedding;

  String? embeddingModel;

  _iphilgki.ValueBand valueBand;

  String? storageBin;

  String? privateNotes;

  String? finderName;

  DateTime foundAt;

  _isc.UuidValue loggedByAuthUserId;

  DateTime? holdUntil;

  DateTime? handoffDueAt;

  DateTime createdAt;

  DateTime updatedAt;

  /// Returns a shallow copy of this [FoundItem]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  FoundItem copyWith({
    _isc.UuidValue? id,
    _isc.UuidValue? venueId,
    _isc.UuidValue? zoneId,
    _ibbyonnn.ItemStatus? status,
    String? refCode,
    String? photoPath,
    String? thumbPath,
    bool? restricted,
    _i43d0yeo.ItemAttributes? attributes,
    String? captionText,
    _isc.Vector? embedding,
    String? embeddingModel,
    _iphilgki.ValueBand? valueBand,
    String? storageBin,
    String? privateNotes,
    String? finderName,
    DateTime? foundAt,
    _isc.UuidValue? loggedByAuthUserId,
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

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _FoundItemImpl extends FoundItem {
  _FoundItemImpl({
    _isc.UuidValue? id,
    required _isc.UuidValue venueId,
    _isc.UuidValue? zoneId,
    _ibbyonnn.ItemStatus? status,
    required String refCode,
    String? photoPath,
    String? thumbPath,
    bool? restricted,
    _i43d0yeo.ItemAttributes? attributes,
    String? captionText,
    _isc.Vector? embedding,
    String? embeddingModel,
    _iphilgki.ValueBand? valueBand,
    String? storageBin,
    String? privateNotes,
    String? finderName,
    DateTime? foundAt,
    required _isc.UuidValue loggedByAuthUserId,
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
  @_isc.useResult
  @override
  FoundItem copyWith({
    Object? id = _Undefined,
    _isc.UuidValue? venueId,
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
    _isc.UuidValue? loggedByAuthUserId,
    Object? holdUntil = _Undefined,
    Object? handoffDueAt = _Undefined,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FoundItem(
      id: id is _isc.UuidValue? ? id : this.id,
      venueId: venueId ?? this.venueId,
      zoneId: zoneId is _isc.UuidValue? ? zoneId : this.zoneId,
      status: status ?? this.status,
      refCode: refCode ?? this.refCode,
      photoPath: photoPath is String? ? photoPath : this.photoPath,
      thumbPath: thumbPath is String? ? thumbPath : this.thumbPath,
      restricted: restricted ?? this.restricted,
      attributes: attributes is _i43d0yeo.ItemAttributes?
          ? attributes
          : this.attributes?.copyWith(),
      captionText: captionText is String? ? captionText : this.captionText,
      embedding: embedding is _isc.Vector?
          ? embedding
          : this.embedding?.clone(),
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
