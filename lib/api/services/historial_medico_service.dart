// lib/api/services/historial_medico_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:smged/api/models/historial_medico.dart';
import 'package:smged/config.dart';
import 'package:smged/api/exceptions/api_exception.dart';

class HistorialMedicoService {
  final String _baseUrl = '${Config.apiUrl}/historial_medico';

  /// Obtiene todos los historiales médicos.
  Future<List<HistorialMedico>> obtenerTodosLosHistorialesMedicos() async {
    try {
      final response = await http.get(Uri.parse(_baseUrl));
      if (response.statusCode == 200) {
        final List jsonResponse = json.decode(response.body);
        return jsonResponse.map((data) => HistorialMedico.fromJson(data)).toList();
      } else {
        _handleError(response);
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw NetworkException('No se pudo conectar con el servidor de historiales médicos.');
    }
    throw UnknownApiException('Error desconocido al obtener historiales médicos');
  }

  /// Obtiene un historial médico por el ID del estudiante.
  Future<HistorialMedico?> obtenerHistorialPorEstudiante(int idEstudiante) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/estudiante/$idEstudiante'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return HistorialMedico.fromJson(data);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        _handleError(response);
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw NetworkException('No se pudo conectar con el servidor de historiales médicos.');
    }
    throw UnknownApiException('Error desconocido al obtener historial médico del estudiante');
  }

  /// Obtiene un historial médico por su ID.
  Future<HistorialMedico> obtenerHistorialMedicoPorId(int id) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/$id'));
      if (response.statusCode == 200) {
        return HistorialMedico.fromJson(json.decode(response.body));
      } else {
        _handleError(response);
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw NetworkException('No se pudo conectar con el servidor de historiales médicos.');
    }
    throw UnknownApiException('Error desconocido al obtener historial médico por ID');
  }

  /// Crea un nuevo historial médico.
  Future<HistorialMedico> crearHistorialMedico(HistorialMedico historial) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(historial.toCreateJson()),
      );
      if (response.statusCode == 201) {
        return HistorialMedico.fromJson(json.decode(response.body));
      } else {
        _handleError(response);
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw NetworkException('No se pudo conectar con el servidor de historiales médicos.');
    }
    throw UnknownApiException('Error desconocido al crear historial médico');
  }

  /// Edita un historial médico existente.
  Future<HistorialMedico> editarHistorialMedico(int id, HistorialMedico historial) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(historial.toCreateJson()),
      );
      if (response.statusCode == 200) {
        return HistorialMedico.fromJson(json.decode(response.body));
      } else {
        _handleError(response);
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw NetworkException('No se pudo conectar con el servidor de historiales médicos.');
    }
    throw UnknownApiException('Error desconocido al editar historial médico');
  }

  /// Elimina un historial médico.
  Future<void> eliminarHistorialMedico(int id) async {
    try {
      final response = await http.delete(Uri.parse('$_baseUrl/$id'));
      if (response.statusCode == 200 || response.statusCode == 204) {
        return;
      } else {
        _handleError(response);
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw NetworkException('No se pudo conectar con el servidor de historiales médicos.');
    }
    throw UnknownApiException('Error desconocido al eliminar historial médico');
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