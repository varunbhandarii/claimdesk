import 'dart:typed_data';
import 'package:serverpod/serverpod.dart';
import 'package:claimdesk_server/src/generated/protocol.dart';
import 'package:claimdesk_server/src/policy/release_rules.dart';
import 'package:test/test.dart';

FoundItem item({
  String category = 'umbrella',
  ValueBand value = ValueBand.under20,
  bool restricted = false,
}) => FoundItem(
  venueId: UuidValue.fromString('12345678-1234-7123-8123-123456789abc'),
  refCode: 'TEST01',
  loggedByAuthUserId: UuidValue.fromString(
    '12345678-1234-7123-8123-123456789abc',
  ),
  restricted: restricted,
  valueBand: value,
  attributes: ItemAttributes(
    category: category,
    colours: [],
    marks: [],
    description: '',
    personalDataKinds: [],
    keywords: [],
    source: 'staff',
  ),
);
ReleaseInput input() => ReleaseInput(
  claimantName: 'Demo Owner',
  idTypeSeen: 'passport',
  detailsMatched: 2,
  describedBeforeViewing: true,
  thirdParty: false,
);
void main() {
  test(
    'Identity and detail requirements cover categories and value boundaries',
    () {
      for (final category in ReleaseRules.detailedCategories) {
        expect(ReleaseRules.minimumDetails(item(category: category)), 2);
      }
      expect(ReleaseRules.minimumDetails(item(value: ValueBand.from20to99)), 1);
      expect(
        ReleaseRules.minimumDetails(item(value: ValueBand.from100to499)),
        2,
      );
      expect(
        ReleaseRules.validate(
          item(),
          input().copyWith(idTypeSeen: 'none', detailsMatched: 1),
          null,
        ),
        isNull,
      );
      for (final row in [
        item(restricted: true),
        item(category: 'bank_card'),
        item(value: ValueBand.from20to99),
      ]) {
        expect(
          ReleaseRules.validate(
            row,
            input().copyWith(idTypeSeen: 'none'),
            null,
          ),
          isNotNull,
        );
      }
      for (final invalid in [
        input().copyWith(describedBeforeViewing: false),
        input().copyWith(detailsMatched: 0),
        input().copyWith(detailsMatched: 6),
        input().copyWith(idTypeSeen: 'ID number'),
        input().copyWith(claimantName: 'A'),
        input().copyWith(claimantName: 'x' * 121),
        input().copyWith(thirdParty: true),
        input().copyWith(thirdParty: true, thirdPartyAuthorisationNote: 'four'),
        input().copyWith(
          thirdParty: true,
          thirdPartyAuthorisationNote: 'x' * 301,
        ),
      ]) {
        expect(ReleaseRules.validate(item(), invalid, null), isNotNull);
      }
      for (final length in [2, 120]) {
        expect(
          ReleaseRules.validate(
            item(),
            input().copyWith(claimantName: 'x' * length),
            null,
          ),
          isNull,
        );
      }
      for (final length in [5, 300]) {
        expect(
          ReleaseRules.validate(
            item(),
            input().copyWith(
              thirdParty: true,
              thirdPartyAuthorisationNote: 'x' * length,
            ),
            null,
          ),
          isNull,
        );
      }
      expect(ReleaseRules.clean(' \u0000Demo\nOwner\u007f '), 'DemoOwner');
    },
  );
  test(
    'Optional signature requires PNG magic and respects the exact size limit',
    () {
      final png = Uint8List(200 * 1024)
        ..setAll(0, [137, 80, 78, 71, 13, 10, 26, 10]);
      expect(
        ReleaseRules.validate(item(), input(), ByteData.sublistView(png)),
        isNull,
      );
      expect(
        ReleaseRules.validate(
          item(),
          input(),
          ByteData.sublistView(Uint8List.fromList([...png, 0])),
        ),
        isNotNull,
      );
      expect(ReleaseRules.validate(item(), input(), ByteData(7)), isNotNull);
      expect(ReleaseRules.validate(item(), input(), ByteData(8)), isNotNull);
    },
  );
}
