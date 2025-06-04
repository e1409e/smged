// lib/layout/utils/citas_utils.dart
import 'package:flutter/material.dart';
import 'package:smged/api/models/cita.dart'; // Asegúrate de importar tu modelo Cita
import 'package:smged/layout/widgets/custom_colors.dart'; // Para usar AppColors

class CitasUtils {
  static void showCitaInfoModal(BuildContext context, dynamic item) {
    // Es crucial castear el item a Cita para acceder a sus propiedades.
    final cita = item as Cita;

    // Formatear la fecha de la cita
    // Puedes añadir la hora si es necesario:
    // String fechaCitaFormateada = DateFormat('dd/MM/yyyy HH:mm').format(cita.fecha_cita);
    String fechaCitaFormateada =
        '${cita.fecha_cita.day}/${cita.fecha_cita.month}/${cita.fecha_cita.year}';

    // Determinar el estado de la cita
    String estadoCita = cita.pendiente == 1 ? 'Pendiente' : 'Realizada';
    Color estadoColor = cita.pendiente == 1
        ? AppColors.info
        : AppColors.success; // Color para el estado

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        // Usamos dialogContext para claridad
        return AlertDialog(
          title: Align(
            child: const Text(
              'Información de la Cita',
              style: TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                // Campo Código (Etiqueta en negrita)
                Text.rich(
                  // Usamos Text.rich para combinar texto normal y negrita
                  TextSpan(
                    children: [
                      const TextSpan(
                        text: 'Código: ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: cita.id_citas?.toString() ?? 'N/A'),
                    ],
                  ),
                ),

                // Campo Estudiante (Etiqueta en negrita)
                Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(
                        text: 'Estudiante: ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: cita.nombre_estudiante ?? 'N/A'),
                    ],
                  ),
                ),

                // Campo Fecha (Etiqueta en negrita)
                Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(
                        text: 'Fecha: ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: fechaCitaFormateada),
                    ],
                  ),
                ),

                // Campo Motivo (Salto de línea, con etiqueta en negrita)
                const SizedBox(height: 8.0), // Espacio antes del título
                const Text(
                  'Motivo:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  cita.motivo_cita ?? 'N/A',
                  softWrap:
                      true, // Permite que el texto se ajuste a varias líneas
                  overflow: TextOverflow.visible,
                ),
                // Eliminamos el Text('') que estaba vacío

                // Campo Estado (Etiqueta en negrita para "Estado:", y Chip)
                Padding(
                  padding: const EdgeInsets.only(
                    top: 8.0,
                  ), // Pequeño padding para separar
                  child: Row(
                    children: [
                      const Text(
                        'Estado: ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ), // Etiqueta en negrita
                      ),
                      Chip(
                        label: Text(
                          estadoCita,
                          style: TextStyle(
                            color: estadoColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        backgroundColor: Colors.grey[200],
                        padding: const EdgeInsets.all(1),
                      ),
                    ],
                  ),
                ),
                const Divider(), // Separador para legibilidad
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cerrar'),
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(); // Usa dialogContext aquí también
              },
            ),
          ],
        );
      },
    );
  }
}
