// lib/api/services/discapacidades_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:smged/api/models/discapacidad.dart';
import 'package:smged/config.dart';
import 'package:smged/api/exceptions/api_exception.dart';

class DiscapacidadesService {
  final String _baseUrl = Config.apiUrl;
  final Map<String, String> _headers = {'Content-Type': 'application/json'};

  /// Obtiene todas las discapacidades desde la API.
  Future<List<Discapacidad>> obtenerDiscapacidades() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/discapacidades'));
      _handleError(response);
      List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => Discapacidad.fromJson(json)).toList();
    } catch (e) {
      if (e is ApiException) rethrow;
      throw UnknownApiException('Fallo al obtener discapacidades: $e');
    }
  }

  /// Obtiene una discapacidad específica por su ID.
  Future<Discapacidad> obtenerDiscapacidadPorId(int id) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/discapacidades/$id'));
      _handleError(response);
      return Discapacidad.fromJson(json.decode(response.body));
    } catch (e) {
      if (e is ApiException) rethrow;
      throw UnknownApiException('Fallo al obtener discapacidad por ID: $e');
    }
  }

  /// Crea una nueva discapacidad.
  Future<Discapacidad> crearDiscapacidad(String nombreDiscapacidad) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/discapacidades'),
        headers: _headers,
        body: json.encode({'discapacidad': nombreDiscapacidad}),
      );
      _handleError(response, expectCreated: true);

      final dynamic body = json.decode(response.body);

      // Si la respuesta es solo el id (int), construye el modelo manualmente
      if (body is int) {
        return Discapacidad(
          idDiscapacidad: body,
          nombre: nombreDiscapacidad,
        );
      }
      // Si la respuesta es un objeto con el id
      if (body is Map && body.containsKey('discapacidad_id')) {
        return Discapacidad.fromJson(Map<String, dynamic>.from(body));
      }
      // Si la respuesta es un string que representa un número
      if (body is String && int.tryParse(body) != null) {
        return Discapacidad(
          idDiscapacidad: int.parse(body),
          nombre: nombreDiscapacidad,
        );
      }

      throw UnknownApiException('Respuesta inesperada al crear discapacidad: ${response.body}');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw UnknownApiException('Fallo al crear discapacidad: $e');
    }
  }

  /// Edita una discapacidad existente.
  Future<void> editarDiscapacidad(int id, String nuevoNombreDiscapacidad) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/discapacidades/$id'),
        headers: _headers,
        body: json.encode({'discapacidad': nuevoNombreDiscapacidad}),
      );
      _handleError(response);
      // La API solo retorna un mensaje, no el objeto actualizado.
      return;
    } catch (e) {
      if (e is ApiException) rethrow;
      throw UnknownApiException('Fallo al editar discapacidad: $e');
    }
  }

  /// Elimina una discapacidad por su ID.
  Future<void> eliminarDiscapacidad(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/discapacidades/$id'),
        headers: _headers,
      );
      _handleError(response);
      // La API solo retorna un mensaje, no el objeto eliminado.
      return;
    } catch (e) {
      if (e is ApiException) rethrow;
      throw UnknownApiException('Fallo al eliminar discapacidad: $e');
    }
  }

  /// Manejo centralizado de errores según la estructura de la API y api_exception.dart
  void _handleError(http.Response response, {bool expectCreated = false}) {
    final status = response.statusCode;
    if ((expectCreated && status == 201) || (!expectCreated && status >= 200 && status < 300)) {
      return;
    }

    dynamic body;
    try {
      body = json.decode(response.body);
    } catch (_) {
      throw UnknownApiException('Respuesta inesperada del servidor', statusCode: status, details: response.body);
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