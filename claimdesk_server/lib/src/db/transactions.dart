import 'package:serverpod/serverpod.dart';

Future<T> serializable<T>(
  Session session,
  Future<T> Function(Transaction) action,
) async {
  for (var attempt = 0; ; attempt++) {
    try {
      return await session.db.transaction(
        action,
        settings: const TransactionSettings(
          isolationLevel: IsolationLevel.serializable,
        ),
      );
    } on DatabaseQueryException catch (error) {
      if (attempt >= 4 || !{'40001', '40P01'}.contains(error.code)) rethrow;
      await Future<void>.delayed(Duration(milliseconds: 20 * (attempt + 1)));
    }
  }
}
