import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:smged/api/models/facultad.dart';
import 'package:smged/config.dart';
import 'package:smged/api/exceptions/api_exception.dart';
import 'package:smged/api/services/auth_service.dart'; // Importa el AuthService

class FacultadesService {
  final String _baseUrl = '${Config.apiUrl}/facultades';
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

  Future<List<Facultad>> obtenerFacultades() async {
    try {
      final headers = await _getHeaders(includeContentType: false); // GET no necesita Content-Type
      final response = await http.get(
        Uri.parse(_baseUrl),
        headers: headers, // Usar los encabezados con el token
      );
      _handleError(response); // Manejo de errores centralizado
      List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => Facultad.fromJson(json)).toList();
    } catch (e) {
      if (e is ApiException) rethrow;
      throw UnknownApiException('Error desconocido al obtener facultades: $e');
    }
  }

  Future<Facultad> obtenerFacultadPorId(int id) async {
    try {
      final headers = await _getHeaders(includeContentType: false); // GET no necesita Content-Type
      final response = await http.get(
        Uri.parse('$_baseUrl/$id'),
        headers: headers, // Usar los encabezados con el token
      );
      _handleError(response); // Manejo de errores centralizado
      return Facultad.fromJson(json.decode(response.body));
    } catch (e) {
      if (e is ApiException) rethrow;
      throw UnknownApiException('Error desconocido al obtener la facultad: $e');
    }
  }

  Future<void> crearFacultad(String facultad, String siglas) async {
    try {
      final headers = await _getHeaders(); // POST sí necesita Content-Type
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: headers, // Usar los encabezados con el token
        body: json.encode({'facultad': facultad, 'siglas': siglas}),
      );
      _handleError(response, expectCreated: true); // Manejo de errores, esperando 201
    } catch (e) {
      if (e is ApiException) rethrow;
      throw UnknownApiException('Error desconocido al crear facultad: $e');
    }
  }

  Future<void> actualizarFacultad(int id, String facultad, String siglas) async {
    try {
      final headers = await _getHeaders(); // PUT sí necesita Content-Type
      final response = await http.put(
        Uri.parse('$_baseUrl/$id'),
        headers: headers, // Usar los encabezados con el token
        body: json.encode({'facultad': facultad, 'siglas': siglas}),
      );
      _handleError(response); // Manejo de errores centralizado
    } catch (e) {
      if (e is ApiException) rethrow;
      throw UnknownApiException('Error desconocido al actualizar facultad: $e');
    }
  }

  Future<void> eliminarFacultad(int id) async {
    try {
      final headers = await _getHeaders(includeContentType: false); // DELETE no necesita Content-Type
      final response = await http.delete(
        Uri.parse('$_baseUrl/$id'),
        headers: headers, // Usar los encabezados con el token
      );
      _handleError(response); // Manejo de errores centralizado
    } catch (e) {
      if (e is ApiException) rethrow;
      throw UnknownApiException('Error desconocido al eliminar facultad: $e');
    }
  }

  Future<List<Facultad>> obtenerFacultadesConCarreras() async {
    try {
      final headers = await _getHeaders(includeContentType: false); // GET no necesita Content-Type
      final url = Uri.parse('${Config.apiUrl}/facultades/carreras');
      final response = await http.get(
        url,
        headers: headers, // Usar los encabezados con el token
      );
      _handleError(response); // Manejo de errores centralizado

      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Facultad.fromJson(json)).toList();
    } catch (e) {
      if (e is ApiException) rethrow;
      throw UnknownApiException('Error al obtener facultades con carreras: $e');
    }
  }

  /// Manejo centralizado de errores según la estructura de la API y api_exception.dart
  void _handleError(http.Response response, {bool expectCreated = false}) {
    final status = response.statusCode;

    // Si el estado es 200-299 (o 201 si se espera creación), no hay error.
    // También incluye el 204 No Content para eliminaciones exitosas.
    if ((expectCreated && status == 201) || (!expectCreated && (status >= 200 && status < 300 || status == 204))) {
      return;
    }

    dynamic body;
    try {
      body = json.decode(response.body);
    } catch (_) {
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