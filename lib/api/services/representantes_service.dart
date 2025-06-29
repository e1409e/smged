import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:smged/api/models/representante.dart';
import 'package:smged/config.dart';

class RepresentantesService {
  final String _baseUrl = '${Config.apiUrl}/representantes';

  Future<List<Representante>> obtenerRepresentantes() async {
    final response = await http.get(Uri.parse(_baseUrl));
    if (response.statusCode == 200) {
      List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => Representante.fromJson(json)).toList();
    } else {
      throw Exception('Error al obtener representantes');
    }
  }

  Future<Representante> obtenerRepresentantePorId(int id) async {
    final response = await http.get(Uri.parse('$_baseUrl/$id'));
    if (response.statusCode == 200) {
      return Representante.fromJson(json.decode(response.body));
    } else {
      throw Exception('Error al obtener representante');
    }
  }

  Future<Representante?> obtenerRepresentantePorEstudiante(int idEstudiante) async {
    final response = await http.get(Uri.parse('$_baseUrl/estudiante/$idEstudiante'));
    if (response.statusCode == 200) {
      return Representante.fromJson(json.decode(response.body));
    } else if (response.statusCode == 404) {
      // No hay representante para este estudiante
      return null;
    } else {
      throw Exception('Error al obtener representante por estudiante');
    }
  }

  Future<void> crearRepresentante(Representante representante) async {
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(representante.toJson()),
    );
    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Error al crear representante');
    }
    // No intentes hacer fromJson aquí, porque la respuesta es solo el id
  }

  Future<void> editarRepresentante(int id, Representante representante) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(representante.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception('Error al editar representante');
    }
    // No intentes hacer fromJson aquí
  }

  Future<void> eliminarRepresentante(int id) async {
    final response = await http.delete(Uri.parse('$_baseUrl/$id'));
    if (response.statusCode != 200) {
      throw Exception('Error al eliminar representante');
    }
  }
}