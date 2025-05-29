// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cita.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Cita _$CitaFromJson(Map<String, dynamic> json) => Cita(
  id_citas: (json['id_citas'] as num).toInt(),
  id_estudiante: (json['id_estudiante'] as num).toInt(),
  fecha_cita: DateTime.parse(json['fecha_cita'] as String),
  motivo_cita: json['motivo_cita'] as String?,
  pendiente: (json['pendiente'] as num).toInt(),
);

Map<String, dynamic> _$CitaToJson(Cita instance) => <String, dynamic>{
  'id_citas': instance.id_citas,
  'id_estudiante': instance.id_estudiante,
  'fecha_cita': instance.fecha_cita.toIso8601String(),
  'motivo_cita': instance.motivo_cita,
  'pendiente': instance.pendiente,
};
