import 'package:claimdesk_server/src/jobs/job_queue.dart';
import 'package:test/test.dart';

void main() {
  test('retry delays begin at five seconds and double', () {
    expect(
      [for (var i = 1; i <= 4; i++) JobQueue.backoff(i).inSeconds],
      [5, 10, 20, 40],
    );
  });
}
