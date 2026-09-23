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
import 'retention_policy.dart' as _ic8ul1lq;

abstract class Venue
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  Venue._({
    this.id,
    required this.name,
    required this.slug,
    String? timezone,
    this.deskHours,
    this.pickupInstructions,
    this.retentionPolicy,
    int? policeHandoffThresholdCents,
    int? policeHandoffDays,
    DateTime? createdAt,
  }) : timezone = timezone ?? 'America/New_York',
       policeHandoffThresholdCents = policeHandoffThresholdCents ?? 2000,
       policeHandoffDays = policeHandoffDays ?? 10,
       createdAt = createdAt ?? DateTime.now();

  factory Venue({
    _isc.UuidValue? id,
    required String name,
    required String slug,
    String? timezone,
    String? deskHours,
    String? pickupInstructions,
    _ic8ul1lq.RetentionPolicy? retentionPolicy,
    int? policeHandoffThresholdCents,
    int? policeHandoffDays,
    DateTime? createdAt,
  }) = _VenueImpl;

  factory Venue.fromJson(Map<String, dynamic> jsonSerialization) {
    return Venue(
      id: jsonSerialization['id'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      name: jsonSerialization['name'] as String,
      slug: jsonSerialization['slug'] as String,
      timezone: jsonSerialization['timezone'] as String?,
      deskHours: jsonSerialization['deskHours'] as String?,
      pickupInstructions: jsonSerialization['pickupInstructions'] as String?,
      retentionPolicy: jsonSerialization['retentionPolicy'] == null
          ? null
          : _i3upg8fq.Protocol().deserialize<_ic8ul1lq.RetentionPolicy>(
              jsonSerialization['retentionPolicy'],
            ),
      policeHandoffThresholdCents:
          jsonSerialization['policeHandoffThresholdCents'] as int?,
      policeHandoffDays: jsonSerialization['policeHandoffDays'] as int?,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  _isc.UuidValue? id;

  String name;

  String slug;

  String timezone;

  String? deskHours;

  String? pickupInstructions;

  _ic8ul1lq.RetentionPolicy? retentionPolicy;

  int policeHandoffThresholdCents;

  int policeHandoffDays;

  DateTime createdAt;

  /// Returns a shallow copy of this [Venue]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  Venue copyWith({
    _isc.UuidValue? id,
    String? name,
    String? slug,
    String? timezone,
    String? deskHours,
    String? pickupInstructions,
    _ic8ul1lq.RetentionPolicy? retentionPolicy,
    int? policeHandoffThresholdCents,
    int? policeHandoffDays,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Venue',
      if (id != null) 'id': id?.toJson(),
      'name': name,
      'slug': slug,
      'timezone': timezone,
      if (deskHours != null) 'deskHours': deskHours,
      if (pickupInstructions != null) 'pickupInstructions': pickupInstructions,
      if (retentionPolicy != null) 'retentionPolicy': retentionPolicy?.toJson(),
      'policeHandoffThresholdCents': policeHandoffThresholdCents,
      'policeHandoffDays': policeHandoffDays,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Venue',
      if (id != null) 'id': id?.toJson(),
      'name': name,
      'slug': slug,
      'timezone': timezone,
      if (deskHours != null) 'deskHours': deskHours,
      if (pickupInstructions != null) 'pickupInstructions': pickupInstructions,
      if (retentionPolicy != null)
        'retentionPolicy': retentionPolicy?.toJsonForProtocol(),
      'policeHandoffThresholdCents': policeHandoffThresholdCents,
      'policeHandoffDays': policeHandoffDays,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _VenueImpl extends Venue {
  _VenueImpl({
    _isc.UuidValue? id,
    required String name,
    required String slug,
    String? timezone,
    String? deskHours,
    String? pickupInstructions,
    _ic8ul1lq.RetentionPolicy? retentionPolicy,
    int? policeHandoffThresholdCents,
    int? policeHandoffDays,
    DateTime? createdAt,
  }) : super._(
         id: id,
         name: name,
         slug: slug,
         timezone: timezone,
         deskHours: deskHours,
         pickupInstructions: pickupInstructions,
         retentionPolicy: retentionPolicy,
         policeHandoffThresholdCents: policeHandoffThresholdCents,
         policeHandoffDays: policeHandoffDays,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [Venue]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  Venue copyWith({
    Object? id = _Undefined,
    String? name,
    String? slug,
    String? timezone,
    Object? deskHours = _Undefined,
    Object? pickupInstructions = _Undefined,
    Object? retentionPolicy = _Undefined,
    int? policeHandoffThresholdCents,
    int? policeHandoffDays,
    DateTime? createdAt,
  }) {
    return Venue(
      id: id is _isc.UuidValue? ? id : this.id,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      timezone: timezone ?? this.timezone,
      deskHours: deskHours is String? ? deskHours : this.deskHours,
      pickupInstructions: pickupInstructions is String?
          ? pickupInstructions
          : this.pickupInstructions,
      retentionPolicy: retentionPolicy is _ic8ul1lq.RetentionPolicy?
          ? retentionPolicy
          : this.retentionPolicy?.copyWith(),
      policeHandoffThresholdCents:
          policeHandoffThresholdCents ?? this.policeHandoffThresholdCents,
      policeHandoffDays: policeHandoffDays ?? this.policeHandoffDays,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
