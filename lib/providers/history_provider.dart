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
  }

  final Ref ref;

  Future<void> _loadHistory() async {
    try {
      final authState = ref.read(authProvider);
      final userId = authState.whenOrNull(data: (user) => user?["id"] as int?);

      if (userId != null) {
        final history = await DatabaseHelper.instance.getRechargesByUser(userId);

        if (mounted) { // 🔹 Verifica si el provider sigue activo antes de actualizar el estado
          state = AsyncValue.data(history);
        }
      } else {
        if (mounted) {
          state = AsyncValue.data([]);
        }
      }
    } catch (e) {
      if (mounted) { // 🔹 Evita errores cuando el provider ha sido eliminado
        state = AsyncValue.error("Error al cargar historial: $e", StackTrace.empty);
      }
    }
  }

  Future<void> deleteRecharge(int rechargeId) async {
    try {
      await DatabaseHelper.instance.deleteRecharge(rechargeId);
      _loadHistory();
    } catch (e) {
      if (mounted) {
        state = AsyncValue.error("Error al eliminar recarga: $e", StackTrace.empty);
      }
    }
  }

  Future<void> updateRecharge(Recharge recharge) async {
    try {
      await DatabaseHelper.instance.updateRecharge(recharge);
      _loadHistory();
    } catch (e) {
      if (mounted) {
        state = AsyncValue.error("Error al actualizar recarga: $e", StackTrace.empty);
      }
    }
  }
}
