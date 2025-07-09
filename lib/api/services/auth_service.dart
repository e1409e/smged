// lib/api/services/auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint; // Agregado debugPrint
import 'dart:io' show Platform;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smged/api/models/login_request.dart';
import 'package:smged/api/models/login_response.dart';
import 'package:smged/config.dart';

class AuthService {
  static final String _baseUrl = Config.apiUrl;

  static const String _loginEndpoint = '/usuarios/login';
  // Claves para SharedPreferences
  static const String _authTokenKey = 'auth_token';
  static const String _userIdKey = 'userId';
  // ¡NUEVA CLAVE para el rol de usuario!
  static const String _userRoleKey = 'user_role';

  // --- NUEVO: Callback para notificar cambios de estado de autenticación ---
  Function(bool isLoggedIn, String? role)? onAuthStatusChanged;

  Future<LoginResponse> login(LoginRequest request) async {
    final url = Uri.parse('$_baseUrl$_loginEndpoint');
    debugPrint('Intentando POST a: $url');
    debugPrint('Cuerpo de la petición: ${jsonEncode(request.toJson())}');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      );
      debugPrint('Respuesta de la API (Status: ${response.statusCode}): ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        final loginResponse = LoginResponse.fromJson(responseBody);

        if (loginResponse.success) {
          final SharedPreferences prefs = await SharedPreferences.getInstance();

          // Guardar el token de la respuesta
          if (loginResponse.token != null && loginResponse.token!.isNotEmpty) {
            await prefs.setString(_authTokenKey, loginResponse.token!);
          }

          // Guardar el ID de usuario si está disponible
          if (loginResponse.id_usuario != 0) {
            await prefs.setInt(_userIdKey, loginResponse.id_usuario);
          }

          // --- MODIFICACIÓN CLAVE: Guardar el rol de usuario ---
          if (loginResponse.rol != null && loginResponse.rol!.isNotEmpty) {
            await prefs.setString(_userRoleKey, loginResponse.rol!);
          }

          // --- NUEVO: Notificar a los oyentes que el estado de autenticación cambió (login exitoso) ---
          if (onAuthStatusChanged != null) {
            debugPrint('[AuthService] Login exitoso, notificando cambio de estado.');
            onAuthStatusChanged!(true, loginResponse.rol);
          }
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
          debugPrint('No se pudo decodificar el cuerpo del error como JSON: $e');
        }

        // --- IMPORTANTE: Si el login falla, NO notificar un estado "logueado" ---
        // El callback solo se llama en éxito. En fallo, la app se mantendrá en estado 'loggedOut'.
        return LoginResponse(
          success: false,
          message: errorMessage,
          rol: rolFromError ?? '',
          id_usuario: idUsuarioError,
          token: null,
        );
      }
    } catch (e) {
      debugPrint('Excepción capturada en AuthService.login: $e');
      return LoginResponse(
        success: false,
        message: 'Error de conexión. Asegúrate de que el servidor esté funcionando y que tienes conexión a internet.',
        rol: '',
        id_usuario: 0,
        token: null,
      );
    }
  }

  /// Verifica la existencia del token para determinar si el usuario está logueado.
  Future<bool> isLoggedIn() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_authTokenKey) != null && prefs.getString(_authTokenKey)!.isNotEmpty;
  }

  /// Obtiene el ID del usuario logueado de SharedPreferences.
  Future<int?> getUserId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_userIdKey);
  }

  /// --- NUEVO: Obtiene el rol del usuario logueado de SharedPreferences. ---
  Future<String?> getUserRole() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userRoleKey);
  }

  /// Elimina el token de autenticación y el ID de usuario de SharedPreferences.
  Future<void> logout() async {
    debugPrint('[AuthService] Iniciando cierre de sesión. Limpiando SharedPreferences.');
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_authTokenKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_userRoleKey); // --- NUEVO: Eliminar también el rol ---

    // --- NUEVO: Notificar a los oyentes que el estado de autenticación cambió (logout) ---
    if (onAuthStatusChanged != null) {
      debugPrint('[AuthService] Cierre de sesión exitoso, notificando cambio de estado.');
      onAuthStatusChanged!(false, null);
    }
  }

  /// Añadir un método para obtener el token, útil para otros servicios.
  Future<String?> getAuthToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_authTokenKey);
  }
}