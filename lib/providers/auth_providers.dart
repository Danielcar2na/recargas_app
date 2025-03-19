import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/database_helper.dart';
import '../services/api_service.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AsyncValue<Map<String, dynamic>?>>((ref) {
  return AuthNotifier();
});

class AuthNotifier extends StateNotifier<AsyncValue<Map<String, dynamic>?>> {
  AuthNotifier() : super(const AsyncValue.data(null)) {
    _loadUserSession(); 
  }

  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final ApiService _apiService = ApiService();


  Future<void> register(String username, String password) async {
    state = const AsyncValue.loading();
    try {
      final userId = await _dbHelper.registerUser(username, password);
      if (userId > 0) {
        await login(username, password); 
      } else {
        state = AsyncValue.error("El usuario ya existe", StackTrace.empty);
      }
    } catch (e) {
      state = AsyncValue.error("Error al registrar usuario: $e", StackTrace.empty);
    }
  }


  Future<void> login(String username, String password) async {
    state = const AsyncValue.loading();
    try {
      print("🔍 Buscando usuario en SQLite: $username");


      final user = await _dbHelper.authenticateUser(username, password);
      if (user == null) {
        print("❌ Usuario no encontrado o contraseña incorrecta.");
        state = AsyncValue.error("Credenciales incorrectas", StackTrace.empty);
        return;
      }

      print("✅ Usuario encontrado en SQLite: ${user['username']}");


      print("🌐 Solicitando token a la API...");
      final token = await _apiService.authenticate();

      if (token == null) {
        print("❌ Error obteniendo token de la API.");
        state = AsyncValue.error("Error obteniendo token", StackTrace.empty);
        return;
      }

      print("✅ Token recibido: $token");

      
      final userData = {
        'id': user['id'],
        'username': user['username'],
        'token': token,
      };

      await _saveUserSession(userData);
      state = AsyncValue.data(userData);
      print("✅ Usuario logueado correctamente y sesión guardada.");

    } catch (e) {
      print("❌ Error en el login: $e");
      state = AsyncValue.error("Error al iniciar sesión: $e", StackTrace.empty);
    }
  }

  
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    state = const AsyncValue.data(null);
  }


  Future<void> _saveUserSession(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('user_id', userData['id']);
    await prefs.setString('username', userData['username']);
    await prefs.setString('token', userData['token']);
  }


  Future<void> _loadUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');
    final username = prefs.getString('username');
    final token = prefs.getString('token');

    if (userId != null && username != null && token != null) {
      state = AsyncValue.data({
        'id': userId,
        'username': username,
        'token': token,
      });
    }
  }
}
