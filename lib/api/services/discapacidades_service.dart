// lib/api/services/discapacidades_service.dart
import 'dart:convert';
//import 'dart:io';
//import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:smged/api/models/discapacidad.dart';
import 'package:smged/config.dart';
import 'package:smged/api/exceptions/api_exception.dart';
import 'package:smged/api/services/auth_service.dart'; // Importa el AuthService

class DiscapacidadesService {
  final String _baseUrl = Config.apiUrl;
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

  /// Obtiene todas las discapacidades desde la API.
  Future<List<Discapacidad>> obtenerDiscapacidades() async {
    try {
      final headers = await _getHeaders(includeContentType: false); // GET no necesita Content-Type
      final response = await http.get(
        Uri.parse('$_baseUrl/discapacidades'),
        headers: headers, // Usar los encabezados con el token
      );
      _handleError(response);
      List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => Discapacidad.fromJson(json)).toList();
    } on http.ClientException catch (e) { // Capturar errores de red específicos
      throw NetworkException('Verifica tu conexión a internet o la URL de la API. Detalles: ${e.message}');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw UnknownApiException('Fallo al obtener discapacidades: ${e.toString()}');
    }
  }

  /// Obtiene una discapacidad específica por su ID.
  Future<Discapacidad> obtenerDiscapacidadPorId(int id) async {
    try {
      final headers = await _getHeaders(includeContentType: false); // GET no necesita Content-Type
      final response = await http.get(
        Uri.parse('$_baseUrl/discapacidades/$id'),
        headers: headers, // Usar los encabezados con el token
      );
      _handleError(response);
      return Discapacidad.fromJson(json.decode(response.body));
    } on http.ClientException catch (e) { // Capturar errores de red específicos
      throw NetworkException('Verifica tu conexión a internet o la URL de la API. Detalles: ${e.message}');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw UnknownApiException('Fallo al obtener discapacidad por ID: ${e.toString()}');
    }
  }

  /// Crea una nueva discapacidad.
  Future<Discapacidad> crearDiscapacidad(String nombreDiscapacidad) async {
    try {
      final headers = await _getHeaders(); // POST sí necesita Content-Type
      final response = await http.post(
        Uri.parse('$_baseUrl/discapacidades'),
        headers: headers, // Usar los encabezados con el token
        body: json.encode({'discapacidad': nombreDiscapacidad}),
      );
      _handleError(response, expectCreated: true); // Esperamos 201

      final dynamic body = json.decode(response.body);

      // Lógica existente para construir el modelo desde la respuesta
      if (body is int) {
        return Discapacidad(
          idDiscapacidad: body,
          nombre: nombreDiscapacidad,
        );
      }
      if (body is Map && body.containsKey('discapacidad_id')) {
        return Discapacidad.fromJson(Map<String, dynamic>.from(body));
      }
      if (body is String && int.tryParse(body) != null) {
        return Discapacidad(
          idDiscapacidad: int.parse(body),
          nombre: nombreDiscapacidad,
        );
      }

      // Si no se ajusta a ninguno de los formatos esperados y el _handleError no lanzó, aún es un problema.
      throw UnknownApiException('Respuesta inesperada al crear discapacidad: ${response.body}', statusCode: response.statusCode, details: response.body);
    } on http.ClientException catch (e) { // Capturar errores de red específicos
      throw NetworkException('Verifica tu conexión a internet o la URL de la API. Detalles: ${e.message}');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw UnknownApiException('Fallo al crear discapacidad: ${e.toString()}');
    }
  }

  /// Edita una discapacidad existente.
  Future<void> editarDiscapacidad(int id, String nuevoNombreDiscapacidad) async {
    try {
      final headers = await _getHeaders(); // PUT sí necesita Content-Type
      final response = await http.put(
        Uri.parse('$_baseUrl/discapacidades/$id'),
        headers: headers, // Usar los encabezados con el token
        body: json.encode({'discapacidad': nuevoNombreDiscapacidad}),
      );
      _handleError(response); // Esperamos 200
      // La API solo retorna un mensaje, no el objeto actualizado, así que el retorno void es correcto.
      return;
    } on http.ClientException catch (e) { // Capturar errores de red específicos
      throw NetworkException('Verifica tu conexión a internet o la URL de la API. Detalles: ${e.message}');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw UnknownApiException('Fallo al editar discapacidad: ${e.toString()}');
    }
  }

  /// Elimina una discapacidad por su ID.
  Future<void> eliminarDiscapacidad(int id) async {
    try {
      final headers = await _getHeaders(includeContentType: false); // DELETE no necesita Content-Type
      final response = await http.delete(
        Uri.parse('$_baseUrl/discapacidades/$id'),
        headers: headers, // Usar los encabezados con el token
      );
      _handleError(response); // Esperamos 200 o 204
      // La API solo retorna un mensaje o nada, así que el retorno void es correcto.
      return;
    } on http.ClientException catch (e) { // Capturar errores de red específicos
      throw NetworkException('Verifica tu conexión a internet o la URL de la API. Detalles: ${e.message}');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw UnknownApiException('Fallo al eliminar discapacidad: ${e.toString()}');
    }
  }

  /// Manejo centralizado de errores según la estructura de la API y api_exception.dart
  void _handleError(http.Response response, {bool expectCreated = false}) {
    final status = response.statusCode;

    // Si el estado es 200-299 (o 201 si se espera creación), o 204 (No Content para DELETE)
    // El 204 se añadió aquí para consistencia con eliminaciones.
    if ((expectCreated && status == 201) || (!expectCreated && (status >= 200 && status < 300 || status == 204))) {
      return;
    }

    dynamic body;
    try {
      body = json.decode(response.body);
    } catch (_) {
      // Si no se puede decodificar, es una respuesta inesperada no-JSON
      throw UnknownApiException('Respuesta inesperada del servidor', statusCode: status, details: response.body);
    }

    // Manejo específico para 401 Unauthorized (añadido aquí)
    if (status == 401) {
      throw UnauthorizedException(body['message'] ?? 'Token inválido o expirado. Vuelve a iniciar sesión.', statusCode: status, details: body);
    }

    // Validaciones de express-validator (campo 'errores' o 'errors')
    if (body is Map && (body.containsKey('errores') || body.containsKey('errors'))) {
      final errorsList = body['errores'] ?? body['errors'];
      final Map<String, List<String>> validationErrors = {};
      for (var error in errorsList) {
        // Asegúrate de que error sea un mapa y contenga las claves esperadas
        if (error is Map && (error.containsKey('param') || error.containsKey('path')) && error.containsKey('msg')) {
          final field = error['param'] ?? error['path'] ?? 'general';
          final msg = error['msg'] ?? 'Error de validación';
          validationErrors.putIfAbsent(field, () => []).add(msg);
        } else {
          // Si el formato del error en la lista no es el esperado
          validationErrors.putIfAbsent('general', () => []).add('Error de formato en la validación.');
        }
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

    // Otros errores no reconocidos que son JSON válidos
    throw UnknownApiException('Error inesperado: ${response.body}', statusCode: status, details: body);
  }
}