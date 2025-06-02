// lib/api/models/cita.dart
import 'package:json_annotation/json_annotation.dart';
import 'package:flutter/material.dart'; // Necesario para DataCell, Text, Icon, etc.
import 'package:data_table_2/data_table_2.dart'; // Necesario para DataColumn2
import 'package:smged/layout/widgets/custom_data_table.dart'; // Necesario para TableData
import 'package:smged/layout/widgets/custom_colors.dart'; // Necesario para AppColors

part 'cita.g.dart'; // Se generará automáticamente

@JsonSerializable()
class Cita implements TableData {
  final int? id_citas;
  final int id_estudiante;

  // ¡NUEVO CAMPO! Mapea 'nombres' de la API y no lo incluyas al serializar a JSON para enviar al backend.
  @JsonKey(name: 'nombres', includeToJson: false)
  final String? nombre_estudiante;

  @JsonKey(
    name: 'fecha_cita',
    fromJson: _dateTimeFromJson,
    toJson: _dateTimeToJson,
  )
  final DateTime fecha_cita;

  final String? motivo_cita;
  final int pendiente;

  Cita({
    this.id_citas,
    required this.id_estudiante,
    this.nombre_estudiante, // Añade al constructor para que pueda ser inicializado
    required this.fecha_cita,
    this.motivo_cita,
    required this.pendiente,
  });

  factory Cita.fromJson(Map<String, dynamic> json) => _$CitaFromJson(json);
  Map<String, dynamic> toJson() => _$CitaToJson(this);

  // --- Helpers para DateTime para Cita ---
  static DateTime _dateTimeFromJson(String json) {
    return DateTime.parse(json);
  }

  static String _dateTimeToJson(DateTime date) {
    return date.toIso8601String().split('T')[0]; // Formato 'YYYY-MM-DD'
  }
  // --- FIN Helpers para DateTime para Cita ---

  // *******************************************************************
  // ** ESTE ES EL MÉTODO 'copyWith' QUE DEBES AÑADIR A TU MODELO CITA **
  // *******************************************************************
  Cita copyWith({
    int? id_citas,
    int? id_estudiante,
    DateTime? fecha_cita,
    String? motivo_cita,
    int? pendiente,
    String? nombre_estudiante, // También incluye el nuevo campo aquí
  }) {
    return Cita(
      id_citas: id_citas ?? this.id_citas,
      id_estudiante: id_estudiante ?? this.id_estudiante,
      fecha_cita: fecha_cita ?? this.fecha_cita,
      motivo_cita: motivo_cita ?? this.motivo_cita,
      pendiente: pendiente ?? this.pendiente,
      nombre_estudiante: nombre_estudiante ?? this.nombre_estudiante, // Añade esto
    );
  }

  @override
  int get id => id_citas ?? 0; // Implementación de TableData

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
          cells.add(DataCell(Text(id_citas?.toString() ?? 'N/A'))); // Usa ?. para seguridad
          break;
        case 'Estudiante':
          cells.add(DataCell(Text(nombre_estudiante ?? 'N/A')));
          break;
        case 'Fecha Cita':
          cells.add(
            DataCell(Text(fecha_cita.toLocal().toString().split(' ')[0])),
          );
          break;
        case 'Motivo':
          cells.add(DataCell(Text(motivo_cita ?? 'N/A')));
          break;
        case 'Pendiente':
          cells.add(
            DataCell(
              Icon(
                pendiente == 1
                    ? Icons.check_circle_outline
                    : Icons.cancel_outlined,
                color: pendiente == 1 ? Colors.green : Colors.red,
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
                      icon: const Icon(
                        Icons.edit,
                        size: 25,
                        color: AppColors.primary,
                      ),
                      tooltip: 'Editar cita',
                      onPressed: () {
                        actionCallbacks['edit']?.call(this);
                      },
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(
                        Icons.delete,
                        size: 25,
                        color: AppColors.error,
                      ),
                      tooltip: 'Eliminar cita',
                      onPressed: () {
                        actionCallbacks['delete']?.call(this);
                      },
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: Icon(
                        Icons.task_alt,
                        size: 25,
                        color: pendiente == 1
                            ? AppColors.info // Un color diferente para indicar que se puede marcar
                            : Colors.grey, // Deshabilitar/gris si ya está realizada
                      ),
                      tooltip: pendiente == 1
                          ? 'Marcar como realizada'
                          : 'Cita ya realizada',
                      onPressed: pendiente == 1
                          ? () {
                              actionCallbacks['mark_realized']?.call(this);
                            }
                          : null, // Deshabilitar si ya está pendiente=0
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