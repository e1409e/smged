// lib/api/models/estudiante.dart
import 'package:flutter/material.dart'; // Necesario para debugPrint, BuildContext, Text, DataCell
import 'package:data_table_2/data_table_2.dart'; // Necesario para DataColumn2
import 'package:smged/layout/widgets/custom_data_table.dart'; // Necesario para TableData

class Estudiante implements TableData {
  // === CAMBIO CLAVE 1: Asegúrate de que 'idEstudiante' puede recibir null si la API lo manda como tal
  // Y si el constructor lo requiere, es porque la API *siempre* debería mandarlo.
  // Pero el error sugiere que no es así. Mantengámoslo int pero seamos más robustos en fromJson.
  final int idEstudiante;
  final String nombres;
  final String apellidos;
  final String cedula;
  final DateTime? fechaNacimiento;
  final String? correo;
  final String? telefono;
  final String? direccion;
  final String? observaciones;
  final String? seguimiento;
  // === CAMBIO CLAVE 2: Elimina discapacidadId si la API ya no lo envía ===
  // final int? discapacidadId; // Eliminar si ya no lo usas
  final String? discapacidad; // Propiedad para el nombre de la discapacidad (String)
  final DateTime? fechaRegistro;
  final DateTime? fechaActualizacion;

  Estudiante({
    required this.idEstudiante,
    required this.nombres,
    required this.apellidos,
    required this.cedula,
    this.fechaNacimiento,
    this.correo,
    this.telefono,
    this.direccion,
    this.observaciones,
    this.seguimiento,
    // Elimina este parámetro si eliminaste la propiedad discapacidadId
    // this.discapacidadId,
    this.discapacidad,
    this.fechaRegistro,
    this.fechaActualizacion,
  });

  factory Estudiante.fromJson(Map<String, dynamic> json) {
    debugPrint('JSON recibido para Estudiante: $json'); // LÍNEA DE DEPURACIÓN

    try {
      return Estudiante(
        // === CAMBIO CRÍTICO 1: Usar 'id_estudiante' del JSON ===
        // Si el JSON viene con 'id_estudiante' (con guion bajo), así debe ser el mapeo.
        // Usamos 'as int? ?? 0' para seguridad si por alguna razón sigue viniendo null.
        idEstudiante: json['id_estudiante'] as int? ?? 0,

        nombres: json['nombres'] as String,
        apellidos: json['apellidos'] as String,
        cedula: json['cedula'] as String,
        fechaNacimiento: json['fecha_nacimiento'] != null // === ¡REVISAR ESTO TAMBIÉN! ===
            ? DateTime.parse(json['fecha_nacimiento'])
            : null,
        correo: json['correo'] as String?,
        telefono: json['telefono'] as String?,
        direccion: json['direccion'] as String?,
        observaciones: json['observaciones'] as String?,
        seguimiento: json['seguimiento'] as String?,
        // === CAMBIO CRÍTICO 2: Eliminar la asignación de discapacidadId si no existe en el JSON ===
        // discapacidadId: json['discapacidadId'] as int?, // Eliminar o comentar esta línea
        discapacidad: json['discapacidad'] as String?, // Esta línea está bien
        fechaRegistro: json['fecha_registro'] != null // === ¡REVISAR ESTO TAMBIÉN! ===
            ? DateTime.parse(json['fecha_registro'])
            : null,
        fechaActualizacion: json['fecha_actualizacion'] != null // === ¡REVISAR ESTO TAMBIÉN! ===
            ? DateTime.parse(json['fecha_actualizacion'])
            : null,
      );
    } catch (e) {
      debugPrint('Error al parsear Estudiante desde JSON: $e');
      debugPrint('JSON problemático: $json');
      rethrow;
    }
  }

  // Método para convertir el objeto Estudiante a un Map JSON (para POST/PUT)
  Map<String, dynamic> toJson() {
    return {
      // === REVISAR ESTO PARA TU API DE ENVÍO ===
      // Si tu API para crear/actualizar usa 'idEstudiante' (camelCase) o 'id_estudiante' (snake_case)
      'idEstudiante': idEstudiante, // O 'id_estudiante': idEstudiante,
      'nombres': nombres,
      'apellidos': apellidos,
      'cedula': cedula,
      'fechaNacimiento': fechaNacimiento?.toIso8601String(),
      'correo': correo,
      'telefono': telefono,
      'direccion': direccion,
      'observaciones': observaciones,
      'seguimiento': seguimiento,
      // === ELIMINAR si ya no envías discapacidadId ===
      // 'discapacidadId': discapacidadId,
      // Si la API espera el nombre de la discapacidad al enviar:
      'discapacidad': discapacidad,
      'fechaRegistro': fechaRegistro?.toIso8601String(),
      'fechaActualizacion': fechaActualizacion?.toIso8601String(),
    };
  }

  // Implementación de la interfaz TableData
  @override
  int get id => idEstudiante;

  @override
  List<DataCell> getCells(BuildContext context, List<DataColumn2> currentColumns) {
    List<DataCell> cells = [];

    for (var column in currentColumns) {
      final columnLabel = (column.label as Text).data;

      if (columnLabel == 'ID') {
        cells.add(DataCell(Text(idEstudiante.toString())));
      } else if (columnLabel == 'Nombres') {
        cells.add(DataCell(Text(nombres)));
      } else if (columnLabel == 'Apellidos') {
        cells.add(DataCell(Text(apellidos)));
      } else if (columnLabel == 'Cédula') {
        cells.add(DataCell(Text(cedula)));
      }
    }
    return cells;
  }
}