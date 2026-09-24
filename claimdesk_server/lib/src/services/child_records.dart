import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import '../jobs/job_queue.dart';

/// Shared persistence paths for child records. Callers authorize access before
/// calling these methods; tenant ids always come from stored parent rows.
class ChildRecords {
  static Future<WorkItem> itemWork(
    Session session, {
    required UuidValue itemId,
    required String kind,
    required String identifier,
    Map<String, String> data = const {},
    int maxAttempts = 5,
    Transaction? transaction,
  }) async {
    final item = await FoundItem.db.findById(
      session,
      itemId,
      transaction: transaction,
    );
    if (item == null) throw ArgumentError('Item unavailable');
    return JobQueue.enqueue(
      session,
      kind: kind,
      venueId: item.venueId,
      identifier: identifier,
      payload: WorkPayload(entityId: item.id, data: data),
      maxAttempts: maxAttempts,
      transaction: transaction,
    );
  }

  static Future<FoundItem> _item(Session session, UuidValue id) async {
    final item = await FoundItem.db.findById(session, id);
    if (item == null) throw ArgumentError('Item unavailable');
    return item;
  }

  static Future<CaptionRun> caption(
    Session session, {
    required UuidValue itemId,
    required String provider,
    required String modelId,
    required String promptVersion,
    required String outcome,
    required int latencyMs,
    int? inputTokens,
    int? outputTokens,
    String? errorMessage,
    Transaction? transaction,
  }) async {
    final item = await FoundItem.db.findById(
      session,
      itemId,
      transaction: transaction,
    );
    if (item == null) throw ArgumentError('Item unavailable');
    return CaptionRun.db.insertRow(
      session,
      CaptionRun(
        venueId: item.venueId,
        itemId: item.id!,
        provider: provider,
        modelId: modelId,
        promptVersion: promptVersion,
        outcome: outcome,
        latencyMs: latencyMs,
        inputTokens: inputTokens,
        outputTokens: outputTokens,
        errorMessage: errorMessage,
      ),
      transaction: transaction,
    );
  }

  static Future<ReportAnswer> answer(
    Session session, {
    required UuidValue matchId,
    required String question,
    required String answer,
  }) async {
    final match = await ItemMatch.db.findById(session, matchId);
    if (match == null) throw ArgumentError('Match unavailable');
    final report = await LostReport.db.findById(session, match.reportId);
    final item = await _item(session, match.itemId);
    if (report == null ||
        report.venueId != match.venueId ||
        report.venueId != item.venueId) {
      throw ArgumentError('Match parents must belong to the same venue');
    }
    return ReportAnswer.db.insertRow(
      session,
      ReportAnswer(
        venueId: report.venueId,
        reportId: report.id!,
        matchId: match.id!,
        question: question,
        answer: answer,
      ),
    );
  }

  static Future<ReleaseRecord> release(
    Session session, {
    required UuidValue itemId,
    UuidValue? reportId,
    required String claimantName,
    required String idTypeSeen,
    required int detailsMatched,
    required bool describedBeforeViewing,
    required UuidValue releasedByAuthUserId,
    String? thirdPartyAuthorisationNote,
    String? signaturePath,
  }) async {
    final item = await _item(session, itemId);
    if (reportId != null) {
      final report = await LostReport.db.findById(session, reportId);
      if (report == null || report.venueId != item.venueId) {
        throw ArgumentError('Report and item must belong to the same venue');
      }
    }
    try {
      return await ReleaseRecord.db.insertRow(
        session,
        ReleaseRecord(
          venueId: item.venueId,
          itemId: item.id!,
          reportId: reportId,
          claimantName: claimantName,
          idTypeSeen: idTypeSeen,
          detailsMatched: detailsMatched,
          describedBeforeViewing: describedBeforeViewing,
          releasedByAuthUserId: releasedByAuthUserId,
          thirdPartyAuthorisationNote: thirdPartyAuthorisationNote,
          signaturePath: signaturePath,
        ),
      );
    } on DatabaseUniqueViolationException catch (error) {
      if (error.constraintName != 'release_record_item_idx') rethrow;
      throw AlreadyReleasedException(
        message: 'Item already released',
        itemId: itemId,
      );
    }
  }

  static Future<CustodyEvent> custody(
    Session session, {
    required UuidValue itemId,
    required String fromLocation,
    required String toLocation,
    required UuidValue byAuthUserId,
    String? reference,
  }) async {
    final item = await _item(session, itemId);
    return CustodyEvent.db.insertRow(
      session,
      CustodyEvent(
        venueId: item.venueId,
        itemId: item.id!,
        fromLocation: fromLocation,
        toLocation: toLocation,
        reference: reference,
        byAuthUserId: byAuthUserId,
      ),
    );
  }
}
