import 'dart:async';
import 'package:claimdesk_client/claimdesk_client.dart';
import 'package:flutter/foundation.dart';

/// One subscription per desk, with cancellable reconnects and catch-up refresh.
class VenueEvents extends ChangeNotifier {
  VenueEvents({
    required this.openStream,
    required this.onReconnect,
    this.onDenied,
  });
  final Stream<DeskEvent> Function() openStream;
  final VoidCallback onReconnect;
  final void Function(Object)? onDenied;
  final _events = StreamController<DeskEvent>.broadcast();
  Stream<DeskEvent> get events => _events.stream;
  StreamSubscription<DeskEvent>? _subscription;
  Timer? _retry;
  Timer? _stall;
  bool _disposed = false;
  bool _paused = false;

  /// True once a dropped stream has stayed down for [stallAfter]; short drops
  /// that recover on their own never reach the screen.
  bool reconnecting = false;
  static const stallAfter = Duration(seconds: 5);
  int _failures = 0;
  static const delays = [2, 4, 8, 15, 30];
  int get nextDelay => delays[_failures.clamp(0, 4)];
  int _generation = 0;

  void start() {
    if (_disposed || _paused || _subscription != null) return;
    _retry?.cancel();
    final generation = ++_generation;
    try {
      _subscription = openStream().listen(
        (event) {
          if (_disposed || generation != _generation) return;
          _failures = 0;
          _recovered();
          _events.add(event);
        },
        onError: (Object error) {
          if (generation != _generation || _disposed) return;
          if (error is NotAMemberException) {
            _subscription?.cancel();
            _subscription = null;
            ++_generation;
            onDenied?.call(error);
          } else {
            _scheduleReconnect();
          }
        },
        onDone: () {
          if (generation == _generation && !_disposed) _scheduleReconnect();
        },
      );
      onReconnect();
    } catch (_) {
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    if (_disposed || _paused || _retry?.isActive == true) return;
    ++_generation;
    _subscription?.cancel();
    _subscription = null;
    _stall ??= Timer(stallAfter, () {
      if (_disposed) return;
      reconnecting = true;
      notifyListeners();
    });
    final seconds = nextDelay;
    _failures++;
    _retry = Timer(Duration(seconds: seconds), start);
  }

  void _recovered() {
    _stall?.cancel();
    _stall = null;
    if (reconnecting) {
      reconnecting = false;
      notifyListeners();
    }
  }

  void connectivityChanged(bool connected) {
    if (_disposed) return;
    if (!connected) {
      _scheduleReconnect();
    } else {
      _retry?.cancel();
      _failures = 0;
      ++_generation;
      _subscription?.cancel();
      _subscription = null;
      start();
    }
  }

  /// The app went to the background: close the stream on purpose instead of
  /// letting the system break it and counting that as a failure.
  void pause() {
    if (_disposed) return;
    _paused = true;
    ++_generation;
    _retry?.cancel();
    _subscription?.cancel();
    _subscription = null;
  }

  /// Back in the foreground: open a fresh stream at once (no backoff) and let
  /// [onReconnect] catch up on anything that changed meanwhile.
  void resume() {
    if (_disposed) return;
    _paused = false;
    _retry?.cancel();
    _failures = 0;
    ++_generation;
    _subscription?.cancel();
    _subscription = null;
    _recovered();
    start();
  }

  void serverAvailable() {
    if (_disposed) return;
    _recovered();
  }

  @override
  void dispose() {
    _disposed = true;
    ++_generation;
    _retry?.cancel();
    _stall?.cancel();
    _subscription?.cancel();
    _events.close();
    super.dispose();
  }
}
