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
import 'value_band.dart' as _iphilgki;

abstract class ItemPatch
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  ItemPatch._({
    this.attributes,
    this.valueBand,
    this.storageBin,
    bool? clearStorageBin,
    this.privateNotes,
    bool? clearPrivateNotes,
    this.zoneId,
    bool? clearZone,
  }) : clearStorageBin = clearStorageBin ?? false,
       clearPrivateNotes = clearPrivateNotes ?? false,
       clearZone = clearZone ?? false;

  factory ItemPatch({
    _i43d0yeo.ItemAttributes? attributes,
    _iphilgki.ValueBand? valueBand,
    String? storageBin,
    bool? clearStorageBin,
    String? privateNotes,
    bool? clearPrivateNotes,
    _isc.UuidValue? zoneId,
    bool? clearZone,
  }) = _ItemPatchImpl;

  factory ItemPatch.fromJson(Map<String, dynamic> jsonSerialization) {
    return ItemPatch(
      attributes: jsonSerialization['attributes'] == null
          ? null
          : _i3upg8fq.Protocol().deserialize<_i43d0yeo.ItemAttributes>(
              jsonSerialization['attributes'],
            ),
      valueBand: jsonSerialization['valueBand'] == null
          ? null
          : _iphilgki.ValueBand.fromJson(
              (jsonSerialization['valueBand'] as String),
            ),
      storageBin: jsonSerialization['storageBin'] as String?,
      clearStorageBin: jsonSerialization['clearStorageBin'] == null
          ? null
          : _isc.BoolJsonExtension.fromJson(
              jsonSerialization['clearStorageBin'],
            ),
      privateNotes: jsonSerialization['privateNotes'] as String?,
      clearPrivateNotes: jsonSerialization['clearPrivateNotes'] == null
          ? null
          : _isc.BoolJsonExtension.fromJson(
              jsonSerialization['clearPrivateNotes'],
            ),
      zoneId: jsonSerialization['zoneId'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(jsonSerialization['zoneId']),
      clearZone: jsonSerialization['clearZone'] == null
          ? null
          : _isc.BoolJsonExtension.fromJson(jsonSerialization['clearZone']),
    );
  }

  _i43d0yeo.ItemAttributes? attributes;

  _iphilgki.ValueBand? valueBand;

  String? storageBin;

  bool clearStorageBin;

  String? privateNotes;

  bool clearPrivateNotes;

  _isc.UuidValue? zoneId;

  bool clearZone;

  /// Returns a shallow copy of this [ItemPatch]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  ItemPatch copyWith({
    _i43d0yeo.ItemAttributes? attributes,
    _iphilgki.ValueBand? valueBand,
    String? storageBin,
    bool? clearStorageBin,
    String? privateNotes,
    bool? clearPrivateNotes,
    _isc.UuidValue? zoneId,
    bool? clearZone,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ItemPatch',
      if (attributes != null) 'attributes': attributes?.toJson(),
      if (valueBand != null) 'valueBand': valueBand?.toJson(),
      if (storageBin != null) 'storageBin': storageBin,
      'clearStorageBin': clearStorageBin,
      if (privateNotes != null) 'privateNotes': privateNotes,
      'clearPrivateNotes': clearPrivateNotes,
      if (zoneId != null) 'zoneId': zoneId?.toJson(),
      'clearZone': clearZone,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'ItemPatch',
      if (attributes != null) 'attributes': attributes?.toJsonForProtocol(),
      if (valueBand != null) 'valueBand': valueBand?.toJson(),
      if (storageBin != null) 'storageBin': storageBin,
      'clearStorageBin': clearStorageBin,
      if (privateNotes != null) 'privateNotes': privateNotes,
      'clearPrivateNotes': clearPrivateNotes,
      if (zoneId != null) 'zoneId': zoneId?.toJson(),
      'clearZone': clearZone,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ItemPatchImpl extends ItemPatch {
  _ItemPatchImpl({
    _i43d0yeo.ItemAttributes? attributes,
    _iphilgki.ValueBand? valueBand,
    String? storageBin,
    bool? clearStorageBin,
    String? privateNotes,
    bool? clearPrivateNotes,
    _isc.UuidValue? zoneId,
    bool? clearZone,
  }) : super._(
         attributes: attributes,
         valueBand: valueBand,
         storageBin: storageBin,
         clearStorageBin: clearStorageBin,
         privateNotes: privateNotes,
         clearPrivateNotes: clearPrivateNotes,
         zoneId: zoneId,
         clearZone: clearZone,
       );

  /// Returns a shallow copy of this [ItemPatch]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  ItemPatch copyWith({
    Object? attributes = _Undefined,
    Object? valueBand = _Undefined,
    Object? storageBin = _Undefined,
    bool? clearStorageBin,
    Object? privateNotes = _Undefined,
    bool? clearPrivateNotes,
    Object? zoneId = _Undefined,
    bool? clearZone,
  }) {
    return ItemPatch(
      attributes: attributes is _i43d0yeo.ItemAttributes?
          ? attributes
          : this.attributes?.copyWith(),
      valueBand: valueBand is _iphilgki.ValueBand? ? valueBand : this.valueBand,
      storageBin: storageBin is String? ? storageBin : this.storageBin,
      clearStorageBin: clearStorageBin ?? this.clearStorageBin,
      privateNotes: privateNotes is String? ? privateNotes : this.privateNotes,
      clearPrivateNotes: clearPrivateNotes ?? this.clearPrivateNotes,
      zoneId: zoneId is _isc.UuidValue? ? zoneId : this.zoneId,
      clearZone: clearZone ?? this.clearZone,
    );
  }
}
