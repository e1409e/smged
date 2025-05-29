// lib/api/services/auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

import 'package:smged/api/models/login_request.dart';
import 'package:smged/api/models/login_response.dart';

class AuthService {
  static final String _baseUrl = _getPlatformBaseUrl();

  static String _getPlatformBaseUrl() {
    if (kIsWeb) {
      return 'http://127.0.0.1:3000';
    } else {
      if (Platform.isAndroid) {
        return 'http://10.0.2.2:3000';
      } else {
        return 'http://127.0.0.1:3000';
      }
    }
  }

  static const String _loginEndpoint = '/usuarios/login';

  Future<LoginResponse> login(LoginRequest request) async {
    final url = Uri.parse('$_baseUrl$_loginEndpoint');
    print('Intentando POST a: $url');
    print('Cuerpo de la petición: ${jsonEncode(request.toJson())}');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      );

      print('Respuesta de la API (Status: ${response.statusCode}): ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        return LoginResponse.fromJson(responseBody);
      } else if (response.statusCode == 401) {
        // --- Manejo específico para 401 Unauthorized (Credenciales incorrectas) ---
        String errorMessage = 'Cédula o contraseña incorrectas.'; // Mensaje predeterminado

        try {
          final Map<String, dynamic> errorBody = jsonDecode(response.body);
          // Prioriza 'message', luego 'error', si no, usa el predeterminado
          errorMessage = errorBody['message'] ?? errorBody['error'] ?? errorMessage;
        } catch (e) {
          // Si el cuerpo no es JSON o no se puede decodificar, usa el mensaje predeterminado.
          print('No se pudo decodificar el cuerpo del error 401 como JSON. Usando mensaje predeterminado.');
        }
        throw Exception(errorMessage); // Lanza la excepción con el mensaje específico
      } else {
        // --- Manejo para otros códigos de error (400, 500, etc.) ---
        String errorMessage = 'Error desconocido del servidor.';

        try {
          final Map<String, dynamic> errorBody = jsonDecode(response.body);
          errorMessage = errorBody['message'] ?? errorBody['error'] ?? 'Error de servidor: ${response.statusCode}';
        } catch (e) {
          errorMessage = 'Error al procesar la respuesta del servidor (Estatus: ${response.statusCode}).';
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('Excepción capturada en AuthService.login: $e');
      throw Exception(' ${e.toString()}');
    }
  }
}