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

abstract class TransferInput
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  TransferInput._({
    required this.toLocation,
    this.reference,
    this.note,
  });

  factory TransferInput({
    required String toLocation,
    String? reference,
    String? note,
  }) = _TransferInputImpl;

  factory TransferInput.fromJson(Map<String, dynamic> jsonSerialization) {
    return TransferInput(
      toLocation: jsonSerialization['toLocation'] as String,
      reference: jsonSerialization['reference'] as String?,
      note: jsonSerialization['note'] as String?,
    );
  }

  String toLocation;

  String? reference;

  String? note;

  /// Returns a shallow copy of this [TransferInput]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  TransferInput copyWith({
    String? toLocation,
    String? reference,
    String? note,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'TransferInput',
      'toLocation': toLocation,
      if (reference != null) 'reference': reference,
      if (note != null) 'note': note,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'TransferInput',
      'toLocation': toLocation,
      if (reference != null) 'reference': reference,
      if (note != null) 'note': note,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _TransferInputImpl extends TransferInput {
  _TransferInputImpl({
    required String toLocation,
    String? reference,
    String? note,
  }) : super._(
         toLocation: toLocation,
         reference: reference,
         note: note,
       );

  /// Returns a shallow copy of this [TransferInput]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  TransferInput copyWith({
    String? toLocation,
    Object? reference = _Undefined,
    Object? note = _Undefined,
  }) {
    return TransferInput(
      toLocation: toLocation ?? this.toLocation,
      reference: reference is String? ? reference : this.reference,
      note: note is String? ? note : this.note,
    );
  }
}
