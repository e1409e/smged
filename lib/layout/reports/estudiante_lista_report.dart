import 'dart:io';
import 'dart:typed_data'; // Necesario para ByteData y Uint8List
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart'; // Para formatear fechas

import 'package:smged/api/models/estudiante.dart';
import 'package:smged/api/services/estudiantes_service.dart';

class EstudianteListaReport {
  static const String _logoPath = 'icon/logo_smged.png'; // Ruta de tu logo

  /// Genera y opcionalmente muestra/guarda el reporte PDF en formato de tabla.
  ///
  /// [showPreview]: Si es true, abrirá una vista previa del PDF.
  /// [saveToFile]: Si es true, guardará el PDF en el directorio de documentos/descargas.
  /// [shareFile]: Si es true, abrirá el diálogo para compartir el PDF.
  static Future<void> generateEstudianteListaReport({
    bool showPreview = true,
    bool saveToFile = false,
    bool shareFile = false,
  }) async {
    final EstudiantesService estudiantesService = EstudiantesService();
    List<Estudiante> estudiantes;

    try {
      estudiantes = await estudiantesService.obtenerTodosLosEstudiantes();
      if (estudiantes.isEmpty) {
        print('No hay estudiantes para generar el reporte de lista.');
        return;
      }
    } catch (e) {
      print('Error al obtener los datos de estudiantes para la lista: $e');
      return;
    }

    final pdf = pw.Document();

    // Cargar la imagen del logo
    final ByteData bytes = await rootBundle.load(_logoPath);
    final Uint8List logoBytes = bytes.buffer.asUint8List();
    final pw.MemoryImage logoImage = pw.MemoryImage(logoBytes);

    // Formateador de fechas
    final DateFormat formatter = DateFormat('dd/MM/yyyy');

    // Definir los encabezados de la tabla
    final List<String> headers = [
      'ID',
      'Nombres',
      'Apellidos',
      'Cédula',
      'Fecha Nac.',
      'Correo',
      'Teléfono'
    ];

    // Mapear los datos de los estudiantes a filas para la tabla
    final List<List<String>> data = estudiantes.map((estudiante) {
      String fechaNacimientoFormateada = estudiante.fechaNacimiento != null
          ? formatter.format(estudiante.fechaNacimiento!)
          : 'N/A';

      return [
        estudiante.idEstudiante?.toString() ?? 'N/A',
        estudiante.nombres,
        estudiante.apellidos,
        estudiante.cedula,
        fechaNacimientoFormateada,
        estudiante.correo ?? 'N/A',
        estudiante.telefono ?? 'N/A',
      ];
    }).toList();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape, // Usar formato horizontal para más columnas
        build: (pw.Context context) {
          return [
            // Encabezado con Logo y Título
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Container(
                  width: 70, // Ajusta el tamaño del logo según necesites
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
                        'Reporte de Lista de Estudiantes', // Título actualizado
                        style: pw.TextStyle(
                            fontSize: 22, fontWeight: pw.FontWeight.bold),
                        textAlign: pw.TextAlign.center,
                      ),
                      pw.Divider(thickness: 1, color: PdfColors.black),
                    ],
                  ),
                ),
                pw.SizedBox(width: 70), // Espacio para alinear el título
              ],
            ),
            pw.SizedBox(height: 30), // Espacio después del encabezado

            // Tabla de estudiantes
            pw.Table.fromTextArray(
              headers: headers,
              data: data,
              border: pw.TableBorder.all(color: PdfColors.black, width: 0.5),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
              cellStyle: const pw.TextStyle(fontSize: 9),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
              columnWidths: { // Puedes ajustar los anchos de las columnas aquí
                0: const pw.FlexColumnWidth(0.8), // ID
                1: const pw.FlexColumnWidth(1.5), // Nombres
                2: const pw.FlexColumnWidth(1.5), // Apellidos
                3: const pw.FlexColumnWidth(1.0), // Cédula
                4: const pw.FlexColumnWidth(1.0), // Fecha Nac.
                5: const pw.FlexColumnWidth(2.0), // Correo
                6: const pw.FlexColumnWidth(1.0), // Teléfono
              },
              cellAlignment: pw.Alignment.centerLeft,
              headerAlignment: pw.Alignment.center,
            ),
          ];
        },
      ),
    );

    // --- Opciones de Salida ---

    if (showPreview) {
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );
    }

    if (saveToFile) {
      try {
        final directory = await getApplicationDocumentsDirectory();
        final path = '${directory.path}/reporte_lista_estudiantes.pdf';
        final file = File(path);
        await file.writeAsBytes(await pdf.save());
        print('PDF de lista guardado en: $path');
      } catch (e) {
        print('Error al guardar el PDF de lista: $e');
      }
    }

    if (shareFile) {
      try {
        await Printing.sharePdf(bytes: await pdf.save(), filename: 'reporte_lista_estudiantes.pdf');
      } catch (e) {
        print('Error al compartir el PDF de lista: $e');
      }
    }
  }
}