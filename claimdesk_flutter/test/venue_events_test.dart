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
