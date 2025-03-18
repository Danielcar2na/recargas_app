import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';

final authProvider = StateNotifierProvider<AuthNotifier, String?>((ref) {
  return AuthNotifier();
});

class AuthNotifier extends StateNotifier<String?> {
  AuthNotifier() : super(null);

  final ApiService _apiService = ApiService();

  Future<void> login() async {
    final token = await _apiService.authenticate();
    if (token != null) {
      state = token;
    }
  }
}
