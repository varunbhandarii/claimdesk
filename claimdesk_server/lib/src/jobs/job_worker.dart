import 'dart:async';
import 'dart:io';
import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';
import 'job_handler.dart';
import 'job_queue.dart';
import 'job_wakeup.dart';

class JobWorker {
  JobWorker(
    this.pod, {
    required List<JobHandler> handlers,
    this.interval = const Duration(seconds: 3),
    this.lease = const Duration(minutes: 2),
    DateTime Function()? clock,
    this.renewLeases = true,
  }) : handlers = {for (final h in handlers) h.kind: h},
       clock = clock ?? (() => DateTime.now().toUtc());
  final Serverpod pod;
  final Map<String, JobHandler> handlers;
  final Duration interval, lease;
  final DateTime Function() clock;
  final bool renewLeases;
  Timer? _timer;
  Future<void>? _active;
  bool _stopping = false;
  bool _wakeRequested = false;

  void start() {
    if (_timer != null) return;
    _stopping = false;
    stdout.writeln(
      'Job worker started: ${interval.inSeconds}s interval, ${lease.inSeconds}s renewable lease',
    );
    JobWakeup.register(pod, wake);
    _timer = Timer.periodic(interval, (_) {
      if (_active == null) wake();
    });
    pod.experimental.shutdownTasks.addTask('job-worker', stop);
  }

  /// Signals work without delaying the caller or overlapping worker ticks.
  void wake() {
    if (_timer == null || _stopping) return;
    _wakeRequested = true;
    if (_active != null) return;
    _active =
        Future<void>.microtask(() async {
          do {
            _wakeRequested = false;
            try {
              await pod.withSession((s) => tick(s));
            } catch (_) {
              stderr.writeln(
                'Job worker tick failed; pending work will be retried',
              );
            }
          } while (_wakeRequested && !_stopping);
        }).whenComplete(() {
          _active = null;
          // A notification can arrive between the final loop check and completion.
          if (_wakeRequested && !_stopping) wake();
        });
  }

  Future<void> stop() async {
    _stopping = true;
    _wakeRequested = false;
    JobWakeup.unregister(pod, wake);
    _timer?.cancel();
    _timer = null;
    await _active;
  }

  Future<WorkItem?> claim(Session session) =>
      session.db.transaction((tx) async {
        final now = clock();
        final job = await WorkItem.db.findFirstRow(
          session,
          where: (t) =>
              (t.state.equals(WorkState.pending) & (t.runAt <= now)) |
              (t.state.equals(WorkState.running) & (t.leaseUntil < now)),
          orderBy: (t) => t.runAt,
          lockMode: LockMode.forUpdate,
          lockBehavior: LockBehavior.skipLocked,
          transaction: tx,
        );
        if (job == null) return null;
        if (job.attempts >= job.maxAttempts) {
          await WorkItem.db.updateRow(
            session,
            job.copyWith(
              state: WorkState.failed,
              leaseUntil: null,
              lastError: 'Job attempt limit reached after expired lease',
              updatedAt: now,
            ),
            transaction: tx,
          );
          return job.copyWith(state: WorkState.failed);
        }
        return WorkItem.db.updateRow(
          session,
          job.copyWith(
            state: WorkState.running,
            leaseUntil: now.add(lease),
            attempts: job.attempts + 1,
            updatedAt: now,
          ),
          transaction: tx,
        );
      });
  Future<void> tick(Session session) async {
    for (var count = 0; count < 10 && !_stopping; count++) {
      final job = await claim(session);
      if (job == null) return;
      final handler = handlers[job.kind];
      if (job.state == WorkState.failed) {
        await handler?.failed(session, job);
        continue;
      }
      Timer? heartbeat;
      Future<void>? heartbeatInFlight;
      if (renewLeases) {
        heartbeat = Timer.periodic(
          Duration(milliseconds: lease.inMilliseconds ~/ 3),
          (_) {
            if (heartbeatInFlight != null) return;
            heartbeatInFlight = pod
                .withSession((s) async {
                  await WorkItem.db.updateWhere(
                    s,
                    columnValues: (t) => [t.leaseUntil(clock().add(lease))],
                    where: (t) => JobClaim.matches(t, job),
                  );
                })
                .catchError((Object _) {})
                .whenComplete(() => heartbeatInFlight = null);
          },
        );
      }
      try {
        if (handler == null) throw StateError('Unregistered job kind');
        await handler.run(session, job);
        await WorkItem.db.updateWhere(
          session,
          columnValues: (t) => [
            t.state(WorkState.done),
            t.completedAt(clock()),
            t.leaseUntil(null),
            t.lastError(null),
          ],
          where: (t) => JobClaim.matches(t, job),
        );
        session.log('Job ${job.kind} completed (attempt ${job.attempts})');
      } catch (_) {
        final exhausted = job.attempts >= job.maxAttempts;
        final changed = await WorkItem.db.updateWhere(
          session,
          columnValues: (t) => [
            t.state(exhausted ? WorkState.failed : WorkState.pending),
            t.leaseUntil(null),
            t.runAt(clock().add(JobQueue.backoff(job.attempts))),
            t.lastError('Job handler failed'),
          ],
          where: (t) => JobClaim.matches(t, job),
        );
        if (exhausted && changed.isNotEmpty) {
          await handler?.failed(session, job);
        }
        session.log(
          'Job ${job.kind} ${exhausted ? 'failed' : 'scheduled for retry'} (attempt ${job.attempts})',
        );
      } finally {
        heartbeat?.cancel();
        await heartbeatInFlight;
      }
    }
  }
}
