// lib/api/services/citas_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:smged/config.dart';
import 'package:smged/api/models/cita.dart';
import 'package:smged/api/exceptions/api_exception.dart';
import 'package:smged/api/services/auth_service.dart'; // Importa el AuthService
import 'package:flutter/foundation.dart' show debugPrint; // Para debugPrint

class CitasService {
  final String _baseUrl = '${Config.apiUrl}/citas';
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

  Future<List<Cita>> obtenerCitas() async {
    debugPrint('[CitasService] Solicitando todas las citas a: $_baseUrl');
    try {
      final headers = await _getHeaders(includeContentType: false); // GET no necesita Content-Type
      final response = await http.get(
        Uri.parse(_baseUrl),
        headers: headers, // Usar los encabezados con el token
      );
      _handleResponse(response); // _handleError renombra a _handleResponse para consistencia
      List<dynamic> jsonList = json.decode(utf8.decode(response.bodyBytes));
      return jsonList.map((json) => Cita.fromJson(json)).toList();
    } on http.ClientException catch (e) {
      throw NetworkException('Verifica tu conexión a internet o la URL de la API. Detalles: ${e.message}');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw UnknownApiException('Ha ocurrido un error inesperado al obtener citas: ${e.toString()}');
    }
  }

  Future<Cita> obtenerCitaPorId(int idCita) async {
    final uri = Uri.parse('$_baseUrl/$idCita');
    debugPrint('[CitasService] Solicitando cita con ID $idCita a: $uri');
    try {
      final headers = await _getHeaders(includeContentType: false); // GET no necesita Content-Type
      final response = await http.get(
        uri,
        headers: headers, // Usar los encabezados con el token
      );
      _handleResponse(response);
      return Cita.fromJson(json.decode(utf8.decode(response.bodyBytes)));
    } on http.ClientException catch (e) {
      throw NetworkException('Verifica tu conexión a internet o la URL de la API. Detalles: ${e.message}');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw UnknownApiException('Ha ocurrido un error inesperado al obtener la cita por ID: ${e.toString()}');
    }
  }

  Future<Cita> crearCita(Cita cita) async {
    final uri = Uri.parse(_baseUrl);
    debugPrint('[CitasService] Intentando POST a: $uri');
    final String requestBody = json.encode(cita.toJson());
    debugPrint('[CitasService] Cuerpo de la petición: $requestBody');

    try {
      final headers = await _getHeaders(); // POST sí necesita Content-Type
      final response = await http.post(
        uri,
        headers: headers, // Usar los encabezados con el token
        body: requestBody,
      );

      debugPrint('[CitasService] Respuesta de la API (Status: ${response.statusCode}): ${utf8.decode(response.bodyBytes)}');

      _handleResponse(response, expectCreated: true); // Esperamos 201 Created

      final Map<String, dynamic> responseBody = json.decode(utf8.decode(response.bodyBytes));
      if (responseBody.containsKey('id_citas')) {
        return cita.copyWith(id_citas: responseBody['id_citas'] as int);
      } else {
        throw UnknownApiException('La API no devolvió el id_citas al crear la cita.', statusCode: response.statusCode, details: responseBody);
      }
    } on http.ClientException catch (e) {
      throw NetworkException('Verifica tu conexión a internet o la URL de la API. Detalles: ${e.message}');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw UnknownApiException('Ha ocurrido un error inesperado al crear la cita: ${e.toString()}');
    }
  }

