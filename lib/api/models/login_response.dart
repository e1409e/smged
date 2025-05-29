import 'package:json_annotation/json_annotation.dart';

// Importante: La parte que el generador de código creará.
part 'login_response.g.dart';

/// Clase que representa el cuerpo de la respuesta de la API al intentar un login.
/// Será utilizada para deserializar (convertir de JSON a objeto Dart) los datos
/// que recibes de tu API de Node.js.
@JsonSerializable() // Anotación para que 'json_serializable' genere el código.
class LoginResponse {
  // Asegúrate de que los nombres de estas propiedades (message, success)
  // coincidan exactamente con los nombres de los campos que tu API de Node.js devuelve
  // en el JSON de respuesta.
  final String message;
  final bool success;
  // Si tu API devuelve un token u otros datos en la respuesta de login,
  // puedes añadirlos aquí, por ejemplo:
  // final String? token;
  // final User? user; // Si tienes un modelo User

  /// Constructor para crear una instancia de LoginResponse.
  LoginResponse({
    required this.message,
    required this.success,
    // this.token, // Si lo incluyes arriba, añádelo aquí también
    // this.user,
  });

  /// Un constructor de fábrica que permite crear una instancia de `LoginResponse`
  /// a partir de un mapa Dart (representación de un objeto JSON).
  /// El método `_$LoginResponseFromJson` será generado automáticamente.
  factory LoginResponse.fromJson(Map<String, dynamic> json) => _$LoginResponseFromJson(json);

  /// Un método que permite convertir esta instancia de `LoginResponse`
  /// a un mapa Dart (útil si alguna vez necesitas serializarlo de nuevo a JSON,
  /// aunque menos común para respuestas).
  /// El método `_$LoginResponseToJson` será generado automáticamente.
  Map<String, dynamic> toJson() => _$LoginResponseToJson(this);
}