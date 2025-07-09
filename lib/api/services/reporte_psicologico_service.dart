import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:smged/api/models/reporte_psicologico.dart';
import 'package:smged/config.dart';
import 'package:smged/api/exceptions/api_exception.dart'; // Importa tus excepciones API
import 'package:smged/api/services/auth_service.dart'; // Importa el AuthService

class ReportePsicologicoService {
  final String _baseUrl = '${Config.apiUrl}/reporte-psicologico';
  final AuthService _authService = AuthService(); // Instancia de AuthService

  // Función auxiliar para obtener los encabezados con el token
  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getAuthToken();
    if (token == null || token.isEmpty) {
      throw UnauthorizedException('No hay token de autenticación disponible. Inicia sesión nuevamente.', statusCode: 401);
    }
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token', // ¡Aquí se añade el token!
    };
  }

  Future<List<ReportePsicologico>> obtenerReportesPsicologicos() async {
    try {
      final headers = await _getHeaders(); // Obtener encabezados con el token
      final response = await http.get(
        Uri.parse(_baseUrl),
        headers: headers, // Usar los encabezados con el token
      );
      _handleError(response); // Manejo de errores centralizado
      List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => ReportePsicologico.fromJson(json)).toList();
    } catch (e) {
      if (e is ApiException) rethrow;
      throw UnknownApiException('Fallo al obtener reportes psicológicos: $e');
    }
  }

  Future<ReportePsicologico> obtenerReportePsicologicoPorId(int id) async {
    try {
      final headers = await _getHeaders(); // Obtener encabezados con el token
      final response = await http.get(
        Uri.parse('$_baseUrl/$id'),
        headers: headers, // Usar los encabezados con el token
      );
      _handleError(response); // Manejo de errores centralizado
      return ReportePsicologico.fromJson(json.decode(response.body));
    } catch (e) {
      if (e is ApiException) rethrow;
      throw UnknownApiException('Fallo al obtener reporte psicológico: $e');
    }
  }

  /// Nueva función: obtener reportes psicológicos por ID de estudiante
  Future<List<ReportePsicologico>> obtenerReportesPorEstudiante(int idEstudiante) async {
    try {
      final headers = await _getHeaders(); // Obtener encabezados con el token
      final response = await http.get(
        Uri.parse('$_baseUrl/estudiante/$idEstudiante'),
        headers: headers, // Usar los encabezados con el token
      );
      if (response.statusCode == 404) {
        return []; // No se encontraron reportes para este estudiante
      }
      _handleError(response); // Manejo de errores centralizado
      List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => ReportePsicologico.fromJson({
            ...json,
            // Compatibilidad para nombres de campos según el JSON de la API
            'nombre_estudiante': json['nombres'],
            'apellido_estudiante': json['apellidos'],
          })).toList();
    } catch (e) {
      if (e is ApiException) rethrow;
      throw UnknownApiException('Fallo al obtener reportes psicológicos por estudiante: $e');
    }
  }

  Future<int> crearReportePsicologico(ReportePsicologico reporte) async {
    try {
      final headers = await _getHeaders(); // Obtener encabezados con el token
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: headers, // Usar los encabezados con el token
        body: json.encode(reporte.toCreateJson()),
      );
      _handleError(response, expectCreated: true); // Manejo de errores centralizado
      final data = json.decode(response.body);
      return data['id_psicologico'];
    } catch (e) {
      if (e is ApiException) rethrow;
      throw UnknownApiException('Fallo al crear reporte psicológico: $e');
    }
  }

  Future<void> editarReportePsicologico(int id, ReportePsicologico reporte) async {
    try {
      final headers = await _getHeaders(); // Obtener encabezados con el token
      final response = await http.put(
        Uri.parse('$_baseUrl/$id'),
        headers: headers, // Usar los encabezados con el token
        body: json.encode(reporte.toCreateJson()),
      );
      _handleError(response); // Manejo de errores centralizado
    } catch (e) {
      if (e is ApiException) rethrow;
      throw UnknownApiException('Fallo al editar reporte psicológico: $e');
    }
  }

  Future<void> eliminarReportePsicologico(int id) async {
    try {
      final headers = await _getHeaders(); // Obtener encabezados con el token
      final response = await http.delete(
        Uri.parse('$_baseUrl/$id'),
        headers: headers, // Usar los encabezados con el token
      );
      _handleError(response); // Manejo de errores centralizado
    } catch (e) {
      if (e is ApiException) rethrow;
      throw UnknownApiException('Fallo al eliminar reporte psicológico: $e');
    }
  }

  // Manejo centralizado de errores según la estructura de la API y api_exception.dart
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