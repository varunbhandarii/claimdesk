import 'dart:async';
import 'package:claimdesk_client/claimdesk_client.dart';
import 'package:claimdesk_flutter/app/venue_session.dart';
import 'package:flutter_test/flutter_test.dart';
import 'fixtures.dart';
import 'match_fixtures.dart';

class DeskTestClient extends Client {
  DeskTestClient() : super('http://localhost:8080/');
  final events = StreamController<DeskEvent>.broadcast();
  final calls = <String, int>{};
  List<MatchCard> cards = [];
  @override
  Future<T> callServerEndpoint<T>(
    String endpoint,
    String method,
    Map<String, dynamic> args, {
    bool authenticated = true,
  }) async {
    calls.update(endpoint, (n) => n + 1, ifAbsent: () => 1);
    final Object result = switch (endpoint) {
      'item' => <FoundItem>[],
      'report' => <LostReport>[],
      'venue' => <Zone>[],
      'match' => cards,
      _ => throw StateError('Unexpected endpoint $endpoint'),
    };
    return result as T;
  }

  @override
  dynamic callStreamingServerEndpoint<T, G>(
    String endpoint,
    String method,
    Map<String, dynamic> args,
    Map<String, Stream> streams, {
    bool authenticated = true,
  }) => events.stream;
}

void main() {
  testWidgets('matching events refresh all three lists once after one second', (
    tester,
  ) async {
    final client = DeskTestClient();
    final session = VenueSession(
      client: client,
      venue: Venue(id: venueId, name: 'Desk', slug: 'desk'),
      membership: StaffMembership(
        venueId: venueId,
        authUserId: venueId,
        displayName: 'Staff',
      ),
      onDenied: () {},
    );
    final start = session.start();
    await tester.pump();
    await start;
    final initial = Map<String, int>.of(client.calls);
    client.cards = [matchCard()];
    client.events.add(
      DeskEvent(
        kind: 'matchCreated',
        venueId: venueId,
        matchId: itemId,
        at: DateTime.now(),
      ),
    );
    client.events.add(
      DeskEvent(
        kind: 'matchStatus',
        venueId: venueId,
        matchId: itemId,
        at: DateTime.now(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 999));
    expect(session.inbox, isEmpty);
    await tester.pump(const Duration(milliseconds: 1));
    await tester.pump();
    expect(session.inbox.single.match.id, itemId);
    for (final endpoint in ['item', 'report', 'match']) {
      expect(client.calls[endpoint], initial[endpoint]! + 1);
    }
    client.cards = [];
    client.events.add(
      DeskEvent(
        kind: 'matchStatus',
        venueId: venueId,
        matchId: itemId,
        at: DateTime.now(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();
    expect(session.inbox, isEmpty);
    session.dispose();
    await client.events.close();
    client.close();
  });
}
