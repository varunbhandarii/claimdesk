import 'dart:collection';
import 'dart:io';
import 'package:serverpod/serverpod.dart';
import '../../services/public_codes.dart';
import '../public/public_lang.dart';
import '../public/public_page.dart';
import '../public/public_strings.dart';

String clientAddress(Request request, {required bool trustProxy}) {
  final forwarded = request.headers['x-forwarded-for']?.firstOrNull
      ?.split(',')
      .first
      .trim();
  if (trustProxy &&
      forwarded != null &&
      InternetAddress.tryParse(forwarded) != null) {
    return forwarded;
  }
  return request.connectionInfo.remote.address.toString();
}

String clientAddressSource(Request request, {required bool trustProxy}) {
  final first = request.headers['x-forwarded-for']?.firstOrNull
      ?.split(',')
      .first
      .trim();
  return trustProxy && first != null && InternetAddress.tryParse(first) != null
      ? 'X-Forwarded-For'
      : 'socket';
}

class SlidingWindow {
  SlidingWindow({required this.limit, required this.window});
  final int limit;
  final Duration window;
  final _visits = <String, Queue<DateTime>>{};
  DateTime? _lastSweep;
  int? retryAfter(String key, DateTime now) {
    final cutoff = now.subtract(window);
    if (_lastSweep == null ||
        now.difference(_lastSweep!) >= const Duration(minutes: 1)) {
      _visits.removeWhere(
        (_, times) => times.isEmpty || !times.last.isAfter(cutoff),
      );
      _lastSweep = now;
    }
    final times = _visits.putIfAbsent(key, Queue.new);
    while (times.isNotEmpty && !times.first.isAfter(cutoff)) {
      times.removeFirst();
    }
    if (times.length >= limit) {
      return (times.first.add(window).difference(now).inMilliseconds / 1000)
          .ceil()
          .clamp(1, window.inSeconds);
    }
    times.add(now);
    return null;
  }
}

Middleware rateLimit({
  required int limit,
  required Duration window,
  Set<Method>? methods,
  required bool trustProxy,
  required String salt,
  DateTime Function()? now,
}) {
  final limiter = SlidingWindow(limit: limit, window: window);
  return (Handler next) => (Request request) async {
    if (methods != null && !methods.contains(request.method)) {
      return next(request);
    }
    final key = PublicCodes.ipHash(
      salt,
      clientAddress(request, trustProxy: trustProxy),
    );
    final retry = limiter.retryAfter(key, (now ?? DateTime.now)());
    if (retry == null) return next(request);
    final locale = PublicLocale.of(request);
    final response = await PublicPage.html(
      'rate_limited',
      {
        'retryAfter': retry,
        'rateBody': PublicStrings.fill(
          PublicStrings.of(locale.lang)['rateBody']!,
          {'seconds': retry},
        ),
      },
      status: 429,
      noStore: true,
      locale: locale,
    );
    return response.copyWith(
      headers: response.headers.transform((h) => h['Retry-After'] = ['$retry']),
    );
  };
}
