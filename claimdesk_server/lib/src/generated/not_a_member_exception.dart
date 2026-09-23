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

abstract class NotAMemberException
    implements
        _is.SerializableException,
        _is.SerializableModel,
        _is.ProtocolSerialization {
  NotAMemberException._({
    required this.message,
    required this.venueId,
  });

  factory NotAMemberException({
    required String message,
    required _is.UuidValue venueId,
  }) = _NotAMemberExceptionImpl;

  factory NotAMemberException.fromJson(Map<String, dynamic> jsonSerialization) {
    return NotAMemberException(
      message: jsonSerialization['message'] as String,
      venueId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['venueId'],
      ),
    );
  }

  String message;

  _is.UuidValue venueId;

  /// Returns a shallow copy of this [NotAMemberException]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  NotAMemberException copyWith({
    String? message,
    _is.UuidValue? venueId,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'NotAMemberException',
      'message': message,
      'venueId': venueId.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'NotAMemberException',
      'message': message,
      'venueId': venueId.toJson(),
    };
  }

  @override
  String toString() {
    return 'NotAMemberException(message: $message, venueId: $venueId)';
  }
}

class _NotAMemberExceptionImpl extends NotAMemberException {
  _NotAMemberExceptionImpl({
    required String message,
    required _is.UuidValue venueId,
  }) : super._(
         message: message,
         venueId: venueId,
       );

  /// Returns a shallow copy of this [NotAMemberException]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  NotAMemberException copyWith({
    String? message,
    _is.UuidValue? venueId,
  }) {
    return NotAMemberException(
      message: message ?? this.message,
      venueId: venueId ?? this.venueId,
    );
  }
}
