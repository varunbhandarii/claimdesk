String? itemEntry(Uri uri) {
  final value = uri.queryParameters['item']?.trim().toUpperCase();
  return value != null && RegExp(r'^[A-Z0-9]{6}$').hasMatch(value)
      ? value
      : null;
}