  Future<Cita> actualizarCita(Cita cita) async {
    if (cita.id_citas == null) {
      throw ApiException('El ID de la cita es requerido para la actualización.', statusCode: 400);
    }
    final uri = Uri.parse('$_baseUrl/${cita.id_citas}');
    debugPrint('[CitasService] Enviando PUT a: $uri');
    final String requestBody = json.encode(cita.toJson());
    debugPrint('[CitasService] Cuerpo de la solicitud: $requestBody');

    try {
      final headers = await _getHeaders(); // PUT sí necesita Content-Type
      final response = await http.put(
        uri,
        headers: headers, // Usar los encabezados con el token
        body: requestBody,
      );

      debugPrint('[CitasService] Código de estado de la API al actualizar: ${response.statusCode}');
      debugPrint('[CitasService] Cuerpo de la respuesta de la API al actualizar: ${utf8.decode(response.bodyBytes)}');

      _handleResponse(response); // Esperamos 200 OK

      // La API puede devolver "true" o un objeto JSON o un mensaje
      final String responseBodyString = utf8.decode(response.bodyBytes).trim();
      if (responseBodyString.toLowerCase() == 'true') {
        return cita; // Retorna el objeto original si la API solo confirma con 'true'
      } else if (responseBodyString.toLowerCase() == 'false') {
        throw ApiException('No se pudo actualizar la cita. La API respondió "false".', statusCode: response.statusCode, details: responseBodyString);
      } else {
        try {
          // Intenta decodificar el cuerpo de la respuesta como JSON
          final Map<String, dynamic> responseBody = json.decode(responseBodyString);
          if (responseBody.containsKey('message') && responseBody['message'].toString().toLowerCase().contains('actualizada')) {
            // Si hay un mensaje de éxito, retornamos el objeto original.
            return cita;
          }
          // Si la API devuelve el objeto actualizado, deberías parsearlo aquí.
          // Por ejemplo: return Cita.fromJson(responseBody);
          // Si no es un objeto Cita completo, o solo un mensaje, retorna la cita original.
          debugPrint('[CitasService] Respuesta JSON inesperada en actualización, devolviendo cita original: $responseBody');
          return cita; // Asumimos que la cita original es la actualizada si la respuesta es ambigua pero 200 OK
        } on FormatException {
          throw UnknownApiException('Respuesta inesperada al actualizar la cita (no JSON): "$responseBodyString"', statusCode: response.statusCode, details: responseBodyString);
        }
      }
    } on http.ClientException catch (e) {
      throw NetworkException('Verifica tu conexión a internet o la URL de la API. Detalles: ${e.message}');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw UnknownApiException('Ha ocurrido un error inesperado al actualizar la cita: ${e.toString()}');
    }
  }

  Future<void> eliminarCita(int idCita) async {
    final uri = Uri.parse('$_baseUrl/$idCita');
    debugPrint('[CitasService] Intentando DELETE para cita con ID $idCita a: $uri');
    try {
      final headers = await _getHeaders(includeContentType: false); // DELETE no necesita Content-Type
      final response = await http.delete(
        uri,
        headers: headers, // Usar los encabezados con el token
      );

      debugPrint('[CitasService] Código de estado de la API al eliminar: ${response.statusCode}');
      debugPrint('[CitasService] Cuerpo de la respuesta de la API al eliminar: ${utf8.decode(response.bodyBytes)}');

      _handleResponse(response); // Esperamos 200 OK o 204 No Content. Si no, lanza excepción.
      return; // Si no lanza excepción, la eliminación fue exitosa
    } on http.ClientException catch (e) {
      throw NetworkException('Verifica tu conexión a internet o la URL de la API. Detalles: ${e.message}');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw UnknownApiException('Ha ocurrido un error inesperado al eliminar la cita: ${e.toString()}');
    }
  }

