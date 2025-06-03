// lib/api/services/citas_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'dart:io' show Platform;
import 'dart:typed_data'; // Importar para utf8.decode

import 'package:smged/api/models/cita.dart'; // Asegúrate de que este import sea correcto

class CitasService {
  // Ajusta esta URL según tu entorno (desarrollo/producción)
  final String _baseUrl = kIsWeb
      ? 'http://127.0.0.1:3000'
      : Platform.isAndroid
          ? 'http://10.0.2.2:3000'
          : 'http://127.0.0.1:3000';

  // Método para obtener todas las citas
  Future<List<Cita>> obtenerCitas() async {
    final uri = Uri.parse('$_baseUrl/citas');
    debugPrint('GET: $uri');

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        List<dynamic> jsonList = json.decode(utf8.decode(response.bodyBytes));
        return jsonList.map((json) => Cita.fromJson(json)).toList();
      } else {
        // Mejorar manejo de errores decodificando el cuerpo
        final errorBody = json.decode(utf8.decode(response.bodyBytes));
        debugPrint('Error al obtener citas: ${response.statusCode} - ${errorBody['error'] ?? 'No hay mensaje de error'}');
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
    debugPrint('POST: $uri');
    debugPrint('Body: ${json.encode(cita.toJson())}');

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(cita.toJson()),
      );

      debugPrint('Crear Cita - Status: ${response.statusCode}');
      debugPrint('Crear Cita - Response Body: ${utf8.decode(response.bodyBytes)}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> responseBody = json.decode(utf8.decode(response.bodyBytes));
        if (responseBody.containsKey('id_citas')) {
          
          return cita.copyWith(id_citas: responseBody['id_citas'] as int);
        } else {
          // Si por alguna razón el ID no viene, podrías lanzar un error o devolver la cita original.
          throw Exception('La API no devolvió el id_citas al crear la cita.');
        }

      } else {
        final errorBody = json.decode(utf8.decode(response.bodyBytes));
        debugPrint('Error al crear cita: ${response.statusCode} - ${errorBody['error'] ?? 'No hay mensaje de error'}');
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
    debugPrint('PUT: $uri');
    debugPrint('Body: ${json.encode(cita.toJson())}');

    try {
      final response = await http.put(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(cita.toJson()),
      );

      debugPrint('Actualizar Cita - Status: ${response.statusCode}');
      debugPrint('Actualizar Cita - Response Body: "${utf8.decode(response.bodyBytes)}".');

      if (response.statusCode == 200) {
        final String responseBodyString = utf8.decode(response.bodyBytes).trim();

        // --- INICIO DE LA LÓGICA CLARA PARA ACTUALIZAR CITA ---
        if (responseBodyString.toLowerCase() == 'true') {
          debugPrint('Actualizar Cita - API devolvió "true". Asumiendo éxito.');
          // Si la API solo devuelve "true", la operación fue exitosa.
          // Retorna el objeto 'cita' que recibiste, ya que ya contiene los datos actualizados.
          return cita; 
        } else if (responseBodyString.toLowerCase() == 'false') {
          debugPrint('Actualizar Cita - API devolvió "false". Indicando fallo lógico.');
          throw Exception('La API indicó que la actualización de la cita no fue exitosa (respuesta "false").');
        } else {
          // Esto es un RESGUARDO por si la API de actualización cambia y devuelve un JSON.
          // Si tu API SIEMPRE devuelve "true" o "false", esta parte nunca se ejecutará.
          debugPrint('Actualizar Cita - API no devolvió "true"/"false". Intentando JSON...');
          try {
            final Map<String, dynamic> responseBody = json.decode(responseBodyString);
            // Aquí podrías añadir lógica si esperas un JSON como {"success": true} o el objeto completo
            if (responseBody.containsKey('message') && responseBody['message'].contains('actualizada')) {
              debugPrint('Actualizar Cita - JSON con mensaje de éxito.');
              return cita; // Asume éxito por el mensaje
            }
            // Si la API devuelve el objeto Cita completo actualizado
            // return Cita.fromJson(responseBody);
            
            debugPrint('Actualizar Cita - JSON inesperado o sin confirmación explícita.');
            throw Exception('La API devolvió un JSON inesperado al actualizar: $responseBody');

          } on FormatException catch (e) {
            debugPrint('Actualizar Cita - Error al decodificar respuesta como JSON: $e');
            throw Exception('Error al decodificar la respuesta. La API devolvió un formato inesperado: "$responseBodyString". Error: $e');
          }
        }

      } else {
        final errorBody = json.decode(utf8.decode(response.bodyBytes));
        debugPrint('Error al actualizar cita: ${response.statusCode} - ${errorBody['error'] ?? 'No hay mensaje de error'}');
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
    debugPrint('DELETE: $uri');

    try {
      final response = await http.delete(uri);

      if (response.statusCode == 204 || response.statusCode == 200) {
        debugPrint('Cita con ID $idCita eliminada exitosamente.');
      } else {
        final errorBody = json.decode(utf8.decode(response.bodyBytes));
        debugPrint('Error al eliminar cita: ${response.statusCode} - ${errorBody['error'] ?? 'No hay mensaje de error'}');
        throw Exception(errorBody['error'] ?? 'Error al eliminar la cita');
      }
    } catch (e) {
      debugPrint('Excepción al eliminar cita: $e');
      throw Exception('Problema de conexión o error inesperado: ${e.toString().replaceFirst('Exception: ', '')}');
    }
  }

  // Función para marcar una cita como realizada
  Future<bool> marcarCitaComoRealizada(int idCita) async {
    final uri = Uri.parse('$_baseUrl/citas/marcar-realizada/$idCita');
    debugPrint('PATCH: $uri');

    try {
      final response = await http.patch(uri);

      debugPrint('Marcar Realizada - Status: ${response.statusCode}');
      debugPrint('Marcar Realizada - Response Body: "${utf8.decode(response.bodyBytes)}".');

      if (response.statusCode == 200) {
        final String responseBodyString = utf8.decode(response.bodyBytes).trim();
        if (responseBodyString.toLowerCase() == 'true') {
          debugPrint('Marcar Realizada - API devolvió "true".');
          return true;
        } else if (responseBodyString.toLowerCase() == 'false') {
          debugPrint('Marcar Realizada - API devolvió "false".');
          return false;
        } else {
          // Si la API devuelve un JSON para "marcar como realizada"
          try {
            final Map<String, dynamic> responseBody = json.decode(responseBodyString);
            return responseBody['success'] ?? false; // Asume 'success' en la respuesta
          } on FormatException catch (e) {
            debugPrint('Marcar Realizada - Error decodificando JSON: $e');
            throw Exception('Respuesta inesperada al marcar como realizada: "$responseBodyString"');
          }
        }
      } else {
        final errorBody = json.decode(utf8.decode(response.bodyBytes));
        debugPrint('Error al marcar cita como realizada: ${response.statusCode} - ${errorBody['error'] ?? 'No hay mensaje de error'}');
        throw Exception(errorBody['error'] ?? 'Error al marcar la cita como realizada');
      }
    } catch (e) {
      debugPrint('Excepción al marcar cita como realizada: $e');
      throw Exception('Problema de conexión o error inesperado: ${e.toString().replaceFirst('Exception: ', '')}');
    }
  }
}