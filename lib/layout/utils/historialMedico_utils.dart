// lib/layout/utils/historialMedico_utils.dart
import 'package:flutter/material.dart';
import 'package:smged/api/models/historial_medico.dart'; // Asegúrate de importar tu modelo HistorialMedico
import 'package:smged/layout/widgets/custom_colors.dart'; // Para usar AppColors

class HistorialMedicoUtils {
  static void showHistorialMedicoInfoModal(BuildContext context, dynamic item) {
    // Es crucial castear el item a HistorialMedico para acceder a sus propiedades.
    final historial = item as HistorialMedico;

    // Formatear las fechas
    String fechaCreacionFormateada =
        '${historial.fechaCreacion.day}/${historial.fechaCreacion.month}/${historial.fechaCreacion.year}';
    String fechaActualizacionFormateada =
        '${historial.fechaActualizacion.day}/${historial.fechaActualizacion.month}/${historial.fechaActualizacion.year}';

    // Determinar el estado del certificado CONAPDIS y su color basado en el String
    String conapdisEstado = historial.certificadoConapdis; // Ahora es un String directamente
    Color conapdisColor = historial.certificadoConapdis == 'Sí' ? AppColors.success : AppColors.error; // Color para el estado

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        // Usamos dialogContext para claridad
        return AlertDialog(
          title: Align(
            child: const Text(
              'Información del Historial Médico',
              style: TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                // Campo ID Historial Médico
                Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(
                        text: 'ID Historial: ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: historial.idHistorialMedico.toString()),
                    ],
                  ),
                ),
                const SizedBox(height: 4.0), // Pequeño espacio entre campos

                // Campo ID Estudiante
                Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(
                        text: 'ID Estudiante: ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: historial.idEstudiante.toString()),
                    ],
                  ),
                ),
                const SizedBox(height: 4.0),

                // Campo Certificado CONAPDIS
                Padding(
                  padding: const EdgeInsets.only(top: 4.0, bottom: 4.0),
                  child: Row(
                    children: [
                      const Text(
                        'Certificado CONAPDIS: ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Chip(
                        label: Text(
                          conapdisEstado,
                          style: TextStyle(
                            color: conapdisColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        backgroundColor: Colors.grey[200],
                        padding: const EdgeInsets.all(1),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8.0), // Espacio antes de los títulos de bloque

                // Campo Informe Médico
                const Text(
                  'Informe Médico:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  historial.informeMedico,
                  softWrap: true,
                  overflow: TextOverflow.visible,
                ),
                const SizedBox(height: 8.0),

                // Campo Tratamiento
                const Text(
                  'Tratamiento:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  historial.tratamiento,
                  softWrap: true,
                  overflow: TextOverflow.visible,
                ),
                const SizedBox(height: 8.0),

                // Campo Fecha de Creación
                Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(
                        text: 'Fecha de Creación: ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: fechaCreacionFormateada),
                    ],
                  ),
                ),
                const SizedBox(height: 4.0),

                // Campo Fecha de Actualización
                Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(
                        text: 'Última Actualización: ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: fechaActualizacionFormateada),
                    ],
                  ),
                ),
                const Divider(height: 20, thickness: 1), // Separador para legibilidad
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cerrar'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }
}