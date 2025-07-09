import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:smged/api/models/incidencia.dart';
import 'package:smged/config.dart';
import 'package:smged/api/exceptions/api_exception.dart';
import 'package:smged/api/services/auth_service.dart'; // Importa el AuthService

class IncidenciasService {
  final String _baseUrl = '${Config.apiUrl}/incidencias';
  final AuthService _authService = AuthService(); // Instancia de AuthService

  // Función auxiliar para obtener los encabezados con el token
  Future<Map<String, String>> _getHeaders({bool includeContentType = true}) async {
    final token = await _authService.getAuthToken();
    if (token == null || token.isEmpty) {
      throw UnauthorizedException('No hay token de autenticación disponible. Inicia sesión nuevamente.', statusCode: 401);
    }
    final headers = {
      'Authorization': 'Bearer $token', // ¡Aquí se añade el token!
    };
    if (includeContentType) {
      headers['Content-Type'] = 'application/json';
    }
    return headers;
  }

  Future<List<Incidencia>> obtenerIncidencias() async {
    try {
      final headers = await _getHeaders(); // Obtener encabezados con el token
      final response = await http.get(
        Uri.parse(_baseUrl),
        headers: headers, // Usar los encabezados con el token
      );
      _handleError(response); // Manejo de errores centralizado
      List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => Incidencia.fromJson(json)).toList();
    } catch (e) {
      if (e is ApiException) rethrow;
      throw UnknownApiException('Error desconocido al obtener incidencias: $e'); // Cambiado a UnknownApiException para consistencia
    }
  }

  Future<Incidencia> obtenerIncidenciaPorId(int id) async {
    try {
      final headers = await _getHeaders(); // Obtener encabezados con el token
      final response = await http.get(
        Uri.parse('$_baseUrl/$id'),
        headers: headers, // Usar los encabezados con el token
      );
      _handleError(response); // Manejo de errores centralizado
      return Incidencia.fromJson(json.decode(response.body));
    } catch (e) {
      if (e is ApiException) rethrow;
      throw UnknownApiException('Error desconocido al obtener la incidencia: $e'); // Cambiado a UnknownApiException
    }
  }

  Future<List<Incidencia>> obtenerIncidenciasPorEstudiante(int idEstudiante) async {
    try {
      final headers = await _getHeaders(); // Obtener encabezados con el token
      final response = await http.get(
        Uri.parse('$_baseUrl/estudiante/$idEstudiante'),
        headers: headers, // Usar los encabezados con el token
      );
      if (response.statusCode == 404) {
        return []; // Se mantiene el retorno [] para 404 si no hay incidencias específicas
      }
      _handleError(response); // Manejo de errores centralizado
      List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => Incidencia.fromJson(json)).toList();
    } catch (e) {
      if (e is ApiException) rethrow;
      throw UnknownApiException('Error desconocido al obtener incidencias del estudiante: $e'); // Cambiado a UnknownApiException
    }
  }

  Future<int> crearIncidencia(Incidencia incidencia) async {
    try {
      final headers = await _getHeaders(); // Obtener encabezados con el token
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: headers, // Usar los encabezados con el token
        body: json.encode(incidencia.toJson()),
      );
      _handleError(response, expectCreated: true); // Manejo de errores centralizado, esperando 201
      final data = json.decode(response.body);
      // Puede retornar el objeto completo o solo el id
      if (data is Map && data.containsKey('id_incidencia')) {
        return data['id_incidencia'];
      }
      if (data is int) {
        return data;
      }
      // Si retorna el objeto completo, intenta extraer el id
      if (data is Map && data.containsKey('id')) {
        return data['id'];
      }
      throw UnknownApiException('La API no devolvió el id_incidencia al crear la incidencia.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw UnknownApiException('Error desconocido al crear incidencia: $e'); // Cambiado a UnknownApiException
    }
  }

  Future<void> editarIncidencia(int id, Incidencia incidencia) async {
    try {
      final headers = await _getHeaders(); // Obtener encabezados con el token
      final response = await http.put(
        Uri.parse('$_baseUrl/$id'),
        headers: headers, // Usar los encabezados con el token
        body: json.encode(incidencia.toJson()),
      );
      _handleError(response); // Manejo de errores centralizado
      return;
    } catch (e) {
      if (e is ApiException) rethrow;
      throw UnknownApiException('Error desconocido al editar incidencia: $e'); // Cambiado a UnknownApiException
    }
  }

  Future<void> eliminarIncidencia(int id) async {
    try {
      final headers = await _getHeaders(); // Obtener encabezados con el token
      final response = await http.delete(
        Uri.parse('$_baseUrl/$id'),
        headers: headers, // Usar los encabezados con el token
      );
      _handleError(response); // Manejo de errores centralizado
      return;
    } catch (e) {
      if (e is ApiException) rethrow;
      throw UnknownApiException('Error desconocido al eliminar incidencia: $e'); // Cambiado a UnknownApiException
    }
  }

  /// Manejo centralizado de errores según la estructura de la API y api_exception.dart
  void _handleError(http.Response response, {bool expectCreated = false}) {
    final status = response.statusCode;

    // Si el estado es 200-299 (o 201 si se espera creación), no hay error.
    if ((expectCreated && status == 201) || (!expectCreated && status >= 200 && status < 300)) {
      return;
    }

    dynamic body;
    try {
      body = json.decode(response.body);
    } catch (_) {
      // Si no se puede decodificar, es una respuesta inesperada
      throw UnknownApiException('Respuesta inesperada del servidor', statusCode: status, details: response.body);
    }

    // Manejo específico para 401 Unauthorized
    if (status == 401) {
      throw UnauthorizedException(body['message'] ?? 'Token inválido o expirado. Vuelve a iniciar sesión.', statusCode: status, details: body);
    }

    // Validaciones de express-validator (campo 'errors' o 'errores')
    if (body is Map && (body.containsKey('errors') || body.containsKey('errores'))) {
      final errorsList = body['errors'] ?? body['errores'];
      final Map<String, List<String>> validationErrors = {};
      for (var error in errorsList) {
        final field = error['param'] ?? error['path'] ?? 'general';
        final msg = error['msg'] ?? 'Error de validación';
        validationErrors.putIfAbsent(field, () => []).add(msg);
      }
      throw ValidationException('Verifica los campos ingresados.', validationErrors, statusCode: status, details: body);
    }

    // Error general (campo 'error' o 'message')
    if (body is Map && (body.containsKey('error') || body.containsKey('message'))) {
      final msg = (body['error'] ?? body['message']).toString();
      if (status == 404) {
        throw NotFoundException(msg, statusCode: status, details: body);
      }
      if (status >= 500) {
        throw ServerException(msg, statusCode: status, details: body);
      }
      throw ApiException(msg, statusCode: status, details: body);
    }

    // Si llegamos aquí, es un error no cubierto por las validaciones anteriores.
    throw UnknownApiException('Error inesperado: ${response.body}', statusCode: status, details: body);
  }
}