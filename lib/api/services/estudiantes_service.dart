// lib/api/services/estudiantes_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show debugPrint;

import 'package:smged/api/models/estudiante.dart';
import 'package:smged/config.dart';
// Importa las nuevas clases de excepción
import 'package:smged/api/exceptions/api_exception.dart'; 


class EstudiantesService {
  static final String _baseUrl = '${Config.apiUrl}/estudiantes';
  static const Map<String, String> _headers = {'Content-Type': 'application/json'};

  Future<List<Estudiante>> obtenerTodosLosEstudiantes() async {
    debugPrint('[EstudiantesService] Solicitando todos los estudiantes a: $_baseUrl');
    try {
      final response = await http.get(Uri.parse(_baseUrl));
      _handleResponse(response); 
      final List<dynamic> estudiantesJson = json.decode(utf8.decode(response.bodyBytes));
      return estudiantesJson.map((json) => Estudiante.fromJson(json)).toList();
    } on http.ClientException catch (e) {
      throw NetworkException('Verifica tu conexión a internet o la URL de la API. Detalles: ${e.message}');
    } catch (e) {
      // Ahora, si la excepción no es una de las nuestras, la envolvemos en UnknownApiException
      if (e is ApiException) rethrow; // Ya es una excepción de la API, la relanzamos.
      throw UnknownApiException('Ha ocurrido un error inesperado al obtener estudiantes: ${e.toString()}');
    }
  }

  Future<Estudiante> obtenerEstudiantePorId(int id) async {
    debugPrint('[EstudiantesService] Solicitando estudiante con ID $id a: $_baseUrl/$id');
    try {
      final response = await http.get(Uri.parse('$_baseUrl/$id'));
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
      final response = await http.post(
        url,
        headers: _headers, 
        body: requestBody, 
      );

      debugPrint('[EstudiantesService] Respuesta de la API (Status: ${response.statusCode}): ${utf8.decode(response.bodyBytes)}');

      _handleResponse(response);

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
      throw Exception('El ID del estudiante es necesario para actualizar.'); // Puedes cambiar a ApiException si lo prefieres
    }
    final url = Uri.parse('$_baseUrl/${estudiante.idEstudiante}');
    debugPrint('[EstudiantesService] Enviando PUT a: $url');
    
    final String requestBody = json.encode(estudiante.toJson()); 
    debugPrint('[EstudiantesService] Cuerpo de la solicitud: $requestBody');

    try {
      final response = await http.put(
        url,
        headers: _headers,
        body: requestBody,
      );

      debugPrint('[EstudiantesService] Código de estado de la API al actualizar: ${response.statusCode}');
      debugPrint('[EstudiantesService] Cuerpo de la respuesta de la API al actualizar: ${utf8.decode(response.bodyBytes)}');

      _handleResponse(response);

      debugPrint('[EstudiantesService] Actualización exitosa, obteniendo datos actualizados del estudiante...');
      return await obtenerEstudiantePorId(estudiante.idEstudiante!);

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
      final response = await http.delete(Uri.parse('$_baseUrl/$id'));
      
      debugPrint('[EstudiantesService] Código de estado de la API al eliminar: ${response.statusCode}');
      debugPrint('[EstudiantesService] Cuerpo de la respuesta de la API al eliminar: ${utf8.decode(response.bodyBytes)}');

      if (response.statusCode == 200) {
        return; 
      } else {
        _handleResponse(response);
      }
    } on http.ClientException catch (e) {
      throw NetworkException('Verifica tu conexión a internet o la URL de la API. Detalles: ${e.message}');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw UnknownApiException('Ha ocurrido un error inesperado al eliminar estudiante: ${e.toString()}');
    }
  }

  // --- Manejo Centralizado de Respuestas HTTP ---

  void _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return; 
    } 

    String serverMessage = utf8.decode(response.bodyBytes);
    debugPrint('[EstudiantesService] _handleResponse - Raw error body: $serverMessage');

    try {
      final errorBody = json.decode(serverMessage);
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
            statusCode: response.statusCode,
            details: errorBody,
          );
        } else if (errorBody.containsKey('error') && errorBody['error'] is String) {
          // Maneja errores generales de la API (ej. "Estudiante no encontrado")
          // Puedes personalizar más el mensaje para 404
          if (response.statusCode == 404) {
            throw NotFoundException(
              errorBody['error'].toString(), 
              statusCode: response.statusCode, 
              details: errorBody
            );
          } else {
            throw ApiException(
              errorBody['error'].toString(), 
              statusCode: response.statusCode, 
              details: errorBody
            );
          }
        } else {
          // Si el cuerpo del error es un JSON válido pero no tiene 'error' ni 'errors'
          throw UnknownApiException(
            'Respuesta de error inesperada de la API. Por favor, inténtalo de nuevo más tarde.', 
            statusCode: response.statusCode, 
            details: errorBody
          );
        }
      } else {
        // Si el cuerpo del error no es un JSON válido o no es un Map
        throw UnknownApiException(
          'El servidor respondió con un error no reconocido. Por favor, inténtalo de nuevo.', 
          statusCode: response.statusCode, 
          details: serverMessage
        );
      }
    } catch (e) {
      // Si la decodificación JSON falla o se lanza una excepción de nuestra jerarquía
      if (e is ApiException) rethrow; // Relanza nuestras excepciones ya manejadas
      throw UnknownApiException(
        'No se pudo procesar la respuesta del servidor. Inténtalo de nuevo.', 
        statusCode: response.statusCode, 
        details: serverMessage
      );
    }
  }
}