// lib/api/models/carrera.dart
class Carrera {
  final int idCarrera;
  final String carrera;
  final int idFacultad;
  final String nombreFacultad;

  Carrera({
    required this.idCarrera,
    required this.carrera,
    required this.idFacultad,
    required this.nombreFacultad,
  });

  factory Carrera.fromJson(Map<String, dynamic> json) {
    return Carrera(
      idCarrera: json['id_carrera'],
      carrera: json['carrera'],
      idFacultad: json['id_facultad'],
      nombreFacultad: json['facultad'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_carrera': idCarrera,
      'carrera': carrera,
      'id_facultad': idFacultad,
    };
  }
}
