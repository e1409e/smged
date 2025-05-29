// lib/api/services/estudiantes_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

import 'package:smged/api/models/estudiante.dart';

class EstudiantesService {
  static final String _baseUrl = _getPlatformBaseUrl();

  static String _getPlatformBaseUrl() {
    if (kIsWeb) {
      return 'http://127.0.0.1:3000/estudiantes';
    } else {
      if (Platform.isAndroid) {
        return 'http://10.0.2.2:3000/estudiantes';
      } else {
        return 'http://127.0.0.1:3000/estudiantes';
      }
    }
  }

  Future<List<Estudiante>> obtenerTodosLosEstudiantes() async {
    try {
      final response = await http.get(Uri.parse(_baseUrl));

      if (response.statusCode == 200) {
        // La solicitud fue exitosa (código 200 OK)
        try {
          final List<dynamic> estudiantesJson = json.decode(utf8.decode(response.bodyBytes));
          return estudiantesJson.map((json) => Estudiante.fromJson(json)).toList();
        } catch (e) {
          // Error al parsear el JSON
          throw Exception('Error al procesar los datos de estudiantes: La respuesta del servidor no tiene el formato esperado. Detalles: $e');
        }
      } else if (response.statusCode >= 400 && response.statusCode < 500) {
        // Errores del lado del cliente (4xx)
        throw Exception('Error de la aplicación al cargar estudiantes (código ${response.statusCode}). Por favor, contacta a soporte si persiste. Mensaje del servidor: ${response.body}');
      } else if (response.statusCode >= 500 && response.statusCode < 600) {
        // Errores del lado del servidor (5xx)
        throw Exception('Error del servidor al cargar estudiantes (código ${response.statusCode}). Intenta de nuevo más tarde. Mensaje del servidor: ${response.body}');
      } else {
        // Otros códigos de estado HTTP
        throw Exception('Error desconocido al cargar estudiantes (código ${response.statusCode}). Mensaje del servidor: ${response.body}');
      }
    } on http.ClientException catch (e) {
      // Error de red (por ejemplo, sin conexión a internet, URL incorrecta)
      throw Exception('Error de conexión: Verifica tu conexión a internet o la URL de la API. Detalles: ${e.message}');
    } on FormatException catch (e) {
      // Error si la URL no es válida
      throw Exception('Error de formato de URL: La dirección de la API es inválida. Detalles: $e');
    } catch (e) {
      // Cualquier otra excepción no capturada específicamente
      throw Exception('Ha ocurrido un error inesperado al obtener estudiantes: $e');
    }
  }
  Future<Estudiante> obtenerEstudiantePorId(int id) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/$id'));
      if (response.statusCode == 200) {
        return Estudiante.fromJson(json.decode(response.body));
      } else if (response.statusCode == 404) {
        throw Exception('Estudiante con ID $id no encontrado.');
      } else {
        throw Exception('Error al obtener estudiante: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      throw Exception('Error de conexión o de red al obtener estudiante: $e');
    }
  }

  Future<Estudiante> crearEstudiante(Estudiante estudiante) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(estudiante.toJson()),
      );
      if (response.statusCode == 201) {
        return Estudiante.fromJson(json.decode(response.body));
      } else {
        throw Exception('Error al crear estudiante: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      throw Exception('Error de conexión o de red al crear estudiante: $e');
    }
  }

  Future<Estudiante> actualizarEstudiante(int id, Estudiante estudiante) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(estudiante.toJson()),
      );
      if (response.statusCode == 200) {
        return Estudiante.fromJson(json.decode(response.body));
      } else if (response.statusCode == 404) {
        throw Exception('Estudiante con ID $id no encontrado para actualizar.');
      } else {
        throw Exception('Error al actualizar estudiante: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      throw Exception('Error de conexión o de red al actualizar estudiante: $e');
    }
  }

  Future<void> eliminarEstudiante(int id) async {
    try {
      final response = await http.delete(Uri.parse('$_baseUrl/$id'));
      if (response.statusCode != 204) {
        throw Exception('Error al eliminar estudiante: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      throw Exception('Error de conexión o de red al eliminar estudiante: $e');
    }
  }
}