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
      } else {
        String errorMessage = 'Error desconocido al iniciar sesión.';
        String? rolFromError;
        int idUsuarioError = 0;

        try {
          final Map<String, dynamic> errorBody = jsonDecode(response.body);
          errorMessage = errorBody['error'] ?? errorBody['message'] ?? errorMessage;
          rolFromError = errorBody['rol'];
          idUsuarioError = errorBody['id_usuario'] ?? 0;
        } catch (e) {
          print('No se pudo decodificar el cuerpo del error como JSON: $e');
        }

        return LoginResponse(
          success: false,
          message: errorMessage,
          rol: rolFromError ?? '',
          id_usuario: idUsuarioError,
        );
      }
    } catch (e) {
      print('Excepción capturada en AuthService.login: $e');
      return LoginResponse(
        success: false,
        message: 'Error de conexión. Asegúrate de que el servidor esté funcionando y que tienes conexión a internet.',
        rol: '',
        id_usuario: 0,
      );
    }
  }
}