  Future<bool> marcarCitaComoRealizada(int idCita) async {
    final uri = Uri.parse('$_baseUrl/marcar-realizada/$idCita');
    debugPrint('[CitasService] Intentando PATCH para marcar cita $idCita como realizada a: $uri');
    try {
      final headers = await _getHeaders(includeContentType: false); // PATCH puede que no necesite Content-Type si solo cambia un estado
      final response = await http.patch(
        uri,
        headers: headers, // Usar los encabezados con el token
      );

      debugPrint('[CitasService] Código de estado de la API al marcar como realizada: ${response.statusCode}');
      debugPrint('[CitasService] Cuerpo de la respuesta de la API al marcar como realizada: ${utf8.decode(response.bodyBytes)}');

      _handleResponse(response); // Esperamos 200 OK

      final String responseBodyString = utf8.decode(response.bodyBytes).trim();
      if (responseBodyString.toLowerCase() == 'true') {
        return true;
      } else if (responseBodyString.toLowerCase() == 'false') {
        return false; // La API devolvió 'false' pero un 200 OK, lo cual es manejable aquí.
      } else {
        try {
          final Map<String, dynamic> responseBody = json.decode(responseBodyString);
          return responseBody['success'] ?? false;
        } on FormatException {
          throw UnknownApiException('Respuesta inesperada al marcar como realizada (no JSON): "$responseBodyString"', statusCode: response.statusCode, details: responseBodyString);
        }
      }
    } on http.ClientException catch (e) {
      throw NetworkException('Verifica tu conexión a internet o la URL de la API. Detalles: ${e.message}');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw UnknownApiException('Ha ocurrido un error inesperado al marcar cita como realizada: ${e.toString()}');
    }
  }

  /// Manejo centralizado de respuestas HTTP (éxito y error)
  void _handleResponse(http.Response response, {bool expectCreated = false}) {
    final status = response.statusCode;
    final serverMessage = utf8.decode(response.bodyBytes);
    debugPrint('[CitasService] _handleResponse - Raw body: $serverMessage (Status: $status)');

    // Manejo de códigos de éxito (200-299, 201 para creación, 204 para no-content)
    if ((expectCreated && status == 201) || (!expectCreated && (status >= 200 && status < 300 || status == 204))) {
      return; // La respuesta es exitosa según lo esperado.
    }

    // Si no fue un código de éxito, intentamos parsear el error.
    dynamic errorBody;
    try {
      errorBody = json.decode(serverMessage);
    } catch (_) {
      // Si no se puede decodificar, es una respuesta inesperada no-JSON o un error simple.
      throw UnknownApiException('Respuesta inesperada del servidor: $serverMessage', statusCode: status, details: serverMessage);
    }

    // Manejo específico para 401 Unauthorized (token inválido/expirado)
    if (status == 401) {
      throw UnauthorizedException(errorBody['message'] ?? 'Token inválido o expirado. Vuelve a iniciar sesión.', statusCode: status, details: errorBody);
    }

    // Validaciones de express-validator (campo 'errors' o 'errores')
    if (errorBody is Map && (errorBody.containsKey('errors') || errorBody.containsKey('errores'))) {
      final errorsList = errorBody['errors'] ?? errorBody['errores'];
      if (errorsList is List) {
        final Map<String, List<String>> validationErrors = {};
        for (var errorItem in errorsList) {
          if (errorItem is Map && (errorItem.containsKey('param') || errorItem.containsKey('path')) && errorItem.containsKey('msg')) {
            final field = errorItem['param'] ?? errorItem['path'] ?? 'general';
            final msg = errorItem['msg'] ?? 'Error de validación';
            validationErrors.putIfAbsent(field, () => []).add(msg);
          } else {
            validationErrors.putIfAbsent('general', () => []).add('Error de formato en la validación.');
          }
        }
        throw ValidationException('Verifica los campos ingresados.', validationErrors, statusCode: status, details: errorBody);
      }
    }

    // Error general (campo 'error' o 'message')
    if (errorBody is Map && (errorBody.containsKey('error') || errorBody.containsKey('message'))) {
      final msg = (errorBody['error'] ?? errorBody['message']).toString();
      if (status == 404) {
        throw NotFoundException(msg, statusCode: status, details: errorBody);
      }
      if (status >= 500) {
        throw ServerException(msg, statusCode: status, details: errorBody);
      }
      throw ApiException(msg, statusCode: status, details: errorBody);
    }

    // Cualquier otro caso de error no especificado pero con JSON válido
    throw UnknownApiException('Error inesperado de la API: $serverMessage', statusCode: status, details: errorBody);
  }
}