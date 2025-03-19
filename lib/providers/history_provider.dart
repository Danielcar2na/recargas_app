import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recargas_app/database/database_helper.dart';
import 'package:recargas_app/models/recharge_model.dart';
import 'package:recargas_app/providers/auth_providers.dart';

final historyProvider = StateNotifierProvider<HistoryNotifier, AsyncValue<List<Recharge>>>((ref) {
  return HistoryNotifier(ref);
});

class HistoryNotifier extends StateNotifier<AsyncValue<List<Recharge>>> {
  HistoryNotifier(this.ref) : super(const AsyncValue.loading()) {
    _loadHistory();
    ref.listen(authProvider, (previous, next) {
      if (previous != next) {
        _loadHistory(); 
      }
    });
  }

  final Ref ref;

  Future<void> _loadHistory() async {
    try {
      final authState = ref.read(authProvider);
      final userData = authState.whenOrNull(data: (user) => user);
      
      if (userData == null || userData["id"] == null) {
        state = AsyncValue.data([]); 
        return;
      }

      final int userId = userData["id"] is int ? userData["id"] : int.tryParse(userData["id"].toString()) ?? 0;
      if (userId == 0) {
        state = AsyncValue.data([]);
        return;
      }

      final history = await DatabaseHelper.instance.getRechargesByUser(userId);

    
      history.sort((a, b) => b.date.compareTo(a.date));

      if (mounted) {
        state = AsyncValue.data(history);
      }
    } catch (e) {
      if (mounted) {
        state = AsyncValue.error("Error al cargar historial: $e", StackTrace.empty);
      }
    }
  }

  Future<void> deleteRecharge(int rechargeId) async {
    await DatabaseHelper.instance.deleteRecharge(rechargeId);
    _loadHistory();
  }

  Future<void> updateRecharge(Recharge recharge) async {
    await DatabaseHelper.instance.updateRecharge(recharge);
    _loadHistory();
  }
}
