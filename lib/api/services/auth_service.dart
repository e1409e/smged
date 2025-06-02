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
        // Para iOS (simulador o físico) y otros, 127.0.0.1 (localhost) o la IP de tu máquina host.
        // Si usas un dispositivo iOS físico en la misma red Wi-Fi, deberías usar la IP de tu PC.
        return 'http://127.0.0.1:3000';
      }
    }
  }

  // ¡CORRECCIÓN FINAL AQUÍ!
  // Basado en tu archivo de rutas de Node.js (router.post('/login', iniciarSesion);),
  // y asumiendo que el prefijo del router es '/usuarios' en tu archivo principal de Express (ej. app.use('/usuarios', usuariosRoutes);),
  // el endpoint completo es '/usuarios/login'.
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

        try {
          final Map<String, dynamic> errorBody = jsonDecode(response.body);
          // Tu API devuelve 'error' para credenciales inválidas y 'message' en otros casos
          errorMessage = errorBody['error'] ?? errorBody['message'] ?? errorMessage;
        } catch (e) {
          print('No se pudo decodificar el cuerpo del error como JSON: $e');
        }

        return LoginResponse(
          success: false,
          message: errorMessage,
          rol: rolFromError,
        );
      }
    } catch (e) {
      print('Excepción capturada en AuthService.login: $e');
      String userFriendlyMessage = 'Error de conexión. Asegúrate de que el servidor esté funcionando y que tienes conexión a internet.';
      if (e.toString().contains('SocketException')) {
        userFriendlyMessage = 'No se pudo conectar al servidor. Verifica tu conexión o la URL de la API.';
      } else if (e.toString().contains('Connection refused')) {
        userFriendlyMessage = 'Conexión rechazada. Asegúrate de que el servidor backend está corriendo.';
      }
      return LoginResponse(
        success: false,
        message: userFriendlyMessage,
        rol: null,
      );
    }
  }
}