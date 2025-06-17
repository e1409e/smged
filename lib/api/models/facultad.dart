// lib/api/models/facultad.dart
import 'carrera.dart';

class Facultad {
  final int idFacultad;
  final String facultad;
  final String siglas;
  final List<Carrera> carreras;

  Facultad({
    required this.idFacultad,
    required this.facultad,
    required this.siglas,
    required this.carreras,
  });

  factory Facultad.fromJson(Map<String, dynamic> json) {
    return Facultad(
      idFacultad: json['id_facultad'],
      facultad: json['facultad'],
      siglas: json['siglas'],
      carreras: (json['carreras'] as List<dynamic>?)
              ?.map((c) => Carrera.fromJson(c))
              .toList() ??
          [],
    );
  }
}