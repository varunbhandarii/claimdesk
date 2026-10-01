class DuplicateRule {
  static Set<String> words(String text) => RegExp(
    r'[a-z0-9]+',
  ).allMatches(text.toLowerCase()).map((m) => m[0]!).toSet();
  static double overlap(String a, String b) {
    final left = words(a), right = words(b);
    if (left.isEmpty || right.isEmpty) return 0;
    return left.intersection(right).length /
        (left.length > right.length ? left.length : right.length);
  }

  static bool matches({
    required String? category,
    required String? previousCategory,
    required String text,
    required String previousText,
    required DateTime previousCreatedAt,
    required DateTime now,
  }) =>
      !previousCreatedAt.isBefore(now.subtract(const Duration(hours: 24))) &&
      (category != null && category == previousCategory ||
          overlap(text, previousText) >= .7);
}
