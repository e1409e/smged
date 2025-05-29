import 'package:json_annotation/json_annotation.dart';

part 'cita.g.dart'; // Se generará automáticamente

@JsonSerializable()
class Cita {
  final int id_citas;
  final int id_estudiante;
  final DateTime fecha_cita;
  final String? motivo_cita; // Puede ser nulo
  final int pendiente; // Agregamos el campo pendiente

  Cita({
    required this.id_citas,
    required this.id_estudiante,
    required this.fecha_cita,
    this.motivo_cita,
    required this.pendiente,
  });

  factory Cita.fromJson(Map<String, dynamic> json) => _$CitaFromJson(json);
  Map<String, dynamic> toJson() => _$CitaToJson(this);
}