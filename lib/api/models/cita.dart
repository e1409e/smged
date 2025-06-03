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

  // --- Método copyWith para Cita ---
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
      nombre_estudiante:
          nombre_estudiante ?? this.nombre_estudiante, // Añade esto
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
    String? columnLabel;
    // --- INICIO DEL CAMBIO ---
    if (column.label is Text) {
      // Si el label es directamente un Text (caso original)
      columnLabel = (column.label as Text).data;
    } else if (column.label is Center && (column.label as Center).child is Text) {
      // Si el label es un Center y su hijo es un Text (caso actual de 'Acciones'/'Info')
      columnLabel = ((column.label as Center).child as Text).data;
    }
    // --- FIN DEL CAMBIO ---

    // Asegúrate de que columnLabel no sea nulo antes de usarlo en el switch
    if (columnLabel == null) {
      cells.add(const DataCell(Text('N/A')));
      continue; // Pasa a la siguiente columna
    }

    switch (columnLabel) {
      case 'ID':
        cells.add(DataCell(Text(id_citas?.toString() ?? 'N/A')));
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
      case 'Realizada':
        cells.add(
          DataCell(
            Align(
              alignment: Alignment.center,
              child: Icon(
                pendiente == 1
                    ? Icons.cancel_outlined
                    : Icons.check_circle_outline,
                color: pendiente == 1 ? Colors.blue : Colors.green,
              ),
            ),
          ),
        );
        break;

      case 'Info':
        cells.add(
          DataCell(
            Align(
              alignment: Alignment.center,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (actionCallbacks.containsKey('info'))
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(
                        Icons.info_outline,
                        size: 25,
                        color: AppColors.info,
                      ),
                      tooltip: 'Ver detalles de la cita',
                      onPressed: () {
                        actionCallbacks['info']?.call(this);
                      },
                    ),
                ],
              ),
            ),
          ),
        );
        break;

      case 'Acciones':
        cells.add(
          DataCell(
            Align(
              alignment: Alignment.center,
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
                  const SizedBox(width: 0),
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
                  const SizedBox(width: 0),
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: Icon(
                      Icons.task_alt,
                      size: 25,
                      color: pendiente == 1
                          ? AppColors.info
                          : Colors.grey,
                    ),
                    tooltip: pendiente == 1
                        ? 'Marcar como realizada'
                        : 'Cita ya realizada',
                    onPressed: pendiente == 1
                        ? () {
                            actionCallbacks['mark_realized']?.call(this);
                          }
                        : null,
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
