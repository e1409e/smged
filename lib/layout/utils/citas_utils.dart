// lib/layout/utils/citas_utils.dart
import 'package:flutter/material.dart';
import 'package:smged/api/models/cita.dart'; // Asegúrate de importar tu modelo Cita
import 'package:smged/layout/widgets/custom_colors.dart'; // Para usar AppColors

class CitasUtils {
  static void showCitaInfoModal(BuildContext context, dynamic item) {
    // Es crucial castear el item a Cita para acceder a sus propiedades.
    final cita = item as Cita;

    // Formatear la fecha de la cita
    String fechaCitaFormateada =
        '${cita.fecha_cita.day}/${cita.fecha_cita.month}/${cita.fecha_cita.year}';

    //Codigo para agregar la hora    
    //${cita.fecha_cita.hour.toString().padLeft(2, '0')}:${cita.fecha_cita.minute.toString().padLeft(2, '0')}


    // Determinar el estado de la cita
    String estadoCita = cita.pendiente == 1 ? 'Pendiente' : 'Realizada';
    Color estadoColor = cita.pendiente == 1 ? AppColors.info : AppColors.success; // Color para el estado

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Información Detallada de la Cita'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                // Campos de la cita
                Text('Código: ${cita.id_citas ?? 'N/A'}'),
                Text('Estudiante: ${cita.nombre_estudiante ?? 'N/A'}'),
                //Text('ID Estudiante: ${cita.id_estudiante ?? 'N/A'}'),
                Text('Fecha: $fechaCitaFormateada'),
                Text('Motivo: ${cita.motivo_cita ?? 'N/A'}'),
                Text(''),
                Row(
                  children: [
                    const Text('Estado: '),
                    Chip(
                      label: Text(
                        estadoCita,
                        style: TextStyle(color: estadoColor, fontWeight: FontWeight.bold),
                      ),
                      backgroundColor: Colors.grey[200],
                      padding: const EdgeInsets.all(1),

                    ),
                  ],
                ),
                const Divider(), // Separador para legibilidad

              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cerrar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}