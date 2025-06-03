// lib/api/models/carrera.dart
class Carrera {
  final int idCarrera;
  final String carrera;
  final int? idFacultad; // Este sí viene en la tabla 'carreras'

  Carrera({
    required this.idCarrera,
    required this.carrera,
    this.idFacultad, // Hazlo opcional por si acaso, aunque en DB sea NOT NULL o siempre venga
  });

  factory Carrera.fromJson(Map<String, dynamic> json) {
    return Carrera(
      idCarrera: json['id_carrera'],
      carrera: json['carrera'],
      idFacultad: json['id_facultad'], // Incluye este campo
    );
  }
}