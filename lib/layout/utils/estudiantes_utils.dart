// lib/layout/utils/estudiantes_utils.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Importar para formateo de fechas más robusto
import 'package:smged/api/models/estudiante.dart'; // Asegúrate de importar tu modelo Estudiante
import 'package:smged/layout/widgets/custom_colors.dart'; // Para usar AppColors

class EstudiantesUtils {
  static void showEstudianteInfoModal(BuildContext context, dynamic item) {
    // Es crucial castear el item a Estudiante para acceder a sus propiedades.
    final estudiante = item as Estudiante;

    // Formateador de fechas
    final DateFormat formatter = DateFormat('dd/MM/yyyy');
    final DateFormat dateTimeFormatter = DateFormat('dd/MM/yyyy HH:mm'); // Para fecha y hora de registro

    String fechaNacimientoFormateada = estudiante.fechaNacimiento != null
        ? formatter.format(estudiante.fechaNacimiento!)
        : 'N/A';

    String fechaRegistroFormateada = estudiante.fechaRegistro != null
        ? dateTimeFormatter.format(estudiante.fechaRegistro!) // Usar el formateador de fecha y hora
        : 'N/A';

    // Para el estado de CONAPDIS
    String conapdisEstado = estudiante.poseeConapdis == true ? 'Sí' : (estudiante.poseeConapdis == false ? 'No' : 'N/A');
    Color conapdisColor = estudiante.poseeConapdis == true ? AppColors.success : AppColors.error;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Información Detallada del Estudiante'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                // --- SECCIÓN DE INFORMACIÓN PERSONAL ---
                _buildInfoRow('ID Estudiante:', estudiante.idEstudiante?.toString() ?? 'N/A'),
                _buildInfoRow('Nombres:', estudiante.nombres),
                _buildInfoRow('Apellidos:', estudiante.apellidos),
                _buildInfoRow('Cédula:', estudiante.cedula),
                _buildInfoRow('Fecha de Nacimiento:', fechaNacimientoFormateada),
                _buildInfoRow('Correo:', estudiante.correo ?? 'N/A'),
                _buildInfoRow('Teléfono Principal:', estudiante.telefono ?? 'N/A'),
                _buildInfoRow('Otro Teléfono:', estudiante.otroTelefono ?? 'N/A'), // Nuevo
                _buildMultilineInfo('Dirección:', estudiante.direccion ?? 'N/A'), // Mejorado para dirección
                const Divider(), // Separador para legibilidad

                // --- SECCIÓN DE INFORMACIÓN ACADÉMICA Y DE SALUD ---
                _buildInfoRow('Discapacidad:', estudiante.discapacidad ?? 'N/A'), // Usar el nombre de la discapacidad
                _buildInfoRow('Carrera:', estudiante.nombreCarrera ?? 'N/A'), // Nuevo
                _buildInfoRow('Facultad:', '${estudiante.nombreFacultad ?? 'N/A'} (${estudiante.siglasFacultad ?? 'N/A'})'), // Nuevo
                _buildInfoRow('Representante:', estudiante.nombreRepre ?? 'N/A'), // Nuevo

                // Mostrar "Posee CONAPDIS" con un Chip similar al de Citas
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    children: [
                      const Text(
                        'Posee CONAPDIS: ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Chip(
                        label: Text(
                          conapdisEstado,
                          style: TextStyle(color: conapdisColor, fontWeight: FontWeight.bold),
                        ),
                        backgroundColor: Colors.grey[200],
                        padding: const EdgeInsets.all(1),
                      ),
                    ],
                  ),
                ),
                const Divider(),

                // --- SECCIÓN DE OBSERVACIONES Y SEGUIMIENTO ---
                _buildMultilineInfo('Observaciones:', estudiante.observaciones ?? 'N/A'),
                _buildMultilineInfo('Seguimiento:', estudiante.seguimiento ?? 'N/A'),
                const Divider(),

                // --- SECCIÓN DE FECHAS DE SISTEMA ---
                _buildInfoRow('Fecha de Registro:', fechaRegistroFormateada),
                // Fecha de Actualización no está en tu JSON de ejemplo, pero si lo tuvieras:
                // _buildInfoRow('Fecha de Actualización:', estudiante.fechaActualizacion != null
                //     ? dateTimeFormatter.format(estudiante.fechaActualizacion!)
                //     : 'N/A'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  // Helper para construir filas de información clave-valor
  static Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '$label ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  // Helper para construir bloques de información con posible salto de línea
  static Widget _buildMultilineInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4.0),
          Text(
            value,
            softWrap: true,
            overflow: TextOverflow.visible,
          ),
        ],
      ),
    );
  }
}