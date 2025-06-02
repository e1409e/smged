// lib/api/models/login_response.dart
import 'package:json_annotation/json_annotation.dart';

part 'login_response.g.dart';

/// Clase que representa el cuerpo de la respuesta de la API al intentar un login.
/// Será utilizada para deserializar (convertir de JSON a objeto Dart) los datos
/// que recibes de tu API de Node.js.
@JsonSerializable() // Anotación para que 'json_serializable' genere el código.
class LoginResponse {
  final String message;
  final bool success;
  // ¡Añade esta línea para incluir el rol en la respuesta!
  final String? rol; // El '?' indica que puede ser nulo, si tu API lo permite así.

  /// Constructor para crear una instancia de LoginResponse.
  LoginResponse({
    required this.message,
    required this.success,
    this.rol, // ¡Añádelo también al constructor!
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