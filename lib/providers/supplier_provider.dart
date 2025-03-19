import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recargas_app/providers/auth_providers.dart';
import '../services/api_service.dart';

final supplierProvider = FutureProvider<List<Map<String, String>>?>((ref) async {
  final authState = ref.watch(authProvider);
  final token = authState.whenOrNull(data: (user) => user?["token"] as String?); // ✅ Extrae solo el token

  if (token != null) {
    return ApiService().getSuppliers(token);
  }
  return null;
});
