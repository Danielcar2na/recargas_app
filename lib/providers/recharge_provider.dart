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

  Future<void> buyRecharge(
      String phone, String providerId, double amount) async {
    state = const AsyncValue.loading();

    final authState = ref.read(authProvider);
    final userId = authState.whenOrNull(
        data: (user) => user?["id"] as int?); // ✅ Convertimos a int

    if (userId == null) {
      state = AsyncValue.error("Error: No autenticado", StackTrace.empty);
      return;
    }

    try {
      final token = authState.whenOrNull(data: (user) => user?["token"]);

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

        await DatabaseHelper.instance.insertRecharge(
          Recharge(
            userId: userId,
            phoneNumber: phone,
            provider: providerId,
            amount: amount,
            date: DateTime.now().toIso8601String(),
          ),
          userId,
        );

        ref.invalidate(historyProvider);

        Future.delayed(Duration(seconds: 3), () {
          state = const AsyncValue.data(null);
        });
      } else {
        state = AsyncValue.error(
            "❌ Error en la recarga: ${response.body}", StackTrace.empty);
      }
    } catch (e) {
      state = AsyncValue.error("❌ Error de conexión: $e", StackTrace.empty);
    }
  }
}
