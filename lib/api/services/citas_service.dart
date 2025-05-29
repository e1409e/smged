import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:smged/api/models/cita.dart'; // Asegúrate de importar el modelo Cita
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;


class CitasService {
  // Ajusta esta URL según tu entorno (desarrollo/producción)
final String _baseUrl = kIsWeb // Si es la web
    ? 'http://127.0.0.1:3000' // Usa localhost para el navegador web
    : Platform.isAndroid // Si es Android (emulador o dispositivo)
        ? 'http://10.0.2.2:3000' // Usa 10.0.2.2 para el emulador de Android
        : 'http://127.0.0.1:3000'; // Para otras plataformas como iOS, Windows, macOS, Linux

  // Función para obtener todas las citas
  Future<List<Cita>> obtenerTodasLasCitas() async {
    final uri = Uri.parse('$_baseUrl/citas');
    print('GET: $uri'); // Para depuración

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        // Asume que la API devuelve un array de objetos Cita
        List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => Cita.fromJson(json)).toList();
      } else {
        final errorBody = json.decode(response.body);
        print('Error al obtener citas: ${response.statusCode} - ${errorBody['error'] ?? response.body}');
        throw Exception(errorBody['error'] ?? 'Error al cargar las citas');
      }
    } catch (e) {
      print('Excepción al obtener citas: $e');
      throw Exception('Problema de conexión o error inesperado: $e');
    }
  }

  // Función para marcar una cita como realizada
  Future<bool> marcarCitaComoRealizada(int idCita) async {
    final uri = Uri.parse('$_baseUrl/citas/marcar-realizada/$idCita');
    print('PATCH: $uri'); // Para depuración

    try {
      final response = await http.patch(uri); // Usamos PATCH

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        print('Cita marcada como realizada: $responseBody');
        return responseBody['success'] ?? true; // Asume 'success' en la respuesta de la API
      } else {
        final errorBody = json.decode(response.body);
        print('Error al marcar cita como realizada: ${response.statusCode} - ${errorBody['error'] ?? response.body}');
        throw Exception(errorBody['error'] ?? 'Error al marcar la cita como realizada');
      }
    } catch (e) {
      print('Excepción al marcar cita como realizada: $e');
      throw Exception('Problema de conexión o error inesperado: $e');
    }
  }

  // Puedes añadir más funciones aquí para crear, actualizar, eliminar citas
}