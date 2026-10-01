import 'dart:async';
import 'package:claimdesk_server/src/generated/protocol.dart';
import 'package:claimdesk_server/src/jobs/job_handler.dart';
import 'package:claimdesk_server/src/jobs/job_queue.dart';
import 'package:claimdesk_server/src/jobs/job_worker.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';
import 'test_tools/serverpod_test_tools.dart';

class _Handler extends JobHandler {
  _Handler(this.claimed);
  final Completer<WorkItem> claimed;
  @override
  String get kind => 'record';
  @override
  Future<void> run(Session session, WorkItem job) async =>
      claimed.complete(job);
}

class _PausedEmptyWorker extends JobWorker {
  _PausedEmptyWorker(super.pod, {required super.handlers})
    : super(interval: const Duration(hours: 1), renewLeases: false);
  final empty = Completer<void>(), resume = Completer<void>();
  bool first = true;
  @override
  Future<void> tick(Session session) async {
    await super.tick(session);
    if (first) {
      first = false;
      empty.complete();
      await resume.future;
    }
  }
}

void main() {
  withServerpod('Given a worker with a one-hour fallback timer', (builder, _) {
    late JobWorker worker;
    tearDown(() async {
      await worker.stop();
      worker.pod.experimental.shutdownTasks.removeTask('job-worker');
      await WorkItem.db.deleteWhere(
        builder.build(),
        where: (t) => Constant.bool(true),
      );
    });
    test(
      'when enqueue commits then the job is claimed without the timer firing',
      () async {
        final claimed = Completer<WorkItem>();
        worker = JobWorker(
          builder.build().serverpod,
          interval: const Duration(hours: 1),
          handlers: [_Handler(claimed)],
          renewLeases: false,
        )..start();
        final job = await JobQueue.enqueue(
          builder.build(),
          kind: 'record',
          payload: WorkPayload(data: {}),
        );
        final processed = await claimed.future.timeout(
          const Duration(seconds: 2),
        );
        expect(processed.id, job.id);
        expect(processed.state, WorkState.running);
        expect(processed.attempts, 1);
      },
    );
    test(
      'when work commits after an empty claim then a busy wake triggers another pass',
      () async {
        final claimed = Completer<WorkItem>();
        final paused = _PausedEmptyWorker(
          builder.build().serverpod,
          handlers: [_Handler(claimed)],
        );
        worker = paused..start();
        worker.wake();
        await paused.empty.future.timeout(const Duration(seconds: 2));
        try {
          final job = await JobQueue.enqueue(
            builder.build(),
            kind: 'record',
            payload: WorkPayload(data: {}),
          );
          expect(
            claimed.isCompleted,
            false,
          ); // Enqueue returned while the tick is busy.
          paused.resume.complete();
          expect(
            (await claimed.future.timeout(const Duration(seconds: 2))).id,
            job.id,
          );
        } finally {
          if (!paused.resume.isCompleted) paused.resume.complete();
        }
      },
    );
    test(
      'when the enclosing enqueue rolls back then no job is claimed',
      () async {
        final claimed = Completer<WorkItem>();
        worker = JobWorker(
          builder.build().serverpod,
          interval: const Duration(hours: 1),
          handlers: [_Handler(claimed)],
          renewLeases: false,
        )..start();
        final session = builder.build();
        await expectLater(
          session.db.transaction((tx) async {
            await JobQueue.enqueue(
              session,
              kind: 'record',
              payload: WorkPayload(data: {}),
              transaction: tx,
            );
            worker
                .wake(); // Even a concurrent wake cannot see uncommitted work.
            await Future<void>.delayed(const Duration(milliseconds: 50));
            expect(claimed.isCompleted, false);
            throw StateError('rollback');
          }),
          throwsStateError,
        );
        expect(await WorkItem.db.count(session), 0);
        expect(claimed.isCompleted, false);
      },
    );
  }, rollbackDatabase: RollbackDatabase.disabled);
}
