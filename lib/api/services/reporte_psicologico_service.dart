import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:smged/api/models/reporte_psicologico.dart';
import 'package:smged/config.dart';

class ReportePsicologicoService {
  final String _baseUrl = '${Config.apiUrl}/reporte-psicologico';

  Future<List<ReportePsicologico>> obtenerReportesPsicologicos() async {
    final response = await http.get(Uri.parse(_baseUrl));
    if (response.statusCode == 200) {
      List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => ReportePsicologico.fromJson(json)).toList();
    } else {
      throw Exception('Error al obtener reportes psicológicos');
    }
  }

  Future<ReportePsicologico> obtenerReportePsicologicoPorId(int id) async {
    final response = await http.get(Uri.parse('$_baseUrl/$id'));
    if (response.statusCode == 200) {
      return ReportePsicologico.fromJson(json.decode(response.body));
    } else if (response.statusCode == 404) {
      throw Exception('Reporte psicológico no encontrado');
    } else {
      throw Exception('Error al obtener reporte psicológico');
    }
  }

  /// Nueva función: obtener reportes psicológicos por ID de estudiante
  Future<List<ReportePsicologico>> obtenerReportesPorEstudiante(int idEstudiante) async {
    final response = await http.get(Uri.parse('$_baseUrl/estudiante/$idEstudiante'));
    if (response.statusCode == 200) {
      List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => ReportePsicologico.fromJson({
        ...json,
        // Compatibilidad para nombres de campos según el JSON de la API
        'nombre_estudiante': json['nombres'],
        'apellido_estudiante': json['apellidos'],
      })).toList();
    } else if (response.statusCode == 404) {
      // No se encontraron reportes para este estudiante
      return [];
    } else {
      throw Exception('Error al obtener reportes psicológicos por estudiante');
    }
  }

  Future<int> crearReportePsicologico(ReportePsicologico reporte) async {
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(reporte.toCreateJson()),
    );
    if (response.statusCode == 201) {
      final data = json.decode(response.body);
      return data['id_psicologico'];
    } else if (response.statusCode == 400) {
      final errorData = json.decode(response.body);
      final errors = (errorData['errors'] as List).map((e) => e['msg']).join(', ');
      throw Exception('Error de validación: $errors');
    } else {
      throw Exception('Error al crear reporte psicológico');
    }
  }

  Future<void> editarReportePsicologico(int id, ReportePsicologico reporte) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(reporte.toCreateJson()),
    );
    if (response.statusCode != 200) {
      throw Exception('Error al editar reporte psicológico');
    }
  }

  Future<void> eliminarReportePsicologico(int id) async {
    final response = await http.delete(Uri.parse('$_baseUrl/$id'));
    if (response.statusCode != 200) {
      throw Exception('Error al eliminar reporte psicológico');
    }
  }
}