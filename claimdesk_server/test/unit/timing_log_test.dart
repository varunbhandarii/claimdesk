import 'package:claimdesk_server/src/jobs/timing_log.dart';
import 'package:test/test.dart';

void main() {
  test('intake stage line contains only its reference and numeric durations', () {
    expect(
      intakeTiming(
        reference: 'SEED01',
        prepareMs: 1,
        captionMs: 2,
        storeMs: 3,
        embedMs: 4,
        totalMs: 15,
      ),
      'Intake timing item=SEED01 prepareMs=1 captionMs=2 storeMs=3 embedMs=4 totalMs=15',
    );
    expect(
      () => intakeTiming(
        reference: 'private@example.test',
        prepareMs: 1,
        captionMs: 2,
        storeMs: 3,
        embedMs: 4,
        totalMs: 15,
      ),
      throwsArgumentError,
    );
  });
}
