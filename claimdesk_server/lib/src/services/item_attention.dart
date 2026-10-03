import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';

class ItemAttention {
  static const values = {'captioningFailed', 'overdue', 'expiringSoon'};
  static Expression condition(
    FoundItemTable t,
    String? attention,
    DateTime now,
  ) {
    switch (attention) {
      case null:
        return Constant.bool(true);
      case 'captioningFailed':
        return t.status.equals(ItemStatus.captioning) &
            Expression('''EXISTS (
          SELECT 1 FROM "work_item" w WHERE w."venueId" = ${t.venueId}
          AND w."kind" = 'caption_item' AND w."state" = 'failed'
          AND w."identifier" = 'caption_' || ${t.id}::text)''');
      case 'overdue':
        return t.status.inSet({
              ItemStatus.unclaimed,
              ItemStatus.matched,
              ItemStatus.expired,
            }) &
            (t.handoffDueAt < now);
      case 'expiringSoon':
        return t.status.equals(ItemStatus.unclaimed) &
            t.holdUntil.between(now, now.add(const Duration(days: 3)));
      default:
        throw ArgumentError('Unknown attention filter');
    }
  }

  static Expression filter(
    FoundItemTable t,
    UuidValue venueId,
    ItemFilter filter,
    DateTime now,
  ) =>
      t.venueId.equals(venueId) &
      (filter.status != null
          ? t.status.equals(filter.status)
          : filter.attention == 'overdue'
          ? Constant.bool(true)
          : t.status.notInSet({ItemStatus.disposed, ItemStatus.expired})) &
      (filter.zoneId == null
          ? Constant.bool(true)
          : t.zoneId.equals(filter.zoneId)) &
      condition(t, filter.attention, now);
}
