import 'package:serverpod/serverpod.dart';
import '../access/venue_guard.dart';
import '../generated/protocol.dart';
import '../services/item_attention.dart';
import '../services/staff_views.dart';

class DeskEndpoint extends Endpoint with VenueGuard {
  Future<DeskSummary> summary(Session session, UuidValue venueId) async {
    await requireMembership(session, venueId);
    final now = DateTime.now().toUtc();
    Future<List<FoundItem>> attention(String key) => FoundItem.db.find(
      session,
      where: (t) =>
          t.venueId.equals(venueId) & ItemAttention.condition(t, key, now),
      orderByList: (t) => key == 'overdue'
          ? [t.handoffDueAt, t.id]
          : key == 'expiringSoon'
          ? [t.holdUntil, t.id]
          : [t.createdAt, t.id],
      limit: 5,
    );
    // Counts are independent of the five-row previews. Bound values only;
    // the failed-job join uses the same identifier as the retry action.
    final result = await Future.wait<Object>([
      session.db.unsafeQuery(
        '''SELECT
        count(*) FILTER (WHERE f."status" = 'captioning' AND EXISTS (
          SELECT 1 FROM "work_item" w WHERE w."venueId" = f."venueId"
          AND w."kind" = 'caption_item' AND w."state" = 'failed'
          AND w."identifier" = 'caption_' || f."id"::text)),
        count(*) FILTER (WHERE f."status" IN ('unclaimed','matched','expired') AND f."handoffDueAt" < @now),
        count(*) FILTER (WHERE f."status" = 'unclaimed' AND f."holdUntil" BETWEEN @now AND @soon),
        count(*) FILTER (WHERE f."status" = 'expired'),
        count(*) FILTER (WHERE f."status" IN ('unclaimed','matched')),
        count(*) FILTER (WHERE f."status" = 'claimed' AND f."updatedAt" >= @week)
        FROM "found_item" f WHERE f."venueId" = @venue::uuid''',
        parameters: QueryParameters.named({
          'venue': venueId.toString(),
          'now': now,
          'soon': now.add(const Duration(days: 3)),
          'week': now.subtract(const Duration(days: 7)),
        }),
      ),
      attention('captioningFailed'),
      attention('overdue'),
      attention('expiringSoon'),
      FoundItem.db.find(
        session,
        where: (t) =>
            t.venueId.equals(venueId) & t.status.equals(ItemStatus.expired),
        orderByList: (t) => [t.createdAt, t.id],
        limit: 5,
      ),
      FoundItem.db.find(
        session,
        where: (t) => t.venueId.equals(venueId),
        orderByList: (t) => [t.createdAt.desc(), t.id.desc()],
        limit: 5,
      ),
      ItemMatch.db.count(
        session,
        where: (t) =>
            t.venueId.equals(venueId) &
            t.state.equals(MatchState.pending) &
            t.label.inSet({'strong', 'possible'}),
      ),
      LostReport.db.count(
        session,
        where: (t) =>
            t.venueId.equals(venueId) &
            t.status.inSet({
              ReportStatus.received,
              ReportStatus.searching,
              ReportStatus.possibleMatch,
              ReportStatus.readyForPickup,
            }),
      ),
    ]);
    final counts = (result[0] as List).single as List;
    List<FoundItem> items(int index) =>
        (result[index] as List<FoundItem>).map(StaffViews.item).toList();
    return DeskSummary(
      newMatches: result[6] as int,
      captioningFailed: items(1),
      captioningFailedCount: (counts[0] as num).toInt(),
      overdue: items(2),
      overdueCount: (counts[1] as num).toInt(),
      expiringSoon: items(3),
      expiringSoonCount: (counts[2] as num).toInt(),
      expired: items(4),
      expiredCount: (counts[3] as num).toInt(),
      openReports: result[7] as int,
      recent: items(5),
      onShelf: (counts[4] as num).toInt(),
      returnedThisWeek: (counts[5] as num).toInt(),
      generatedAt: now,
    );
  }
}
