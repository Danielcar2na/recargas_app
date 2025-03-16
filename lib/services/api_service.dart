import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _baseUrl =
      "https://us-central1-puntored-dev.cloudfunctions.net/technicalTest-developer/api";
  static const String _apiKey =
      "mtrQF6Q11eosqyQnkMY0JGFbGqcxVg5icvfVnX1ifIyWDvwGApJ8WUM8nHVrdSkN";

  Future<String?> authenticate() async {
  final response = await http.post(
    Uri.parse("$_baseUrl/auth"),
    headers: {"x-api-key": _apiKey, "Content-Type": "application/json"},
    body: jsonEncode({"user": "user0147", "password": "#3Q34Sh0NlDS"}),
  );

  print("Respuesta autenticación: ${response.body}"); // 🔍 Verifica qué devuelve la API

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data["token"];
  } else {
    print("Error en autenticación: ${response.body}");
    return null;
  }
}
  Future<List<Map<String, String>>?> getSuppliers(String token) async {
    final response = await http.get(
      Uri.parse("$_baseUrl/getSuppliers"),
      headers: {"authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((supplier) {
        return {
          "id": supplier["id"].toString(), // Convertir id a String
          "name": supplier["name"].toString(), // Convertir name a String
        };
      }).toList();
    } else {
      print("Error obteniendo proveedores: ${response.body}");
      return null;
    }
  }


}
