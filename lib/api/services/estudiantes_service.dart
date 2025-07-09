// lib/api/services/estudiantes_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show debugPrint;

import 'package:smged/api/models/estudiante.dart';
import 'package:smged/config.dart';
import 'package:smged/api/exceptions/api_exception.dart';
import 'package:smged/api/services/auth_service.dart'; // Importa el AuthService

class EstudiantesService {
  static final String _baseUrl = '${Config.apiUrl}/estudiantes';
  // Eliminamos _headers estáticos, se generarán dinámicamente.
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

  Future<List<Estudiante>> obtenerTodosLosEstudiantes() async {
    debugPrint('[EstudiantesService] Solicitando todos los estudiantes a: $_baseUrl');
    try {
      final headers = await _getHeaders(includeContentType: false); // GET no necesita Content-Type
      final response = await http.get(
        Uri.parse(_baseUrl),
        headers: headers, // Usar los encabezados con el token
      );
      _handleResponse(response);
      final List<dynamic> estudiantesJson = json.decode(utf8.decode(response.bodyBytes));
      return estudiantesJson.map((json) => Estudiante.fromJson(json)).toList();
    } on http.ClientException catch (e) {
      throw NetworkException('Verifica tu conexión a internet o la URL de la API. Detalles: ${e.message}');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw UnknownApiException('Ha ocurrido un error inesperado al obtener estudiantes: ${e.toString()}');
    }
  }

  Future<Estudiante> obtenerEstudiantePorId(int id) async {
    debugPrint('[EstudiantesService] Solicitando estudiante con ID $id a: $_baseUrl/$id');
    try {
      final headers = await _getHeaders(includeContentType: false); // GET no necesita Content-Type
      final response = await http.get(
        Uri.parse('$_baseUrl/$id'),
        headers: headers, // Usar los encabezados con el token
      );
      _handleResponse(response);
      return Estudiante.fromJson(json.decode(utf8.decode(response.bodyBytes)));
    } on http.ClientException catch (e) {
      throw NetworkException('Verifica tu conexión a internet o la URL de la API. Detalles: ${e.message}');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw UnknownApiException('Ha ocurrido un error inesperado al obtener estudiante por ID: ${e.toString()}');
    }
  }

  Future<Estudiante> crearEstudiante(Estudiante estudiante) async {
    final url = Uri.parse('$_baseUrl');
    debugPrint('[EstudiantesService] Intentando POST a: $url');

    final String requestBody = json.encode(estudiante.toJson());
    debugPrint('[EstudiantesService] Cuerpo de la petición: $requestBody');

    try {
      final headers = await _getHeaders(); // POST sí necesita Content-Type
      final response = await http.post(
        url,
        headers: headers, // Usar los encabezados con el token
        body: requestBody,
      );

      debugPrint('[EstudiantesService] Respuesta de la API (Status: ${response.statusCode}): ${utf8.decode(response.bodyBytes)}');

      _handleResponse(response, expectCreated: true); // Esperamos 201

      final Map<String, dynamic> responseBody = json.decode(utf8.decode(response.bodyBytes));
      return Estudiante.fromJson(responseBody);
    } on http.ClientException catch (e) {
      throw NetworkException('Verifica tu conexión a internet o la URL de la API. Detalles: ${e.message}');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw UnknownApiException('Ha ocurrido un error inesperado al crear estudiante: ${e.toString()}');
    }
  }

  Future<Estudiante> actualizarEstudiante(Estudiante estudiante) async {
    if (estudiante.idEstudiante == null) {
      throw ApiException('El ID del estudiante es necesario para actualizar.', statusCode: 400); // Cambiado a ApiException
    }
    final url = Uri.parse('$_baseUrl/${estudiante.idEstudiante}');
    debugPrint('[EstudiantesService] Enviando PUT a: $url');

    final String requestBody = json.encode(estudiante.toJson());
    debugPrint('[EstudiantesService] Cuerpo de la solicitud: $requestBody');

    try {
      final headers = await _getHeaders(); // PUT sí necesita Content-Type
      final response = await http.put(
        url,
        headers: headers, // Usar los encabezados con el token
        body: requestBody,
      );

      debugPrint('[EstudiantesService] Código de estado de la API al actualizar: ${response.statusCode}');
      debugPrint('[EstudiantesService] Cuerpo de la respuesta de la API al actualizar: ${utf8.decode(response.bodyBytes)}');

      _handleResponse(response); // No se espera 201, solo 200-299

      debugPrint('[EstudiantesService] Actualización exitosa, obteniendo datos actualizados del estudiante...');
      // Retornar el estudiante actualizado desde la respuesta PUT si la API lo devuelve.
      // Si la API solo devuelve un mensaje de éxito, y la obtención por ID es necesaria
      // se deja como estaba, pero se prefiere devolver desde la respuesta directa.
      // Asumimos que la API devuelve el estudiante actualizado.
      return Estudiante.fromJson(json.decode(utf8.decode(response.bodyBytes)));

    } on http.ClientException catch (e) {
      throw NetworkException('Verifica tu conexión a internet o la URL de la API. Detalles: ${e.message}');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw UnknownApiException('Ha ocurrido un error inesperado al actualizar estudiante: ${e.toString()}');
    }
  }

