// lib/api/models/estudiante.dart
import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:smged/layout/widgets/custom_data_table.dart';
import 'package:smged/layout/widgets/custom_colors.dart';

class Estudiante implements TableData {
  final int? idEstudiante;
  final String nombres;
  final String apellidos;
  final String cedula;
  final DateTime? fechaNacimiento;
  final String? correo;
  final String? telefono;
  final String? direccion;
  final String? observaciones;
  final String? seguimiento;
  final String? discapacidad; // Campo para el NOMBRE de la discapacidad (para visualización)
  final int? idDiscapacidad; // ¡NUEVO CAMPO! Para el ID numérico de la discapacidad (para guardar/editar)
  final DateTime? fechaRegistro;
  final DateTime? fechaActualizacion;

  Estudiante({
    this.idEstudiante,
    required this.nombres,
    required this.apellidos,
    required this.cedula,
    this.fechaNacimiento,
    this.correo,
    this.telefono,
    this.direccion,
    this.observaciones,
    this.seguimiento,
    this.discapacidad, // Puede ser nulo si la API no lo envía al crear o si no lo necesitas siempre
    this.idDiscapacidad, // ¡NUEVO: Este puede ser nulo en fromJson si no siempre viene, pero es requerido para el POST/PUT!
    this.fechaRegistro,
    this.fechaActualizacion,
  });

  factory Estudiante.fromJson(Map<String, dynamic> json) {
    try {
      return Estudiante(
        idEstudiante: json['id_estudiante'] as int?,
        nombres: json['nombres'] as String,
        apellidos: json['apellidos'] as String,
        cedula: json['cedula'] as String,
        fechaNacimiento: json['fecha_nacimiento'] != null
            ? DateTime.parse(json['fecha_nacimiento'])
            : null,
        correo: json['correo'] as String?,
        telefono: json['telefono'] as String?,
        direccion: json['direccion'] as String?,
        observaciones: json['observaciones'] as String?,
        seguimiento: json['seguimiento'] as String?,
        discapacidad: json['discapacidad'] as String?, // Nombre de la discapacidad
        idDiscapacidad: json['discapacidad_id'] as int?, // ¡NUEVO: ID de la discapacidad desde la API!
        fechaRegistro: json['fecha_registro'] != null
            ? DateTime.parse(json['fecha_registro'])
            : null,
        fechaActualizacion: json['fecha_actualizacion'] != null
            ? DateTime.parse(json['fecha_actualizacion'])
            : null,
      );
    } catch (e) {
      debugPrint('Error al parsear Estudiante desde JSON: $e');
      debugPrint('JSON problemático: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      // 'id_estudiante': idEstudiante, // No incluyas idEstudiante para operaciones POST (crear)
      // Si tu API espera el ID para las operaciones PUT (actualizar), puedes incluirlo condicionalmente:
      if (idEstudiante != null) 'id_estudiante': idEstudiante,
      
      'nombres': nombres,
      'apellidos': apellidos,
      'cedula': cedula,
      // Asegúrate de que la API espere 'fecha_nacimiento' en este formato
      'fecha_nacimiento': fechaNacimiento?.toIso8601String().split('T')[0], // Formato 'YYYY-MM-DD'
      'correo': correo,
      'telefono': telefono,
      'direccion': direccion,
      'observaciones': observaciones,
      'seguimiento': seguimiento,
      // 'discapacidad': discapacidad, // No envíes el NOMBRE de la discapacidad en el payload de guardado
      'discapacidad_id': idDiscapacidad, // ¡ENVÍA EL ID!
      
      // 'fecha_registro': fechaRegistro?.toIso8601String(), // La API suele manejar esto automáticamente en POST
      // 'fecha_actualizacion': fechaActualizacion?.toIso8601String(), // La API suele manejar esto automáticamente en POST
    };
  }

  @override
  int get id => idEstudiante ?? 0; // Si idEstudiante es nulo, devuelve 0 o un valor por defecto.

  @override
  List<DataCell> getCells(
    BuildContext context,
    List<DataColumn2> currentColumns,
    Map<String, Function(dynamic item)> actionCallbacks,
  ) {
    List<DataCell> cells = [];

    for (var column in currentColumns) {
      final columnLabel = (column.label as Text).data;

      switch (columnLabel) {
        case 'ID':
          cells.add(DataCell(Text(idEstudiante.toString())));
          break;
        case 'Nombres':
          cells.add(DataCell(Text(nombres)));
          break;
        case 'Apellidos':
          cells.add(DataCell(Text(apellidos)));
          break;
        case 'Cédula':
          cells.add(DataCell(Text(cedula)));
          break;
        case 'Discapacidad': // Asegúrate de que tu CustomDataTable tiene esta columna
          cells.add(DataCell(Text(discapacidad ?? 'N/A'))); // Muestra el nombre
          break;
        case 'Info':
          cells.add(
            DataCell(
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.info_outline, size: 25, color: AppColors.primary),
                  tooltip: 'Ver información del estudiante',
                  onPressed: () {
                    actionCallbacks['info']?.call(this);
                  },
                ),
              ),
            ),
          );
          break;
        case 'Acciones':
          cells.add(
            DataCell(
              Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(Icons.edit, size: 25, color: AppColors.primary),
                      tooltip: 'Editar estudiante',
                      onPressed: () {
                        actionCallbacks['edit']?.call(this);
                      },
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(Icons.delete, size: 25, color: AppColors.error),
                      tooltip: 'Eliminar estudiante',
                      onPressed: () {
                        actionCallbacks['delete']?.call(this);
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
          break;
        default:
          cells.add(const DataCell(Text('N/A')));
      }
    }
    return cells;
  }
}