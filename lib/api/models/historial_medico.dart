// lib/api/models/historial_medico.dart
import 'package:flutter/material.dart'; // Mantener si se usa en getCells para algo visual
import 'package:data_table_2/data_table_2.dart';
import 'package:smged/layout/widgets/custom_data_table.dart';
import 'package:smged/layout/widgets/custom_colors.dart';

class HistorialMedico implements TableData {
  final int idHistorialMedico;
  final int idEstudiante;
  final String certificadoConapdis;
  final String informeMedico;
  final String tratamiento;
  final DateTime fechaCreacion;
  final DateTime fechaActualizacion;

  HistorialMedico({
    required this.idHistorialMedico,
    required this.idEstudiante,
    required this.certificadoConapdis,
    required this.informeMedico,
    required this.tratamiento,
    required this.fechaCreacion,
    required this.fechaActualizacion,
  });

  factory HistorialMedico.fromJson(Map<String, dynamic> json) {
    String parsedCertificadoConapdis;
    if (json['certificado_conapdis'] != null) {
      parsedCertificadoConapdis = json['certificado_conapdis'].toString();
    } else {
      parsedCertificadoConapdis = '';
    }

    return HistorialMedico(
      idHistorialMedico: json['id_historialmedico'],
      idEstudiante: json['id_estudiante'],
      certificadoConapdis: parsedCertificadoConapdis,
      informeMedico: json['informe_medico'] ?? '',
      tratamiento: json['tratamiento'] ?? '',
      // >>> Esto es lo que resuelve la ausencia de fechas en el JSON <<<
      fechaCreacion: json['fecha_creacion'] != null
          ? DateTime.parse(json['fecha_creacion'])
          : DateTime.now(), // Fallback
      fechaActualizacion: json['fecha_actualizacion'] != null
          ? DateTime.parse(json['fecha_actualizacion'])
          : DateTime.now(), // Fallback
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_historialmedico': idHistorialMedico,
      'id_estudiante': idEstudiante,
      'certificado_conapdis': certificadoConapdis, // Directamente String
      'informe_medico': informeMedico,
      'tratamiento': tratamiento,
    };
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'id_estudiante': idEstudiante,
      'certificado_conapdis': certificadoConapdis, // Directamente String
      'informe_medico': informeMedico,
      'tratamiento': tratamiento,
    };
  }

  @override
  int get id => idHistorialMedico;

  @override
  List<DataCell> getCells(
    BuildContext context,
    List<DataColumn2> currentColumns,
    Map<String, Function(dynamic item)> actionCallbacks,
  ) {
    final List<DataCell> cells = [];

    String fechaCreacionFormateada =
        '${fechaCreacion.day.toString().padLeft(2, '0')}/${fechaCreacion.month.toString().padLeft(2, '0')}/${fechaCreacion.year}';
    String fechaActualizacionFormateada =
        '${fechaActualizacion.day.toString().padLeft(2, '0')}/${fechaActualizacion.month.toString().padLeft(2, '0')}/${fechaActualizacion.year}';

    for (var col in currentColumns) {
      // Importante: El label de la columna debe coincidir exactamente con el 'case'
      switch (col.label is Text ? (col.label as Text).data : '') {
        case 'ID Historial':
          cells.add(DataCell(Text(idHistorialMedico.toString())));
          break;
        case 'ID Estudiante':
          cells.add(DataCell(Text(idEstudiante.toString())));
          break;
        case 'Certificado CONAPDIS':
          Color conapdisColor = certificadoConapdis == 'Sí' ? AppColors.success : AppColors.error;
          cells.add(DataCell(
            Chip(
              label: Text(
                certificadoConapdis,
                style: TextStyle(
                  color: conapdisColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: Colors.grey[200],
              padding: const EdgeInsets.all(1),
            ),
          ));
          break;
        case 'Informe Médico':
          cells.add(DataCell(
            Container(
              constraints: const BoxConstraints(maxWidth: 200),
              child: Text(informeMedico, overflow: TextOverflow.ellipsis, maxLines: 2),
            ),
          ));
          break;
        case 'Tratamiento':
          cells.add(DataCell(
            Container(
              constraints: const BoxConstraints(maxWidth: 200),
              child: Text(tratamiento, overflow: TextOverflow.ellipsis, maxLines: 2),
            ),
          ));
          break;
        case 'Fecha Creación':
          cells.add(DataCell(Text(fechaCreacionFormateada)));
          break;
        case 'Fecha Actualización':
          cells.add(DataCell(Text(fechaActualizacionFormateada)));
          break;
        case 'Acciones': // >>> ¡Esta es la etiqueta que debe coincidir! <<<
          cells.add(DataCell(
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Estos 'if' controlan si el callback fue proporcionado por el CustomDataTable
                if (actionCallbacks.containsKey('info'))
                  IconButton(
                    icon: const Icon(Icons.info, color: Colors.blue),
                    onPressed: () => actionCallbacks['info']!(this),
                    tooltip: 'Ver información',
                  ),
                if (actionCallbacks.containsKey('edit'))
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.orange),
                    onPressed: () => actionCallbacks['edit']!(this),
                    tooltip: 'Editar',
                  ),
                if (actionCallbacks.containsKey('delete'))
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => actionCallbacks['delete']!(this),
                    tooltip: 'Eliminar',
                  ),
              ],
            ),
          ));
          break;
        default:
          cells.add(const DataCell(Text('N/A')));
          break;
      }
    }
    return cells;
  }
}