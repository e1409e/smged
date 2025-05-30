// lib/api/services/discapacidades_service.dart
import 'dart:convert'; // Para codificar y decodificar JSON
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http; // Paquete para realizar peticiones HTTP
import 'package:smged/api/models/discapacidad.dart'; // Importa el modelo de Discapacidad

class DiscapacidadesService {
  // La URL base de tu API.
  // Es crucial que esta URL sea accesible desde el entorno donde corres tu app.
  // - Para emuladores Android: 'http://10.0.2.2:3000/api'
  // - Para simuladores iOS/Web/Desktop local: 'http://localhost:3000/api'
  // - Si tu API está en una red local y usas un dispositivo físico: 'http://TU_IP_LOCAL:3000/api'
  final String _baseUrl = _getPlatformBaseUrl(); // ¡Ajusta esta URL a tu configuración!
  final Map<String, String> _headers = {'Content-Type': 'application/json'}; // Encabezado común para JSON

  static String _getPlatformBaseUrl() {
    if (kIsWeb) {
      // Para desarrollo web, usa localhost o la IP de tu máquina si accedes desde otro dispositivo en la misma red
      return 'http://127.0.0.1:3000';
    } else {
      // Para Android, usa la IP especial para emuladores que apunta al localhost de la máquina host
      if (Platform.isAndroid) {
        return 'http://10.0.2.2:3000';
      } else {
        // Para iOS, Desktop, y otros, usa localhost
        return 'http://127.0.0.1:3000';
      }
    }
  }
  /// Obtiene todas las discapacidades desde la API.
  /// Retorna una lista de objetos [Discapacidad].
  /// Lanza una [Exception] si la petición falla.
  Future<List<Discapacidad>> obtenerDiscapacidades() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/discapacidades'));

      if (response.statusCode == 200) {
        // Decodifica la respuesta JSON y mapea cada elemento a un objeto Discapacidad.
        List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => Discapacidad.fromJson(json)).toList();
      } else {
        // Lanza una excepción con el mensaje de error de la API si no es 200 OK.
        throw Exception('Error al cargar discapacidades: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      // Captura errores de red o cualquier otra excepción.
      throw Exception('Fallo al obtener discapacidades: $e');
    }
  }

  /// Obtiene una discapacidad específica por su ID.
  /// Retorna un objeto [Discapacidad].
  /// Lanza una [Exception] si la petición falla o la discapacidad no se encuentra.
  Future<Discapacidad> obtenerDiscapacidadPorId(int id) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/discapacidades/$id'));

      if (response.statusCode == 200) {
        // Decodifica la respuesta y crea un objeto Discapacidad.
        return Discapacidad.fromJson(json.decode(response.body));
      } else if (response.statusCode == 404) {
        throw Exception('Discapacidad con ID $id no encontrada.');
      } else {
        throw Exception('Error al obtener discapacidad por ID: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Fallo al obtener discapacidad por ID: $e');
    }
  }

  /// Crea una nueva discapacidad.
  /// Recibe el nombre de la discapacidad.
  /// Retorna el objeto [Discapacidad] creado con su ID.
  /// Lanza una [Exception] si la creación falla.
  Future<Discapacidad> crearDiscapacidad(String nombreDiscapacidad) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/discapacidades'),
        headers: _headers,
        body: json.encode({'discapacidad': nombreDiscapacidad}), // El nombre de la discapacidad se envía en el cuerpo
      );

      if (response.statusCode == 201) { // 201 Created
        return Discapacidad.fromJson(json.decode(response.body));
      } else {
        throw Exception('Error al crear discapacidad: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Fallo al crear discapacidad: $e');
    }
  }

  /// Edita una discapacidad existente.
  /// Recibe el ID de la discapacidad y el nuevo nombre.
  /// Retorna el objeto [Discapacidad] actualizado.
  /// Lanza una [Exception] si la edición falla.
  Future<Discapacidad> editarDiscapacidad(int id, String nuevoNombreDiscapacidad) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/discapacidades/$id'),
        headers: _headers,
        body: json.encode({'discapacidad': nuevoNombreDiscapacidad}),
      );

      if (response.statusCode == 200) { // 200 OK
        return Discapacidad.fromJson(json.decode(response.body));
      } else if (response.statusCode == 404) {
        throw Exception('Discapacidad con ID $id no encontrada para editar.');
      } else {
        throw Exception('Error al editar discapacidad: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Fallo al editar discapacidad: $e');
    }
  }

  /// Elimina una discapacidad por su ID.
  /// Retorna [true] si la eliminación fue exitosa.
  /// Lanza una [Exception] si la eliminación falla.
  Future<bool> eliminarDiscapacidad(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/discapacidades/$id'),
        headers: _headers,
      );

      if (response.statusCode == 200) { // 200 OK
        // La API devuelve un mensaje de éxito, podemos devolver true.
        return true;
      } else if (response.statusCode == 404) {
        throw Exception('Discapacidad con ID $id no encontrada para eliminar.');
      } else {
        throw Exception('Error al eliminar discapacidad: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Fallo al eliminar discapacidad: $e');
    }
  }
}