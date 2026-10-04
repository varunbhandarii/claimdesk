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
import 'package:serverpod/serverpod.dart' as _is;

abstract class DisposeInput
    implements _is.SerializableModel, _is.ProtocolSerialization {
  DisposeInput._({
    required this.action,
    this.note,
  });

  factory DisposeInput({
    required String action,
    String? note,
  }) = _DisposeInputImpl;

  factory DisposeInput.fromJson(Map<String, dynamic> jsonSerialization) {
    return DisposeInput(
      action: jsonSerialization['action'] as String,
      note: jsonSerialization['note'] as String?,
    );
  }

  String action;

  String? note;

  /// Returns a shallow copy of this [DisposeInput]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  DisposeInput copyWith({
    String? action,
    String? note,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'DisposeInput',
      'action': action,
      if (note != null) 'note': note,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'DisposeInput',
      'action': action,
      if (note != null) 'note': note,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _DisposeInputImpl extends DisposeInput {
  _DisposeInputImpl({
    required String action,
    String? note,
  }) : super._(
         action: action,
         note: note,
       );

  /// Returns a shallow copy of this [DisposeInput]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  DisposeInput copyWith({
    String? action,
    Object? note = _Undefined,
  }) {
    return DisposeInput(
      action: action ?? this.action,
      note: note is String? ? note : this.note,
    );
  }
}
