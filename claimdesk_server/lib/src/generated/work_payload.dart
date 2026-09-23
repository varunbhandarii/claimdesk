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

abstract class WorkPayload
    implements _is.SerializableModel, _is.ProtocolSerialization {
  WorkPayload._({
    this.entityId,
    required this.data,
  });

  factory WorkPayload({
    _is.UuidValue? entityId,
    required Map<String, String> data,
  }) = _WorkPayloadImpl;

  factory WorkPayload.fromJson(Map<String, dynamic> jsonSerialization) {
    return WorkPayload(
      entityId: jsonSerialization['entityId'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['entityId']),
      data: _ii1g677k.Protocol().deserialize<Map<String, String>>(
        jsonSerialization['data'],
      ),
    );
  }

  _is.UuidValue? entityId;

  Map<String, String> data;

  /// Returns a shallow copy of this [WorkPayload]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  WorkPayload copyWith({
    _is.UuidValue? entityId,
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
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _WorkPayloadImpl extends WorkPayload {
  _WorkPayloadImpl({
    _is.UuidValue? entityId,
    required Map<String, String> data,
  }) : super._(
         entityId: entityId,
         data: data,
       );

  /// Returns a shallow copy of this [WorkPayload]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  WorkPayload copyWith({
    Object? entityId = _Undefined,
    Map<String, String>? data,
  }) {
    return WorkPayload(
      entityId: entityId is _is.UuidValue? ? entityId : this.entityId,
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
