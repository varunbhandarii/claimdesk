import 'package:claimdesk_server/src/ai/fakes.dart';
import 'package:claimdesk_server/src/generated/protocol.dart';
import 'package:claimdesk_server/src/matching/english_lexemes.dart';
import 'package:claimdesk_server/src/matching/in_memory_candidates.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

void main() {
  test('English reference stems words and drops the PostgreSQL stop list', () {
    expect(EnglishLexemes.of('the wooden handles and curved umbrellas'), {
      'wooden',
      'handl',
      'curv',
      'umbrella',
    });
  });
  test(
    'reference deduplicates lexical and vector legs and preserves lexical-only candidates',
    () async {
      final id = UuidValue.fromString('12345678-1234-7123-8123-123456789abc');
      final at = DateTime.utc(2026, 9, 30);
      final e = FakeEmbedder();
      final report = LostReport(
        venueId: id,
        refCode: 'REPORT',
        publicToken: '',
        rawText: 'black umbrella wooden handle',
        colourHints: [],
        lostAt: at,
        embedding: Vector(await e.embedQuery('black umbrella wooden handle')),
      );
      FoundItem item(String ref, {Vector? embedding}) => FoundItem(
        id: UuidValue.fromString(ref),
        venueId: id,
        status: ItemStatus.unclaimed,
        refCode: ref.substring(0, 6),
        loggedByAuthUserId: id,
        captionText: 'black umbrella wooden handles',
        foundAt: at,
        embedding: embedding,
      );
      final both = item(
        '12345678-1234-7123-8123-123456789abd',
        embedding: Vector(
          await e.embedDocument('black umbrella wooden handles'),
        ),
      );
      final lex = item('12345678-1234-7123-8123-123456789abe');
      final result = InMemoryCandidates(
        now: () => at,
      ).forReport(report, [both, lex], []);
      expect(result.map((c) => c.item.id).toSet(), {both.id, lex.id});
      expect(result.first.keywordCoverage, 1);
      expect(result.last.cosSim, isNull);
    },
  );
}
