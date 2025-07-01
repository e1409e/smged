// lib/api/services/carreras_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:smged/api/models/carrera.dart';
import 'package:smged/config.dart';
import 'package:smged/api/exceptions/api_exception.dart';

class CarrerasService {
  final String _baseUrl = '${Config.apiUrl}/carreras';

  Future<List<Carrera>> obtenerCarreras() async {
    final response = await http.get(Uri.parse(_baseUrl));
    if (response.statusCode == 200) {
      List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => Carrera.fromJson(json)).toList();
    } else {
      _handleError(response);
    }
    throw UnknownApiException('Error desconocido al obtener carreras');
  }

  Future<Carrera> obtenerCarreraPorId(int id) async {
    final response = await http.get(Uri.parse('$_baseUrl/$id'));
    if (response.statusCode == 200) {
      return Carrera.fromJson(json.decode(response.body));
    } else {
      _handleError(response);
    }
    throw UnknownApiException('Error desconocido al obtener carrera por ID');
  }

  Future<void> crearCarrera(String carrera, int idFacultad) async {
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'carrera': carrera, 'id_facultad': idFacultad}),
    );
    if (response.statusCode != 201) {
      _handleError(response);
    }
  }

  Future<void> actualizarCarrera(int id, String carrera, int idFacultad) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'carrera': carrera, 'id_facultad': idFacultad}),
    );
    if (response.statusCode != 200) {
      _handleError(response);
    }
  }

  Future<void> eliminarCarrera(int id) async {
    final response = await http.delete(Uri.parse('$_baseUrl/$id'));
    if (response.statusCode != 200) {
      _handleError(response);
    }
  }

  /// Manejo centralizado de errores según la estructura de la API y api_exception.dart
  void _handleError(http.Response response) {
    final status = response.statusCode;
    dynamic body;
    try {
      body = json.decode(response.body);
    } catch (_) {
      throw UnknownApiException('Respuesta inesperada del servidor',
          statusCode: status, details: response.body);
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
      throw ValidationException(
          'Verifica los campos ingresados.', validationErrors,
          statusCode: status, details: body);
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
    throw UnknownApiException(
        'Error inesperado: ${response.body}', statusCode: status, details: body);
  }
}
