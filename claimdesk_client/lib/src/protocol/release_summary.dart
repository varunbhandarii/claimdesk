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
import 'release_record.dart' as _ieeq0b1h;

abstract class ReleaseSummary
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  ReleaseSummary._({
    required this.record,
    required this.releasedByName,
    this.reportRefCode,
  });

  factory ReleaseSummary({
    required _ieeq0b1h.ReleaseRecord record,
    required String releasedByName,
    String? reportRefCode,
  }) = _ReleaseSummaryImpl;

  factory ReleaseSummary.fromJson(Map<String, dynamic> jsonSerialization) {
    return ReleaseSummary(
      record: _i3upg8fq.Protocol().deserialize<_ieeq0b1h.ReleaseRecord>(
        jsonSerialization['record'],
      ),
      releasedByName: jsonSerialization['releasedByName'] as String,
      reportRefCode: jsonSerialization['reportRefCode'] as String?,
    );
  }

  _ieeq0b1h.ReleaseRecord record;

  String releasedByName;

  String? reportRefCode;

  /// Returns a shallow copy of this [ReleaseSummary]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  ReleaseSummary copyWith({
    _ieeq0b1h.ReleaseRecord? record,
    String? releasedByName,
    String? reportRefCode,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ReleaseSummary',
      'record': record.toJson(),
      'releasedByName': releasedByName,
      if (reportRefCode != null) 'reportRefCode': reportRefCode,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'ReleaseSummary',
      'record': record.toJsonForProtocol(),
      'releasedByName': releasedByName,
      if (reportRefCode != null) 'reportRefCode': reportRefCode,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ReleaseSummaryImpl extends ReleaseSummary {
  _ReleaseSummaryImpl({
    required _ieeq0b1h.ReleaseRecord record,
    required String releasedByName,
    String? reportRefCode,
  }) : super._(
         record: record,
         releasedByName: releasedByName,
         reportRefCode: reportRefCode,
       );

  /// Returns a shallow copy of this [ReleaseSummary]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  ReleaseSummary copyWith({
    _ieeq0b1h.ReleaseRecord? record,
    String? releasedByName,
    Object? reportRefCode = _Undefined,
  }) {
    return ReleaseSummary(
      record: record ?? this.record.copyWith(),
      releasedByName: releasedByName ?? this.releasedByName,
      reportRefCode: reportRefCode is String?
          ? reportRefCode
          : this.reportRefCode,
    );
  }
}
