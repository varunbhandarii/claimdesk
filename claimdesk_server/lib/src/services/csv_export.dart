import 'dart:convert';
import 'dart:typed_data';

class CsvWriter {
  static String field(Object? value) {
    var text = value is DateTime
        ? value.toUtc().toIso8601String()
        : value?.toString() ?? '';
    // Keep user-entered strings as text when opened by spreadsheet software.
    if (value is String && RegExp(r'^\s*[=+@-]').hasMatch(text)) {
      text = "'$text";
    }
    return RegExp('[,"\r\n]').hasMatch(text)
        ? '"${text.replaceAll('"', '""')}"'
        : text;
  }

  static ByteData bytes(
    List<String> header,
    Iterable<List<Object?>> rows,
  ) => ByteData.sublistView(
    Uint8List.fromList(
      utf8.encode(
        '\ufeff${[header, ...rows].map((r) => r.map(field).join(',')).join('\r\n')}\r\n',
      ),
    ),
  );
}
