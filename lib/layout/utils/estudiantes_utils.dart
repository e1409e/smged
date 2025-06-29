// lib/layout/utils/estudiantes_utils.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smged/api/models/estudiante.dart';
import 'package:smged/layout/widgets/custom_colors.dart';
import 'package:smged/layout/reports/estudiantes_report.dart';
import 'package:smged/routes.dart'; // ¡NUEVA IMPORTACIÓN!

class EstudiantesUtils {
  static void showEstudianteInfoModal(BuildContext context, dynamic item) {
    final estudiante = item as Estudiante;

    final DateFormat formatter = DateFormat('dd/MM/yyyy');
    final DateFormat dateTimeFormatter = DateFormat('dd/MM/yyyy HH:mm');

    String fechaNacimientoFormateada = estudiante.fechaNacimiento != null
        ? formatter.format(estudiante.fechaNacimiento!)
        : 'N/A';

    String fechaRegistroFormateada = estudiante.fechaRegistro != null
        ? dateTimeFormatter.format(estudiante.fechaRegistro!)
        : 'N/A';

    String conapdisEstado = estudiante.poseeConapdis == true
        ? 'Sí'
        : (estudiante.poseeConapdis == false ? 'No' : 'N/A');
    Color conapdisColor = estudiante.poseeConapdis == true
        ? AppColors.success
        : AppColors.error;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        final bool esWindows = Theme.of(context).platform == TargetPlatform.windows;
        return AlertDialog(
          title: const Center(
            child: Text(
              'Información Detallada del Estudiante',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          insetPadding: esWindows
              ? const EdgeInsets.symmetric(horizontal: 40.0, vertical: 24.0) // Padding original en Windows
              : const EdgeInsets.symmetric(horizontal: 8.0, vertical: 24.0), // Más ancho en otras plataformas
          content: SizedBox(
            width: esWindows ? 500 : MediaQuery.of(context).size.width * 0.95, // Ancho original en Windows, ancho grande en otros
            child: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  

                  _buildInfoRow(
                    'Código del Estudiante:',
                    estudiante.idEstudiante?.toString() ?? 'N/A',
                  ),
                  _buildInfoRow('Nombres:', estudiante.nombres),
                  _buildInfoRow('Apellidos:', estudiante.apellidos),
                  _buildInfoRow('Cédula:', estudiante.cedula),
                  _buildInfoRow(
                    'Fecha de Nacimiento:',
                    fechaNacimientoFormateada,
                  ),
                  _buildInfoRow('Correo:', estudiante.correo ?? 'N/A'),
                  _buildInfoRow(
                    'Teléfono Principal:',
                    estudiante.telefono ?? 'N/A',
                  ),
                  _buildInfoRow(
                    'Otro Teléfono:',
                    estudiante.otroTelefono ?? 'N/A',
                  ),
                  _buildMultilineInfo(
                    'Dirección:',
                    estudiante.direccion ?? 'N/A',
                  ),
                  const Divider(),
                  _buildInfoRow(
                    'Discapacidad:',
                    estudiante.discapacidad ?? 'N/A',
                  ),
                  _buildInfoRow(
                    'Carrera:',
                    estudiante.nombreCarrera ?? 'N/A',
                  ),
                  _buildInfoRow(
                    'Facultad:',
                    '${estudiante.nombreFacultad ?? 'N/A'} (${estudiante.siglasFacultad ?? 'N/A'})',
                  ),
                  _buildInfoRow(
                    'Representante:',
                    estudiante.nombreRepre ?? 'N/A',
                  ),
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
                  const Divider(),
                  _buildMultilineInfo(
                    'Observaciones:',
                    estudiante.observaciones ?? 'N/A',
                  ),
                  _buildMultilineInfo(
                    'Seguimiento:',
                    estudiante.seguimiento ?? 'N/A',
                  ),
                  const Divider(),
                  _buildInfoRow('Fecha de Registro:', fechaRegistroFormateada),
                  const Divider(),
                  // Botón "Descargar en PDF"
                  const SizedBox(height: 20), // Espacio antes del botón
                  Align(
                    alignment: Alignment.center,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        Navigator.of(dialogContext).pop(); // Cierra el modal primero
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Generando PDF del estudiante...')),
                        );
                        try {
                          String filename = 'reporte_${estudiante.nombres}_${estudiante.apellidos}.pdf'
                              .toLowerCase()
                              .replaceAll(' ', '_'); // Nombre de archivo limpio
                          await EstudiantesReport.generateEstudiantesReport(
                            estudiantesToReport: [estudiante], // ¡Solo este estudiante!
                            showPreview: true, // Puedes cambiar a false si quieres que solo descargue
                            saveToFile: false, // Puedes cambiar a true si quieres que solo descargue
                            shareFile: false, // Puedes cambiar a true si quieres la opción de compartir
                            customFilename: filename, // Nombre de archivo personalizado
                          );
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('PDF del estudiante generado con éxito.')),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error al generar PDF: ${e.toString()}'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          print('Error al generar PDF del estudiante: $e'); // Para depuración
                        }
                      },
                      icon: const Icon(Icons.download, color: Colors.white),
                      label: const Text('Descargar en PDF', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error, // O el color que prefieras
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  // ¡BOTÓN: Ver historial médico!
                  const SizedBox(height: 15), // Espacio antes del botón
                  Align(
                    alignment: Alignment.center,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.description, color: Colors.white),
                      label: const Text('Ver Reportes', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue, // O AppColors.primary si es azul
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).pushNamed(
                          AppRoutes.historialesMedicosList,
                          arguments: estudiante.idEstudiante,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  // BOTÓN: Ver Representante
                  Align(
                    alignment: Alignment.center,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.person, color: Colors.white),
                      label: const Text('Ver Representante', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).pushNamed(
                          AppRoutes.representantesList,
                          arguments: estudiante.idEstudiante,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
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

  // Helpers sin cambios
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

  static Widget _buildMultilineInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4.0),
          Text(value, softWrap: true, overflow: TextOverflow.visible),
        ],
      ),
    );
  }
}