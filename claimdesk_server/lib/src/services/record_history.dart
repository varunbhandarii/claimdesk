import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';

class StaffActors {
  static Future<Map<UuidValue, String>> names(
    Session s,
    UuidValue venue,
    Set<UuidValue> ids,
  ) async {
    if (ids.isEmpty) return {};
    final rows = await StaffMembership.db.find(
      s,
      where: (t) => t.venueId.equals(venue) & t.authUserId.inSet(ids),
    );
    return {for (final row in rows) row.authUserId: row.displayName};
  }

  static String name(Map<UuidValue, String> names, UuidValue id) =>
      names[id] ?? 'Former staff member';
}

class RecordHistory {
  static const _summaries = <String, String>{
    'created': 'Record created',
    'updated': 'Staff updated item',
    'captioned': 'Item captioned',
    'normalised': 'Report normalised',
    'match_completed': 'Report compared with found items',
    'match_failed': 'Matching unavailable',
    'match_rejected': 'Match rejected',
    'match_confirmed': 'Match confirmed',
    'confirmation_undone': 'Confirmation undone',
    'answered': 'Owner answered the questions',
    'ready_for_pickup': 'Ready for pickup',
    'released': 'Item returned to claimant',
    'returned': 'Reported item returned',
    'closed': 'Report closed',
    'expired': 'Item expired',
    'photo_attached': 'Demo photo attached',
    'handoff_overdue': 'Police hand-off overdue',
    'contact_purged': 'Contact details purged',
    'photo_purged': 'Photo purged',
    'moved': 'Item moved',
    'transferred': 'Item handed over',
    'disposed': 'Item disposed',
  };
  static const _safeKeys = {
    'provider',
    'outcome',
    'latencyMs',
    'model',
    'itemCount',
    'algorithmVersion',
    'count',
    'idTypeSeen',
    'detailsMatched',
    'thirdParty',
    'recommendedAction',
    'toLocation',
    'reference',
    'action',
    'reportRef',
    'itemRef',
    'reportRefCode',
    'itemRefCode',
    'refCode',
    'recaption',
  };
  static const _states = {
    'captioning',
    'unclaimed',
    'matched',
    'claimed',
    'transferred',
    'expired',
    'disposed',
    'received',
    'searching',
    'possibleMatch',
    'readyForPickup',
    'returned',
    'closed',
    'desk',
    'safe',
    'police',
    'issuer',
    'pending',
    'confirmed',
    'rejected',
  };

  static Future<List<HistoryEntry>> item(Session s, FoundItem item) =>
      _read(s, item.venueId, item.id!, isItem: true);
  static Future<List<HistoryEntry>> report(Session s, LostReport report) =>
      _read(
        s,
        report.venueId,
        report.id!,
        isItem: false,
        includeRelease: report.status == ReportStatus.returned,
      );

  static Future<List<HistoryEntry>> _read(
    Session s,
    UuidValue venue,
    UuidValue id, {
    required bool isItem,
    bool includeRelease = true,
  }) async {
    final audit = await AuditEvent.db.find(
      s,
      where: (t) =>
          t.venueId.equals(venue) &
          t.entityType.equals(isItem ? 'item' : 'report') &
          t.entityId.equals(id),
      orderByList: (t) => [t.at.desc(), t.id.desc()],
      limit: 200,
    );
    final custody = isItem
        ? await CustodyEvent.db.find(
            s,
            where: (t) => t.venueId.equals(venue) & t.itemId.equals(id),
            orderByList: (t) => [t.at.desc(), t.id.desc()],
            limit: 200,
          )
        : <CustodyEvent>[];
    final captions = isItem
        ? await CaptionRun.db.find(
            s,
            where: (t) => t.venueId.equals(venue) & t.itemId.equals(id),
            orderByList: (t) => [t.createdAt.desc(), t.id.desc()],
            limit: 200,
          )
        : <CaptionRun>[];
    final releases = includeRelease
        ? await ReleaseRecord.db.find(
            s,
            where: (t) =>
                t.venueId.equals(venue) &
                (isItem ? t.itemId.equals(id) : t.reportId.equals(id)),
            limit: 1,
          )
        : <ReleaseRecord>[];
    final names = await StaffActors.names(s, venue, {
      for (final row in audit)
        if (row.actorAuthUserId != null) row.actorAuthUserId!,
      for (final row in custody) row.byAuthUserId,
      for (final row in releases) row.releasedByAuthUserId,
    });
    String? state(String? value) => _states.contains(value) ? value : null;
    final entries = <HistoryEntry>[
      for (final row in audit)
        HistoryEntry(
          at: row.at,
          kind: 'audit',
          action: row.action,
          // Summaries and details are operational only: arbitrary close reasons,
          // notes and unknown payload fields never enter the timeline.
          summary: _summaries[row.action] ?? 'Record updated',
          fromState: state(row.payload?.fromState),
          toState: state(row.payload?.toState),
          actor: row.actorAuthUserId != null
              ? StaffActors.name(names, row.actorAuthUserId!)
              : (row.action == 'answered' ||
                        (!isItem && row.action == 'created')
                    ? 'Owner'
                    : 'System'),
          counterpart: _counterpart(row.payload?.data ?? {}, isItem),
          data: {
            for (final entry
                in (row.payload?.data ?? <String, String>{}).entries)
              if (_safeKeys.contains(entry.key)) entry.key: entry.value,
          },
        ),
      for (final row in custody)
        HistoryEntry(
          at: row.at,
          kind: 'custody',
          action: 'moved',
          summary: 'Moved from ${row.fromLocation} to ${row.toLocation}',
          fromState: row.fromLocation,
          toState: row.toLocation,
          actor: StaffActors.name(names, row.byAuthUserId),
          data: {if (row.reference != null) 'reference': row.reference!},
        ),
      for (final row in releases)
        HistoryEntry(
          at: row.releasedAt,
          kind: 'release',
          action: 'released',
          summary: 'Released to a claimant',
          actor: StaffActors.name(names, row.releasedByAuthUserId),
          data: {
            'idTypeSeen': row.idTypeSeen,
            'detailsMatched': '${row.detailsMatched}',
          },
        ),
      for (final row in captions)
        HistoryEntry(
          at: row.createdAt,
          kind: 'caption',
          action: row.outcome,
          summary: 'Caption ${row.outcome}',
          actor: 'System',
          data: {
            'provider': row.provider,
            'model': row.modelId,
            'latencyMs': '${row.latencyMs}',
            'promptVersion': row.promptVersion,
            if (row.inputTokens != null) 'inputTokens': '${row.inputTokens}',
            if (row.outputTokens != null) 'outputTokens': '${row.outputTokens}',
          },
        ),
    ];
    entries.sort((a, b) => b.at.compareTo(a.at));
    return entries.take(200).toList();
  }

  static String? _counterpart(Map<String, String> data, bool isItem) {
    for (final key in [
      'counterpartRef',
      ...(isItem ? ['reportRefCode', 'reportRef'] : ['itemRefCode', 'itemRef']),
    ]) {
      final value = data[key];
      if (value != null && RegExp(r'^[A-Z0-9]{6}$').hasMatch(value)) {
        return value;
      }
    }
    return null;
  }
}
