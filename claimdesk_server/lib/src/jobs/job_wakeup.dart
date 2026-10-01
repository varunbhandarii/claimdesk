import 'package:serverpod/serverpod.dart';

/// Best-effort, process-local notification after an enqueue transaction commits.
/// The durable queue and periodic worker remain the recovery mechanism.
class JobWakeup {
  static final _callbacks = Expando<void Function()>();
  static void register(Serverpod pod, void Function() callback) =>
      _callbacks[pod] = callback;
  static void unregister(Serverpod pod, void Function() callback) {
    if (_callbacks[pod] == callback) _callbacks[pod] = null;
  }

  static void notify(Session session) => _callbacks[session.serverpod]?.call();
}
