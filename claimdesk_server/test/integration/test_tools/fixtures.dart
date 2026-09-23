import 'dart:math';

import 'package:claimdesk_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';
import 'package:serverpod_auth_idp_server/providers/email.dart';

void configureTestAuth() {
  AuthServices.set(
    tokenManagerBuilders: [
      JwtConfig(
        algorithm: JwtAlgorithm.hmacSha512(
          SecretKey('test-only-signing-key-32-characters'),
        ),
        refreshTokenHashPepper: 'test-only-refresh-pepper',
      ),
    ],
    identityProviderBuilders: [
      EmailIdpConfig(secretHashPepper: 'test-only-email-pepper'),
    ],
  );
}

final actorId = UuidValue.fromString('12345678-1234-7123-8123-123456789abc');

Future<Venue> makeVenue(Session s, {String slug = 'test-desk'}) =>
    Venue.db.insertRow(s, Venue(name: 'Test desk', slug: slug));

Future<FoundItem> makeItem(
  Session s,
  UuidValue venueId, {
  String refCode = 'ITEM01',
  UuidValue? zoneId,
  Vector? embedding,
}) => FoundItem.db.insertRow(
  s,
  FoundItem(
    venueId: venueId,
    refCode: refCode,
    zoneId: zoneId,
    embedding: embedding,
    loggedByAuthUserId: actorId,
  ),
);

Future<LostReport> makeReport(
  Session s,
  UuidValue venueId, {
  String refCode = 'REPORT01',
  String publicToken = 'opaque-test-token',
  UuidValue? zoneId,
}) => LostReport.db.insertRow(
  s,
  LostReport(
    venueId: venueId,
    refCode: refCode,
    publicToken: publicToken,
    rawText: 'A black umbrella',
    colourHints: ['black'],
    zoneId: zoneId,
  ),
);

MatchExplanation explanation() => MatchExplanation(
  cosSim: .9,
  keywordCoverage: .8,
  matchedKeywords: ['umbrella', 'black'],
  category: 1,
  colour: 1,
  brand: .5,
  zone: .7,
  time: .8,
  weightsHash: 'test-weights',
  guardrailApplied: true,
);

Future<ItemMatch> makeMatch(Session s, FoundItem item, LostReport report) =>
    ItemMatch.db.insertRow(
      s,
      ItemMatch(
        venueId: item.venueId,
        itemId: item.id!,
        reportId: report.id!,
        score: .91,
        label: 'strong',
        rank: 1,
        explanation: explanation(),
        algorithmVersion: 'test-v1',
      ),
    );

Vector unitVector(double first, double second) {
  final norm = sqrt(first * first + second * second);
  return Vector(
    List<double>.generate(
      1536,
      (i) => i == 0
          ? first / norm
          : i == 1
          ? second / norm
          : 0,
    ),
  );
}
