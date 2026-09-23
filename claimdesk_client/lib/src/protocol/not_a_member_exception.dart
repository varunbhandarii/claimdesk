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

abstract class NotAMemberException
    implements
        _isc.SerializableException,
        _isc.SerializableModel,
        _isc.ProtocolSerialization {
  NotAMemberException._({
    required this.message,
    required this.venueId,
  });

  factory NotAMemberException({
    required String message,
    required _isc.UuidValue venueId,
  }) = _NotAMemberExceptionImpl;

  factory NotAMemberException.fromJson(Map<String, dynamic> jsonSerialization) {
    return NotAMemberException(
      message: jsonSerialization['message'] as String,
      venueId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['venueId'],
      ),
    );
  }

  String message;

  _isc.UuidValue venueId;

  /// Returns a shallow copy of this [NotAMemberException]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  NotAMemberException copyWith({
    String? message,
    _isc.UuidValue? venueId,
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
    required _isc.UuidValue venueId,
  }) : super._(
         message: message,
         venueId: venueId,
       );

  /// Returns a shallow copy of this [NotAMemberException]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  NotAMemberException copyWith({
    String? message,
    _isc.UuidValue? venueId,
  }) {
    return NotAMemberException(
      message: message ?? this.message,
      venueId: venueId ?? this.venueId,
    );
  }
}
