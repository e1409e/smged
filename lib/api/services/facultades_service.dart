import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:smged/api/models/facultad.dart';
import 'package:smged/config.dart';

class FacultadesService {
  final String _baseUrl = '${Config.apiUrl}/facultades';

  Future<List<Facultad>> obtenerFacultades() async {
    final response = await http.get(Uri.parse(_baseUrl));
    if (response.statusCode == 200) {
      List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => Facultad.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar facultades: ${response.statusCode} - ${response.body}');
    }
  }

  Future<Facultad> obtenerFacultadPorId(int id) async {
    final response = await http.get(Uri.parse('$_baseUrl/$id'));
    if (response.statusCode == 200) {
      return Facultad.fromJson(json.decode(response.body));
    } else {
      throw Exception('Fallo al cargar la facultad: ${response.statusCode} ${response.body}');
    }
  }

  Future<void> crearFacultad(String facultad, String siglas) async {
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'facultad': facultad, 'siglas': siglas}),
    );
    if (response.statusCode != 201) {
      throw Exception('Error al crear facultad: ${response.statusCode} - ${response.body}');
    }
  }

  Future<void> actualizarFacultad(int id, String facultad, String siglas) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'facultad': facultad, 'siglas': siglas}),
    );
    if (response.statusCode != 200) {
      throw Exception('Error al actualizar facultad: ${response.statusCode} - ${response.body}');
    }
  }

  Future<void> eliminarFacultad(int id) async {
    final response = await http.delete(Uri.parse('$_baseUrl/$id'));
    if (response.statusCode != 200) {
      throw Exception('Error al eliminar facultad: ${response.statusCode} - ${response.body}');
    }
  }
}