import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:recargas_app/database/database_helper.dart';
import 'package:recargas_app/models/recharge_model.dart';
import 'package:recargas_app/providers/auth_providers.dart';
import 'package:recargas_app/services/api_service.dart';
import 'history_provider.dart';

final rechargeProvider =
    StateNotifierProvider<RechargeNotifier, AsyncValue<String?>>((ref) {
  return RechargeNotifier(ref);
});

class RechargeNotifier extends StateNotifier<AsyncValue<String?>> {
  RechargeNotifier(this.ref) : super(const AsyncValue.data(null));

  final Ref ref;
  final ApiService _apiService = ApiService();

  Future<void> buyRecharge(String phone, String providerId, double amount) async {
    state = const AsyncValue.loading();
    final token = ref.read(authProvider);

    if (token == null) {
      state = AsyncValue.error("Error: No autenticado", StackTrace.empty);
      return;
    }

    try {
      final response = await http.post(
        Uri.parse("${ApiService.baseUrl}/buy"),
        headers: {
          "Authorization": "$token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "cellPhone": phone,
          "supplierId": providerId,
          "value": amount.toInt(),
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        state = AsyncValue.data("✅ Recarga exitosa: ${data["message"]}");

        // ✅ Guardar la recarga en SQLite
        await DatabaseHelper.instance.insertRecharge(Recharge(
          phoneNumber: phone,
          provider: providerId,
          amount: amount,
          date: DateTime.now().toIso8601String(),
        ));

        // ✅ Refrescar historial de recargas
        ref.invalidate(historyProvider);

        // ✅ Restablecer el estado y limpiar campos después de 3 segundos
        Future.delayed(Duration(seconds: 3), () {
          state = const AsyncValue.data(null);
        });

      } else {
        state = AsyncValue.error("❌ Error en la recarga: ${response.body}", StackTrace.empty);
      }
    } catch (e) {
      state = AsyncValue.error("❌ Error de conexión: $e", StackTrace.empty);
    }
  }
}
