// lib/api/services/estudiantes_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'dart:io' show Platform;
import 'package:smged/api/models/estudiante.dart';
import 'package:smged/config.dart';

class EstudiantesService {
  // URL base de la API para estudiantes, determinada al inicio de la aplicación
  static final String _baseUrl = '${Config.apiUrl}/estudiantes';

  // Encabezados HTTP comunes para solicitudes que envían JSON
  static const Map<String, String> _headers = {'Content-Type': 'application/json'};

  // // Método para determinar la URL base según la plataforma (Web, Android, iOS/Desktop)
  // static String _getPlatformBaseUrl() {
  //   if (kIsWeb) {
  //     // Para desarrollo web, usa localhost o la IP de tu máquina si accedes desde otro dispositivo en la misma red
  //     return 'http://127.0.0.1:3000/estudiantes';
  //   } else {
  //     // Para Android, usa la IP especial para emuladores que apunta al localhost de la máquina host
  //     if (Platform.isAndroid) {
  //       return 'http://10.0.2.2:3000/estudiantes';
  //     } else {
  //       // Para iOS, Desktop, y otros, usa localhost
  //       return 'http://127.0.0.1:3000/estudiantes';
  //     }
  //   }
  // }

  // --- Métodos de Consumo de API (CRUD) ---

  // Obtener todos los estudiantes
  Future<List<Estudiante>> obtenerTodosLosEstudiantes() async {
    try {
      final response = await http.get(Uri.parse(_baseUrl));
      _handleResponse(response); // Llama al manejador centralizado de respuestas

      // Si la respuesta es exitosa, decodifica y mapea a objetos Estudiante
      // El Estudiante.fromJson ya está adaptado para los nuevos campos
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

      // El Estudiante.fromJson ya está adaptado para los nuevos campos
      return Estudiante.fromJson(json.decode(utf8.decode(response.bodyBytes)));
    } on http.ClientException catch (e) {
      throw Exception('Error de conexión o de red al obtener estudiante: ${e.message}');
    } catch (e) {
      throw Exception('Ha ocurrido un error inesperado al obtener estudiante por ID: $e');
    }
  }

