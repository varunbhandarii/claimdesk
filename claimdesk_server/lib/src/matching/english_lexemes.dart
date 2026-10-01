import 'package:porter_2_stemmer/porter_2_stemmer.dart';

class EnglishLexemes {
  static final stemmer = Porter2Stemmer();
  static final stopWords =
      '''i me my myself we our ours ourselves you your yours yourself yourselves
he him his himself she her hers herself it its itself they them their theirs themselves what which who whom
this that these those am is are was were be been being have has had having do does did doing a an the
and but if or because as until while of at by for with about against between into through during before
after above below to from up down in out on off over under again further then once here there when where
why how all any both each few more most other some such no nor not only own same so than too very s t can
will just don should now'''
          .split(RegExp(r'\s+'))
          .toSet();
  static String stem(String word) => stemmer.stem(word.toLowerCase());
  static List<String> tokens(String text) {
    final result = <String>[];
    for (final m in RegExp(
      r"[a-z0-9À-ÿ]+(?:[-'][a-z0-9À-ÿ]+)*",
    ).allMatches(text.toLowerCase())) {
      final word = m.group(0)!;
      if (!stopWords.contains(word)) result.add(stem(word));
      if (word.contains('-')) {
        result.addAll(
          word.split('-').where((w) => !stopWords.contains(w)).map(stem),
        );
      }
    }
    return result;
  }

  static Set<String> of(String text) => tokens(text).toSet();
}
