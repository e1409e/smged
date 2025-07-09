// lib/api/services/auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
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
  static const String _userRoleKey = 'user_role';
  static const String _lastActivityTimeKey = 'last_activity_time'; // <-- ¡NUEVA CLAVE!

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

          // Guardar el rol de usuario
          if (loginResponse.rol != null && loginResponse.rol!.isNotEmpty) {
            await prefs.setString(_userRoleKey, loginResponse.rol!);
          } else {
            // Si el rol es nulo o vacío, asegúrate de que no quede un rol viejo
            await prefs.remove(_userRoleKey);
            debugPrint('[AuthService] Advertencia: Rol de usuario es nulo o vacío en la respuesta de login. No se guarda rol en SP.');
          }

          // --- Guardar el timestamp del login exitoso ---
          await prefs.setString(_lastActivityTimeKey, DateTime.now().toIso8601String());
          debugPrint('[AuthService] Tiempo de última actividad guardado (Login): ${DateTime.now()}');

          // Notificar a los oyentes que el estado de autenticación cambió (login exitoso)
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

  /// Obtiene el rol del usuario logueado de SharedPreferences.
  Future<String?> getUserRole() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userRoleKey);
  }

  /// --- NUEVO MÉTODO: Para actualizar el tiempo de actividad ---
  Future<void> updateLastActivityTime() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastActivityTimeKey, DateTime.now().toIso8601String());
    debugPrint('[AuthService] Tiempo de última actividad actualizado: ${DateTime.now()}');
  }

  /// --- NUEVO MÉTODO: Para obtener el tiempo de actividad ---
  Future<DateTime?> getLastActivityTime() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? timestamp = prefs.getString(_lastActivityTimeKey);
    if (timestamp != null) {
      try {
        return DateTime.parse(timestamp);
      } catch (e) {
        debugPrint('[AuthService] Error al parsear last_activity_time: $e');
        return null;
      }
    }
    return null;
  }

  /// Elimina el token de autenticación y el ID de usuario de SharedPreferences.
  Future<void> logout() async {
    debugPrint('[AuthService] Iniciando cierre de sesión. Limpiando SharedPreferences.');
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_authTokenKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_userRoleKey);
    await prefs.remove(_lastActivityTimeKey); // <-- ¡NUEVO: Eliminar también el timestamp!

    // --- VERIFICACIÓN DE DEPURACIÓN EXTREMA ---
    final String? tokenAfterLogout = prefs.getString(_authTokenKey);
    final String? roleAfterLogout = prefs.getString(_userRoleKey);
    final String? lastActivityAfterLogout = prefs.getString(_lastActivityTimeKey);

    debugPrint('[AuthService] Verificación POST-LOGOUT:');
    debugPrint('  - Token: ${tokenAfterLogout == null ? "LIMPIO (null)" : "EXISTE ($tokenAfterLogout)"}');
    debugPrint('  - Rol: ${roleAfterLogout == null ? "LIMPIO (null)" : "EXISTE ($roleAfterLogout)"}');
    debugPrint('  - Última Actividad: ${lastActivityAfterLogout == null ? "LIMPIO (null)" : "EXISTE ($lastActivityAfterLogout)"}');
    // --- FIN VERIFICACIÓN DE DEPURACIÓN EXTREMA ---

    // Notificar a los oyentes que el estado de autenticación cambió (logout)
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