import 'package:claimdesk_client/claimdesk_client.dart';

class ReleaseRules {
  static const labels = {
    'drivers_licence': "Driver's licence",
    'passport': 'Passport',
    'student_id': 'Student ID',
    'other_government_id': 'Other government ID',
    'none': 'None',
  };
  static const detailed = {
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
  static const restricted = {
    'wallet_or_purse',
    'bank_card',
    'cash',
    'id_card_or_pass',
    'medical_device_or_medication',
    'jewellery',
  };
  static int minimum(FoundItem item) =>
      detailed.contains(item.attributes?.category) ||
          item.valueBand.index >= ValueBand.from100to499.index
      ? 2
      : 1;
  static bool allowsNoId(FoundItem item) =>
      item.valueBand == ValueBand.under20 &&
      !item.restricted &&
      !restricted.contains(item.attributes?.category);
  static String clean(String value) =>
      value.replaceAll(RegExp(r'[\x00-\x1f\x7f]'), '').trim();
  static bool valid(FoundItem item, ReleaseInput input) =>
      input.describedBeforeViewing &&
      input.detailsMatched >= minimum(item) &&
      input.detailsMatched <= 5 &&
      labels.containsKey(input.idTypeSeen) &&
      (input.idTypeSeen != 'none' || allowsNoId(item)) &&
      clean(input.claimantName).length >= 2 &&
      clean(input.claimantName).length <= 120 &&
      (!input.thirdParty ||
          (clean(input.thirdPartyAuthorisationNote ?? '').length >= 5 &&
              clean(input.thirdPartyAuthorisationNote ?? '').length <= 300));
}
