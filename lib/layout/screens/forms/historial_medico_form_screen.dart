import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:smged/config.dart';
import 'package:smged/layout/widgets/custom_colors.dart';
import 'package:smged/api/models/historial_medico.dart';

class HistorialMedicoFormScreen extends StatefulWidget {
  const HistorialMedicoFormScreen({super.key});

  @override
  State<HistorialMedicoFormScreen> createState() => _HistorialMedicoFormScreenState();
}

class _HistorialMedicoFormScreenState extends State<HistorialMedicoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;
  PlatformFile? _certificadoFile;
  PlatformFile? _informeFile;
  PlatformFile? _tratamientoFile;
  int? _idEstudiante;

  // Agrega estos campos:
  String? _certificadoUrl;
  String? _informeUrl;
  String? _tratamientoUrl;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map) {
      _idEstudiante = args['idEstudiante'] as int?;
      final historial = args['historial'] as HistorialMedico?;
      if (historial != null) {
        _certificadoUrl = historial.certificadoConapdis;
        _informeUrl = historial.informeMedico;
        _tratamientoUrl = historial.tratamiento;
      }
    } else if (args is int) {
      _idEstudiante = args;
    }
  }

  Future<void> _pickFile(Function(PlatformFile) onPicked) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.single.path != null) {
      onPicked(result.files.single);
    }
  }

  Future<void> _guardarHistorial() async {
    if (_idEstudiante == null) return;
    setState(() => _isSaving = true);

    try {
      final uri = Uri.parse('${Config.apiUrl}/historial_medico');
      final request = http.MultipartRequest('POST', uri);

      request.fields['id_estudiante'] = _idEstudiante.toString();

      if (_certificadoFile != null && _certificadoFile!.path != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'certificado_conapdis',
          _certificadoFile!.path!,
          filename: _certificadoFile!.name,
        ));
      }
      if (_informeFile != null && _informeFile!.path != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'informe_medico',
          _informeFile!.path!,
          filename: _informeFile!.name,
        ));
      }
      if (_tratamientoFile != null && _tratamientoFile!.path != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'tratamiento',
          _tratamientoFile!.path!,
          filename: _tratamientoFile!.name,
        ));
      }

      final response = await request.send();

      if (response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Historial médico guardado exitosamente')),
          );
          Navigator.of(context).pop();
        }
      } else {
        final respStr = await response.stream.bytesToString();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al guardar: $respStr')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e')),
        );
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Widget _buildArchivoField({
    required String label,
    required PlatformFile? file,
    required VoidCallback onPick,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: Text(
                file?.name ?? 'No seleccionado',
                style: TextStyle(
                  color: file != null ? Colors.black87 : Colors.grey,
                  fontStyle: file != null ? FontStyle.normal : FontStyle.italic,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              icon: const Icon(Icons.upload_file),
              label: const Text('Seleccionar'),
              onPressed: onPick,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool esEscritorio = MediaQuery.of(context).size.width > 700;
    final double cardWidth = esEscritorio ? 500 : MediaQuery.of(context).size.width * 0.95;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuevo Historial Médico', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: cardWidth),
          child: Card(
            elevation: 4,
            margin: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildArchivoField(
                      label: 'Certificado CONAPDIS',
                      file: _certificadoFile,
                      onPick: () => _pickFile((file) => setState(() => _certificadoFile = file)),
                    ),
                    _buildArchivoField(
                      label: 'Informe Médico',
                      file: _informeFile,
                      onPick: () => _pickFile((file) => setState(() => _informeFile = file)),
                    ),
                    _buildArchivoField(
                      label: 'Tratamiento',
                      file: _tratamientoFile,
                      onPick: () => _pickFile((file) => setState(() => _tratamientoFile = file)),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.save),
                        label: _isSaving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Text('Guardar'),
                        onPressed: _isSaving ? null : _guardarHistorial,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}