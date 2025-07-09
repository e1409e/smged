// lib/api/services/carreras_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show debugPrint; // Para debugPrint

import 'package:smged/api/models/carrera.dart';
import 'package:smged/config.dart';
import 'package:smged/api/exceptions/api_exception.dart';
import 'package:smged/api/services/auth_service.dart'; // Importa el AuthService

class CarrerasService {
  final String _baseUrl = '${Config.apiUrl}/carreras';
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

  Future<List<Carrera>> obtenerCarreras() async {
    debugPrint('[CarrerasService] Solicitando todas las carreras a: $_baseUrl');
    try {
      final headers = await _getHeaders(includeContentType: false); // GET no necesita Content-Type
      final response = await http.get(
        Uri.parse(_baseUrl),
        headers: headers, // Usar los encabezados con el token
      );
      _handleResponse(response); // Llama a la función centralizada de manejo
      List<dynamic> jsonList = json.decode(utf8.decode(response.bodyBytes));
      return jsonList.map((json) => Carrera.fromJson(json)).toList();
    } on http.ClientException catch (e) {
      throw NetworkException('Verifica tu conexión a internet o la URL de la API. Detalles: ${e.message}');
    } catch (e) {
      if (e is ApiException) rethrow; // Relanza las excepciones de la API ya manejadas
      throw UnknownApiException('Ha ocurrido un error inesperado al obtener carreras: ${e.toString()}');
    }
  }

  Future<Carrera> obtenerCarreraPorId(int id) async {
    debugPrint('[CarrerasService] Solicitando carrera con ID $id a: $_baseUrl/$id');
    try {
      final headers = await _getHeaders(includeContentType: false); // GET no necesita Content-Type
      final response = await http.get(
        Uri.parse('$_baseUrl/$id'),
        headers: headers, // Usar los encabezados con el token
      );
      _handleResponse(response); // Llama a la función centralizada de manejo
      return Carrera.fromJson(json.decode(utf8.decode(response.bodyBytes)));
    } on http.ClientException catch (e) {
      throw NetworkException('Verifica tu conexión a internet o la URL de la API. Detalles: ${e.message}');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw UnknownApiException('Ha ocurrido un error inesperado al obtener carrera por ID: ${e.toString()}');
    }
  }

  Future<void> crearCarrera(String carrera, int idFacultad) async {
    final url = Uri.parse(_baseUrl);
    debugPrint('[CarrerasService] Intentando POST a: $url');
    final String requestBody = json.encode({'carrera': carrera, 'id_facultad': idFacultad});
    debugPrint('[CarrerasService] Cuerpo de la petición: $requestBody');

    try {
      final headers = await _getHeaders(); // POST sí necesita Content-Type
      final response = await http.post(
        url,
        headers: headers, // Usar los encabezados con el token
        body: requestBody,
      );

      debugPrint('[CarrerasService] Respuesta de la API (Status: ${response.statusCode}): ${utf8.decode(response.bodyBytes)}');
      _handleResponse(response, expectCreated: true); // Esperamos 201 Created
      // Si la API devuelve el objeto creado, puedes parsearlo aquí:
      // return Carrera.fromJson(json.decode(utf8.decode(response.bodyBytes)));
    } on http.ClientException catch (e) {
      throw NetworkException('Verifica tu conexión a internet o la URL de la API. Detalles: ${e.message}');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw UnknownApiException('Ha ocurrido un error inesperado al crear carrera: ${e.toString()}');
    }
  }

  Future<void> actualizarCarrera(int id, String carrera, int idFacultad) async {
    final url = Uri.parse('$_baseUrl/$id');
    debugPrint('[CarrerasService] Enviando PUT a: $url');
    final String requestBody = json.encode({'carrera': carrera, 'id_facultad': idFacultad});
    debugPrint('[CarrerasService] Cuerpo de la solicitud: $requestBody');

    try {
      final headers = await _getHeaders(); // PUT sí necesita Content-Type
      final response = await http.put(
        url,
        headers: headers, // Usar los encabezados con el token
        body: requestBody,
      );

      debugPrint('[CarrerasService] Código de estado de la API al actualizar: ${response.statusCode}');
      debugPrint('[CarrerasService] Cuerpo de la respuesta de la API al actualizar: ${utf8.decode(response.bodyBytes)}');

      _handleResponse(response); // Esperamos 200 OK
      // Si la API devuelve el objeto actualizado, puedes parsearlo aquí:
      // return Carrera.fromJson(json.decode(utf8.decode(response.bodyBytes)));
    } on http.ClientException catch (e) {
      throw NetworkException('Verifica tu conexión a internet o la URL de la API. Detalles: ${e.message}');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw UnknownApiException('Ha ocurrido un error inesperado al actualizar carrera: ${e.toString()}');
    }
  }

  Future<void> eliminarCarrera(int id) async {
    final url = Uri.parse('$_baseUrl/$id');
    debugPrint('[CarrerasService] Intentando DELETE para carrera con ID $id a: $url');
    try {
      final headers = await _getHeaders(includeContentType: false); // DELETE no necesita Content-Type
      final response = await http.delete(
        url,
        headers: headers, // Usar los encabezados con el token
      );

      debugPrint('[CarrerasService] Código de estado de la API al eliminar: ${response.statusCode}');
      debugPrint('[CarrerasService] Cuerpo de la respuesta de la API al eliminar: ${utf8.decode(response.bodyBytes)}');

      _handleResponse(response); // Esperamos 200 OK o 204 No Content
    } on http.ClientException catch (e) {
      throw NetworkException('Verifica tu conexión a internet o la URL de la API. Detalles: ${e.message}');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw UnknownApiException('Ha ocurrido un error inesperado al eliminar carrera: ${e.toString()}');
    }
  }

  /// Manejo centralizado de respuestas HTTP (éxito y error)
  void _handleResponse(http.Response response, {bool expectCreated = false}) {
    final status = response.statusCode;
    final serverMessage = utf8.decode(response.bodyBytes);
    debugPrint('[CarrerasService] _handleResponse - Raw body: $serverMessage (Status: $status)');

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