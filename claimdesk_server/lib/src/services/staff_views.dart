import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';

class StaffViews {
  static FoundItem item(FoundItem row) => row.copyWith(embedding: null);
  static LostReport report(LostReport row, {String? lastMatchOutcome}) =>
      row.copyWith(
        publicToken: '',
        ipHash: null,
        embedding: null,
        lastMatchOutcome: lastMatchOutcome,
      );
  static Future<List<LostReport>> reports(
    Session s,
    List<LostReport> rows,
  ) async {
    if (rows.isEmpty) return [];
    final audits = await AuditEvent.db.find(
      s,
      where: (t) =>
          t.entityType.equals('report') &
          t.entityId.inSet(rows.map((r) => r.id!).toSet()) &
          t.action.inSet({'match_failed', 'match_completed'}),
      orderByList: (t) => [t.at.desc(), t.id.desc()],
    );
    final outcomes = <UuidValue, String>{};
    for (final audit in audits) {
      outcomes.putIfAbsent(
        audit.entityId,
        () => audit.action == 'match_failed' ? 'match_failed' : 'ok',
      );
    }
    return [
      for (final row in rows) report(row, lastMatchOutcome: outcomes[row.id]),
    ];
  }
}
