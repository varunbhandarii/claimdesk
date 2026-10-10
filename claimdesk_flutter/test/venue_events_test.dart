import 'dart:async';
import 'package:claimdesk_client/claimdesk_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:claimdesk_flutter/live/venue_events.dart';
import 'fixtures.dart';

void main() {
  testWidgets(
    'reconnects at bounded delays, resets on delivery and cancels on disposal',
    (tester) async {
      final streams = <StreamController<DeskEvent>>[];
      var catches = 0;
      final live = VenueEvents(
        openStream: () {
          final stream = StreamController<DeskEvent>();
          streams.add(stream);
          return stream.stream;
        },
        onReconnect: () => catches++,
      );
      live.start();
      for (final seconds in [2, 4, 8, 15, 30, 30]) {
        streams.last.addError(Exception('Disconnected'));
        await tester.pump();
        final count = streams.length;
        await tester.pump(Duration(seconds: seconds - 1));
        expect(streams.length, count);
        await tester.pump(const Duration(seconds: 1));
        expect(streams.length, count + 1);
      }
      streams.last.add(
        DeskEvent(kind: 'itemStatus', venueId: venueId, at: DateTime.now()),
      );
      await tester.pump();
      expect(live.nextDelay, 2);
      expect(live.reconnecting, false);
      streams.last.addError(Exception('Disconnected'));
      await tester.pump();
      final count = streams.length;
      live.dispose();
      await tester.pump(const Duration(seconds: 60));
      expect(streams.length, count);
      expect(catches, count);
      for (final stream in streams) {
        unawaited(stream.close());
      }
      await tester.pump();
    },
  );
  testWidgets('a short drop never shows; a stalled one does after 5 s', (
    tester,
  ) async {
    final streams = <StreamController<DeskEvent>>[];
    final live = VenueEvents(
      openStream: () {
        final stream = StreamController<DeskEvent>();
        streams.add(stream);
        return stream.stream;
      },
      onReconnect: () {},
    );
    live.start();
    streams.last.addError(Exception('Disconnected'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    expect(streams.length, 2);
    live.serverAvailable();
    await tester.pump(const Duration(seconds: 2));
    expect(live.reconnecting, false);

    streams.last.addError(Exception('Disconnected'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 4900));
    expect(live.reconnecting, false);
    await tester.pump(const Duration(milliseconds: 100));
    expect(live.reconnecting, true);
    live.dispose();
    for (final stream in streams) {
      unawaited(stream.close());
    }
    await tester.pump();
  });

  testWidgets(
    'pausing closes the stream quietly; resuming reopens it at once and catches up',
    (tester) async {
      final streams = <StreamController<DeskEvent>>[];
      var catches = 0;
      final live = VenueEvents(
        openStream: () {
          final stream = StreamController<DeskEvent>();
          streams.add(stream);
          return stream.stream;
        },
        onReconnect: () => catches++,
      );
      live.start();
      expect(catches, 1);
      live.pause();
      // The system breaking the old stream while paused is not a failure.
      streams.last.addError(Exception('Software caused connection abort'));
      await tester.pump(const Duration(seconds: 60));
      expect(streams.length, 1);
      expect(live.reconnecting, false);
      live.resume();
      expect(streams.length, 2);
      expect(catches, 2);
      expect(live.reconnecting, false);
      expect(live.nextDelay, 2);
      live.dispose();
      for (final stream in streams) {
        unawaited(stream.close());
      }
      await tester.pump();
    },
  );

  testWidgets(
    'membership denial stops reconnects and returns to venue selection',
    (tester) async {
      var attempts = 0;
      var denied = false;
      final live = VenueEvents(
        openStream: () {
          attempts++;
          return Stream.error(
            NotAMemberException(message: 'No access', venueId: venueId),
          );
        },
        onReconnect: () {},
        onDenied: (_) => denied = true,
      );
      live.start();
      await tester.pump();
      await tester.pump(const Duration(seconds: 60));
      expect(denied, true);
      expect(attempts, 1);
      live.dispose();
    },
  );
}
