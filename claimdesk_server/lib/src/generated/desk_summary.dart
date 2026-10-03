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
import 'found_item.dart' as _i52cv103;

abstract class DeskSummary
    implements _is.SerializableModel, _is.ProtocolSerialization {
  DeskSummary._({
    required this.newMatches,
    required this.captioningFailed,
    required this.captioningFailedCount,
    required this.overdue,
    required this.overdueCount,
    required this.expiringSoon,
    required this.expiringSoonCount,
    required this.expired,
    required this.expiredCount,
    required this.openReports,
    required this.recent,
    required this.onShelf,
    required this.returnedThisWeek,
    required this.generatedAt,
  });

  factory DeskSummary({
    required int newMatches,
    required List<_i52cv103.FoundItem> captioningFailed,
    required int captioningFailedCount,
    required List<_i52cv103.FoundItem> overdue,
    required int overdueCount,
    required List<_i52cv103.FoundItem> expiringSoon,
    required int expiringSoonCount,
    required List<_i52cv103.FoundItem> expired,
    required int expiredCount,
    required int openReports,
    required List<_i52cv103.FoundItem> recent,
    required int onShelf,
    required int returnedThisWeek,
    required DateTime generatedAt,
  }) = _DeskSummaryImpl;

  factory DeskSummary.fromJson(Map<String, dynamic> jsonSerialization) {
    return DeskSummary(
      newMatches: jsonSerialization['newMatches'] as int,
      captioningFailed: _ii1g677k.Protocol()
          .deserialize<List<_i52cv103.FoundItem>>(
            jsonSerialization['captioningFailed'],
          ),
      captioningFailedCount: jsonSerialization['captioningFailedCount'] as int,
      overdue: _ii1g677k.Protocol().deserialize<List<_i52cv103.FoundItem>>(
        jsonSerialization['overdue'],
      ),
      overdueCount: jsonSerialization['overdueCount'] as int,
      expiringSoon: _ii1g677k.Protocol().deserialize<List<_i52cv103.FoundItem>>(
        jsonSerialization['expiringSoon'],
      ),
      expiringSoonCount: jsonSerialization['expiringSoonCount'] as int,
      expired: _ii1g677k.Protocol().deserialize<List<_i52cv103.FoundItem>>(
        jsonSerialization['expired'],
      ),
      expiredCount: jsonSerialization['expiredCount'] as int,
      openReports: jsonSerialization['openReports'] as int,
      recent: _ii1g677k.Protocol().deserialize<List<_i52cv103.FoundItem>>(
        jsonSerialization['recent'],
      ),
      onShelf: jsonSerialization['onShelf'] as int,
      returnedThisWeek: jsonSerialization['returnedThisWeek'] as int,
      generatedAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['generatedAt'],
      ),
    );
  }

  int newMatches;

  List<_i52cv103.FoundItem> captioningFailed;

  int captioningFailedCount;

  List<_i52cv103.FoundItem> overdue;

  int overdueCount;

  List<_i52cv103.FoundItem> expiringSoon;

  int expiringSoonCount;

  List<_i52cv103.FoundItem> expired;

  int expiredCount;

  int openReports;

  List<_i52cv103.FoundItem> recent;

  int onShelf;

  int returnedThisWeek;

  DateTime generatedAt;

  /// Returns a shallow copy of this [DeskSummary]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  DeskSummary copyWith({
    int? newMatches,
    List<_i52cv103.FoundItem>? captioningFailed,
    int? captioningFailedCount,
    List<_i52cv103.FoundItem>? overdue,
    int? overdueCount,
    List<_i52cv103.FoundItem>? expiringSoon,
    int? expiringSoonCount,
    List<_i52cv103.FoundItem>? expired,
    int? expiredCount,
    int? openReports,
    List<_i52cv103.FoundItem>? recent,
    int? onShelf,
    int? returnedThisWeek,
    DateTime? generatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'DeskSummary',
      'newMatches': newMatches,
      'captioningFailed': captioningFailed.toJson(
        valueToJson: (v) => v.toJson(),
      ),
      'captioningFailedCount': captioningFailedCount,
      'overdue': overdue.toJson(valueToJson: (v) => v.toJson()),
      'overdueCount': overdueCount,
      'expiringSoon': expiringSoon.toJson(valueToJson: (v) => v.toJson()),
      'expiringSoonCount': expiringSoonCount,
      'expired': expired.toJson(valueToJson: (v) => v.toJson()),
      'expiredCount': expiredCount,
      'openReports': openReports,
      'recent': recent.toJson(valueToJson: (v) => v.toJson()),
      'onShelf': onShelf,
      'returnedThisWeek': returnedThisWeek,
      'generatedAt': generatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'DeskSummary',
      'newMatches': newMatches,
      'captioningFailed': captioningFailed.toJson(
        valueToJson: (v) => v.toJsonForProtocol(),
      ),
      'captioningFailedCount': captioningFailedCount,
      'overdue': overdue.toJson(valueToJson: (v) => v.toJsonForProtocol()),
      'overdueCount': overdueCount,
      'expiringSoon': expiringSoon.toJson(
        valueToJson: (v) => v.toJsonForProtocol(),
      ),
      'expiringSoonCount': expiringSoonCount,
      'expired': expired.toJson(valueToJson: (v) => v.toJsonForProtocol()),
      'expiredCount': expiredCount,
      'openReports': openReports,
      'recent': recent.toJson(valueToJson: (v) => v.toJsonForProtocol()),
      'onShelf': onShelf,
      'returnedThisWeek': returnedThisWeek,
      'generatedAt': generatedAt.toJson(),
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _DeskSummaryImpl extends DeskSummary {
  _DeskSummaryImpl({
    required int newMatches,
    required List<_i52cv103.FoundItem> captioningFailed,
    required int captioningFailedCount,
    required List<_i52cv103.FoundItem> overdue,
    required int overdueCount,
    required List<_i52cv103.FoundItem> expiringSoon,
    required int expiringSoonCount,
    required List<_i52cv103.FoundItem> expired,
    required int expiredCount,
    required int openReports,
    required List<_i52cv103.FoundItem> recent,
    required int onShelf,
    required int returnedThisWeek,
    required DateTime generatedAt,
  }) : super._(
         newMatches: newMatches,
         captioningFailed: captioningFailed,
         captioningFailedCount: captioningFailedCount,
         overdue: overdue,
         overdueCount: overdueCount,
         expiringSoon: expiringSoon,
         expiringSoonCount: expiringSoonCount,
         expired: expired,
         expiredCount: expiredCount,
         openReports: openReports,
         recent: recent,
         onShelf: onShelf,
         returnedThisWeek: returnedThisWeek,
         generatedAt: generatedAt,
       );

  /// Returns a shallow copy of this [DeskSummary]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  DeskSummary copyWith({
    int? newMatches,
    List<_i52cv103.FoundItem>? captioningFailed,
    int? captioningFailedCount,
    List<_i52cv103.FoundItem>? overdue,
    int? overdueCount,
    List<_i52cv103.FoundItem>? expiringSoon,
    int? expiringSoonCount,
    List<_i52cv103.FoundItem>? expired,
    int? expiredCount,
    int? openReports,
    List<_i52cv103.FoundItem>? recent,
    int? onShelf,
    int? returnedThisWeek,
    DateTime? generatedAt,
  }) {
    return DeskSummary(
      newMatches: newMatches ?? this.newMatches,
      captioningFailed:
          captioningFailed ??
          this.captioningFailed.map((e0) => e0.copyWith()).toList(),
      captioningFailedCount:
          captioningFailedCount ?? this.captioningFailedCount,
      overdue: overdue ?? this.overdue.map((e0) => e0.copyWith()).toList(),
      overdueCount: overdueCount ?? this.overdueCount,
      expiringSoon:
          expiringSoon ?? this.expiringSoon.map((e0) => e0.copyWith()).toList(),
      expiringSoonCount: expiringSoonCount ?? this.expiringSoonCount,
      expired: expired ?? this.expired.map((e0) => e0.copyWith()).toList(),
      expiredCount: expiredCount ?? this.expiredCount,
      openReports: openReports ?? this.openReports,
      recent: recent ?? this.recent.map((e0) => e0.copyWith()).toList(),
      onShelf: onShelf ?? this.onShelf,
      returnedThisWeek: returnedThisWeek ?? this.returnedThisWeek,
      generatedAt: generatedAt ?? this.generatedAt,
    );
  }
}
