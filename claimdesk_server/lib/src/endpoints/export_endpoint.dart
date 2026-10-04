import 'dart:math';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';
import '../access/venue_guard.dart';
import '../generated/protocol.dart';
import '../services/csv_export.dart';
import '../services/venue_exports.dart';

class ExportEndpoint extends Endpoint with VenueGuard {
  Future<ExportResult> export(Session s, UuidValue venueId, String kind) async {
    await requireMembership(s, venueId, supervisor: true);
    final data = await VenueExports.build(s, venueId, kind);
    final now = DateTime.now().toUtc();
    final stamp = now
        .toIso8601String()
        .replaceAll(RegExp(r'[-:]'), '')
        .replaceFirst('T', '-')
        .substring(0, 15);
    final random = Random.secure();
    final suffix = List.generate(
      4,
      (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'),
    ).join();
    final path = 'venues/$venueId/exports/$kind-$stamp-$suffix.csv';
    await s.storage.storeFile(
      storageId: 'private',
      path: path,
      byteData: CsvWriter.bytes(data.header, data.rows),
      options: StoreFileOptions(
        metadata: FileMetadata(
          contentType: 'text/csv; charset=utf-8',
          cacheControl: 'no-store',
          contentDisposition: 'attachment; filename="$kind-$stamp.csv"',
        ),
      ),
    );
    try {
      final url = await s.storage.temporaryDownloadUrl(
        storageId: 'private',
        path: path,
        options: const TemporaryDownloadUrlOptions(
          expirationDuration: Duration(minutes: 10),
        ),
      );
      await AuditEvent.db.insertRow(
        s,
        AuditEvent(
          venueId: venueId,
          entityType: 'venue',
          entityId: venueId,
          action: 'exported',
          actorAuthUserId: s.authenticated!.authUserId,
          payload: AuditPayload(
            summary: 'Venue CSV exported',
            data: {'kind': kind, 'rows': '${data.rows.length}'},
          ),
        ),
      );
      return ExportResult(
        url: url.toString(),
        rows: data.rows.length,
        expiresAt: now.add(const Duration(minutes: 10)),
        kind: kind,
      );
    } catch (_) {
      await s.storage.deleteFile(storageId: 'private', path: path);
      rethrow;
    }
  }
}
