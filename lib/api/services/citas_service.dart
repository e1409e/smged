// lib/api/services/citas_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:smged/api/models/cita.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint; // Añadido debugPrint

class CitasService {
  // Ajusta esta URL según tu entorno (desarrollo/producción)
  final String _baseUrl = kIsWeb // Si es la web
      ? 'http://127.0.0.1:3000' // Usa localhost para el navegador web
      : Platform.isAndroid // Si es Android (emulador o dispositivo)
          ? 'http://10.0.2.2:3000' // Usa 10.0.2.2 para el emulador de Android
          : 'http://127.0.0.1:3000'; // Para otras plataformas como iOS, Windows, macOS, Linux

  // Método para obtener todas las citas
  Future<List<Cita>> obtenerCitas() async { // Renombrado a 'obtenerCitas' para consistencia
    final uri = Uri.parse('$_baseUrl/citas');
    debugPrint('GET: $uri'); // Para depuración

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => Cita.fromJson(json)).toList();
      } else {
        final errorBody = json.decode(response.body);
        debugPrint('Error al obtener citas: ${response.statusCode} - ${errorBody['error'] ?? response.body}');
        throw Exception(errorBody['error'] ?? 'Error al cargar las citas');
      }
    } catch (e) {
      debugPrint('Excepción al obtener citas: $e');
      throw Exception('Problema de conexión o error inesperado: ${e.toString().replaceFirst('Exception: ', '')}');
    }
  }

  // Método para crear una nueva cita
  Future<Cita> crearCita(Cita cita) async {
    final uri = Uri.parse('$_baseUrl/citas');
    debugPrint('POST: $uri'); // Para depuración
    debugPrint('Body: ${json.encode(cita.toJson())}'); // Para depuración

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(cita.toJson()),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return Cita.fromJson(json.decode(response.body));
      } else {
        final errorBody = json.decode(response.body);
        debugPrint('Error al crear cita: ${response.statusCode} - ${errorBody['error'] ?? response.body}');
        throw Exception(errorBody['error'] ?? 'Error al crear la cita');
      }
    } catch (e) {
      debugPrint('Excepción al crear cita: $e');
      throw Exception('Problema de conexión o error inesperado: ${e.toString().replaceFirst('Exception: ', '')}');
    }
  }

  // Método para actualizar una cita existente
  Future<Cita> actualizarCita(Cita cita) async {
    if (cita.id_citas == null) {
      throw Exception('El ID de la cita es requerido para la actualización.');
    }
    final uri = Uri.parse('$_baseUrl/citas/${cita.id_citas}');
    debugPrint('PUT: $uri'); // Para depuración
    debugPrint('Body: ${json.encode(cita.toJson())}'); // Para depuración

    try {
      final response = await http.put( // Usamos PUT para actualizar el recurso completo
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(cita.toJson()),
      );

      if (response.statusCode == 200) {
        return Cita.fromJson(json.decode(response.body));
      } else {
        final errorBody = json.decode(response.body);
        debugPrint('Error al actualizar cita: ${response.statusCode} - ${errorBody['error'] ?? response.body}');
        throw Exception(errorBody['error'] ?? 'Error al actualizar la cita');
      }
    } catch (e) {
      debugPrint('Excepción al actualizar cita: $e');
      throw Exception('Problema de conexión o error inesperado: ${e.toString().replaceFirst('Exception: ', '')}');
    }
  }

  // Método para eliminar una cita
  Future<void> eliminarCita(int idCita) async {
    final uri = Uri.parse('$_baseUrl/citas/$idCita');
    debugPrint('DELETE: $uri'); // Para depuración

    try {
      final response = await http.delete(uri);

      if (response.statusCode == 204 || response.statusCode == 200) { // 204 No Content es común para DELETE exitoso
        debugPrint('Cita con ID $idCita eliminada exitosamente.');
      } else {
        final errorBody = json.decode(response.body);
        debugPrint('Error al eliminar cita: ${response.statusCode} - ${errorBody['error'] ?? response.body}');
        throw Exception(errorBody['error'] ?? 'Error al eliminar la cita');
      }
    } catch (e) {
      debugPrint('Excepción al eliminar cita: $e');
      throw Exception('Problema de conexión o error inesperado: ${e.toString().replaceFirst('Exception: ', '')}');
    }
  }

  // Función para marcar una cita como realizada (ya lo tenías)
  Future<bool> marcarCitaComoRealizada(int idCita) async {
    final uri = Uri.parse('$_baseUrl/citas/marcar-realizada/$idCita');
    debugPrint('PATCH: $uri'); // Para depuración

    try {
      final response = await http.patch(uri); // Usamos PATCH

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        debugPrint('Cita marcada como realizada: $responseBody');
        return responseBody['success'] ?? true; // Asume 'success' en la respuesta de la API
      } else {
        final errorBody = json.decode(response.body);
        debugPrint('Error al marcar cita como realizada: ${response.statusCode} - ${errorBody['error'] ?? response.body}');
        throw Exception(errorBody['error'] ?? 'Error al marcar la cita como realizada');
      }
    } catch (e) {
      debugPrint('Excepción al marcar cita como realizada: $e');
      throw Exception('Problema de conexión o error inesperado: ${e.toString().replaceFirst('Exception: ', '')}');
    }
  }
}