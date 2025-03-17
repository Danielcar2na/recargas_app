import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:recargas_app/providers/auth_providers.dart';
import '../services/api_service.dart';


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
  state = AsyncValue.data("Recarga exitosa: ${data["message"]}");
} else {
  state = AsyncValue.error("Error en la recarga: ${response.body}", StackTrace.empty);
}
} catch (e) {
  state = AsyncValue.error("Error de conexión: $e", StackTrace.empty);
}
  }
}
