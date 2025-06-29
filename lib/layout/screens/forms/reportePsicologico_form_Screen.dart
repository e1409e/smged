import 'package:flutter/material.dart';
import 'package:smged/layout/widgets/custom_colors.dart';
import 'package:smged/api/models/estudiante.dart';
import 'package:smged/api/models/reporte_psicologico.dart';
import 'package:smged/api/services/estudiantes_service.dart';
import 'package:smged/api/services/reporte_psicologico_service.dart';
import 'package:collection/collection.dart';

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
          // El estudiante se selecciona en _fetchEstudiantes
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
        // Selección de estudiante para edición o estudiante fijo
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
        title: Text(isEdit ? 'Editar Reporte Psicológico' : 'Agregar Reporte Psicológico'),
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
                        isEdit ? 'Editar Reporte Psicológico' : 'Nuevo Reporte Psicológico',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20.0),
                      DropdownButtonFormField<Estudiante>(
                        value: _selectedEstudiante,
                        items: _estudiantes
                            .map((e) => DropdownMenuItem(
                                  value: e,
                                  child: Text('${e.nombres} ${e.apellidos} (${e.cedula})'),
                                ))
                            .toList(),
                        onChanged: estudianteFieldDisabled
                            ? null
                            : (value) => setState(() => _selectedEstudiante = value),
                        decoration: InputDecoration(
                          labelText: 'Estudiante',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        validator: (value) => value == null ? 'Seleccione un estudiante' : null,
                      ),
                      const SizedBox(height: 18),
                      TextFormField(
                        controller: _motivoController,
                        decoration: InputDecoration(
                          labelText: 'Motivo de Consulta',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          prefixIcon: const Icon(Icons.psychology),
                        ),
                        maxLines: 2,
                        validator: (value) =>
                            value == null || value.trim().isEmpty ? 'Ingrese el motivo de consulta' : null,
                      ),
                      const SizedBox(height: 18),
                      TextFormField(
                        controller: _sintesisController,
                        decoration: InputDecoration(
                          labelText: 'Síntesis Diagnóstica',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          prefixIcon: const Icon(Icons.description),
                        ),
                        maxLines: 2,
                        validator: (value) =>
                            value == null || value.trim().isEmpty ? 'Ingrese la síntesis diagnóstica' : null,
                      ),
                      const SizedBox(height: 18),
                      TextFormField(
                        controller: _recomendacionesController,
                        decoration: InputDecoration(
                          labelText: 'Recomendaciones',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          prefixIcon: const Icon(Icons.recommend),
                        ),
                        maxLines: 2,
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
                              : Icon(isEdit ? Icons.save : Icons.add),
                          label: Text(isEdit ? 'Guardar Cambios' : 'Agregar Reporte'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
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