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

abstract class AlreadyReleasedException
    implements
        _is.SerializableException,
        _is.SerializableModel,
        _is.ProtocolSerialization {
  AlreadyReleasedException._({
    required this.message,
    required this.itemId,
  });

  factory AlreadyReleasedException({
    required String message,
    required _is.UuidValue itemId,
  }) = _AlreadyReleasedExceptionImpl;

  factory AlreadyReleasedException.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return AlreadyReleasedException(
      message: jsonSerialization['message'] as String,
      itemId: _is.UuidValueJsonExtension.fromJson(jsonSerialization['itemId']),
    );
  }

  String message;

  _is.UuidValue itemId;

  /// Returns a shallow copy of this [AlreadyReleasedException]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  AlreadyReleasedException copyWith({
    String? message,
    _is.UuidValue? itemId,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AlreadyReleasedException',
      'message': message,
      'itemId': itemId.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'AlreadyReleasedException',
      'message': message,
      'itemId': itemId.toJson(),
    };
  }

  @override
  String toString() {
    return 'AlreadyReleasedException(message: $message, itemId: $itemId)';
  }
}

class _AlreadyReleasedExceptionImpl extends AlreadyReleasedException {
  _AlreadyReleasedExceptionImpl({
    required String message,
    required _is.UuidValue itemId,
  }) : super._(
         message: message,
         itemId: itemId,
       );

  /// Returns a shallow copy of this [AlreadyReleasedException]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  AlreadyReleasedException copyWith({
    String? message,
    _is.UuidValue? itemId,
  }) {
    return AlreadyReleasedException(
      message: message ?? this.message,
      itemId: itemId ?? this.itemId,
    );
  }
}