  Future<void> eliminarEstudiante(int id) async {
    debugPrint('[EstudiantesService] Intentando DELETE para estudiante con ID $id a: $_baseUrl/$id');
    try {
      final headers = await _getHeaders(includeContentType: false); // DELETE no necesita Content-Type
      final response = await http.delete(
        Uri.parse('$_baseUrl/$id'),
        headers: headers, // Usar los encabezados con el token
      );

      debugPrint('[EstudiantesService] Código de estado de la API al eliminar: ${response.statusCode}');
      debugPrint('[EstudiantesService] Cuerpo de la respuesta de la API al eliminar: ${utf8.decode(response.bodyBytes)}');

      _handleResponse(response); // Manejo de 200/204 centralizado aquí

    } on http.ClientException catch (e) {
      throw NetworkException('Verifica tu conexión a internet o la URL de la API. Detalles: ${e.message}');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw UnknownApiException('Ha ocurrido un error inesperado al eliminar estudiante: ${e.toString()}');
    }
  }

  // --- Manejo Centralizado de Respuestas HTTP ---

  void _handleResponse(http.Response response, {bool expectCreated = false}) {
    final status = response.statusCode;

    // Si el estado es 200-299 (o 201 si se espera creación), o 204 (No Content para DELETE)
    if ((expectCreated && status == 201) || (!expectCreated && (status >= 200 && status < 300 || status == 204))) {
      return;
    }

    String serverMessage = utf8.decode(response.bodyBytes);
    debugPrint('[EstudiantesService] _handleResponse - Raw error body: $serverMessage');

    dynamic errorBody;
    try {
      errorBody = json.decode(serverMessage);
    } catch (_) {
      // Si no se puede decodificar, es una respuesta inesperada no-JSON
      throw UnknownApiException('Respuesta inesperada del servidor', statusCode: status, details: serverMessage);
    }

    // Manejo específico para 401 Unauthorized (añadido aquí)
    if (status == 401) {
      throw UnauthorizedException(errorBody['message'] ?? 'Token inválido o expirado. Vuelve a iniciar sesión.', statusCode: status, details: errorBody);
    }

    if (errorBody is Map<String, dynamic>) {
      if (errorBody.containsKey('errors') && errorBody['errors'] is List) {
        // Extrae los errores de validación de una forma más estructurada
        final Map<String, List<String>> validationErrors = {};
        for (var errorItem in (errorBody['errors'] as List)) {
          if (errorItem is Map && errorItem.containsKey('path') && errorItem.containsKey('msg')) {
            final String field = errorItem['path'].toString();
            final String msg = errorItem['msg'].toString();
            validationErrors.putIfAbsent(field, () => []).add(msg);
          }
        }
        // Lanza la excepción de validación
        throw ValidationException(
          'Verifica los campos ingresados.', // Mensaje general para el usuario
          validationErrors,
          statusCode: status,
          details: errorBody,
        );
      } else if (errorBody.containsKey('error') && errorBody['error'] is String) {
        // Maneja errores generales de la API (ej. "Estudiante no encontrado")
        if (status == 404) {
          throw NotFoundException(
            errorBody['error'].toString(),
            statusCode: status,
            details: errorBody,
          );
        } else if (status >= 500) { // Añadido para manejar ServerException
          throw ServerException(
            errorBody['error'].toString(),
            statusCode: status,
            details: errorBody,
          );
        } else {
          // Si es otro error de API que no es 404 ni 5xx (ej. 400 Bad Request genérico sin 'errors')
          throw ApiException(
            errorBody['error'].toString(),
            statusCode: status,
            details: errorBody,
          );
        }
      } else if (errorBody.containsKey('message') && errorBody['message'] is String) { // Considera 'message' también para errores
         if (status >= 500) {
          throw ServerException(
            errorBody['message'].toString(),
            statusCode: status,
            details: errorBody,
          );
        } else {
          throw ApiException(
            errorBody['message'].toString(),
            statusCode: status,
            details: errorBody,
          );
        }
      } else {
        // Si el cuerpo del error es un JSON válido pero no tiene 'error', 'errors' o 'message'
        throw UnknownApiException(
          'Respuesta de error inesperada de la API. Por favor, inténtalo de nuevo más tarde.',
          statusCode: status,
          details: errorBody,
        );
      }
    } else {
      // Si el cuerpo del error no es un JSON válido o no es un Map (por ejemplo, un string plano de error)
      throw UnknownApiException(
        'El servidor respondió con un error no reconocido. Por favor, inténtalo de nuevo.',
        statusCode: status,
        details: serverMessage,
      );
    }
  }
}