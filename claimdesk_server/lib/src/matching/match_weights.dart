import 'dart:convert';
import 'package:crypto/crypto.dart';

class MatchWeights {
  const MatchWeights({
    this.sem = .40,
    this.lex = .15,
    this.category = .15,
    this.colour = .10,
    this.brand = .08,
    this.zone = .06,
    this.time = .06,
    this.semanticLow = .85,
    this.semanticHigh = .99,
  });
  final double sem, lex, category, colour, brand, zone, time;
  final double semanticLow, semanticHigh;
  List<double> get values => [sem, lex, category, colour, brand, zone, time];
  String get hash => sha256
      .convert(
        utf8.encode(
          jsonEncode([
            ...values,
            semanticLow,
            semanticHigh,
            .45,
            .70,
            .40,
            .15,
            3,
            5,
          ]),
        ),
      )
      .toString()
      .substring(0, 8);
}
