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

abstract class ReleaseRefusedException
    implements
        _is.SerializableException,
        _is.SerializableModel,
        _is.ProtocolSerialization {
  ReleaseRefusedException._({
    required this.message,
    required this.itemId,
  });

  factory ReleaseRefusedException({
    required String message,
    required _is.UuidValue itemId,
  }) = _ReleaseRefusedExceptionImpl;

  factory ReleaseRefusedException.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return ReleaseRefusedException(
      message: jsonSerialization['message'] as String,
      itemId: _is.UuidValueJsonExtension.fromJson(jsonSerialization['itemId']),
    );
  }

  String message;

  _is.UuidValue itemId;

  /// Returns a shallow copy of this [ReleaseRefusedException]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  ReleaseRefusedException copyWith({
    String? message,
    _is.UuidValue? itemId,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ReleaseRefusedException',
      'message': message,
      'itemId': itemId.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'ReleaseRefusedException',
      'message': message,
      'itemId': itemId.toJson(),
    };
  }

  @override
  String toString() {
    return 'ReleaseRefusedException(message: $message, itemId: $itemId)';
  }
}

class _ReleaseRefusedExceptionImpl extends ReleaseRefusedException {
  _ReleaseRefusedExceptionImpl({
    required String message,
    required _is.UuidValue itemId,
  }) : super._(
         message: message,
         itemId: itemId,
       );

  /// Returns a shallow copy of this [ReleaseRefusedException]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  ReleaseRefusedException copyWith({
    String? message,
    _is.UuidValue? itemId,
  }) {
    return ReleaseRefusedException(
      message: message ?? this.message,
      itemId: itemId ?? this.itemId,
    );
  }
}
