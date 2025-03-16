import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recargas_app/providers/auth_providers.dart';
import '../services/api_service.dart';


// final supplierProvider =
//     FutureProvider<List<Map<String, String>>?>((ref) async {
//   final token = ref.watch(authProvider);
//   if (token != null) {
//     return ApiService().getSuppliers(token);
//   }
//   return null;
// });

final supplierProvider = FutureProvider<List<Map<String, String>>?>((ref) async {
  final authNotifier = ref.read(authProvider.notifier);
  await authNotifier.login(); // Forzar autenticación antes de pedir proveedores
  final token = ref.watch(authProvider);

  if (token != null) {
    return ApiService().getSuppliers(token);
  }
  return null;
});

