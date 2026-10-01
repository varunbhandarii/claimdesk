import 'package:claimdesk_server/src/generated/protocol.dart';
import 'package:claimdesk_server/src/jobs/nightly.dart';
import 'package:test/test.dart';
import 'test_tools/serverpod_test_tools.dart';

void main() {
  test(
    'Nightly always selects the next 02:00 UTC including timezone offsets',
    () {
      expect(
        Nightly.nextRun(DateTime.utc(2026, 10, 1, 1, 59)),
        DateTime.utc(2026, 10, 1, 2),
      );
      expect(
        Nightly.nextRun(DateTime.utc(2026, 10, 1, 2)),
        DateTime.utc(2026, 10, 2, 2),
      );
      expect(
        Nightly.nextRun(DateTime.utc(2026, 10, 1, 2, 1)),
        DateTime.utc(2026, 10, 2, 2),
      );
      expect(
        Nightly.nextRun(DateTime.utc(2026, 10, 1, 1), tomorrow: true),
        DateTime.utc(2026, 10, 2, 2),
      );
    },
  );
  withServerpod('Daily housekeeping schedule', (builder, _) {
    test(
      'Startup and handler bootstrap create one global row per date with three attempts',
      () async {
        final s = builder.build();
        for (var i = 0; i < 2; i++) {
          await Nightly.schedule(s, now: DateTime.utc(2026, 10, 1, 1));
        }
        for (var i = 0; i < 2; i++) {
          await Nightly.schedule(
            s,
            now: DateTime.utc(2026, 10, 1, 1),
            tomorrow: true,
          );
        }
        final jobs = await WorkItem.db.find(
          s,
          where: (t) => t.kind.equals('nightly'),
          orderBy: (t) => t.runAt,
        );
        expect(jobs, hasLength(2));
        expect(jobs.map((j) => j.identifier), [
          'nightly_2026-10-01',
          'nightly_2026-10-02',
        ]);
        expect(
          jobs.every((j) => j.venueId == null && j.maxAttempts == 3),
          isTrue,
        );
      },
    );
  });
}
