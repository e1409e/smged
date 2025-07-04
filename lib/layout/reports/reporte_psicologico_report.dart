import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

import 'package:smged/api/models/reporte_psicologico.dart';

class ReportePsicologicoReport {
  static const String _logoPath = 'icon/logo_smged.png';

  static Future<void> generateReportePsicologicoPdf({
    required ReportePsicologico reporte,
    bool showPreview = true,
    String? customFilename,
  }) async {
    final pdf = pw.Document();

    // Cargar el logo
    final ByteData bytes = await rootBundle.load(_logoPath);
    final Uint8List logoBytes = bytes.buffer.asUint8List();
    final pw.MemoryImage logoImage = pw.MemoryImage(logoBytes);

    final DateFormat formatter = DateFormat('dd/MM/yyyy HH:mm');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
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
                        'Reporte Psicológico',
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
                'Datos del Reporte Psicológico',
                style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
                textAlign: pw.TextAlign.center,
              ),
            ),
            pw.SizedBox(height: 20),
            _buildInfoRow('ID Reporte:', reporte.idPsicologico?.toString() ?? 'N/A'),
            _buildInfoRow('Estudiante:', '${reporte.nombreEstudiante ?? ''} ${reporte.apellidoEstudiante ?? ''}'),
            _buildInfoRow('ID Estudiante:', reporte.idEstudiante.toString()),
            _buildInfoRow('Motivo de Consulta:', reporte.motivoConsulta),
            _buildInfoRow('Síntesis Diagnóstica:', reporte.sintesisDiagnostica),
            _buildInfoRow('Recomendaciones:', reporte.recomendaciones),
            pw.SizedBox(height: 10),
            pw.Divider(thickness: 0.5, color: PdfColors.grey),
            pw.Text(
              'Fecha de generación: ${formatter.format(DateTime.now())}',
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
            ),
          ];
        },
      ),
    );

    final String filename = customFilename ?? 'reporte_psicologico_${reporte.idPsicologico ?? ''}.pdf';

    if (showPreview) {
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name: filename,
      );
    }
  }

  static pw.Widget _buildInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4.0),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            '$label ',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: const pw.TextStyle(fontSize: 11),
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }
}