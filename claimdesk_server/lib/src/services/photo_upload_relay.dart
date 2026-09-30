import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:serverpod/serverpod.dart';

import '../access/venue_guard.dart';
import 'upload_tickets.dart';

/// Authenticated binary uploads avoid browser CORS restrictions on private storage.
@doNotGenerate
class PhotoUploadRelay extends Endpoint with VenueGuard {
  // Serverpod reserves this route for binary request bodies.
  static const endpointName = 'serverpod_cloud_storage';
  static const methodName = 'claimdeskUpload';
  static const maxBytes = 15 * 1024 * 1024;

  @override
  bool get sendAsRaw => true;

  /// The bearer token is returned only to the client that supplied it.
  static String? description(
    Session session, {
    required UuidValue venueId,
    required UuidValue itemId,
    required DateTime expires,
    required String proof,
    required String contentType,
  }) {
    if (session is! MethodCallSession) return null;
    final authorization = session.request.headers['authorization']?.firstOrNull;
    if (authorization == null) return null;
    final config = session.serverpod.config.apiServer;
    return jsonEncode({
      'type': 'binary',
      'method': 'POST',
      'url': Uri(
        scheme: config.publicScheme,
        host: config.publicHost,
        port: config.publicPort,
        path: '/$endpointName',
        queryParameters: {
          'method': methodName,
          'venue': venueId.toString(),
          'item': itemId.toString(),
          'expires': expires.microsecondsSinceEpoch.toString(),
          'proof': proof,
          'contentType': contentType,
        },
      ).toString(),
      'headers': {'Authorization': authorization},
    });
  }

  Future<Response> upload(
    MethodCallSession session, {
    required String venue,
    required String item,
    required String expires,
    required String proof,
    required String contentType,
  }) async {
    if (!['image/jpeg', 'image/png', 'image/webp'].contains(contentType)) {
      return Response.badRequest();
    }
    final authorized = await authorize(
      session,
      venue: venue,
      item: item,
      expires: expires,
      proof: proof,
    );
    if (authorized == null) return Response.forbidden();
    final (:venueId, :itemId, :expiration) = authorized;
    final bytes = await readBounded(session.request.read(), maxBytes);
    if (bytes == null) return Response(413);
    if (bytes.isEmpty || !expiration.isAfter(DateTime.now().toUtc())) {
      return Response.badRequest();
    }
    return forward(
      session,
      venueId: venueId,
      itemId: itemId,
      expiration: expiration,
      contentType: contentType,
      bytes: bytes,
    );
  }

  Future<({UuidValue venueId, UuidValue itemId, DateTime expiration})?>
  authorize(
    Session session, {
    required String venue,
    required String item,
    required String expires,
    required String proof,
  }) async {
    if (session.authenticated == null) return null;
    late UuidValue venueId;
    late UuidValue itemId;
    late DateTime expiration;
    try {
      venueId = UuidValue.fromString(venue);
      itemId = UuidValue.fromString(item);
      expiration = DateTime.fromMicrosecondsSinceEpoch(
        int.parse(expires),
        isUtc: true,
      );
    } catch (_) {
      return null;
    }
    if (!UploadTickets.verify(session, venueId, itemId, expiration, proof)) {
      return null;
    }
    await requireMembership(session, venueId);
    return (venueId: venueId, itemId: itemId, expiration: expiration);
  }

  Future<Response> forward(
    Session session, {
    required UuidValue venueId,
    required UuidValue itemId,
    required DateTime expiration,
    required String contentType,
    required Uint8List bytes,
  }) async {
    // Neither a target URL nor a storage path can be chosen by the caller.
    final target =
        jsonDecode(
              await session.storage.createUploadDescription(
                storageId: 'private',
                path: UploadTickets.path(venueId, itemId),
                options: UploadOptions(
                  maxFileSize: maxBytes,
                  preventOverwrite: true,
                  expirationDuration: expiration.difference(
                    DateTime.now().toUtc(),
                  ),
                  metadata: FileMetadata(contentType: contentType),
                ),
              ),
            )
            as Map<String, dynamic>;
    if (target['type'] != 'binary') return Response(502);
    final transport = http.Client();
    try {
      final request = http.Request(
        target['method'] as String? ?? 'POST',
        Uri.parse(target['url'] as String),
      );
      request.headers.addAll({
        'Content-Type': 'application/octet-stream',
        ...((target['headers'] as Map?)?.cast<String, String>() ?? {}),
      });
      request.bodyBytes = bytes;
      final response = await transport
          .send(request)
          .timeout(const Duration(seconds: 30));
      await response.stream.drain<void>().timeout(const Duration(seconds: 30));
      return response.statusCode == 200 || response.statusCode == 204
          ? Response.ok()
          : Response(502);
    } catch (_) {
      // Signed provider URLs and error bodies must never enter logs or responses.
      return Response(502);
    } finally {
      transport.close();
    }
  }

  static Future<Uint8List?> readBounded(
    Stream<List<int>> stream,
    int limit,
  ) async {
    var length = 0;
    final bytes = BytesBuilder(copy: false);
    await for (final chunk in stream) {
      length += chunk.length;
      if (length > limit) {
        bytes.clear();
      } else {
        bytes.add(chunk);
      }
    }
    return length > limit ? null : bytes.takeBytes();
  }

  /// Register a raw transport endpoint; item APIs and generated models stay typed.
  void register(Serverpod pod) {
    initialize(pod.server, endpointName, null);
    final connector = pod.endpoints.connectors.putIfAbsent(
      endpointName,
      () => EndpointConnector(
        name: endpointName,
        endpoint: this,
        methodConnectors: {},
      ),
    );
    // Preserve the framework's file/download/upload methods on local storage.
    // A shared connector may allow anonymous downloads; authorize() still
    // rejects an unauthenticated relay call before reading its body.
    connector.methodConnectors[methodName] = MethodConnector(
      name: endpointName,
      params: {
        for (final key in [
          'venue',
          'item',
          'expires',
          'proof',
          'contentType',
        ])
          key: ParameterDescription(
            name: key,
            type: String,
            nullable: false,
          ),
      },
      call: (session, params) => upload(
        session as MethodCallSession,
        venue: params['venue'],
        item: params['item'],
        expires: params['expires'],
        proof: params['proof'],
        contentType: params['contentType'],
      ),
    );
  }
}
