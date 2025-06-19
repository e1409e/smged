// lib/api/services/historial_medico_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:smged/api/models/historial_medico.dart';
import 'package:smged/config.dart'; // ¡Importa tu archivo de configuración aquí!

class HistorialMedicoService {
  final String _baseUrl = '${Config.apiUrl}/historial_medico';

  /// Obtiene todos los historiales médicos.
  Future<List<HistorialMedico>> obtenerTodosLosHistorialesMedicos() async {
    final response = await http.get(Uri.parse(_baseUrl));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => HistorialMedico.fromJson(data)).toList();
    } else {
      throw Exception('Error al obtener historiales médicos');
    }
  }

  /// Obtiene un historial médico por el ID del estudiante.
  Future<HistorialMedico?> obtenerHistorialPorEstudiante(int idEstudiante) async {
    final response = await http.get(Uri.parse('$_baseUrl/estudiante/$idEstudiante'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return HistorialMedico.fromJson(data);
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception('Error al obtener historial médico del estudiante');
    }
  }

  /// Obtiene un historial médico por su ID.
  Future<HistorialMedico> obtenerHistorialMedicoPorId(int id) async {
    final response = await http.get(Uri.parse('$_baseUrl/$id'));

    if (response.statusCode == 200) {
      return HistorialMedico.fromJson(json.decode(response.body));
    } else if (response.statusCode == 404) {
      throw Exception('Historial médico no encontrado.');
    } else {
      final errorData = json.decode(response.body);
      throw Exception('Error al obtener historial médico por ID: ${errorData['error'] ?? response.reasonPhrase}');
    }
  }

  /// Crea un nuevo historial médico.
  Future<HistorialMedico> crearHistorialMedico(HistorialMedico historial) async {
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(historial.toCreateJson()),
    );

    if (response.statusCode == 201) {
      return HistorialMedico.fromJson(json.decode(response.body));
    } else if (response.statusCode == 400) {
      final errorData = json.decode(response.body);
      final errors = (errorData['errors'] as List).map((e) => e['msg']).join(', ');
      throw Exception('Error de validación al crear historial médico: $errors');
    } else {
      final errorData = json.decode(response.body);
      throw Exception('Error al crear historial médico: ${errorData['error'] ?? response.reasonPhrase}');
    }
  }

  /// Edita un historial médico existente.
  Future<HistorialMedico> editarHistorialMedico(int id, HistorialMedico historial) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(historial.toJson()),
    );

    if (response.statusCode == 200) {
      return HistorialMedico.fromJson(json.decode(response.body));
    } else if (response.statusCode == 400) {
      final errorData = json.decode(response.body);
      final errors = (errorData['errors'] as List).map((e) => e['msg']).join(', ');
      throw Exception('Error de validación al editar historial médico: $errors');
    } else if (response.statusCode == 404) {
      throw Exception('Historial médico no encontrado para editar.');
    } else {
      final errorData = json.decode(response.body);
      throw Exception('Error al editar historial médico: ${errorData['error'] ?? response.reasonPhrase}');
    }
  }

  /// Elimina un historial médico.
  Future<void> eliminarHistorialMedico(int id) async {
    final response = await http.delete(Uri.parse('$_baseUrl/$id'));

    if (response.statusCode == 200) {
      return;
    } else if (response.statusCode == 404) {
      throw Exception('Historial médico no encontrado para eliminar.');
    } else {
      final errorData = json.decode(response.body);
      throw Exception('Error al eliminar historial médico: ${errorData['error'] ?? response.reasonPhrase}');
    }
  }
}