// lib/api/services/carreras_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:smged/api/models/carrera.dart';
import 'package:smged/config.dart';

class CarrerasService {
  final String _baseUrl = Config.apiUrl;

  Future<List<Carrera>> obtenerCarreras() async {
    final response = await http.get(Uri.parse('$_baseUrl/carreras'));

    if (response.statusCode == 200) {
      List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => Carrera.fromJson(json)).toList();
    } else {
      throw Exception('Fallo al cargar las carreras: ${response.statusCode} ${response.body}');
    }
  }

  Future<Carrera> obtenerCarreraPorId(int id) async {
    final response = await http.get(Uri.parse('$_baseUrl/carreras/$id'));

    if (response.statusCode == 200) {
      return Carrera.fromJson(json.decode(response.body));
    } else if (response.statusCode == 404) {
      throw Exception('Carrera no encontrada con ID: $id');
    } else {
      throw Exception('Fallo al cargar la carrera: ${response.statusCode} ${response.body}');
    }
  }
}