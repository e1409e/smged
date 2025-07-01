import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:smged/api/models/facultad.dart';
import 'package:smged/config.dart';
import 'package:smged/api/exceptions/api_exception.dart';

class FacultadesService {
  final String _baseUrl = '${Config.apiUrl}/facultades';

  Future<List<Facultad>> obtenerFacultades() async {
    final response = await http.get(Uri.parse(_baseUrl));
    if (response.statusCode == 200) {
      List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => Facultad.fromJson(json)).toList();
    } else {
      _handleError(response);
    }
    throw UnknownApiException('Error desconocido al obtener facultades');
  }

  Future<Facultad> obtenerFacultadPorId(int id) async {
    final response = await http.get(Uri.parse('$_baseUrl/$id'));
    if (response.statusCode == 200) {
      return Facultad.fromJson(json.decode(response.body));
    } else {
      _handleError(response);
    }
    throw UnknownApiException('Error desconocido al obtener la facultad');
  }

  Future<void> crearFacultad(String facultad, String siglas) async {
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'facultad': facultad, 'siglas': siglas}),
    );
    if (response.statusCode != 201) {
      _handleError(response);
    }
  }

  Future<void> actualizarFacultad(int id, String facultad, String siglas) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'facultad': facultad, 'siglas': siglas}),
    );
    if (response.statusCode != 200) {
      _handleError(response);
    }
  }

  Future<void> eliminarFacultad(int id) async {
    final response = await http.delete(Uri.parse('$_baseUrl/$id'));
    if (response.statusCode != 200) {
      _handleError(response);
    }
  }

  Future<List<Facultad>> obtenerFacultadesConCarreras() async {
    final url = Uri.parse('${Config.apiUrl}/facultades/carreras');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Facultad.fromJson(json)).toList();
    } else {
      _handleError(response);
    }
    throw UnknownApiException('Error al obtener facultades con carreras');
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