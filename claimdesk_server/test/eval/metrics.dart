import 'package:claimdesk_server/src/matching/scorer.dart';

typedef EvalRanking = ({
  String reportKey,
  String? expectedItem,
  List<({String itemKey, ScoredCandidate result})> rows,
});
typedef EvalMetrics = ({
  double recall1,
  double recall3,
  double mrr,
  double strongFpr,
  double strongPrecision,
});

EvalMetrics metrics(List<EvalRanking> rankings) {
  var truths = 0, first = 0, third = 0, absent = 0, falseStrong = 0;
  var strong = 0, trueStrong = 0;
  var reciprocal = 0.0;
  for (final ranking in rankings) {
    if (ranking.expectedItem != null) {
      truths++;
      final position = ranking.rows.indexWhere(
        (r) => r.itemKey == ranking.expectedItem,
      );
      if (position == 0) first++;
      if (position >= 0 && position < 3) third++;
      if (position >= 0) reciprocal += 1 / (position + 1);
    } else {
      absent++;
      if (ranking.rows.any((r) => r.result.label == 'strong')) falseStrong++;
    }
    for (final row in ranking.rows.where((r) => r.result.label == 'strong')) {
      strong++;
      if (row.itemKey == ranking.expectedItem) trueStrong++;
    }
  }
  return (
    recall1: truths == 0 ? 0 : first / truths,
    recall3: truths == 0 ? 0 : third / truths,
    mrr: truths == 0 ? 0 : reciprocal / truths,
    strongFpr: absent == 0 ? 0 : falseStrong / absent,
    strongPrecision: strong == 0 ? 0 : trueStrong / strong,
  );
}

String metricsTable(EvalMetrics m) =>
    'Metric | Value\n'
    'Recall@1 | ${m.recall1.toStringAsFixed(3)}\nRecall@3 | ${m.recall3.toStringAsFixed(3)}\n'
    'MRR | ${m.mrr.toStringAsFixed(3)}\nStrong FPR | ${m.strongFpr.toStringAsFixed(3)}\n'
    'Strong precision | ${m.strongPrecision.toStringAsFixed(3)}';
