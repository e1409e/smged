import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:smged/api/models/representante.dart';
import 'package:smged/config.dart';
import 'package:smged/api/exceptions/api_exception.dart';
import 'package:smged/api/services/auth_service.dart'; // Importa el AuthService

class RepresentantesService {
  final String _baseUrl = '${Config.apiUrl}/representantes';
  final AuthService _authService = AuthService(); // Instancia de AuthService

  // Función auxiliar para obtener los encabezados con el token
  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getAuthToken();
    if (token == null || token.isEmpty) {
      // Si no hay token, lanza una excepción que debería ser manejada para forzar el logout
      throw UnauthorizedException('No hay token de autenticación disponible. Inicia sesión nuevamente.', statusCode: 401);
    }
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token', // ¡Aquí se añade el token!
    };
  }

  Future<List<Representante>> obtenerRepresentantes() async {
    try {
      final headers = await _getHeaders(); // Obtener encabezados con el token
      final response = await http.get(
        Uri.parse(_baseUrl),
        headers: headers, // Usar los encabezados con el token
      );
      _handleError(response);
      List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => Representante.fromJson(json)).toList();
    } catch (e) {
      if (e is ApiException) rethrow;
      throw UnknownApiException('Fallo al obtener representantes: $e');
    }
  }

  Future<Representante> obtenerRepresentantePorId(int id) async {
    try {
      final headers = await _getHeaders(); // Obtener encabezados con el token
      final response = await http.get(
        Uri.parse('$_baseUrl/$id'),
        headers: headers, // Usar los encabezados con el token
      );
      _handleError(response);
      return Representante.fromJson(json.decode(response.body));
    } catch (e) {
      if (e is ApiException) rethrow;
      throw UnknownApiException('Fallo al obtener representante: $e');
    }
  }

  Future<Representante?> obtenerRepresentantePorEstudiante(int idEstudiante) async {
    try {
      final headers = await _getHeaders(); // Obtener encabezados con el token
      final response = await http.get(
        Uri.parse('$_baseUrl/estudiante/$idEstudiante'),
        headers: headers, // Usar los encabezados con el token
      );
      if (response.statusCode == 404) {
        return null;
      }
      _handleError(response);
      return Representante.fromJson(json.decode(response.body));
    } catch (e) {
      if (e is ApiException) rethrow;
      throw UnknownApiException('Fallo al obtener representante por estudiante: $e');
    }
  }

  Future<void> crearRepresentante(Representante representante) async {
    try {
      final headers = await _getHeaders(); // Obtener encabezados con el token
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: headers, // Usar los encabezados con el token
        body: json.encode(representante.toJson()),
      );
      _handleError(response, expectCreated: true);
      // La API retorna solo el id, no es necesario hacer fromJson aquí
    } catch (e) {
      if (e is ApiException) rethrow;
      throw UnknownApiException('Fallo al crear representante: $e');
    }
  }

  Future<void> editarRepresentante(int id, Representante representante) async {
    try {
      final headers = await _getHeaders(); // Obtener encabezados con el token
      final response = await http.put(
        Uri.parse('$_baseUrl/$id'),
        headers: headers, // Usar los encabezados con el token
        body: json.encode(representante.toJson()),
      );
      _handleError(response);
      // La API retorna solo un mensaje, no es necesario hacer fromJson aquí
    } catch (e) {
      if (e is ApiException) rethrow;
      throw UnknownApiException('Fallo al editar representante: $e');
    }
  }

  Future<void> eliminarRepresentante(int id) async {
    try {
      final headers = await _getHeaders(); // Obtener encabezados con el token
      final response = await http.delete(
        Uri.parse('$_baseUrl/$id'),
        headers: headers, // Usar los encabezados con el token
      );
      _handleError(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw UnknownApiException('Fallo al eliminar representante: $e');
    }
  }

  void _handleError(http.Response response, {bool expectCreated = false}) {
    final status = response.statusCode;
    if ((expectCreated && status == 201) || (!expectCreated && status >= 200 && status < 300)) {
      return;
    }

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

    // Validaciones de express-validator (campo 'errores' o 'errors')
    if (body is Map && (body.containsKey('errores') || body.containsKey('errors'))) {
      final errorsList = body['errores'] ?? body['errors'];
      final Map<String, List<String>> validationErrors = {};
      for (var error in errorsList) {
        final field = error['param'] ?? error['path'] ?? 'general';
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