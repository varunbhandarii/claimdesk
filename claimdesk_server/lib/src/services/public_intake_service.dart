import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';
import '../web/public/report_form_input.dart';
import 'duplicate_rule.dart';
import 'public_codes.dart';
import '../matching/match_jobs.dart';
import '../jobs/job_wakeup.dart';

class PublicIntakeService {
  PublicIntakeService({PublicCodes? codes}) : codes = codes ?? PublicCodes();
  final PublicCodes codes;
  Future<({LostReport report, bool duplicate})> submit(
    Session session,
    Venue venue,
    ReportFormInput input,
    String ipHash,
  ) async {
    for (var attempt = 0; attempt < 5; attempt++) {
      try {
        final result = await session.db.transaction((tx) async {
          // Serialize duplicate checks for this venue, including simultaneous POSTs.
          await Venue.db.findById(
            session,
            venue.id!,
            transaction: tx,
            lockMode: LockMode.forUpdate,
          );
          if (input.zoneId != null) {
            final zone = await Zone.db.findById(
              session,
              UuidValue.fromString(input.zoneId!),
              transaction: tx,
            );
            if (zone?.venueId != venue.id) {
              throw ArgumentError('Zone does not belong to this venue');
            }
          }
          final now = DateTime.now().toUtc();
          final prior = await LostReport.db.find(
            session,
            where: (t) =>
                t.venueId.equals(venue.id!) &
                t.contactEmail.equals(input.contactEmail) &
                (t.createdAt >= now.subtract(const Duration(hours: 24))),
            orderByList: (t) => [t.createdAt.desc()],
            transaction: tx,
          );
          for (final report in prior) {
            if (DuplicateRule.matches(
              category: input.categoryHint,
              previousCategory: report.categoryHint,
              text: input.rawText,
              previousText: report.rawText,
              previousCreatedAt: report.createdAt,
              now: now,
            )) {
              return (
                report: await LostReport.db.updateRow(
                  session,
                  report.copyWith(updatedAt: now),
                  transaction: tx,
                ),
                duplicate: true,
              );
            }
          }
          final report = await LostReport.db.insertRow(
            session,
            LostReport(
              venueId: venue.id!,
              refCode: codes.reference(),
              publicToken: codes.token(),
              rawText: input.rawText,
              categoryHint: input.categoryHint,
              colourHints: input.colourHints,
              brandHint: input.brandHint,
              zoneId: input.zoneId == null
                  ? null
                  : UuidValue.fromString(input.zoneId!),
              whereText: input.whereText,
              lostAt: input.lostAt,
              lostAtFuzzyDays: input.lostAtFuzzyDays,
              ownerOnlyDetails: input.ownerOnlyDetails,
              contactEmail: input.contactEmail,
              ownerName: input.ownerName,
              ipHash: ipHash,
              createdAt: now,
              updatedAt: now,
            ),
            transaction: tx,
          );
          await AuditEvent.db.insertRow(
            session,
            AuditEvent(
              venueId: venue.id!,
              entityType: 'report',
              entityId: report.id!,
              action: 'created',
              payload: AuditPayload(
                summary: 'Lost report received',
                toState: 'received',
                data: {'refCode': report.refCode},
              ),
            ),
            transaction: tx,
          );
          await MatchJobs.report(session, report, transaction: tx);
          return (report: report, duplicate: false);
        });
        if (!result.duplicate) JobWakeup.notify(session);
        await session.messages.postMessage(
          'venue_${venue.id}',
          DeskEvent(
            kind: 'reportCreated',
            venueId: venue.id!,
            reportId: result.report.id!,
            at: result.report.updatedAt,
          ),
        );
        return result;
      } on DatabaseUniqueViolationException catch (error) {
        if (attempt == 4 ||
            !{
              'lost_report__venueId__refCode__unique_idx',
              'lost_report__publicToken__unique_idx',
            }.contains(error.constraintName)) {
          rethrow;
        }
      }
    }
    throw StateError('Unable to allocate report reference');
  }

  Future<LostReport?> findByToken(Session session, String token) async =>
      !PublicCodes.validToken(token)
      ? null
      : LostReport.db.findFirstRow(
          session,
          where: (t) => t.publicToken.equals(token),
        );
}
