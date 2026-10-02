import 'dart:async';
import 'package:claimdesk_server/src/generated/protocol.dart';
import 'package:claimdesk_server/src/jobs/job_queue.dart';
import 'package:claimdesk_server/src/jobs/job_handler.dart';
import 'package:claimdesk_server/src/jobs/job_worker.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';
import 'test_tools/serverpod_test_tools.dart';
import 'test_tools/worker_cleanup.dart';

class _Handler extends JobHandler {
  _Handler(this.callback);
  final Future<void> Function(Session, WorkItem) callback;
  @override
  String get kind => 'record';
  @override
  Future<void> run(Session s, WorkItem j) => callback(s, j);
}

void main() {
  withServerpod('Given durable work', (builder, _) {
    setUp(() => clearWorkerTestData(builder.build()));
    tearDown(() => clearWorkerTestData(builder.build()));
    late Session s;
    late DateTime now;
    setUp(() {
      s = builder.build();
      now = DateTime.now().toUtc();
    });
    Future<WorkItem> enqueue({String? id, int maximum = 5}) => JobQueue.enqueue(
      s,
      kind: 'record',
      payload: WorkPayload(data: {}),
      identifier: id,
      runAt: now,
      maxAttempts: maximum,
    );
    JobWorker worker(JobHandler h) => JobWorker(
      s.serverpod,
      handlers: [h],
      clock: () => now,
      renewLeases: false,
    );
    test('a completed job is not processed again', () async {
      var count = 0;
      final j = await enqueue();
      final w = worker(
        _Handler((_, _) async {
          count++;
        }),
      );
      await w.tick(s);
      await w.tick(s);
      expect(count, 1);
      expect((await WorkItem.db.findById(s, j.id!))!.state, WorkState.done);
    });
    test(
      'two failures retry with increasing delays and third attempt succeeds',
      () async {
        var count = 0;
        final j = await enqueue();
        final w = worker(
          _Handler((_, _) async {
            if (++count <= 2) throw StateError('test');
          }),
        );
        for (final delay in [5, 10]) {
          await w.tick(s);
          final stored = (await WorkItem.db.findById(s, j.id!))!;
          expect(stored.state, WorkState.pending);
          expect(stored.runAt.difference(now).inSeconds, delay);
          now = stored.runAt;
        }
        await w.tick(s);
        final done = (await WorkItem.db.findById(s, j.id!))!;
        expect(done.state, WorkState.done);
        expect(done.attempts, 3);
      },
    );
    test('permanent failure stops exactly at the attempt limit', () async {
      final j = await enqueue();
      final w = worker(
        _Handler((_, _) async => throw StateError('sensitive error body')),
      );
      for (var i = 0; i < 5; i++) {
        await w.tick(s);
        now = (await WorkItem.db.findById(s, j.id!))!.runAt;
      }
      await w.tick(s);
      final failed = (await WorkItem.db.findById(s, j.id!))!;
      expect(failed.state, WorkState.failed);
      expect(failed.attempts, 5);
      expect(failed.lastError, 'Job handler failed');
    });
    test('identifier replacement and cancellation preserve one row', () async {
      final first = await enqueue(id: 'same');
      final second = await enqueue(id: 'same');
      expect(second.id, first.id);
      expect(await WorkItem.db.count(s), 1);
      expect(await JobQueue.cancel(s, 'same'), isTrue);
      await worker(
        _Handler((_, _) async => fail('Cancelled job executed')),
      ).tick(s);
      expect(
        (await WorkItem.db.findById(s, first.id!))!.state,
        WorkState.cancelled,
      );
    });
    test('expired leases recover after a restart', () async {
      final j = await enqueue();
      await WorkItem.db.updateRow(
        s,
        j.copyWith(
          state: WorkState.running,
          attempts: 1,
          leaseUntil: now.subtract(const Duration(seconds: 1)),
        ),
      );
      await worker(_Handler((_, _) async {})).tick(s);
      final done = (await WorkItem.db.findById(s, j.id!))!;
      expect(done.state, WorkState.done);
      expect(done.attempts, 2);
    });
    test(
      'an expired final attempt fails without exceeding the limit',
      () async {
        final j = await enqueue(maximum: 1);
        await WorkItem.db.updateRow(
          s,
          j.copyWith(
            state: WorkState.running,
            attempts: 1,
            leaseUntil: now.subtract(const Duration(seconds: 1)),
          ),
        );
        await worker(
          _Handler((_, _) async => fail('Exhausted job executed')),
        ).tick(s);
        expect((await WorkItem.db.findById(s, j.id!))!.state, WorkState.failed);
      },
    );
    test('enqueue rolls back together with its business transaction', () async {
      await expectLater(
        s.db.transaction((tx) async {
          await JobQueue.enqueue(
            s,
            kind: 'record',
            payload: WorkPayload(data: {}),
            transaction: tx,
          );
          throw StateError('rollback');
        }),
        throwsStateError,
      );
      expect(await WorkItem.db.count(s), 0);
    });
    test('recurring registration preserves an existing schedule', () async {
      await JobQueue.scheduleRecurring(
        s,
        kind: 'record',
        identifier: 'nightly',
        firstRunAt: now,
      );
      await JobQueue.scheduleRecurring(
        s,
        kind: 'record',
        identifier: 'nightly',
        firstRunAt: now.add(const Duration(days: 1)),
      );
      expect((await WorkItem.db.find(s)).single.runAt, now);
    });
  }, rollbackDatabase: RollbackDatabase.disabled);
  withServerpod('Given concurrent workers', (builder, _) {
    tearDown(() async {
      await WorkItem.db.deleteWhere(
        builder.build(),
        where: (t) => Constant.bool(true),
      );
    });
    test(
      'three blocked jobs start on distinct sessions before any completes',
      () async {
        final s = builder.build();
        final allStarted = Completer<void>(), release = Completer<void>();
        final sessions = <Session>[];
        for (var n = 0; n < 3; n++) {
          await JobQueue.enqueue(
            s,
            kind: 'record',
            payload: WorkPayload(data: {}),
          );
        }
        final worker = JobWorker(
          s.serverpod,
          concurrency: 3,
          renewLeases: false,
          handlers: [
            _Handler((session, _) async {
              sessions.add(session);
              if (sessions.length == 3) allStarted.complete();
              await release.future;
            }),
          ],
        );
        final run = worker.tick(s);
        try {
          await allStarted.future.timeout(const Duration(seconds: 2));
          expect(sessions.toSet(), hasLength(3));
          expect(sessions, isNot(contains(s)));
          expect(
            await WorkItem.db.count(
              s,
              where: (t) => t.state.equals(WorkState.running),
            ),
            3,
          );
        } finally {
          release.complete();
          await run;
        }
        expect(
          await WorkItem.db.count(
            s,
            where: (t) => t.state.equals(WorkState.done),
          ),
          3,
        );
      },
    );
    test(
      'one slot preserves start order and completion precedes the next start',
      () async {
        final s = builder.build();
        final calls = <String>[];
        final now = DateTime.now().toUtc();
        for (var n = 0; n < 3; n++) {
          await JobQueue.enqueue(
            s,
            kind: 'record',
            payload: WorkPayload(data: {'n': '$n'}),
            runAt: now.subtract(Duration(seconds: 3 - n)),
          );
        }
        await JobWorker(
          s.serverpod,
          concurrency: 1,
          renewLeases: false,
          handlers: [
            _Handler((_, job) async {
              calls.add('start${job.payload.data['n']}');
              await Future<void>.delayed(const Duration(milliseconds: 5));
              calls.add('end${job.payload.data['n']}');
            }),
          ],
        ).tick(s);
        expect(calls, ['start0', 'end0', 'start1', 'end1', 'start2', 'end2']);
      },
    );
    test(
      'a throwing sibling retries alone without delaying the others',
      () async {
        final s = builder.build();
        final now = DateTime.now().toUtc();
        for (var n = 0; n < 3; n++) {
          await JobQueue.enqueue(
            s,
            kind: 'record',
            payload: WorkPayload(data: {'n': '$n'}),
            runAt: now,
          );
        }
        await JobWorker(
          s.serverpod,
          concurrency: 3,
          clock: () => now,
          renewLeases: false,
          handlers: [
            _Handler((_, job) async {
              if (job.payload.data['n'] == '1') {
                throw StateError('test failure');
              }
            }),
          ],
        ).tick(s);
        final rows = await WorkItem.db.find(s);
        expect(rows.where((r) => r.state == WorkState.done), hasLength(2));
        final retry = rows.singleWhere((r) => r.state == WorkState.pending);
        expect(retry.payload.data['n'], '1');
        expect(retry.runAt, now.add(const Duration(seconds: 5)));
        expect(retry.attempts, 1);
      },
    );
    test(
      'stop waits for every in-flight job and does not claim another',
      () async {
        final s = builder.build();
        final started = Completer<void>(), release = Completer<void>();
        var calls = 0;
        final worker = JobWorker(
          s.serverpod,
          concurrency: 3,
          renewLeases: false,
          interval: const Duration(hours: 1),
          handlers: [
            _Handler((_, _) async {
              if (++calls == 3) started.complete();
              await release.future;
            }),
          ],
        )..start();
        try {
          for (var n = 0; n < 4; n++) {
            await JobQueue.enqueue(
              s,
              kind: 'record',
              payload: WorkPayload(data: {}),
            );
          }
          await started.future.timeout(const Duration(seconds: 2));
          var stopped = false;
          final stopping = worker.stop().then((_) => stopped = true);
          await Future<void>.delayed(const Duration(milliseconds: 30));
          expect(stopped, false);
          release.complete();
          await stopping;
          expect(calls, 3);
          expect(
            await WorkItem.db.count(
              s,
              where: (t) => t.state.equals(WorkState.pending),
            ),
            1,
          );
        } finally {
          if (!release.isCompleted) release.complete();
          await worker.stop();
          s.serverpod.experimental.shutdownTasks.removeTask('job-worker');
        }
      },
    );
    test(
      'a freed slot starts newly committed work while a sibling remains blocked',
      () async {
        final s = builder.build();
        final entered = Completer<void>(),
            release = Completer<void>(),
            newcomer = Completer<void>();
        final worker = JobWorker(
          s.serverpod,
          concurrency: 3,
          renewLeases: false,
          interval: const Duration(hours: 1),
          handlers: [
            _Handler((_, job) async {
              if (job.payload.data['slow'] == 'true') {
                entered.complete();
                await release.future;
              } else {
                newcomer.complete();
              }
            }),
          ],
        )..start();
        try {
          await JobQueue.enqueue(
            s,
            kind: 'record',
            payload: WorkPayload(data: {'slow': 'true'}),
          );
          await entered.future.timeout(const Duration(seconds: 2));
          await JobQueue.enqueue(
            s,
            kind: 'record',
            payload: WorkPayload(data: {}),
          );
          await newcomer.future.timeout(const Duration(seconds: 2));
          expect(release.isCompleted, false);
        } finally {
          release.complete();
          await worker.stop();
          s.serverpod.experimental.shutdownTasks.removeTask('job-worker');
        }
      },
    );
    test('separate workers claim each of three jobs once', () async {
      final s = builder.build();
      final calls = <UuidValue>[];
      for (var i = 0; i < 3; i++) {
        await JobQueue.enqueue(
          s,
          kind: 'record',
          payload: WorkPayload(data: {}),
        );
      }
      final handler = _Handler((_, job) async {
        calls.add(job.id!);
        await Future<void>.delayed(const Duration(milliseconds: 10));
      });
      final a = JobWorker(s.serverpod, handlers: [handler], renewLeases: false);
      final b = JobWorker(s.serverpod, handlers: [handler], renewLeases: false);
      await Future.wait([a.tick(builder.build()), b.tick(builder.build())]);
      expect(calls, hasLength(3));
      expect(calls.toSet(), hasLength(3));
    });
    test('an old worker cannot overwrite a reclaimed job result', () async {
      final s = builder.build();
      var now = DateTime.now().toUtc();
      final started = Completer<void>(), finish = Completer<void>();
      final j = await JobQueue.enqueue(
        s,
        kind: 'record',
        payload: WorkPayload(data: {}),
        runAt: now,
      );
      final old = JobWorker(
        s.serverpod,
        clock: () => now,
        renewLeases: false,
        handlers: [
          _Handler((_, _) async {
            started.complete();
            await finish.future;
            throw StateError('late failure');
          }),
        ],
      );
      final oldRun = old.tick(builder.build());
      await started.future;
      now = now.add(const Duration(minutes: 3));
      await JobWorker(
        s.serverpod,
        clock: () => now,
        renewLeases: false,
        handlers: [_Handler((_, _) async {})],
      ).tick(builder.build());
      finish.complete();
      await oldRun;
      final row = (await WorkItem.db.findById(s, j.id!))!;
      expect(row.state, WorkState.done);
      expect(row.attempts, 2);
      expect(row.lastError, isNull);
    });
    test('simultaneous enqueue of an identifier creates one row', () async {
      final jobs = await Future.wait([
        for (var i = 0; i < 2; i++)
          JobQueue.enqueue(
            builder.build(),
            kind: 'record',
            payload: WorkPayload(data: {}),
            identifier: 'same',
          ),
      ]);
      expect(jobs[0].id, jobs[1].id);
      expect(await WorkItem.db.count(builder.build()), 1);
    });
    test('lease renewal keeps a slow handler from being reclaimed', () async {
      final s = builder.build();
      final entered = Completer<void>(), finish = Completer<void>();
      final j = await JobQueue.enqueue(
        s,
        kind: 'record',
        payload: WorkPayload(data: {}),
      );
      var calls = 0;
      final first = JobWorker(
        s.serverpod,
        lease: const Duration(milliseconds: 600),
        handlers: [
          _Handler((_, _) async {
            calls++;
            entered.complete();
            await finish.future;
          }),
        ],
      );
      final task = first.tick(builder.build());
      await entered.future;
      try {
        await Future<void>.delayed(const Duration(milliseconds: 1000));
        final leased = (await WorkItem.db.findById(s, j.id!))!;
        expect(leased.leaseUntil!.isAfter(DateTime.now().toUtc()), true);
        await JobWorker(
          s.serverpod,
          handlers: [
            _Handler((_, _) async {
              calls++;
            }),
          ],
        ).tick(builder.build());
        expect(calls, 1);
      } finally {
        finish.complete();
        await task;
      }
    });
    test('heartbeat renews a blocked job while its sibling finishes', () async {
      final s = builder.build();
      final entered = Completer<void>(),
          siblingDone = Completer<void>(),
          release = Completer<void>();
      final slow = await JobQueue.enqueue(
        s,
        kind: 'record',
        payload: WorkPayload(data: {'slow': 'true'}),
      );
      final fast = await JobQueue.enqueue(
        s,
        kind: 'record',
        payload: WorkPayload(data: {}),
      );
      final worker = JobWorker(
        s.serverpod,
        concurrency: 3,
        lease: const Duration(milliseconds: 600),
        handlers: [
          _Handler((_, job) async {
            if (job.id == slow.id) {
              entered.complete();
              await release.future;
            } else {
              siblingDone.complete();
            }
          }),
        ],
      );
      final task = worker.tick(s);
      try {
        await Future.wait([
          entered.future,
          siblingDone.future,
        ]).timeout(const Duration(seconds: 2));
        await Future<void>.delayed(const Duration(milliseconds: 800));
        expect(
          (await WorkItem.db.findById(s, fast.id!))!.state,
          WorkState.done,
        );
        expect(
          (await WorkItem.db.findById(
            s,
            slow.id!,
          ))!.leaseUntil!.isAfter(DateTime.now().toUtc()),
          true,
        );
        await JobWorker(
          s.serverpod,
          handlers: [
            _Handler((_, _) async => fail('Renewed sibling was reclaimed')),
          ],
        ).tick(s);
      } finally {
        release.complete();
        await task;
      }
    });
  }, rollbackDatabase: RollbackDatabase.disabled);
}
