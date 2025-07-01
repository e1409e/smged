import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:smged/api/models/incidencia.dart';
import 'package:smged/config.dart';
import 'package:smged/api/exceptions/api_exception.dart';

class IncidenciasService {
  final String _baseUrl = '${Config.apiUrl}/incidencias';

  Future<List<Incidencia>> obtenerIncidencias() async {
    try {
      final response = await http.get(Uri.parse(_baseUrl));
      if (response.statusCode == 200) {
        List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => Incidencia.fromJson(json)).toList();
      } else {
        _handleError(response);
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw NetworkException('No se pudo conectar con el servidor de incidencias.');
    }
    throw UnknownApiException('Error desconocido al obtener incidencias');
  }

  Future<Incidencia> obtenerIncidenciaPorId(int id) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/$id'));
      if (response.statusCode == 200) {
        return Incidencia.fromJson(json.decode(response.body));
      } else {
        _handleError(response);
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw NetworkException('No se pudo conectar con el servidor de incidencias.');
    }
    throw UnknownApiException('Error desconocido al obtener la incidencia');
  }

  Future<List<Incidencia>> obtenerIncidenciasPorEstudiante(int idEstudiante) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/estudiante/$idEstudiante'));
      if (response.statusCode == 200) {
        List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => Incidencia.fromJson(json)).toList();
      } else if (response.statusCode == 404) {
        return [];
      } else {
        _handleError(response);
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw NetworkException('No se pudo conectar con el servidor de incidencias.');
    }
    throw UnknownApiException('Error desconocido al obtener incidencias del estudiante');
  }

  Future<int> crearIncidencia(Incidencia incidencia) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(incidencia.toJson()),
      );
      if (response.statusCode == 201) {
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
      } else {
        _handleError(response);
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw NetworkException('No se pudo conectar con el servidor de incidencias.');
    }
    throw UnknownApiException('Error desconocido al crear incidencia');
  }

  Future<void> editarIncidencia(int id, Incidencia incidencia) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(incidencia.toJson()),
      );
      if (response.statusCode == 200) {
        return;
      } else {
        _handleError(response);
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw NetworkException('No se pudo conectar con el servidor de incidencias.');
    }
    throw UnknownApiException('Error desconocido al editar incidencia');
  }

  Future<void> eliminarIncidencia(int id) async {
    try {
      final response = await http.delete(Uri.parse('$_baseUrl/$id'));
      if (response.statusCode == 200) {
        return;
      } else {
        _handleError(response);
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw NetworkException('No se pudo conectar con el servidor de incidencias.');
    }
    throw UnknownApiException('Error desconocido al eliminar incidencia');
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