import 'package:flutter/material.dart';
import 'package:smged/layout/widgets/custom_colors.dart';
import 'package:smged/api/models/estudiante.dart';
import 'package:smged/api/models/reporte_psicologico.dart';
import 'package:smged/api/services/estudiantes_service.dart';
import 'package:smged/api/services/reporte_psicologico_service.dart';
import 'package:collection/collection.dart';
import 'package:smged/layout/widgets/custom_dropdown_button.dart';

class ReportePsicologicoFormScreen extends StatefulWidget {
  final ReportePsicologico? reporteToEdit;
  final int? idEstudianteFijo;

  const ReportePsicologicoFormScreen({
    super.key,
    this.reporteToEdit,
    this.idEstudianteFijo,
  });

  @override
  State<ReportePsicologicoFormScreen> createState() => _ReportePsicologicoFormScreenState();
}

class _ReportePsicologicoFormScreenState extends State<ReportePsicologicoFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _motivoController = TextEditingController();
  final TextEditingController _sintesisController = TextEditingController();
  final TextEditingController _recomendacionesController = TextEditingController();

  List<Estudiante> _estudiantes = [];
  Estudiante? _selectedEstudiante;

  final EstudiantesService _estudiantesService = EstudiantesService();
  final ReportePsicologicoService _reportePsicologicoService = ReportePsicologicoService();

  bool _isLoadingEstudiantes = true;
  String? _estudiantesError;
  bool _isSaving = false;
  bool _initialized = false;
  int? _idEstudianteFijoArg;

  @override
  void initState() {
    super.initState();
    _fetchEstudiantes();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map) {
        if (args['idEstudianteFijo'] != null) {
          _idEstudianteFijoArg = args['idEstudianteFijo'] as int;
        }
        if (args['reporteToEdit'] != null && args['reporteToEdit'] is ReportePsicologico) {
          final reporte = args['reporteToEdit'] as ReportePsicologico;
          _motivoController.text = reporte.motivoConsulta;
          _sintesisController.text = reporte.sintesisDiagnostica;
          _recomendacionesController.text = reporte.recomendaciones;
        }
      } else if (widget.idEstudianteFijo != null) {
        _idEstudianteFijoArg = widget.idEstudianteFijo;
      }
      _initialized = true;
    }
  }

  Future<void> _fetchEstudiantes() async {
    setState(() {
      _isLoadingEstudiantes = true;
      _estudiantesError = null;
    });
    try {
      final data = await _estudiantesService.obtenerTodosLosEstudiantes();
      setState(() {
        _estudiantes = data;
        final args = ModalRoute.of(context)?.settings.arguments;
        ReportePsicologico? reporteToEdit;
        int? idEstudianteFijo;
        if (args is Map) {
          if (args['reporteToEdit'] != null && args['reporteToEdit'] is ReportePsicologico) {
            reporteToEdit = args['reporteToEdit'] as ReportePsicologico;
          }
          if (args['idEstudianteFijo'] != null) {
            idEstudianteFijo = args['idEstudianteFijo'] as int;
          }
        }
        if (reporteToEdit != null) {
          _selectedEstudiante = _estudiantes.firstWhereOrNull(
            (e) => e.idEstudiante == reporteToEdit!.idEstudiante,
          );
        } else if (idEstudianteFijo != null) {
          _selectedEstudiante = _estudiantes.firstWhereOrNull(
            (e) => e.idEstudiante == idEstudianteFijo,
          );
        }
      });
    } catch (e) {
      setState(() {
        _estudiantesError = e.toString();
      });
    } finally {
      setState(() {
        _isLoadingEstudiantes = false;
      });
    }
  }

  @override
  void dispose() {
    _motivoController.dispose();
    _sintesisController.dispose();
    _recomendacionesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedEstudiante == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seleccione un estudiante')),
      );
      return;
    }
    setState(() {
      _isSaving = true;
    });

    final args = ModalRoute.of(context)?.settings.arguments;
    ReportePsicologico? reporteToEdit = widget.reporteToEdit;
    if (args is Map && args['reporteToEdit'] != null && args['reporteToEdit'] is ReportePsicologico) {
      reporteToEdit = args['reporteToEdit'] as ReportePsicologico;
    }

    final reporte = ReportePsicologico(
      idPsicologico: reporteToEdit?.idPsicologico,
      idEstudiante: _selectedEstudiante!.idEstudiante!,
      motivoConsulta: _motivoController.text.trim(),
      sintesisDiagnostica: _sintesisController.text.trim(),
      recomendaciones: _recomendacionesController.text.trim(),
    );

    try {
      if (reporteToEdit == null) {
        await _reportePsicologicoService.crearReportePsicologico(reporte);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reporte psicológico creado exitosamente')),
        );
      } else {
        await _reportePsicologicoService.editarReportePsicologico(
          reporteToEdit.idPsicologico!,
          reporte,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reporte psicológico actualizado exitosamente')),
        );
      }
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    ReportePsicologico? reporteToEdit = widget.reporteToEdit;
    int? idEstudianteFijo = widget.idEstudianteFijo;
    if (args is Map) {
      if (args['reporteToEdit'] != null && args['reporteToEdit'] is ReportePsicologico) {
        reporteToEdit = args['reporteToEdit'] as ReportePsicologico;
      }
      if (args['idEstudianteFijo'] != null) {
        idEstudianteFijo = args['idEstudianteFijo'] as int;
      }
    }
    final bool isEdit = reporteToEdit != null;
    final bool estudianteFieldDisabled = idEstudianteFijo != null || isEdit;
    final bool esEscritorio = MediaQuery.of(context).size.width > 700;
    final double formWidth = esEscritorio ? 500 : double.infinity;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.reporteToEdit == null
              ? 'Agregar Reporte Psicológico'
              : 'Editar Reporte Psicológico',
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
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
                        widget.reporteToEdit == null
                            ? 'Nuevo Reporte Psicológico'
                            : 'Editar Reporte Psicológico',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20.0),
                      CustomDropdownButton<Estudiante>(
                        labelText: 'Estudiante',
                        hintText: 'Selecciona un estudiante',
                        prefixIcon: Icons.person_search,
                        isLoading: _isLoadingEstudiantes,
                        errorMessage: _estudiantesError,
                        items: _estudiantes,
                        value: _selectedEstudiante,
                        onChanged: (newValue) {
                          if (!estudianteFieldDisabled) {
                            setState(() {
                              _selectedEstudiante = newValue;
                            });
                          }
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Seleccione un estudiante';
                          }
                          return null;
                        },
                        itemDisplayText: (estudiante) =>
                            '${estudiante.nombres} ${estudiante.apellidos}',
                        itemSearchFilter: (estudiante, query) {
                          final fullText =
                              '${estudiante.nombres} ${estudiante.apellidos} ${estudiante.cedula}'
                                  .toLowerCase();
                          return fullText.contains(query.toLowerCase());
                        },
                        enabled: !estudianteFieldDisabled,
                      ),
                      const SizedBox(height: 16.0),
                      TextFormField(
                        controller: _motivoController,
                        decoration: const InputDecoration(
                          labelText: 'Motivo de Consulta',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.psychology),
                        ),
                        maxLines: 3,
                        validator: (value) =>
                            value == null || value.trim().isEmpty ? 'Ingrese el motivo de consulta' : null,
                      ),
                      const SizedBox(height: 16.0),
                      TextFormField(
                        controller: _sintesisController,
                        decoration: const InputDecoration(
                          labelText: 'Síntesis Diagnóstica',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.description),
                        ),
                        maxLines: 3,
                        validator: (value) =>
                            value == null || value.trim().isEmpty ? 'Ingrese la síntesis diagnóstica' : null,
                      ),
                      const SizedBox(height: 16.0),
                      TextFormField(
                        controller: _recomendacionesController,
                        decoration: const InputDecoration(
                          labelText: 'Recomendaciones',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.recommend),
                        ),
                        maxLines: 3,
                        validator: (value) =>
                            value == null || value.trim().isEmpty ? 'Ingrese las recomendaciones' : null,
                      ),
                      const SizedBox(height: 24.0),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: _isSaving
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.save),
                          label: Text(
                            widget.reporteToEdit == null
                                ? 'Registrar Reporte'
                                : 'Actualizar Reporte',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: _isSaving ? null : _save,
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