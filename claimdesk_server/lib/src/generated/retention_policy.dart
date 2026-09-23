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

abstract class RetentionPolicy
    implements _is.SerializableModel, _is.ProtocolSerialization {
  RetentionPolicy._({
    required this.holdDaysByCategory,
    required this.disposalByCategory,
    int? reportAutoCloseDays,
    int? contactPurgeDays,
  }) : reportAutoCloseDays = reportAutoCloseDays ?? 60,
       contactPurgeDays = contactPurgeDays ?? 30;

  factory RetentionPolicy({
    required Map<String, int> holdDaysByCategory,
    required Map<String, String> disposalByCategory,
    int? reportAutoCloseDays,
    int? contactPurgeDays,
  }) = _RetentionPolicyImpl;

  factory RetentionPolicy.fromJson(Map<String, dynamic> jsonSerialization) {
    return RetentionPolicy(
      holdDaysByCategory: _ii1g677k.Protocol().deserialize<Map<String, int>>(
        jsonSerialization['holdDaysByCategory'],
      ),
      disposalByCategory: _ii1g677k.Protocol().deserialize<Map<String, String>>(
        jsonSerialization['disposalByCategory'],
      ),
      reportAutoCloseDays: jsonSerialization['reportAutoCloseDays'] as int?,
      contactPurgeDays: jsonSerialization['contactPurgeDays'] as int?,
    );
  }

  Map<String, int> holdDaysByCategory;

  Map<String, String> disposalByCategory;

  int reportAutoCloseDays;

  int contactPurgeDays;

  /// Returns a shallow copy of this [RetentionPolicy]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  RetentionPolicy copyWith({
    Map<String, int>? holdDaysByCategory,
    Map<String, String>? disposalByCategory,
    int? reportAutoCloseDays,
    int? contactPurgeDays,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'RetentionPolicy',
      'holdDaysByCategory': holdDaysByCategory.toJson(),
      'disposalByCategory': disposalByCategory.toJson(),
      'reportAutoCloseDays': reportAutoCloseDays,
      'contactPurgeDays': contactPurgeDays,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'RetentionPolicy',
      'holdDaysByCategory': holdDaysByCategory.toJson(),
      'disposalByCategory': disposalByCategory.toJson(),
      'reportAutoCloseDays': reportAutoCloseDays,
      'contactPurgeDays': contactPurgeDays,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _RetentionPolicyImpl extends RetentionPolicy {
  _RetentionPolicyImpl({
    required Map<String, int> holdDaysByCategory,
    required Map<String, String> disposalByCategory,
    int? reportAutoCloseDays,
    int? contactPurgeDays,
  }) : super._(
         holdDaysByCategory: holdDaysByCategory,
         disposalByCategory: disposalByCategory,
         reportAutoCloseDays: reportAutoCloseDays,
         contactPurgeDays: contactPurgeDays,
       );

  /// Returns a shallow copy of this [RetentionPolicy]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  RetentionPolicy copyWith({
    Map<String, int>? holdDaysByCategory,
    Map<String, String>? disposalByCategory,
    int? reportAutoCloseDays,
    int? contactPurgeDays,
  }) {
    return RetentionPolicy(
      holdDaysByCategory:
          holdDaysByCategory ??
          this.holdDaysByCategory.map(
            (
              key0,
              value0,
            ) => MapEntry(
              key0,
              value0,
            ),
          ),
      disposalByCategory:
          disposalByCategory ??
          this.disposalByCategory.map(
            (
              key0,
              value0,
            ) => MapEntry(
              key0,
              value0,
            ),
          ),
      reportAutoCloseDays: reportAutoCloseDays ?? this.reportAutoCloseDays,
      contactPurgeDays: contactPurgeDays ?? this.contactPurgeDays,
    );
  }
}
