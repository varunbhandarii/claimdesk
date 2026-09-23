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
import 'staff_role.dart' as _i120pgjk;

abstract class StaffMembership
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  StaffMembership._({
    this.id,
    required this.authUserId,
    required this.venueId,
    _i120pgjk.StaffRole? role,
    required this.displayName,
    DateTime? createdAt,
  }) : role = role ?? _i120pgjk.StaffRole.staff,
       createdAt = createdAt ?? DateTime.now();

  factory StaffMembership({
    _isc.UuidValue? id,
    required _isc.UuidValue authUserId,
    required _isc.UuidValue venueId,
    _i120pgjk.StaffRole? role,
    required String displayName,
    DateTime? createdAt,
  }) = _StaffMembershipImpl;

  factory StaffMembership.fromJson(Map<String, dynamic> jsonSerialization) {
    return StaffMembership(
      id: jsonSerialization['id'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      authUserId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['authUserId'],
      ),
      venueId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['venueId'],
      ),
      role: jsonSerialization['role'] == null
          ? null
          : _i120pgjk.StaffRole.fromJson((jsonSerialization['role'] as String)),
      displayName: jsonSerialization['displayName'] as String,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  _isc.UuidValue? id;

  _isc.UuidValue authUserId;

  _isc.UuidValue venueId;

  _i120pgjk.StaffRole role;

  String displayName;

  DateTime createdAt;

  /// Returns a shallow copy of this [StaffMembership]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  StaffMembership copyWith({
    _isc.UuidValue? id,
    _isc.UuidValue? authUserId,
    _isc.UuidValue? venueId,
    _i120pgjk.StaffRole? role,
    String? displayName,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'StaffMembership',
      if (id != null) 'id': id?.toJson(),
      'authUserId': authUserId.toJson(),
      'venueId': venueId.toJson(),
      'role': role.toJson(),
      'displayName': displayName,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'StaffMembership',
      if (id != null) 'id': id?.toJson(),
      'authUserId': authUserId.toJson(),
      'venueId': venueId.toJson(),
      'role': role.toJson(),
      'displayName': displayName,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _StaffMembershipImpl extends StaffMembership {
  _StaffMembershipImpl({
    _isc.UuidValue? id,
    required _isc.UuidValue authUserId,
    required _isc.UuidValue venueId,
    _i120pgjk.StaffRole? role,
    required String displayName,
    DateTime? createdAt,
  }) : super._(
         id: id,
         authUserId: authUserId,
         venueId: venueId,
         role: role,
         displayName: displayName,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [StaffMembership]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  StaffMembership copyWith({
    Object? id = _Undefined,
    _isc.UuidValue? authUserId,
    _isc.UuidValue? venueId,
    _i120pgjk.StaffRole? role,
    String? displayName,
    DateTime? createdAt,
  }) {
    return StaffMembership(
      id: id is _isc.UuidValue? ? id : this.id,
      authUserId: authUserId ?? this.authUserId,
      venueId: venueId ?? this.venueId,
      role: role ?? this.role,
      displayName: displayName ?? this.displayName,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
