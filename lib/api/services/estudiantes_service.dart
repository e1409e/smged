// lib/api/services/estudiantes_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'dart:io' show Platform;

import 'package:smged/api/models/estudiante.dart';

class EstudiantesService {
  // URL base de la API para estudiantes, determinada al inicio de la aplicación
  static final String _baseUrl = _getPlatformBaseUrl();

  // Encabezados HTTP comunes para solicitudes que envían JSON
  static const Map<String, String> _headers = {'Content-Type': 'application/json'};

  // Método para determinar la URL base según la plataforma (Web, Android, iOS/Desktop)
  static String _getPlatformBaseUrl() {
    if (kIsWeb) {
      // Para desarrollo web, usa localhost o la IP de tu máquina si accedes desde otro dispositivo en la misma red
      return 'http://127.0.0.1:3000/estudiantes';
    } else {
      // Para Android, usa la IP especial para emuladores que apunta al localhost de la máquina host
      if (Platform.isAndroid) {
        return 'http://10.0.2.2:3000/estudiantes';
      } else {
        // Para iOS, Desktop, y otros, usa localhost
        return 'http://127.0.0.1:3000/estudiantes';
      }
    }
  }

  // --- Métodos de Consumo de API (CRUD) ---

  // Obtener todos los estudiantes
  Future<List<Estudiante>> obtenerTodosLosEstudiantes() async {
    try {
      final response = await http.get(Uri.parse(_baseUrl));
      _handleResponse(response); // Llama al manejador centralizado de respuestas

      // Si la respuesta es exitosa, decodifica y mapea a objetos Estudiante
      final List<dynamic> estudiantesJson = json.decode(utf8.decode(response.bodyBytes));
      return estudiantesJson.map((json) => Estudiante.fromJson(json)).toList();
    } on http.ClientException catch (e) {
      // Excepción específica para problemas de red/conexión
      throw Exception('Error de conexión: Verifica tu conexión a internet o la URL de la API. Detalles: ${e.message}');
    } catch (e) {
      // Captura cualquier otra excepción, incluyendo las lanzadas por _handleResponse
      throw Exception('Ha ocurrido un error inesperado al obtener estudiantes: $e');
    }
  }

  // Obtener un estudiante por su ID
  Future<Estudiante> obtenerEstudiantePorId(int id) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/$id'));
      _handleResponse(response); // Maneja la respuesta

      return Estudiante.fromJson(json.decode(response.body));
    } on http.ClientException catch (e) {
      throw Exception('Error de conexión o de red al obtener estudiante: ${e.message}');
    } catch (e) {
      throw Exception('Ha ocurrido un error inesperado al obtener estudiante por ID: $e');
    }
  }

  // Crear un nuevo estudiante
// Crear un nuevo estudiante
  Future<Estudiante> crearEstudiante(Estudiante estudiante) async {
    try {
      final url = Uri.parse('$_baseUrl'); // Asume que este es el endpoint para crear
      debugPrint('[EstudiantesService] Intentando POST a: $url');
      debugPrint('[EstudiantesService] Cuerpo de la petición: ${json.encode(estudiante.toJson())}');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(estudiante.toJson()), 
      );

      debugPrint('[EstudiantesService] Respuesta de la API (Status: ${response.statusCode}): ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
       
        // La API devuelve el objeto Estudiante completo, decodifícalo como JSON
        final Map<String, dynamic> responseBody = json.decode(utf8.decode(response.bodyBytes));
        
        // Ahora, usa el factory Estudiante.fromJson para construir el objeto
        // que ya sabe cómo extraer id_estudiante, nombres, etc.
        return Estudiante.fromJson(responseBody);
      } else {
        // Manejo de errores basado en el código de estado HTTP
        String errorMessage = 'Error desconocido al crear estudiante.';
        try {
          final errorBody = json.decode(response.body);
          if (errorBody is Map && errorBody.containsKey('message')) {
            errorMessage = errorBody['message'];
          } else {
            errorMessage = response.body; // Si no hay 'message', usa todo el cuerpo de la respuesta
          }
        } catch (e) {
          // Si el cuerpo de la respuesta no es un JSON, usamos el cuerpo tal cual
          errorMessage = response.body;
        }
        throw Exception('Error al crear estudiante (Código: ${response.statusCode}): $errorMessage');
      }
    } on http.ClientException catch (e) {
      throw Exception('Error de conexión: Verifica tu conexión a internet o la URL de la API. Detalles: ${e.message}');
    } catch (e) {
      // Re-lanza la excepción para que pueda ser capturada en la UI
      throw Exception('Ha ocurrido un error inesperado al crear estudiante: ${e.toString()}');
    }
  }

