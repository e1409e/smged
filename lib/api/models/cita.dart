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
          cells.add(DataCell(Text(id_citas.toString())));
          break;
        case 'Estudiante': // ¡NUEVA COLUMNA PARA LA TABLA!
          cells.add(DataCell(Text(nombre_estudiante ?? 'N/A')));
          break;
        case 'Fecha Cita':
          cells.add(
            DataCell(Text(fecha_cita.toLocal().toString().split(' ')[0])),
          ); // Formato solo fecha
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
                    // ¡NUEVO BOTÓN! Para marcar como realizada
                    const SizedBox(width: 4),
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: Icon(
                        Icons.task_alt, // Icono para "realizado"
                        size: 25,
                        color: pendiente == 1
                            ? Colors.grey
                            : AppColors
                                  .primary, // Deshabilitar/cambiar color si ya está realizada
                      ),
                      tooltip: pendiente == 1
                          ? 'Cita ya realizada'
                          : 'Marcar como realizada',
                      onPressed: pendiente == 1
                          ? null
                          : () {
                              // Deshabilitar si ya está pendiente=0
                              actionCallbacks['mark_realized']?.call(this);
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
