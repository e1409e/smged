// lib/api/services/auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'package:shared_preferences/shared_preferences.dart'; // ¡Nueva importación!
import 'package:smged/api/models/login_request.dart';
import 'package:smged/api/models/login_response.dart';
import 'package:smged/config.dart';

class AuthService {
  static final String _baseUrl = Config.apiUrl;



  static const String _loginEndpoint = '/usuarios/login';
  // Claves para SharedPreferences
  static const String _authTokenKey = 'authToken'; // Ya la habíamos considerado, pero la mantengo si la vas a usar
  static const String _userIdKey = 'userId'; // ¡Nueva clave para el ID del usuario!

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
        final loginResponse = LoginResponse.fromJson(responseBody);

        // Si el login es exitoso y tenemos un token y un ID, los guardamos.
        // Asegúrate de que tu LoginResponse contenga 'token' si lo usas para _authTokenKey.
        if (loginResponse.success) { // Asumo que `success` es true en un login exitoso
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          // Guarda el ID de usuario si está disponible en la respuesta del login
          if (loginResponse.id_usuario != 0) { // Asumo que 0 es un valor predeterminado si no hay ID válido
            await prefs.setInt(_userIdKey, loginResponse.id_usuario);
          }
          // Si tu LoginResponse tiene un token y lo quieres guardar:
          // await prefs.setString(_authTokenKey, loginResponse.token ?? '');
        }
        return loginResponse;
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

  /// Verifica si hay un token de autenticación guardado, indicando una sesión activa.
  /// (Si usas tokens para la autenticación, si no, puedes basarte solo en el ID de usuario)
  Future<bool> isLoggedIn() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_authTokenKey) != null; // O prefs.getInt(_userIdKey) != null;
  }

  /// Obtiene el ID del usuario logueado de SharedPreferences.
  Future<int?> getUserId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_userIdKey);
  }

  /// Elimina el token de autenticación y el ID del usuario de SharedPreferences para cerrar la sesión.
  Future<void> logout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_authTokenKey); // Si estás usando un token
    await prefs.remove(_userIdKey);    // ¡Importante para eliminar el ID!
  }
}