import 'package:serverpod/serverpod.dart';
import '../../generated/protocol.dart';
import '../job_handler.dart';
import 'caption_item_handler.dart';

class ReembedItemHandler extends JobHandler {
  @override
  String get kind => 'reembed_item';
  @override
  Future<void> run(Session session, WorkItem job) async {
    final item = await FoundItem.db.findById(session, job.payload.entityId!);
    if (item == null ||
        item.venueId != job.venueId ||
        item.attributes == null ||
        item.status == ItemStatus.captioning ||
        item.embedding != null) {
      return;
    }
    await embedItem(session, job, item, retryFailure: true);
    await session.messages.postMessage(
      'venue_${item.venueId}',
      DeskEvent(
        kind: 'itemStatus',
        venueId: item.venueId,
        itemId: item.id,
        at: DateTime.now().toUtc(),
      ),
    );
  }
}
