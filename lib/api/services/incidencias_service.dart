import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:smged/api/models/incidencia.dart';
import 'package:smged/config.dart';

class IncidenciasService {
  final String _baseUrl = '${Config.apiUrl}/incidencias';

  Future<List<Incidencia>> obtenerIncidencias() async {
    final response = await http.get(Uri.parse(_baseUrl));
    if (response.statusCode == 200) {
      List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => Incidencia.fromJson(json)).toList();
    } else {
      throw Exception('Error al obtener incidencias');
    }
  }

  Future<Incidencia> obtenerIncidenciaPorId(int id) async {
    final response = await http.get(Uri.parse('$_baseUrl/$id'));
    if (response.statusCode == 200) {
      return Incidencia.fromJson(json.decode(response.body));
    } else {
      throw Exception('Error al obtener la incidencia');
    }
  }

  Future<List<Incidencia>> obtenerIncidenciasPorEstudiante(int idEstudiante) async {
    final response = await http.get(Uri.parse('$_baseUrl/estudiante/$idEstudiante'));
    if (response.statusCode == 200) {
      List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => Incidencia.fromJson(json)).toList();
    } else if (response.statusCode == 404) {
      // No hay incidencias para este estudiante
      return [];
    } else {
      throw Exception('Error al obtener incidencias del estudiante');
    }
  }

  Future<int> crearIncidencia(Incidencia incidencia) async {
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(incidencia.toJson()),
    );
    if (response.statusCode == 201) {
      final data = json.decode(response.body);
      if (data is int) {
        return data;
      } else if (data is Map && data.containsKey('id_incidencia')) {
        return data['id_incidencia'];
      } else if (data is Map && data.containsKey('id')) {
        return data['id'];
      }
      throw Exception('Respuesta inesperada al crear incidencia');
    } else {
      throw Exception('Error al crear incidencia: ${response.body}');
    }
  }

  Future<void> editarIncidencia(int id, Incidencia incidencia) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(incidencia.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception('Error al editar incidencia: ${response.body}');
    }
  }

  Future<void> eliminarIncidencia(int id) async {
    final response = await http.delete(Uri.parse('$_baseUrl/$id'));
    if (response.statusCode != 200) {
      throw Exception('Error al eliminar incidencia: ${response.body}');
    }
  }
}