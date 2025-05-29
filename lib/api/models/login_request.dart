import 'package:json_annotation/json_annotation.dart';

// Este es un "part" directive especial. Le dice a 'build_runner' que este archivo
// es parte de 'login_request.g.dart'. El archivo 'g.dart' será generado automáticamente
// y contendrá la lógica para convertir entre objetos Dart y JSON.
part 'login_request.g.dart';

/// Clase que representa el cuerpo de la petición POST para el login.
/// Será utilizada para serializar (convertir a JSON) los datos de la cédula y contraseña
/// antes de enviarlos a tu API de Node.js.
@JsonSerializable() // Anotación que indica a 'json_serializable' que genere código para esta clase.
class LoginRequest {
  // Asegúrate de que los nombres de estas propiedades (cedula, contrasena)
  // coincidan exactamente con los nombres de los campos que tu API de Node.js espera
  // en el cuerpo de la petición POST.
  final String cedula_usuario;
  final String password; // <- Este nombre debe coincidir con tu API

  /// Constructor para crear una instancia de LoginRequest.
  LoginRequest({required this.cedula_usuario, required this.password});

  /// Un constructor de fábrica que permite crear una instancia de `LoginRequest`
  /// a partir de un mapa Dart (que es la representación de un objeto JSON).
  /// El método `_$LoginRequestFromJson` será generado automáticamente por `json_serializable`.
  factory LoginRequest.fromJson(Map<String, dynamic> json) => _$LoginRequestFromJson(json);

  /// Un método que permite convertir esta instancia de `LoginRequest`
  /// a un mapa Dart (para luego convertirlo a JSON y enviarlo a la API).
  /// El método `_$LoginRequestToJson` será generado automáticamente por `json_serializable`.
  Map<String, dynamic> toJson() => _$LoginRequestToJson(this);
}