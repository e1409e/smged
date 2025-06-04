// lib/layout/reports/estudiantes_report.dart
import 'dart:io';
import 'dart:typed_data'; // Necesario para ByteData y Uint8List
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

import 'package:smged/api/models/estudiante.dart';
// No necesitamos EstudiantesService aquí, ya que recibiremos la lista de estudiantes
// import 'package:smged/api/services/estudiantes_service.dart';

class EstudiantesReport {
  static const String _logoPath = 'icon/smged_Logo.png';

  /// Genera y opcionalmente muestra/guarda el reporte PDF de estudiantes.
  ///
  /// [estudiantesToReport]: La lista de estudiantes a incluir en el reporte.
  ///                      Si se pasa una lista vacía, intentará obtener todos los estudiantes.
  ///                      Si se pasa un solo estudiante en la lista, generará solo esa página.
  /// [showPreview]: Si es true, abrirá una vista previa del PDF.
  /// [saveToFile]: Si es true, guardará el PDF en el directorio de documentos/descargas.
  /// [shareFile]: Si es true, abrirá el diálogo para compartir el PDF.
  static Future<void> generateEstudiantesReport({
    required List<Estudiante> estudiantesToReport, // CAMBIO: Ahora recibe una lista de estudiantes
    bool showPreview = true,
    bool saveToFile = false,
    bool shareFile = false,
    String? customFilename, // Nuevo parámetro para nombre de archivo personalizado
  }) async {
    List<Estudiante> estudiantes;

    // Si se pasa una lista vacía, obtenemos todos los estudiantes (comportamiento original del reporte masivo)
    // Pero para este caso, siempre se espera que se pase la lista de estudiantes.
    if (estudiantesToReport.isEmpty) {
      // Si llegara aquí, significa que se llamó sin datos.
      // Puedes manejarlo como un error o simplemente no generar nada.
      // Para el propósito de esta solicitud, el modal siempre pasará un estudiante.
      print('La lista de estudiantes para el reporte está vacía.');
      return;
    } else {
      estudiantes = estudiantesToReport;
    }

    final pdf = pw.Document();

    // Cargar la imagen del logo
    final ByteData bytes = await rootBundle.load(_logoPath);
    final Uint8List logoBytes = bytes.buffer.asUint8List();
    final pw.MemoryImage logoImage = pw.MemoryImage(logoBytes);

    // Formateadores de fecha
    final DateFormat formatter = DateFormat('dd/MM/yyyy');
    final DateFormat dateTimeFormatter = DateFormat('dd/MM/yyyy HH:mm');

    for (var estudiante in estudiantes) {
      // Para el estado de CONAPDIS
      String conapdisEstado = estudiante.poseeConapdis == true
          ? 'Sí'
          : (estudiante.poseeConapdis == false ? 'No' : 'N/A');

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return [
              // Encabezado con Logo y Título
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Container(
                    width: 70,
                    height: 70,
                    decoration: pw.BoxDecoration(
                      borderRadius: pw.BorderRadius.circular(10),
                      image: pw.DecorationImage(
                        image: logoImage,
                        fit: pw.BoxFit.contain,
                      ),
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Column(
                      children: [
                        pw.Text(
                          'Información Detallada del Estudiante', // Título para reporte individual
                          style: pw.TextStyle(
                              fontSize: 22, fontWeight: pw.FontWeight.bold),
                          textAlign: pw.TextAlign.center,
                        ),
                        pw.Divider(thickness: 1, color: PdfColors.black),
                      ],
                    ),
                  ),
                  pw.SizedBox(width: 70),
                ],
              ),
              pw.SizedBox(height: 30),

              pw.Center(
                child: pw.Text(
                  'Datos del Estudiante', // Subtítulo
                  style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
                  textAlign: pw.TextAlign.center,
                ),
              ),
              pw.SizedBox(height: 20),

              // Contenido del reporte, imitando la estructura del modal
              _buildInfoRow(
                'Código del Estudiante:',
                estudiante.idEstudiante?.toString() ?? 'N/A',
              ),
              _buildInfoRow('Nombres:', estudiante.nombres),
              _buildInfoRow('Apellidos:', estudiante.apellidos),
              _buildInfoRow('Cédula:', estudiante.cedula),
              _buildInfoRow(
                'Fecha de Nacimiento:',
                estudiante.fechaNacimiento != null
                    ? formatter.format(estudiante.fechaNacimiento!)
                    : 'N/A',
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
              pw.Divider(thickness: 0.5, color: PdfColors.grey),
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
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 4.0),
                child: pw.Row(
                  children: [
                    pw.Text(
                      'Posee CONAPDIS: ',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: pw.BoxDecoration(
                        color: estudiante.poseeConapdis == true
                            ? PdfColors.green100
                            : PdfColors.red100,
                        borderRadius: pw.BorderRadius.circular(5),
                      ),
                      child: pw.Text(
                        conapdisEstado,
                        style: pw.TextStyle(
                          color: estudiante.poseeConapdis == true
                              ? PdfColors.green900
                              : PdfColors.red900,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              pw.Divider(thickness: 0.5, color: PdfColors.grey),
              _buildMultilineInfo(
                'Observaciones:',
                estudiante.observaciones ?? 'N/A',
              ),
              _buildMultilineInfo(
                'Seguimiento:',
                estudiante.seguimiento ?? 'N/A',
              ),
              pw.Divider(thickness: 0.5, color: PdfColors.grey),
              _buildInfoRow(
                'Fecha de Registro:',
                estudiante.fechaRegistro != null
                    ? dateTimeFormatter.format(estudiante.fechaRegistro!)
                    : 'N/A',
              ),
            ];
          },
        ),
      );
    }

    // --- Opciones de Salida ---
    final String filename = customFilename ?? 'reporte_estudiantes.pdf'; // Usa nombre personalizado

    if (showPreview) {
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );
    }

    if (saveToFile) {
      try {
        final directory = await getApplicationDocumentsDirectory();
        final path = '${directory.path}/$filename';
        final file = File(path);
        await file.writeAsBytes(await pdf.save());
        print('PDF guardado en: $path');
      } catch (e) {
        print('Error al guardar el PDF: $e');
      }
    }

    if (shareFile) {
      try {
        await Printing.sharePdf(bytes: await pdf.save(), filename: filename);
      } catch (e) {
        print('Error al compartir el PDF: $e');
      }
    }
  }

  // --- Helpers para construir filas (sin cambios) ---

  static pw.Widget _buildInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4.0),
      child: pw.RichText(
        text: pw.TextSpan(
          children: [
            pw.TextSpan(
              text: '$label ',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11),
            ),
            pw.TextSpan(
              text: value,
              style: const pw.TextStyle(fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  static pw.Widget _buildMultilineInfo(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4.0),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(label, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
          pw.SizedBox(height: 4.0),
          pw.Text(value, softWrap: true, style: const pw.TextStyle(fontSize: 11)),
        ],
      ),
    );
  }
}