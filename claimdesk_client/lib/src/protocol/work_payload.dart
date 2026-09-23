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

abstract class WorkPayload
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  WorkPayload._({
    this.entityId,
    required this.data,
  });

  factory WorkPayload({
    _isc.UuidValue? entityId,
    required Map<String, String> data,
  }) = _WorkPayloadImpl;

  factory WorkPayload.fromJson(Map<String, dynamic> jsonSerialization) {
    return WorkPayload(
      entityId: jsonSerialization['entityId'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(jsonSerialization['entityId']),
      data: _i3upg8fq.Protocol().deserialize<Map<String, String>>(
        jsonSerialization['data'],
      ),
    );
  }

  _isc.UuidValue? entityId;

  Map<String, String> data;

  /// Returns a shallow copy of this [WorkPayload]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  WorkPayload copyWith({
    _isc.UuidValue? entityId,
    Map<String, String>? data,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'WorkPayload',
      if (entityId != null) 'entityId': entityId?.toJson(),
      'data': data.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'WorkPayload',
      if (entityId != null) 'entityId': entityId?.toJson(),
      'data': data.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _WorkPayloadImpl extends WorkPayload {
  _WorkPayloadImpl({
    _isc.UuidValue? entityId,
    required Map<String, String> data,
  }) : super._(
         entityId: entityId,
         data: data,
       );

  /// Returns a shallow copy of this [WorkPayload]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  WorkPayload copyWith({
    Object? entityId = _Undefined,
    Map<String, String>? data,
  }) {
    return WorkPayload(
      entityId: entityId is _isc.UuidValue? ? entityId : this.entityId,
      data:
          data ??
          this.data.map(
            (
              key0,
              value0,
            ) => MapEntry(
              key0,
              value0,
            ),
          ),
    );
  }
}
