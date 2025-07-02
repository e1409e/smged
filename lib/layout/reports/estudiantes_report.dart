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

class EstudiantesReport {
  static const String _logoPath = 'icon/smged_Logo.png'; // Asegúrate de que esta ruta sea correcta

  /// Genera y opcionalmente muestra/guarda el reporte PDF de estudiantes.
  ///
  /// [estudiantesToReport]: La lista de estudiantes a incluir en el reporte.
  /// [showPreview]: Si es true, abrirá una vista previa del PDF.
  /// [saveToFile]: Si es true, guardará el PDF en el directorio de documentos/descargas.
  /// [shareFile]: Si es true, abrirá el diálogo para compartir el PDF.
  /// [customFilename]: Nuevo parámetro para nombre de archivo personalizado.
  static Future<void> generateEstudiantesReport({
    required List<Estudiante> estudiantesToReport,
    bool showPreview = true,
    bool saveToFile = false,
    bool shareFile = false,
    String? customFilename,
  }) async {
    if (estudiantesToReport.isEmpty) {
      print('La lista de estudiantes para el reporte está vacía.');
      return;
    }

    final pdf = pw.Document();

    // Cargar la imagen del logo
    final ByteData bytes = await rootBundle.load(_logoPath);
    final Uint8List logoBytes = bytes.buffer.asUint8List();
    final pw.MemoryImage logoImage = pw.MemoryImage(logoBytes);

    // Formateadores de fecha y hora
    final DateFormat formatter = DateFormat('dd/MM/yyyy');
    final DateFormat dateTimeFormatter = DateFormat('dd/MM/yyyy HH:mm');
    final String reportGenerationDate = dateTimeFormatter.format(DateTime.now());

    // Estilos de texto
    // ELIMINAR 'const' de aquí
    final pw.TextStyle titleStyle = pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey900);
    final pw.TextStyle sectionTitleStyle = pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey700);
    final pw.TextStyle labelStyle = pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10, color: PdfColors.black);
    final pw.TextStyle valueStyle = pw.TextStyle(fontSize: 10, color: PdfColors.black);
    final pw.TextStyle footerStyle = pw.TextStyle(fontSize: 9, color: PdfColors.grey600);

    for (var estudiante in estudiantesToReport) {
      String conapdisEstado = estudiante.poseeConapdis == true
          ? 'Sí'
          : (estudiante.poseeConapdis == false ? 'No' : 'N/A');

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4.copyWith(marginTop: 40, marginBottom: 40, marginLeft: 40, marginRight: 40),
          header: (pw.Context context) {
            return pw.Column(
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    // Logo
                    pw.Container(
                      width: 60,
                      height: 60,
                      child: pw.Image(logoImage),
                    ),
                    // Título y Subtítulo
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        children: [
                          pw.Text(
                            'Sistema de Gestión Estudiantil y de Discapacidad',
                            style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600), // Este no era const, no hay problema
                            textAlign: pw.TextAlign.center,
                          ),
                          pw.Text(
                            'Información Detallada del Estudiante',
                            style: titleStyle,
                            textAlign: pw.TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    // Fecha de generación
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text('Reporte Generado:', style: footerStyle),
                        pw.Text(reportGenerationDate, style: footerStyle),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 10),
                pw.Divider(thickness: 1, color: PdfColors.blueGrey200),
                pw.SizedBox(height: 20),
              ],
            );
          },
          footer: (pw.Context context) {
            return pw.Container(
              alignment: pw.Alignment.centerRight,
              margin: const pw.EdgeInsets.only(top: 10.0),
              child: pw.Text(
                'Página ${context.pageNumber} de ${context.pagesCount}',
                style: footerStyle,
              ),
            );
          },
          build: (pw.Context context) {
            return [
              // Sección de Datos Personales
              _buildSectionTitle('Datos Personales', sectionTitleStyle),
              _buildInfoTable([
                _buildTableRow('Código del Estudiante:', estudiante.idEstudiante?.toString() ?? 'N/A', labelStyle, valueStyle),
                _buildTableRow('Nombres:', estudiante.nombres, labelStyle, valueStyle),
                _buildTableRow('Apellidos:', estudiante.apellidos, labelStyle, valueStyle),
                _buildTableRow('Cédula:', estudiante.cedula, labelStyle, valueStyle),
                _buildTableRow(
                  'Fecha de Nacimiento:',
                  estudiante.fechaNacimiento != null
                      ? formatter.format(estudiante.fechaNacimiento!)
                      : 'N/A',
                  labelStyle, valueStyle,
                ),
                _buildTableRow('Correo:', estudiante.correo ?? 'N/A', labelStyle, valueStyle),
                _buildTableRow('Teléfono Principal:', estudiante.telefono ?? 'N/A', labelStyle, valueStyle),
                _buildTableRow('Otro Teléfono:', estudiante.otroTelefono ?? 'N/A', labelStyle, valueStyle),
              ]),
              _buildMultilineInfo('Dirección:', estudiante.direccion ?? 'N/A', labelStyle, valueStyle),
              pw.SizedBox(height: 15),

              // Sección Académica y de Discapacidad
              _buildSectionTitle('Datos Académicos y de Salud', sectionTitleStyle),
              _buildInfoTable([
                _buildTableRow('Carrera:', estudiante.nombreCarrera ?? 'N/A', labelStyle, valueStyle),
                _buildTableRow(
                  'Facultad:',
                  '${estudiante.nombreFacultad ?? 'N/A'} (${estudiante.siglasFacultad ?? 'N/A'})',
                  labelStyle, valueStyle,
                ),
                _buildTableRow('Discapacidad:', estudiante.discapacidad ?? 'N/A', labelStyle, valueStyle),
                pw.TableRow(children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(vertical: 4.0),
                    child: pw.Text('Posee CONAPDIS:', style: labelStyle),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(vertical: 2.0),
                    child: pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: pw.BoxDecoration(
                        color: estudiante.poseeConapdis == true
                            ? PdfColors.green100
                            : (estudiante.poseeConapdis == false ? PdfColors.red100 : PdfColors.grey200),
                        borderRadius: pw.BorderRadius.circular(5),
                      ),
                      child: pw.Text(
                        conapdisEstado,
                        style: pw.TextStyle(
                          color: estudiante.poseeConapdis == true
                              ? PdfColors.green900
                              : (estudiante.poseeConapdis == false ? PdfColors.red900 : PdfColors.grey700),
                          fontWeight: pw.FontWeight.bold,
                          fontSize: valueStyle.fontSize,
                        ),
                      ),
                    ),
                  ),
                ]),
              ]),
              pw.SizedBox(height: 15),

              // Sección de Observaciones y Seguimiento
              _buildSectionTitle('Información Adicional', sectionTitleStyle),
              _buildMultilineInfo('Observaciones:', estudiante.observaciones ?? 'N/A', labelStyle, valueStyle),
              _buildMultilineInfo('Seguimiento:', estudiante.seguimiento ?? 'N/A', labelStyle, valueStyle),
              pw.SizedBox(height: 15),

              // Sección de Registro
              _buildSectionTitle('Detalles de Registro', sectionTitleStyle),
              _buildInfoTable([
                _buildTableRow(
                  'Representante:',
                  estudiante.nombreRepre ?? 'N/A',
                  labelStyle, valueStyle,
                ),
                _buildTableRow(
                  'Fecha de Registro:',
                  estudiante.fechaRegistro != null
                      ? dateTimeFormatter.format(estudiante.fechaRegistro!)
                      : 'N/A',
                  labelStyle, valueStyle,
                ),
              ]),
            ];
          },
        ),
      );
    }

    // --- Opciones de Salida ---
    final String filename = customFilename ?? 'reporte_estudiantes.pdf';

    if (showPreview) {
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name: filename,
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

  // --- Helpers para construir elementos del PDF ---

  static pw.Widget _buildSectionTitle(String title, pw.TextStyle style) {
    return pw.Container(
      alignment: pw.Alignment.centerLeft,
      padding: const pw.EdgeInsets.only(bottom: 5),
      decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: PdfColors.blueGrey300, width: 0.5)),
      ),
      child: pw.Text(title, style: style),
    );
  }

  static pw.TableRow _buildTableRow(String label, String value, pw.TextStyle labelStyle, pw.TextStyle valueStyle) {
    return pw.TableRow(
      verticalAlignment: pw.TableCellVerticalAlignment.top,
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 4.0),
          child: pw.Text(label, style: labelStyle),
        ),
        pw.Expanded(
          child: pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: 4.0),
            child: pw.Text(value, style: valueStyle, softWrap: true),
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildInfoTable(List<pw.TableRow> rows) {
    return pw.Table(
      columnWidths: {
        0: const pw.FlexColumnWidth(0.4), // Ancho para la etiqueta
        1: const pw.FlexColumnWidth(0.6), // Ancho para el valor
      },
      children: rows,
    );
  }

  static pw.Widget _buildMultilineInfo(String label, String value, pw.TextStyle labelStyle, pw.TextStyle valueStyle) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 8.0),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(label, style: labelStyle),
          pw.SizedBox(height: 4.0),
          pw.Text(value, softWrap: true, style: valueStyle),
        ],
      ),
    );
  }
}