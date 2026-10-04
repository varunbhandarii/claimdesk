import '../generated/protocol.dart';

class Custody {
  static const locations = {'desk', 'safe', 'police', 'issuer'};
  static const terminal = {'police', 'issuer'};
  static const disposalActions = {'donate', 'recycle', 'destroy', 'discard'};
  static String current(Iterable<CustodyEvent> events) {
    final rows = events.toList()
      ..sort((a, b) {
        final order = b.at.compareTo(a.at);
        return order != 0
            ? order
            : (b.id?.toString() ?? '').compareTo(a.id?.toString() ?? '');
      });
    return rows.isEmpty ? 'desk' : rows.first.toLocation;
  }

  static String? clean(String? value, int max) {
    if (value == null) return null;
    final text = value.replaceAll(RegExp(r'[\x00-\x1f\x7f]'), ' ').trim();
    if (text.length > max) throw ArgumentError('Field too long');
    return text.isEmpty ? null : text;
  }
}
