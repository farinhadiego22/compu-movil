import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Declara el token UNA VEZ acá
  static const String tokenProfe =
      "eyJhbGciOiJSUzI1NiIsImtpZCI6IjhlOGZjOGU1NTZmN2E3NmQwOGQzNTgyOWQ2ZjkwYWUyZTEyY2ZkMGQiLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJodHRwczovL2FjY291bnRzLmdvb2dsZS5jb20iLCJhenAiOiIyMTIyNjc2ODY2MDQtMGo0a3M5c25pa2plMHNzdGpqbW10Mm1tZTJvZHYyZnUuYXBwcy5nb29nbGV1c2VyY29udGVudC5jb20iLCJhdWQiOiIyMTIyNjc2ODY2MDQtMGo0a3M5c25pa2plMHNzdGpqbW10Mm1tZTJvZHYyZnUuYXBwcy5nb29nbGV1c2VyY29udGVudC5jb20iLCJzdWIiOiIxMTE2MjQ4MTQxNTc0MDc2MTkyNDkiLCJoZCI6InV0ZW0uY2wiLCJlbWFpbCI6ImRmYXJpbmFAdXRlbS5jbCIsImVtYWlsX3ZlcmlmaWVkIjp0cnVlLCJhdF9oYXNoIjoiNzJwWWdQWTlLZl9Zdnp1UkRpMkFmUSIsIm5hbWUiOiJESUVHTyBKT1JHRSBGQVJJw5FBIFNBTElOQVMiLCJwaWN0dXJlIjoiaHR0cHM6Ly9saDMuZ29vZ2xldXNlcmNvbnRlbnQuY29tL2EvQUNnOG9jSXBzMVlXUlJYbG1RSFNodlRsS3VNcEtoeFdTVDZ1Vy1hUlo1eXd3dHN4MXpFTm5Wcz1zOTYtYyIsImdpdmVuX25hbWUiOiJESUVHTyBKT1JHRSIsImZhbWlseV9uYW1lIjoiRkFSScORQSBTQUxJTkFTIiwiaWF0IjoxNzUyMjA1NTI4LCJleHAiOjE3NTIyMDkxMjh9.jpNG65mmwb1I033GKoibAqvCz7RhQcPV5rLTZgxORXOFMRe41PORzRTrIyv3QNvuvPgT-oVZXk4XuQx_8WQTBjrWkhZKSAJdBQh1Hitj2T74u2FYDCLIkiPLfrXp6CktnOUh7zqtanSJqBfsSaLQhozDuM4-A2a3PU5rAxNEsbMENrI17UkQ227Gj3vnWQtjdzIAG8NrfQEXyETgzycKufEqbWTYPmj85rqBWBsms-Lg-uq-QrgXwuYxLQETP2vLG9wWib0LyZ1evGUdNmwV2xTdGZ86PRlZhw4eUSRxDnmTr8aNNGjnLr6jaLdqMJf-6w8AazvTyhk04Qdj-GohOg";

  static Map<String, String> get _headers => {
    'Authorization': 'Bearer $tokenProfe',
  };

  static Future<List<dynamic>> obtenerMenus() async {
    final url = Uri.parse('https://api.sebastian.cl/restaurant/v1/menu/today');
    final response = await http
        .get(url, headers: _headers)
        .timeout(Duration(seconds: 10));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al obtener los menús: ${response.statusCode}');
    }
  }

  static Future<List<dynamic>> obtenerCategorias() async {
    final url = Uri.parse(
      'https://api.sebastian.cl/restaurant/v1/info/categories',
    );
    final response = await http
        .get(url, headers: _headers)
        .timeout(Duration(seconds: 10));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        'Error al obtener las categorías: ${response.statusCode}',
      );
    }
  }

  static Future<Map<String, dynamic>> obtenerMenuPorCategoria(
    String categoryToken,
  ) async {
    final url = Uri.parse(
      'https://api.sebastian.cl/restaurant/v1/menu/$categoryToken/today',
    );
    final response = await http
        .get(url, headers: _headers)
        .timeout(Duration(seconds: 10));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        'Error al obtener menú por categoría: ${response.statusCode}',
      );
    }
  }

  static Future<Map<String, dynamic>> evaluarPlato({
    required String dishToken,
    required int rate, // debe ser entre 1 y 5
  }) async {
    final url = Uri.parse(
      'https://api.sebastian.cl/restaurant/v1/evaluation/dish',
    );
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $tokenProfe',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'dishToken': dishToken, 'rate': rate}),
    );
    if (response.statusCode == 201 || response.statusCode == 202) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        'Error al evaluar el plato: ${response.statusCode}\n${response.body}',
      );
    }
  }
}
