import 'package:flutter/material.dart';
import 'package:smged/layout/widgets/custom_colors.dart';
import 'package:smged/api/models/historial_medico.dart';
import 'package:smged/api/services/historial_medico_service.dart';

class HistorialMedicoFormScreen extends StatefulWidget {
  const HistorialMedicoFormScreen({super.key});

  @override
  State<HistorialMedicoFormScreen> createState() => _HistorialMedicoFormScreenState();
}

class _HistorialMedicoFormScreenState extends State<HistorialMedicoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;
  int? _idEstudiante;
  int? _idHistorialMedico;

  final TextEditingController _certificadoController = TextEditingController();
  final TextEditingController _informeController = TextEditingController();
  final TextEditingController _tratamientoController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    HistorialMedico? historial;
    if (args is Map) {
      _idEstudiante = args['idEstudiante'] as int?;
      historial = args['historial'] as HistorialMedico?;
    } else if (args is int) {
      _idEstudiante = args;
    } else if (args is HistorialMedico) {
      historial = args;
      _idEstudiante = historial.idEstudiante;
    }
    if (historial != null) {
      _idHistorialMedico = historial.idHistorialMedico;
      _certificadoController.text = historial.certificadoConapdis;
      _informeController.text = historial.informeMedico;
      _tratamientoController.text = historial.tratamiento;
    }
  }

  Future<void> _guardarHistorial() async {
    if (_idEstudiante == null) return;
    setState(() => _isSaving = true);

    final historial = HistorialMedico(
      idHistorialMedico: _idHistorialMedico,
      idEstudiante: _idEstudiante!,
      certificadoConapdis: _certificadoController.text.trim(),
      informeMedico: _informeController.text.trim(),
      tratamiento: _tratamientoController.text.trim(),
    );

    try {
      if (_idHistorialMedico != null) {
        await HistorialMedicoService().editarHistorialMedico(_idHistorialMedico!, historial);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Historial médico actualizado exitosamente')),
          );
          Navigator.of(context).pop(true);
        }
      } else {
        await HistorialMedicoService().crearHistorialMedico(historial);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Historial médico guardado exitosamente')),
          );
          Navigator.of(context).pop(true);
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

  @override
  Widget build(BuildContext context) {
    final bool esEscritorio = MediaQuery.of(context).size.width > 700;
    final double formWidth = esEscritorio ? 500 : double.infinity;

    return Scaffold(
      appBar: AppBar(
        title: Text(_idHistorialMedico != null ? 'Editar Historial Médico' : 'Nuevo Historial Médico', style: const TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: formWidth),
            child: Card(
              elevation: 8.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        _idHistorialMedico != null ? 'Editar Historial Médico' : 'Nuevo Historial Médico',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20.0),
                      TextFormField(
                        controller: _certificadoController,
                        decoration: const InputDecoration(
                          labelText: 'Certificado CONAPDIS',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.picture_as_pdf),
                        ),
                        maxLines: 1,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _informeController,
                        decoration: const InputDecoration(
                          labelText: 'Informe Médico',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.description),
                        ),
                        maxLines: 1,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _tratamientoController,
                        decoration: const InputDecoration(
                          labelText: 'Tratamiento',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.medical_services),
                        ),
                        maxLines: 1,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: _isSaving
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Icon(Icons.save),
                          label: Text(_idHistorialMedico != null ? 'Guardar Cambios' : 'Guardar'),
                          onPressed: _isSaving ? null : _guardarHistorial,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
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
      ),
    );
  }
}