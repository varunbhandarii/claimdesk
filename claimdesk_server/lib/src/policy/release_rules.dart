import 'dart:typed_data';
import '../generated/protocol.dart';
import 'taxonomy.dart';

class ReleaseRules {
  static const idTypes = {
    'drivers_licence',
    'passport',
    'student_id',
    'other_government_id',
    'none',
  };
  static const detailedCategories = {
    'phone',
    'tablet_or_laptop',
    'smartwatch_or_watch',
    'camera',
    'wallet_or_purse',
    'bank_card',
    'cash',
    'id_card_or_pass',
    'keys',
    'jewellery',
  };
  static String clean(String value) =>
      value.replaceAll(RegExp(r'[\x00-\x1f\x7f]'), '').trim();
  static int minimumDetails(FoundItem item) =>
      detailedCategories.contains(item.attributes?.category) ||
          item.valueBand.index >= ValueBand.from100to499.index
      ? 2
      : 1;
  static bool allowsNoId(FoundItem item) =>
      item.valueBand == ValueBand.under20 &&
      !item.restricted &&
      !Taxonomy.isRestricted(item.attributes?.category ?? 'other');
  static String? validate(
    FoundItem item,
    ReleaseInput input,
    ByteData? signature,
  ) {
    if (!input.describedBeforeViewing) {
      return 'The claimant must describe the item before viewing it.';
    }
    if (input.detailsMatched < minimumDetails(item) ||
        input.detailsMatched > 5) {
      return 'Match ${minimumDetails(item)} to 5 identifying details.';
    }
    if (!idTypes.contains(input.idTypeSeen) ||
        (input.idTypeSeen == 'none' && !allowsNoId(item))) {
      return 'Select an accepted photo ID type.';
    }
    if (clean(input.claimantName).length < 2 ||
        clean(input.claimantName).length > 120) {
      return 'Use 2 to 120 characters for the claimant name.';
    }
    final note = clean(input.thirdPartyAuthorisationNote ?? '');
    if (input.thirdParty && (note.length < 5 || note.length > 300)) {
      return 'Describe third-party authorisation in 5 to 300 characters.';
    }
    if (signature != null) {
      const magic = [137, 80, 78, 71, 13, 10, 26, 10];
      if (signature.lengthInBytes < 8 ||
          signature.lengthInBytes > 200 * 1024 ||
          !List.generate(
            8,
            signature.getUint8,
          ).asMap().entries.every((e) => e.value == magic[e.key])) {
        return 'Use a PNG signature no larger than 200 KiB.';
      }
    }
    return null;
  }
}
