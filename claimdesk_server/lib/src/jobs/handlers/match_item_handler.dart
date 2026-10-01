import 'package:serverpod/serverpod.dart';
import '../../generated/protocol.dart';
import '../../matching/candidate_query.dart';
import '../../matching/match_service.dart';
import '../../matching/scorer.dart';
import '../job_handler.dart';

class MatchItemHandler extends JobHandler {
  @override
  String get kind => 'match_item';
  @override
  Future<void> run(Session session, WorkItem job) async {
    final s = session;
    final item = await FoundItem.db.findById(s, job.payload.entityId!);
    if (item == null ||
        item.venueId != job.venueId ||
        item.status != ItemStatus.unclaimed ||
        item.embedding == null ||
        !await JobClaim.current(s, job)) {
      return;
    }
    for (final candidate in await CandidateQuery().forItem(s, item)) {
      await MatchService().apply(s, job, candidate.report, [
        const Scorer().score(candidate),
      ], completeReportSet: false);
    }
  }
}
