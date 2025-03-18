import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recargas_app/database/database_helper.dart';
import 'package:recargas_app/models/recharge_model.dart';

final historyProvider = FutureProvider<List<Recharge>>((ref) async {
  return DatabaseHelper.instance.getAllRecharges();
});

final historyActionsProvider = Provider((ref) => HistoryActions(ref));

class HistoryActions {
  final Ref ref;

  HistoryActions(this.ref);

  Future<void> editRecharge(Recharge recharge) async {
    await DatabaseHelper.instance.updateRecharge(recharge);
    ref.invalidate(historyProvider);
  }

  Future<void> deleteRecharge(int id) async {
    await DatabaseHelper.instance.deleteRecharge(id);
    ref.invalidate(historyProvider);
  }
}
