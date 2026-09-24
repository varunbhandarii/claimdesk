import 'package:claimdesk_server/src/ai/fakes.dart';
import 'package:test/test.dart';

void main() {
  test(
    'token embedding is deterministic, normalized and favors shared meanings',
    () async {
      final e = FakeEmbedder();
      final q = await e.embedQuery('black umbrella wooden handle');
      final same = await e.embedDocument('black brolly wooden handle');
      final other = await e.embedDocument('red backpack zipper straps');
      double dot(List<double> a, List<double> b) =>
          List.generate(a.length, (i) => a[i] * b[i]).fold(0, (s, v) => s + v);
      expect(q, await e.embedQuery('black umbrella wooden handle'));
      expect(dot(q, q), closeTo(1, 1e-10));
      expect(dot(q, same), greaterThan(dot(q, other)));
      expect(await e.embedDocument(''), hasLength(1536));
    },
  );
}
