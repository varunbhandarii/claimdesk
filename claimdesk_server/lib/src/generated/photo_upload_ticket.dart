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

abstract class PhotoUploadTicket
    implements _is.SerializableModel, _is.ProtocolSerialization {
  PhotoUploadTicket._({
    required this.itemId,
    required this.path,
    required this.uploadDescription,
    required this.expiresAt,
    required this.proof,
  });

  factory PhotoUploadTicket({
    required _is.UuidValue itemId,
    required String path,
    required String uploadDescription,
    required DateTime expiresAt,
    required String proof,
  }) = _PhotoUploadTicketImpl;

  factory PhotoUploadTicket.fromJson(Map<String, dynamic> jsonSerialization) {
    return PhotoUploadTicket(
      itemId: _is.UuidValueJsonExtension.fromJson(jsonSerialization['itemId']),
      path: jsonSerialization['path'] as String,
      uploadDescription: jsonSerialization['uploadDescription'] as String,
      expiresAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['expiresAt'],
      ),
      proof: jsonSerialization['proof'] as String,
    );
  }

  _is.UuidValue itemId;

  String path;

  String uploadDescription;

  DateTime expiresAt;

  String proof;

  /// Returns a shallow copy of this [PhotoUploadTicket]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  PhotoUploadTicket copyWith({
    _is.UuidValue? itemId,
    String? path,
    String? uploadDescription,
    DateTime? expiresAt,
    String? proof,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'PhotoUploadTicket',
      'itemId': itemId.toJson(),
      'path': path,
      'uploadDescription': uploadDescription,
      'expiresAt': expiresAt.toJson(),
      'proof': proof,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'PhotoUploadTicket',
      'itemId': itemId.toJson(),
      'path': path,
      'uploadDescription': uploadDescription,
      'expiresAt': expiresAt.toJson(),
      'proof': proof,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _PhotoUploadTicketImpl extends PhotoUploadTicket {
  _PhotoUploadTicketImpl({
    required _is.UuidValue itemId,
    required String path,
    required String uploadDescription,
    required DateTime expiresAt,
    required String proof,
  }) : super._(
         itemId: itemId,
         path: path,
         uploadDescription: uploadDescription,
         expiresAt: expiresAt,
         proof: proof,
       );

  /// Returns a shallow copy of this [PhotoUploadTicket]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  PhotoUploadTicket copyWith({
    _is.UuidValue? itemId,
    String? path,
    String? uploadDescription,
    DateTime? expiresAt,
    String? proof,
  }) {
    return PhotoUploadTicket(
      itemId: itemId ?? this.itemId,
      path: path ?? this.path,
      uploadDescription: uploadDescription ?? this.uploadDescription,
      expiresAt: expiresAt ?? this.expiresAt,
      proof: proof ?? this.proof,
    );
  }
}
