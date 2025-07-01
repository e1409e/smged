// lib/api/services/citas_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:smged/config.dart';
import 'package:smged/api/models/cita.dart';
import 'package:smged/api/exceptions/api_exception.dart';

class CitasService {
  final String _baseUrl = '${Config.apiUrl}/citas';

  Future<List<Cita>> obtenerCitas() async {
    final uri = Uri.parse(_baseUrl);
    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        List<dynamic> jsonList = json.decode(utf8.decode(response.bodyBytes));
        return jsonList.map((json) => Cita.fromJson(json)).toList();
      } else {
        _handleError(response);
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw NetworkException('No se pudo conectar con el servidor de citas.');
    }
    throw UnknownApiException('Error desconocido al obtener citas');
  }

  Future<Cita> obtenerCitaPorId(int idCita) async {
    final uri = Uri.parse('$_baseUrl/$idCita');
    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        return Cita.fromJson(json.decode(utf8.decode(response.bodyBytes)));
      } else {
        _handleError(response);
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw NetworkException('No se pudo conectar con el servidor de citas.');
    }
    throw UnknownApiException('Error desconocido al obtener la cita');
  }

  Future<Cita> crearCita(Cita cita) async {
    final uri = Uri.parse(_baseUrl);
    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(cita.toJson()),
      );
      if (response.statusCode == 201) {
        final Map<String, dynamic> responseBody = json.decode(utf8.decode(response.bodyBytes));
        if (responseBody.containsKey('id_citas')) {
          return cita.copyWith(id_citas: responseBody['id_citas'] as int);
        } else {
          throw UnknownApiException('La API no devolvió el id_citas al crear la cita.');
        }
      } else {
        _handleError(response);
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw NetworkException('No se pudo conectar con el servidor de citas.');
    }
    throw UnknownApiException('Error desconocido al crear la cita');
  }

  Future<Cita> actualizarCita(Cita cita) async {
    if (cita.id_citas == null) {
      throw ApiException('El ID de la cita es requerido para la actualización.');
    }
    final uri = Uri.parse('$_baseUrl/${cita.id_citas}');
    try {
      final response = await http.put(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(cita.toJson()),
      );
      if (response.statusCode == 200) {
        // La API puede devolver "true" o un objeto JSON
        final String responseBodyString = utf8.decode(response.bodyBytes).trim();
        if (responseBodyString.toLowerCase() == 'true') {
          return cita;
        } else if (responseBodyString.toLowerCase() == 'false') {
          throw ApiException('No se pudo actualizar la cita.');
        } else {
          try {
            final Map<String, dynamic> responseBody = json.decode(responseBodyString);
            if (responseBody.containsKey('message') && responseBody['message'].contains('actualizada')) {
              return cita;
            }
            throw UnknownApiException('Respuesta inesperada al actualizar la cita: $responseBodyString');
          } on FormatException {
            throw UnknownApiException('Respuesta inesperada al actualizar la cita: $responseBodyString');
          }
        }
      } else {
        _handleError(response);
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw NetworkException('No se pudo conectar con el servidor de citas.');
    }
    throw UnknownApiException('Error desconocido al actualizar la cita');
  }

  Future<void> eliminarCita(int idCita) async {
    final uri = Uri.parse('$_baseUrl/$idCita');
    try {
      final response = await http.delete(uri);
      if (response.statusCode == 200 || response.statusCode == 204) {
        return;
      } else {
        _handleError(response);
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw NetworkException('No se pudo conectar con el servidor de citas.');
    }
    throw UnknownApiException('Error desconocido al eliminar la cita');
  }

  Future<bool> marcarCitaComoRealizada(int idCita) async {
    final uri = Uri.parse('$_baseUrl/marcar-realizada/$idCita');
    try {
      final response = await http.patch(uri);
      if (response.statusCode == 200) {
        final String responseBodyString = utf8.decode(response.bodyBytes).trim();
        if (responseBodyString.toLowerCase() == 'true') {
          return true;
        } else if (responseBodyString.toLowerCase() == 'false') {
          return false;
        } else {
          try {
            final Map<String, dynamic> responseBody = json.decode(responseBodyString);
            return responseBody['success'] ?? false;
          } on FormatException {
            throw UnknownApiException('Respuesta inesperada al marcar como realizada: "$responseBodyString"');
          }
        }
      } else {
        _handleError(response);
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw NetworkException('No se pudo conectar con el servidor de citas.');
    }
    throw UnknownApiException('Error desconocido al marcar cita como realizada');
  }

  /// Manejo centralizado de errores según la estructura de la API y api_exception.dart
  void _handleError(http.Response response) {
    final status = response.statusCode;
    dynamic body;
    try {
      body = json.decode(utf8.decode(response.bodyBytes));
    } catch (_) {
      throw UnknownApiException('Respuesta inesperada del servidor', statusCode: status, details: response.body);
    }

    // Validaciones de express-validator (campo 'errors')
    if (body is Map && body.containsKey('errors')) {
      final errorsList = body['errors'] as List;
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