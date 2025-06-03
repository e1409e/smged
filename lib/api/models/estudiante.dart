import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:smged/layout/widgets/custom_data_table.dart';
import 'package:smged/layout/widgets/custom_colors.dart'; // Asegúrate de que esta importación sea correcta si la usas
import 'package:intl/intl.dart'; // Necesario para DateFormat

class Estudiante implements TableData {
  final int? idEstudiante;
  final String nombres;
  final String apellidos;
  final String cedula;
  final DateTime? fechaNacimiento;
  final String? correo;
  final String? telefono;
  final String? otroTelefono; // Nuevo campo
  final String? direccion;
  final String? observaciones;
  final String? seguimiento;
  final String? discapacidad; // Nombre de la discapacidad (desde 'discapacidad')
  final int? idDiscapacidad; // ID numérico de la discapacidad (desde 'discapacidad_id')
  final int? idCarrera;      // Nuevo campo (desde 'id_carrera')
  final bool? poseeConapdis; // Nuevo campo, necesita conversión int a bool (desde 'posee_conapdis')

  // Campos para visualización, no para enviar al backend (provienen de JOINs)
  final String? nombreRepre;    // Nuevo campo (desde 'nombre_repre')
  final String? nombreFacultad; // Nuevo campo (desde 'facultad')
  final String? siglasFacultad; // Nuevo campo (desde 'siglas')
  final String? nombreCarrera;  // Nuevo campo (desde 'carrera')
  final DateTime? fechaRegistro;
  final DateTime? fechaActualizacion; // No presente en tu JSON actual, pero lo mantengo si es necesario

  Estudiante({
    this.idEstudiante,
    required this.nombres,
    required this.apellidos,
    required this.cedula,
    this.fechaNacimiento,
    this.correo,
    this.telefono,
    this.otroTelefono,
    this.direccion,
    this.observaciones,
    this.seguimiento,
    this.discapacidad, // Nombre de la discapacidad (desde 'discapacidad')
    this.idDiscapacidad, // ID numérico de la discapacidad (desde 'discapacidad_id')
    this.idCarrera,
    this.poseeConapdis,
    this.nombreRepre,
    this.nombreFacultad,
    this.siglasFacultad,
    this.nombreCarrera,
    this.fechaRegistro,
    this.fechaActualizacion,
  });

  factory Estudiante.fromJson(Map<String, dynamic> json) {
    try {
      // Función auxiliar para convertir int (0/1) a bool
      bool? _parseBoolFromInt(dynamic value) {
        if (value == null) return null;
        if (value is int) {
          return value == 1; // 1 es true, 0 es false.
        }
        // Si por alguna razón viene como bool directamente (ej. durante testing), lo maneja
        if (value is bool) {
          return value;
        }
        return null; // O podrías lanzar un error si el tipo es inesperado
      }

      return Estudiante(
        idEstudiante: json['id_estudiante'] as int?,
        nombres: json['nombres'] as String,
        apellidos: json['apellidos'] as String,
        cedula: json['cedula'] as String,
        fechaNacimiento: json['fecha_nacimiento'] != null
            ? DateTime.parse(json['fecha_nacimiento'] as String) // Asegúrate de que es String
            : null,
        correo: json['correo'] as String?,
        telefono: json['telefono'] as String?,
        otroTelefono: json['otro_telefono'] as String?, // Mapeo del nuevo campo
        direccion: json['direccion'] as String?,
        observaciones: json['observaciones'] as String?,
        seguimiento: json['seguimiento'] as String?,
        discapacidad: json['discapacidad'] as String?,
        idDiscapacidad: json['discapacidad_id'] as int?,
        idCarrera: json['id_carrera'] as int?, // Mapeo del nuevo campo
        poseeConapdis: _parseBoolFromInt(json['posee_conapdis']), // Usa la función de conversión
        nombreRepre: json['nombre_repre'] as String?, // Mapeo del nuevo campo
        nombreFacultad: json['facultad'] as String?, // Mapeo del nuevo campo
        siglasFacultad: json['siglas'] as String?, // Mapeo del nuevo campo
        nombreCarrera: json['carrera'] as String?, // Mapeo del nuevo campo
        fechaRegistro: json['fecha_registro'] != null
            ? DateTime.parse(json['fecha_registro'] as String)
            : null,
        fechaActualizacion: json['fecha_actualizacion'] != null
            ? DateTime.parse(json['fecha_actualizacion'] as String)
            : null,
      );
    } catch (e) {
      debugPrint('Error al parsear Estudiante desde JSON: $e');
      debugPrint('JSON problemático: $json');
      rethrow; // Re-lanza el error para que la aplicación lo maneje
    }
  }

