// lib/api/services/historial_medico_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:smged/api/models/historial_medico.dart';
import 'package:smged/config.dart';
import 'package:smged/api/exceptions/api_exception.dart';
import 'package:smged/api/services/auth_service.dart'; // Importa el AuthService

class HistorialMedicoService {
  final String _baseUrl = '${Config.apiUrl}/historial_medico';
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

  /// Obtiene todos los historiales médicos.
  Future<List<HistorialMedico>> obtenerTodosLosHistorialesMedicos() async {
    try {
      final headers = await _getHeaders(); // Obtener encabezados con el token
      final response = await http.get(
        Uri.parse(_baseUrl),
        headers: headers, // Usar los encabezados con el token
      );
      _handleError(response); // Manejo de errores centralizado
      final List jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => HistorialMedico.fromJson(data)).toList();
    } catch (e) {
      if (e is ApiException) rethrow;
      throw UnknownApiException('Error desconocido al obtener historiales médicos: $e');
    }
  }

  /// Obtiene un historial médico por el ID del estudiante.
  Future<HistorialMedico?> obtenerHistorialPorEstudiante(int idEstudiante) async {
    try {
      final headers = await _getHeaders(); // Obtener encabezados con el token
      final response = await http.get(
        Uri.parse('$_baseUrl/estudiante/$idEstudiante'),
        headers: headers, // Usar los encabezados con el token
      );
      if (response.statusCode == 404) {
        return null; // Mantener la lógica de retorno nulo para 404 si es un caso válido
      }
      _handleError(response); // Manejo de errores centralizado
      final data = json.decode(response.body);
      return HistorialMedico.fromJson(data);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw UnknownApiException('Error desconocido al obtener historial médico del estudiante: $e');
    }
  }

  /// Obtiene un historial médico por su ID.
  Future<HistorialMedico> obtenerHistorialMedicoPorId(int id) async {
    try {
      final headers = await _getHeaders(); // Obtener encabezados con el token
      final response = await http.get(
        Uri.parse('$_baseUrl/$id'),
        headers: headers, // Usar los encabezados con el token
      );
      _handleError(response); // Manejo de errores centralizado
      return HistorialMedico.fromJson(json.decode(response.body));
    } catch (e) {
      if (e is ApiException) rethrow;
      throw UnknownApiException('Error desconocido al obtener historial médico por ID: $e');
    }
  }

  /// Crea un nuevo historial médico.
  Future<HistorialMedico> crearHistorialMedico(HistorialMedico historial) async {
    try {
      final headers = await _getHeaders(); // Obtener encabezados con el token
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: headers, // Usar los encabezados con el token
        body: json.encode(historial.toCreateJson()),
      );
      _handleError(response, expectCreated: true); // Manejo de errores, esperando 201
      return HistorialMedico.fromJson(json.decode(response.body));
    } catch (e) {
      if (e is ApiException) rethrow;
      throw UnknownApiException('Error desconocido al crear historial médico: $e');
    }
  }

  /// Edita un historial médico existente.
  Future<HistorialMedico> editarHistorialMedico(int id, HistorialMedico historial) async {
    try {
      final headers = await _getHeaders(); // Obtener encabezados con el token
      final response = await http.put(
        Uri.parse('$_baseUrl/$id'),
        headers: headers, // Usar los encabezados con el token
        body: json.encode(historial.toCreateJson()),
      );
      _handleError(response); // Manejo de errores centralizado
      return HistorialMedico.fromJson(json.decode(response.body));
    } catch (e) {
      if (e is ApiException) rethrow;
      throw UnknownApiException('Error desconocido al editar historial médico: $e');
    }
  }

  /// Elimina un historial médico.
  Future<void> eliminarHistorialMedico(int id) async {
    try {
      final headers = await _getHeaders(); // Obtener encabezados con el token
      final response = await http.delete(
        Uri.parse('$_baseUrl/$id'),
        headers: headers, // Usar los encabezados con el token
      );
      _handleError(response); // Manejo de errores centralizado, 200 o 204 se manejan dentro de _handleError
      return;
    } catch (e) {
      if (e is ApiException) rethrow;
      throw UnknownApiException('Error desconocido al eliminar historial médico: $e');
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