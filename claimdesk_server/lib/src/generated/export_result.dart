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

abstract class ExportResult
    implements _is.SerializableModel, _is.ProtocolSerialization {
  ExportResult._({
    required this.url,
    required this.rows,
    required this.expiresAt,
    required this.kind,
  });

  factory ExportResult({
    required String url,
    required int rows,
    required DateTime expiresAt,
    required String kind,
  }) = _ExportResultImpl;

  factory ExportResult.fromJson(Map<String, dynamic> jsonSerialization) {
    return ExportResult(
      url: jsonSerialization['url'] as String,
      rows: jsonSerialization['rows'] as int,
      expiresAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['expiresAt'],
      ),
      kind: jsonSerialization['kind'] as String,
    );
  }

  String url;

  int rows;

  DateTime expiresAt;

  String kind;

  /// Returns a shallow copy of this [ExportResult]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  ExportResult copyWith({
    String? url,
    int? rows,
    DateTime? expiresAt,
    String? kind,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ExportResult',
      'url': url,
      'rows': rows,
      'expiresAt': expiresAt.toJson(),
      'kind': kind,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'ExportResult',
      'url': url,
      'rows': rows,
      'expiresAt': expiresAt.toJson(),
      'kind': kind,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _ExportResultImpl extends ExportResult {
  _ExportResultImpl({
    required String url,
    required int rows,
    required DateTime expiresAt,
    required String kind,
  }) : super._(
         url: url,
         rows: rows,
         expiresAt: expiresAt,
         kind: kind,
       );

  /// Returns a shallow copy of this [ExportResult]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  ExportResult copyWith({
    String? url,
    int? rows,
    DateTime? expiresAt,
    String? kind,
  }) {
    return ExportResult(
      url: url ?? this.url,
      rows: rows ?? this.rows,
      expiresAt: expiresAt ?? this.expiresAt,
      kind: kind ?? this.kind,
    );
  }
}