  // Crear un nuevo estudiante
  Future<Estudiante> crearEstudiante(Estudiante estudiante) async {
    try {
      final url = Uri.parse('$_baseUrl'); // Asume que este es el endpoint para crear
      debugPrint('[EstudiantesService] Intentando POST a: $url');
      
      // estudiante.toJson() ahora incluye 'id_carrera', 'posee_conapdis' (como 0/1), 'otro_telefono', 'direccion'
      // y excluye los campos derivados.
      final String requestBody = json.encode(estudiante.toJson());
      debugPrint('[EstudiantesService] Cuerpo de la petición: $requestBody');

      final response = await http.post(
        url,
        headers: _headers, // Usa _headers directamente
        body: requestBody, 
      );

      debugPrint('[EstudiantesService] Respuesta de la API (Status: ${response.statusCode}): ${utf8.decode(response.bodyBytes)}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        // La API devuelve el objeto Estudiante completo con los campos derivados,
        // por lo que usamos Estudiante.fromJson para construirlo.
        final Map<String, dynamic> responseBody = json.decode(utf8.decode(response.bodyBytes));
        return Estudiante.fromJson(responseBody);
      } else {
        String errorMessage = 'Error desconocido al crear estudiante.';
        try {
          final errorBody = json.decode(utf8.decode(response.bodyBytes));
          if (errorBody is Map && errorBody.containsKey('errors')) {
            // Si hay errores de validación, puedes querer mostrar el array de errores
            errorMessage = 'Errores de validación: ${errorBody['errors'].map((e) => e['msg']).join(', ')}';
          } else if (errorBody is Map && errorBody.containsKey('error')) {
            errorMessage = errorBody['error'];
          } else {
            errorMessage = utf8.decode(response.bodyBytes);
          }
        } catch (e) {
          errorMessage = utf8.decode(response.bodyBytes);
        }
        throw Exception('Error al crear estudiante (Código: ${response.statusCode}): $errorMessage');
      }
    } on http.ClientException catch (e) {
      throw Exception('Error de conexión: Verifica tu conexión a internet o la URL de la API. Detalles: ${e.message}');
    } catch (e) {
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
      debugPrint('[EstudiantesService] Enviando PUT a: $url');
      
      // estudiante.toJson() ya está adaptado para enviar los campos correctos.
      final String requestBody = json.encode(estudiante.toJson());
      debugPrint('[EstudiantesService] Cuerpo de la solicitud: $requestBody');

      final response = await http.put(
        url,
        headers: _headers,
        body: requestBody,
      );

      debugPrint('[EstudiantesService] Código de estado de la API al actualizar: ${response.statusCode}');
      debugPrint('[EstudiantesService] Cuerpo de la respuesta de la API al actualizar: ${utf8.decode(response.bodyBytes)}');

      if (response.statusCode == 200) {
        // La API devuelve un JSON simple: {"editar_estudiante": true}
        // Basado en la modificación anterior, si devuelve true, significa éxito.
        // Ahora, queremos devolver el objeto Estudiante con los datos actualizados,
        // incluyendo los campos derivados (facultad, carrera, etc.) para que el UI pueda refrescarse.
        // Para esto, podemos hacer una nueva llamada GET o construir el objeto completo
        // asumiendo que los datos en 'estudiante' (el parámetro) son los correctos.
        // La opción más robusta y que asegura la coherencia con la DB es hacer un GET.
        try {
          final Map<String, dynamic> responseData = json.decode(utf8.decode(response.bodyBytes));
          final bool? editarEstudianteExitoso = responseData['editar_estudiante'] as bool?;

          if (editarEstudianteExitoso == true) {
            // Opción 1 (Recomendado): Hacer un GET para obtener el estudiante completo y actualizado
            // Esto asegura que cualquier campo generado por la DB (ej. fecha_actualizacion)
            // o campos derivados (facultad, carrera) estén actualizados.
            return await obtenerEstudiantePorId(estudiante.idEstudiante!);
          } else {
            throw Exception('La API indicó que la actualización del estudiante no fue exitosa.');
          }
        } catch (e) {
          throw Exception('Error al procesar la respuesta de la API al actualizar: ${e.toString()}');
        }
      } else {
        String errorMessage = 'Error desconocido al actualizar estudiante.';
        try {
          final errorBody = json.decode(utf8.decode(response.bodyBytes));
          if (errorBody is Map && errorBody.containsKey('errors')) {
            errorMessage = 'Errores de validación: ${errorBody['errors'].map((e) => e['msg']).join(', ')}';
          } else if (errorBody is Map && errorBody.containsKey('error')) {
            errorMessage = errorBody['error'];
          } else {
            errorMessage = utf8.decode(response.bodyBytes);
          }
        } catch (e) {
          errorMessage = utf8.decode(response.bodyBytes);
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
      throw Exception('Recurso no encontrado. URL: ${response.request?.url ?? "N/A"}. Mensaje del servidor: ${utf8.decode(response.bodyBytes)}');
    } else if (response.statusCode >= 400 && response.statusCode < 500) {
      // Errores del lado del cliente (4xx)
      throw Exception('Error de la aplicación (código ${response.statusCode}). Mensaje del servidor: ${utf8.decode(response.bodyBytes)}');
    } else if (response.statusCode >= 500 && response.statusCode < 600) {
      // Errores del lado del servidor (5xx)
      throw Exception('Error del servidor (código ${response.statusCode}). Mensaje del servidor: ${utf8.decode(response.bodyBytes)}');
    } else {
      // Otros códigos de estado HTTP no esperados
      throw Exception('Error desconocido (código ${response.statusCode}). Mensaje del servidor: ${utf8.decode(response.bodyBytes)}');
    }
  }
}