import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:smged/api/models/usuario.dart';
import 'package:smged/config.dart';
import 'package:smged/api/exceptions/api_exception.dart';
import 'package:smged/api/services/auth_service.dart'; // Importa el AuthService

class UsuariosService {
  final String _baseUrl = '${Config.apiUrl}/usuarios';
  final AuthService _authService = AuthService(); // Instancia de AuthService para obtener el token

  // Función auxiliar para obtener los encabezados con el token
  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getAuthToken();
    if (token == null || token.isEmpty) {
      // Si no hay token, podemos lanzar una excepción o retornar solo Content-Type
      // Para servicios que requieren auth, lo mejor es lanzar una excepción.
      throw UnauthorizedException('No hay token de autenticación disponible. Inicia sesión nuevamente.', statusCode: 401);
    }
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token', // ¡Aquí se añade el token!
    };
  }

  Future<List<Usuario>> obtenerUsuarios() async {
    final headers = await _getHeaders(); // Obtener encabezados con el token
    final response = await http.get(
      Uri.parse(_baseUrl),
      headers: headers, // Usar los encabezados con el token
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => Usuario.fromJson(json)).toList();
    } else {
      _handleError(response);
    }
    throw UnknownApiException('Error desconocido al obtener usuarios');
  }

  Future<void> crearUsuario(Usuario usuario, String password) async {
    final headers = await _getHeaders(); // Obtener encabezados con el token
    final response = await http.post(
      Uri.parse('$_baseUrl/registrar'),
      headers: headers, // Usar los encabezados con el token
      body: json.encode({
        'nombre': usuario.nombre,
        'apellido': usuario.apellido,
        'cedula_usuario': usuario.cedulaUsuario,
        'password': password,
        'rol': usuario.rol,
      }),
    );
    if (response.statusCode != 201) {
      _handleError(response);
    }
  }

  Future<void> actualizarUsuario(Usuario usuario, {String? password}) async {
    final headers = await _getHeaders(); // Obtener encabezados con el token
    final body = {
      'nombre': usuario.nombre,
      'apellido': usuario.apellido,
      'cedula_usuario': usuario.cedulaUsuario,
      'rol': usuario.rol,
    };
    if (password != null && password.isNotEmpty) {
      body['password'] = password;
    }
    final response = await http.put(
      Uri.parse('$_baseUrl/${usuario.idUsuario}'),
      headers: headers, // Usar los encabezados con el token
      body: json.encode(body),
    );
    if (response.statusCode != 200) {
      _handleError(response);
    }
  }

  Future<void> eliminarUsuario(int idUsuario) async {
    final headers = await _getHeaders(); // Obtener encabezados con el token
    final response = await http.delete(
      Uri.parse('$_baseUrl/$idUsuario'),
      headers: headers, // Usar los encabezados con el token
    );
    if (response.statusCode != 200) {
      _handleError(response);
    }
  }

  /// Manejo centralizado de errores según la estructura de la API y api_exception.dart
  void _handleError(http.Response response) {
    final status = response.statusCode;
    dynamic body;
    try {
      body = json.decode(response.body);
    } catch (_) {
      throw UnknownApiException('Respuesta inesperada del servidor', statusCode: status, details: response.body);
    }

    // Modificación 1: Manejo específico para 401 Unauthorized
    if (status == 401) {
      throw UnauthorizedException(body['message'] ?? 'Token inválido o expirado. Vuelve a iniciar sesión.', statusCode: status, details: body);
    }

    // Validaciones de express-validator (campo 'errores')
    if (body is Map && body.containsKey('errores')) {
      final errorsList = body['errores'] as List;
      final Map<String, List<String>> validationErrors = {};
      for (var error in errorsList) {
        final field = error['param'] ?? 'general';
        final msg = error['msg'] ?? 'Error de validación';
        validationErrors.putIfAbsent(field, () => []).add(msg);
      }
      throw ValidationException('Verifica los campos ingresados.', validationErrors, statusCode: status, details: body);
    }

    // Error general (campo 'error')
    if (body is Map && body.containsKey('error')) {
      final msg = body['error'].toString();
      if (status == 404) {
        throw NotFoundException(msg, statusCode: status, details: body);
      }
      if (status >= 500) {
        throw ServerException(msg, statusCode: status, details: body);
      }
      throw ApiException(msg, statusCode: status, details: body);
    }

    // Otros errores
    throw UnknownApiException('Error inesperado: ${response.body}', statusCode: status, details: body);
  }
}