  Map<String, dynamic> toJson() {
    // Función auxiliar para convertir bool a int (0/1)
    int? _boolToInt(bool? value) {
      if (value == null) return null;
      return value ? 1 : 0; // true es 1, false es 0
    }

    return {
      if (idEstudiante != null) 'id_estudiante': idEstudiante,
      'nombres': nombres,
      'apellidos': apellidos,
      'cedula': cedula,
      'fecha_nacimiento': fechaNacimiento?.toIso8601String().split('T').first, // Solo la fecha YYYY-MM-DD
      'correo': correo,
      'telefono': telefono,
      'otro_telefono': otroTelefono, // Incluir si se envía al backend
      'direccion': direccion,
      'observaciones': observaciones,
      'seguimiento': seguimiento,
      'discapacidad_id': idDiscapacidad,
      'id_carrera': idCarrera, // Incluir si se envía al backend
      'posee_conapdis': _boolToInt(poseeConapdis), // Usar la función de conversión
      // Los campos como 'discapacidad', 'nombreRepre', 'nombreFacultad', etc.
      // no se incluyen aquí porque son datos para visualización que el backend
      // devuelve de JOINs y no se envían para crear/actualizar un estudiante.
    };
  }

  @override
  int get id {
    // Mantengo la solución del ID temporal. Puedes usar 0 si estás seguro
    // de que 0 nunca será un ID válido en tu base de datos y que no tendrás
    // múltiples estudiantes nulos en la misma tabla.
    return idEstudiante ?? (Object.hash(this, nombres, cedula).abs() + 1) * -1;
    // Si prefieres la versión simple que tenías antes:
    // return idEstudiante ?? 0;
  }

  @override
  List<DataCell> getCells(
    BuildContext context,
    List<DataColumn2> currentColumns,
    Map<String, Function(dynamic item)> actionCallbacks,
  ) {
    List<DataCell> cells = [];

    for (var column in currentColumns) {
      String? columnLabel;
      // Revisa si el label es Text directamente o está dentro de Center
      if (column.label is Text) {
        columnLabel = (column.label as Text).data;
      } else if (column.label is Center && (column.label as Center).child is Text) {
        columnLabel = ((column.label as Center).child as Text).data;
      }

      // Asegúrate de que columnLabel no sea nulo antes de usarlo en el switch
      if (columnLabel == null) {
        cells.add(const DataCell(Text('N/A')));
        continue;
      }

      switch (columnLabel) {
        case 'ID':
          cells.add(DataCell(Text(idEstudiante?.toString() ?? 'N/A')));
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
        case 'Fecha Nacimiento':
          cells.add(DataCell(Text(fechaNacimiento != null
              ? DateFormat('dd/MM/yyyy').format(fechaNacimiento!)
              : 'N/A')));
          break;
        case 'Teléfono':
          cells.add(DataCell(Text(telefono ?? 'N/A')));
          break;
        case 'Otro Teléfono': // Nuevo campo en la tabla si lo deseas
          cells.add(DataCell(Text(otroTelefono ?? 'N/A')));
          break;
        case 'Correo':
          cells.add(DataCell(Text(correo ?? 'N/A')));
          break;
        case 'Carrera': // Ahora usa 'nombreCarrera' del JOIN
          cells.add(DataCell(Text(nombreCarrera ?? 'N/A')));
          break;
        case 'Discapacidad':
          cells.add(DataCell(Text(discapacidad ?? 'N/A')));
          break;
        case 'Posee CONAPDIS': // Nuevo campo en la tabla
          cells.add(DataCell(Text(poseeConapdis == true ? 'Sí' : (poseeConapdis == false ? 'No' : 'N/A'))));
          break;
        case 'Observaciones':
          cells.add(DataCell(Text(observaciones ?? 'N/A')));
          break;
        case 'Seguimiento':
          cells.add(DataCell(Text(seguimiento ?? 'N/A')));
          break;
        case 'Representante': // Nuevo campo en la tabla
          cells.add(DataCell(Text(nombreRepre ?? 'N/A')));
          break;
        case 'Facultad': // Nuevo campo en la tabla
          cells.add(DataCell(Text(nombreFacultad ?? 'N/A')));
          break;
        case 'Siglas Facultad': // Nuevo campo en la tabla
          cells.add(DataCell(Text(siglasFacultad ?? 'N/A')));
          break;
        case 'Fecha Registro': // Nuevo campo en la tabla
          cells.add(DataCell(Text(fechaRegistro != null
              ? DateFormat('dd/MM/yyyy HH:mm').format(fechaRegistro!)
              : 'N/A')));
          break;
        case 'Info':
          cells.add(
            DataCell(
              Align(
                alignment: Alignment.center,
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
                alignment: Alignment.center,
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