/// Only references and durations belong in stage logs. Never accept report text,
/// contacts, storage paths, tokens or provider response bodies here.
String intakeTiming({
  required String reference,
  required int prepareMs,
  required int captionMs,
  required int storeMs,
  required int embedMs,
  required int totalMs,
}) {
  if (!RegExp(r'^[A-Z0-9]{6}$').hasMatch(reference)) {
    throw ArgumentError('Invalid intake reference');
  }
  return 'Intake timing item=$reference prepareMs=$prepareMs '
      'captionMs=$captionMs storeMs=$storeMs embedMs=$embedMs totalMs=$totalMs';
}