// Método para actualizar un estudiante
  Future<Estudiante> actualizarEstudiante(Estudiante estudiante) async {
    if (estudiante.idEstudiante == null) {
      throw Exception('El ID del estudiante es necesario para actualizar.');
    }
    try {
      final url = Uri.parse('$_baseUrl/${estudiante.idEstudiante}');
      debugPrint('Enviando PUT a: $url');
      debugPrint('Cuerpo de la solicitud: ${json.encode(estudiante.toJson())}');

      final response = await http.put(
        url,
        headers: _headers,
        body: json.encode(estudiante.toJson()),
      );

      debugPrint('Código de estado de la API al actualizar: ${response.statusCode}');
      debugPrint('Cuerpo de la respuesta de la API al actualizar: ${response.body}');

      if (response.statusCode == 200) {
        // La API devuelve un JSON simple: {"editar_estudiante": true}
        try {
          final Map<String, dynamic> responseData = json.decode(response.body);
          final bool? editarEstudianteExitoso = responseData['editar_estudiante'] as bool?;

          if (editarEstudianteExitoso == true) {
            // Si la API confirma el éxito, retornamos el mismo objeto 'estudiante'
            // que recibimos como parámetro, ya que este contiene los datos actualizados.
            return estudiante;
          } else {
            // Si "editar_estudiante" es false o nulo, es un error lógico de la API
            throw Exception('La API indicó que la actualización del estudiante no fue exitosa.');
          }
        } catch (e) {
          // Esto capturará errores si response.body no es un JSON válido,
          // o si el campo 'editar_estudiante' no es un booleano, etc.
          throw Exception('Error al procesar la respuesta de la API al actualizar: ${e.toString()}');
        }
      } else {
        // Manejo de errores basado en el código de estado HTTP (no 200)
        String errorMessage = 'Error desconocido al actualizar estudiante.';
        try {
          final errorBody = json.decode(response.body);
          if (errorBody is Map && errorBody.containsKey('message')) {
            errorMessage = errorBody['message'];
          } else {
            errorMessage = response.body;
          }
        } catch (e) {
          errorMessage = response.body;
        }
        throw Exception('Error al actualizar estudiante (Código: ${response.statusCode}): $errorMessage');
      }
    } on http.ClientException catch (e) {
      throw Exception('Error de conexión o de red al actualizar estudiante: ${e.message}');
    } catch (e) {
      throw Exception('Ha ocurrido un error inesperado al actualizar estudiante: ${e.toString()}');
    }
  }

  // Eliminar un estudiante
  Future<void> eliminarEstudiante(int id) async {
    try {
      final response = await http.delete(Uri.parse('$_baseUrl/$id'));
      _handleResponse(response); // Maneja la respuesta (espera 204 No Content)
      // Si la respuesta es 204 (No Content), no hay cuerpo para decodificar
      if (response.statusCode == 204) {
        return;
      }
    } on http.ClientException catch (e) {
      throw Exception('Error de conexión o de red al eliminar estudiante: ${e.message}');
    } catch (e) {
      throw Exception('Ha ocurrido un error inesperado al eliminar estudiante: $e');
    }
  }

  // --- Manejo Centralizado de Respuestas HTTP ---

  // Método privado para manejar las respuestas HTTP y lanzar excepciones específicas
  void _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      // La solicitud fue exitosa (códigos 2xx)
      return; // No hay errores, se procede con el procesamiento de datos
    } else if (response.statusCode == 404) {
      throw Exception('Recurso no encontrado. URL: ${response.request?.url ?? "N/A"}. Mensaje del servidor: ${response.body}');
    } else if (response.statusCode >= 400 && response.statusCode < 500) {
      // Errores del lado del cliente (4xx)
      throw Exception('Error de la aplicación (código ${response.statusCode}). Mensaje del servidor: ${response.body}');
    } else if (response.statusCode >= 500 && response.statusCode < 600) {
      // Errores del lado del servidor (5xx)
      throw Exception('Error del servidor (código ${response.statusCode}). Mensaje del servidor: ${response.body}');
    } else {
      // Otros códigos de estado HTTP no esperados
      throw Exception('Error desconocido (código ${response.statusCode}). Mensaje del servidor: ${response.body}');
    }
  }
}