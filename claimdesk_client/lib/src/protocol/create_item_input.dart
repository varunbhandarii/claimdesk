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
import 'value_band.dart' as _iphilgki;

abstract class CreateItemInput
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  CreateItemInput._({
    this.itemId,
    this.photoPath,
    this.uploadProof,
    this.uploadExpiresAt,
    this.zoneId,
    String? category,
    this.colours,
    this.brand,
    this.description,
    _iphilgki.ValueBand? valueBand,
    this.storageBin,
    this.privateNotes,
    this.finderName,
    this.foundAt,
  }) : category = category ?? 'other',
       valueBand = valueBand ?? _iphilgki.ValueBand.under20;

  factory CreateItemInput({
    _isc.UuidValue? itemId,
    String? photoPath,
    String? uploadProof,
    DateTime? uploadExpiresAt,
    _isc.UuidValue? zoneId,
    String? category,
    List<String>? colours,
    String? brand,
    String? description,
    _iphilgki.ValueBand? valueBand,
    String? storageBin,
    String? privateNotes,
    String? finderName,
    DateTime? foundAt,
  }) = _CreateItemInputImpl;

  factory CreateItemInput.fromJson(Map<String, dynamic> jsonSerialization) {
    return CreateItemInput(
      itemId: jsonSerialization['itemId'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(jsonSerialization['itemId']),
      photoPath: jsonSerialization['photoPath'] as String?,
      uploadProof: jsonSerialization['uploadProof'] as String?,
      uploadExpiresAt: jsonSerialization['uploadExpiresAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['uploadExpiresAt'],
            ),
      zoneId: jsonSerialization['zoneId'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(jsonSerialization['zoneId']),
      category: jsonSerialization['category'] as String?,
      colours: jsonSerialization['colours'] == null
          ? null
          : _i3upg8fq.Protocol().deserialize<List<String>>(
              jsonSerialization['colours'],
            ),
      brand: jsonSerialization['brand'] as String?,
      description: jsonSerialization['description'] as String?,
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
    );
  }

  _isc.UuidValue? itemId;

  String? photoPath;

  String? uploadProof;

  DateTime? uploadExpiresAt;

  _isc.UuidValue? zoneId;

  String category;

  List<String>? colours;

  String? brand;

  String? description;

  _iphilgki.ValueBand valueBand;

  String? storageBin;

  String? privateNotes;

  String? finderName;

  DateTime? foundAt;

  /// Returns a shallow copy of this [CreateItemInput]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  CreateItemInput copyWith({
    _isc.UuidValue? itemId,
    String? photoPath,
    String? uploadProof,
    DateTime? uploadExpiresAt,
    _isc.UuidValue? zoneId,
    String? category,
    List<String>? colours,
    String? brand,
    String? description,
    _iphilgki.ValueBand? valueBand,
    String? storageBin,
    String? privateNotes,
    String? finderName,
    DateTime? foundAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'CreateItemInput',
      if (itemId != null) 'itemId': itemId?.toJson(),
      if (photoPath != null) 'photoPath': photoPath,
      if (uploadProof != null) 'uploadProof': uploadProof,
      if (uploadExpiresAt != null) 'uploadExpiresAt': uploadExpiresAt?.toJson(),
      if (zoneId != null) 'zoneId': zoneId?.toJson(),
      'category': category,
      if (colours != null) 'colours': colours?.toJson(),
      if (brand != null) 'brand': brand,
      if (description != null) 'description': description,
      'valueBand': valueBand.toJson(),
      if (storageBin != null) 'storageBin': storageBin,
      if (privateNotes != null) 'privateNotes': privateNotes,
      if (finderName != null) 'finderName': finderName,
      if (foundAt != null) 'foundAt': foundAt?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'CreateItemInput',
      if (itemId != null) 'itemId': itemId?.toJson(),
      if (photoPath != null) 'photoPath': photoPath,
      if (uploadProof != null) 'uploadProof': uploadProof,
      if (uploadExpiresAt != null) 'uploadExpiresAt': uploadExpiresAt?.toJson(),
      if (zoneId != null) 'zoneId': zoneId?.toJson(),
      'category': category,
      if (colours != null) 'colours': colours?.toJson(),
      if (brand != null) 'brand': brand,
      if (description != null) 'description': description,
      'valueBand': valueBand.toJson(),
      if (storageBin != null) 'storageBin': storageBin,
      if (privateNotes != null) 'privateNotes': privateNotes,
      if (finderName != null) 'finderName': finderName,
      if (foundAt != null) 'foundAt': foundAt?.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CreateItemInputImpl extends CreateItemInput {
  _CreateItemInputImpl({
    _isc.UuidValue? itemId,
    String? photoPath,
    String? uploadProof,
    DateTime? uploadExpiresAt,
    _isc.UuidValue? zoneId,
    String? category,
    List<String>? colours,
    String? brand,
    String? description,
    _iphilgki.ValueBand? valueBand,
    String? storageBin,
    String? privateNotes,
    String? finderName,
    DateTime? foundAt,
  }) : super._(
         itemId: itemId,
         photoPath: photoPath,
         uploadProof: uploadProof,
         uploadExpiresAt: uploadExpiresAt,
         zoneId: zoneId,
         category: category,
         colours: colours,
         brand: brand,
         description: description,
         valueBand: valueBand,
         storageBin: storageBin,
         privateNotes: privateNotes,
         finderName: finderName,
         foundAt: foundAt,
       );

  /// Returns a shallow copy of this [CreateItemInput]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  CreateItemInput copyWith({
    Object? itemId = _Undefined,
    Object? photoPath = _Undefined,
    Object? uploadProof = _Undefined,
    Object? uploadExpiresAt = _Undefined,
    Object? zoneId = _Undefined,
    String? category,
    Object? colours = _Undefined,
    Object? brand = _Undefined,
    Object? description = _Undefined,
    _iphilgki.ValueBand? valueBand,
    Object? storageBin = _Undefined,
    Object? privateNotes = _Undefined,
    Object? finderName = _Undefined,
    Object? foundAt = _Undefined,
  }) {
    return CreateItemInput(
      itemId: itemId is _isc.UuidValue? ? itemId : this.itemId,
      photoPath: photoPath is String? ? photoPath : this.photoPath,
      uploadProof: uploadProof is String? ? uploadProof : this.uploadProof,
      uploadExpiresAt: uploadExpiresAt is DateTime?
          ? uploadExpiresAt
          : this.uploadExpiresAt,
      zoneId: zoneId is _isc.UuidValue? ? zoneId : this.zoneId,
      category: category ?? this.category,
      colours: colours is List<String>?
          ? colours
          : this.colours?.map((e0) => e0).toList(),
      brand: brand is String? ? brand : this.brand,
      description: description is String? ? description : this.description,
      valueBand: valueBand ?? this.valueBand,
      storageBin: storageBin is String? ? storageBin : this.storageBin,
      privateNotes: privateNotes is String? ? privateNotes : this.privateNotes,
      finderName: finderName is String? ? finderName : this.finderName,
      foundAt: foundAt is DateTime? ? foundAt : this.foundAt,
    );
  }
}
