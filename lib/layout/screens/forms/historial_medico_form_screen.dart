import 'package:flutter/material.dart';
import 'package:smged/layout/widgets/custom_colors.dart';
import 'package:smged/api/models/historial_medico.dart';
import 'package:smged/api/services/historial_medico_service.dart';
import 'package:smged/api/exceptions/api_exception.dart';

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
  Map<String, List<String>>? _validationErrors;

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
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_idEstudiante == null) {
      _showErrorSnackBar('No se ha especificado el estudiante.');
      return;
    }

    setState(() {
      _isSaving = true;
      _validationErrors = null;
    });

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
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          _showInfoSnackBar('Historial médico actualizado exitosamente.');
          Navigator.of(context).pop(true);
        }
      } else {
        await HistorialMedicoService().crearHistorialMedico(historial);
        if (mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          _showSuccessSnackBar('Historial médico guardado exitosamente.');
          Navigator.of(context).pop(true);
        }
      }
    } on NetworkException catch (e) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      _showErrorSnackBar('Problema de conexión: ${e.message}');
    } on ValidationException catch (e) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      setState(() {
        _validationErrors = e.errors;
      });
      _showErrorSnackBar('Error de validación: ${e.toString()}');
      _formKey.currentState!.validate();
    } on NotFoundException catch (e) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      _showErrorSnackBar('No encontrado: ${e.message}');
    } on ApiException catch (e) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      _showErrorSnackBar('Error de la API: ${e.message}');
    } catch (e) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      _showErrorSnackBar('Ocurrió un error inesperado al guardar el historial médico.');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // Verde para guardado/eliminación exitosa
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  // Azul para edición exitosa
  void _showInfoSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  // Rojo para errores
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  String? _fieldError(String field) {
    if (_validationErrors != null && _validationErrors![field] != null) {
      return _validationErrors![field]!.join('\n');
    }
    return null;
  }

  @override
  void dispose() {
    _certificadoController.dispose();
    _informeController.dispose();
    _tratamientoController.dispose();
    super.dispose();
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
                        onChanged: (_) {
                          if (_validationErrors != null && _validationErrors!.containsKey('certificado_conapdis')) {
                            setState(() {
                              _validationErrors!.remove('certificado_conapdis');
                            });
                          }
                        },
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'Por favor, introduce el certificado CONAPDIS.';
                          }
                          final err = _fieldError('certificado_conapdis');
                          return err;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _informeController,
                        decoration: const InputDecoration(
                          labelText: 'Informe Médico',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.description),
                        ),
                        maxLines: 4,
                        onChanged: (_) {
                          if (_validationErrors != null && _validationErrors!.containsKey('informe_medico')) {
                            setState(() {
                              _validationErrors!.remove('informe_medico');
                            });
                          }
                        },
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'Por favor, introduce el informe médico.';
                          }
                          final err = _fieldError('informe_medico');
                          return err;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _tratamientoController,
                        decoration: const InputDecoration(
                          labelText: 'Tratamiento',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.medical_services),
                        ),
                        maxLines: 4,
                        onChanged: (_) {
                          if (_validationErrors != null && _validationErrors!.containsKey('tratamiento')) {
                            setState(() {
                              _validationErrors!.remove('tratamiento');
                            });
                          }
                        },
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'Por favor, introduce el tratamiento.';
                          }
                          final err = _fieldError('tratamiento');
                          return err;
                        },
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