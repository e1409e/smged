// lib/api/services/carreras_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:smged/api/models/carrera.dart';
import 'package:smged/config.dart';

class CarrerasService {
  final String _baseUrl = '${Config.apiUrl}/carreras';

  Future<List<Carrera>> obtenerCarreras() async {
    final response = await http.get(Uri.parse(_baseUrl));
    if (response.statusCode == 200) {
      List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => Carrera.fromJson(json)).toList();
    } else {
      throw Exception(
        'Error al cargar carreras: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<Carrera> obtenerCarreraPorId(int id) async {
    final response = await http.get(Uri.parse('$_baseUrl/$id'));
    if (response.statusCode == 200) {
      return Carrera.fromJson(json.decode(response.body));
    } else {
      throw Exception(
        'Fallo al cargar la carrera: ${response.statusCode} ${response.body}',
      );
    }
  }

  Future<void> crearCarrera(String carrera, int idFacultad) async {
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'carrera': carrera, 'id_facultad': idFacultad}),
    );
    if (response.statusCode != 201) {
      throw Exception(
        'Error al crear carrera: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<void> actualizarCarrera(int id, String carrera, int idFacultad) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'carrera': carrera, 'id_facultad': idFacultad}),
    );
    if (response.statusCode != 200) {
      throw Exception(
        'Error al actualizar carrera: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<void> eliminarCarrera(int id) async {
    final response = await http.delete(Uri.parse('$_baseUrl/$id'));
    if (response.statusCode != 200) {
      throw Exception(
        'Error al eliminar carrera: ${response.statusCode} - ${response.body}',
      );
    }
  }
}
