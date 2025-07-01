import 'package:flutter/material.dart';
import 'package:smged/layout/widgets/custom_colors.dart';
import 'package:smged/layout/widgets/custom_dataPickerForm.dart';
import 'package:smged/layout/widgets/custom_dropdown_button.dart';
import 'package:smged/api/models/estudiante.dart';
import 'package:smged/api/models/incidencia.dart';
import 'package:smged/api/services/estudiantes_service.dart';
import 'package:smged/api/services/incidencias_service.dart';
import 'package:collection/collection.dart';

class IncidenciasFormScreen extends StatefulWidget {
  final Incidencia? incidenciaToEdit;
  final int? idEstudianteFijo;

  const IncidenciasFormScreen({
    super.key,
    this.incidenciaToEdit,
    this.idEstudianteFijo,
  });

  @override
  State<IncidenciasFormScreen> createState() => _IncidenciasFormScreenState();
}

class _IncidenciasFormScreenState extends State<IncidenciasFormScreen> {
  Incidencia? _incidenciaToEdit; // <--- NUEVO

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _acuerdosController = TextEditingController();
  final TextEditingController _observacionesController =
      TextEditingController();
  final TextEditingController _lugarController = TextEditingController();

  DateTime? _fechaIncidente;
  TimeOfDay? _horaIncidente;

  List<Estudiante> _estudiantes = [];
  Estudiante? _selectedEstudiante;

  final EstudiantesService _estudiantesService = EstudiantesService();
  final IncidenciasService _incidenciasService = IncidenciasService();

  bool _isLoadingEstudiantes = true;
  String? _estudiantesError;
  bool _isSaving = false;
  bool _initialized = false;
  int? _idEstudianteFijoArg; // <-- Para manejar argumento por ruta

  @override
  void initState() {
    super.initState();
    _fetchEstudiantes();

    _fechaIncidente = _fechaIncidente ?? DateTime.now();
    _horaIncidente = _horaIncidente ?? TimeOfDay.now();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final args = ModalRoute.of(context)?.settings.arguments;
      Incidencia? incidenciaToEdit = widget.incidenciaToEdit;
      int? idEstudianteFijo = widget.idEstudianteFijo;
      if (args is Map && args['idEstudianteFijo'] != null) {
        idEstudianteFijo = args['idEstudianteFijo'] as int;
      } else if (args is Incidencia) {
        incidenciaToEdit = args;
      }
      _idEstudianteFijoArg = idEstudianteFijo;
      _incidenciaToEdit = incidenciaToEdit; // <--- NUEVO

      if (_incidenciaToEdit != null) {
        _descripcionController.text = _incidenciaToEdit!.descripcionIncidente;
        _acuerdosController.text = _incidenciaToEdit!.acuerdos ?? '';
        _observacionesController.text = _incidenciaToEdit!.observaciones ?? '';
        _lugarController.text = _incidenciaToEdit!.lugarIncidente ?? '';
        _fechaIncidente =
            DateTime.tryParse(_incidenciaToEdit!.fechaIncidente) ?? DateTime.now();
        if (_incidenciaToEdit!.horaIncidente.isNotEmpty) {
          final parts = _incidenciaToEdit!.horaIncidente.split(':');
          if (parts.length >= 2) {
            _horaIncidente = TimeOfDay(
              hour: int.tryParse(parts[0]) ?? 0,
              minute: int.tryParse(parts[1]) ?? 0,
            );
          }
        }
      }
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _descripcionController.dispose();
    _acuerdosController.dispose();
    _observacionesController.dispose();
    _lugarController.dispose();
    super.dispose();
  }

  Future<void> _fetchEstudiantes() async {
    setState(() {
      _isLoadingEstudiantes = true;
      _estudiantesError = null;
    });
    try {
      final fetchedEstudiantes = await _estudiantesService
          .obtenerTodosLosEstudiantes();
      if (!mounted) return;
      setState(() {
        _estudiantes = fetchedEstudiantes;
        _setInitialEstudianteSelection();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _estudiantesError = 'Error al cargar estudiantes: ${e.toString()}';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingEstudiantes = false;
        });
      }
    }
  }

  void _setInitialEstudianteSelection() {
    if (_incidenciaToEdit != null && _incidenciaToEdit!.idEstudiante != null) {
      final initialEstudiante = _estudiantes.firstWhereOrNull(
        (e) => e.idEstudiante == _incidenciaToEdit!.idEstudiante,
      );
      if (initialEstudiante != null) {
        _selectedEstudiante = initialEstudiante;
      }
    } else if (_idEstudianteFijoArg != null) {
      final estudianteFijo = _estudiantes.firstWhereOrNull(
        (e) => e.idEstudiante == _idEstudianteFijoArg,
      );
      if (estudianteFijo != null) {
        _selectedEstudiante = estudianteFijo;
      }
    }
  }

  // Utilidad para convertir TimeOfDay a "HH:mm"
  String _formatTimeOfDay(TimeOfDay tod) {
    final hour = tod.hour.toString().padLeft(2, '0');
    final minute = tod.minute.toString().padLeft(2, '0');
    return '$hour:$minute'; // Solo HH:mm
  }

  Future<void> _saveIncidencia() async {
    if (!_formKey.currentState!.validate()) return;

    if (_fechaIncidente == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecciona la fecha del incidente.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_horaIncidente == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecciona la hora del incidente.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_selectedEstudiante == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecciona un estudiante.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final incidenciaPayload = Incidencia(
        idIncidencia: _incidenciaToEdit?.idIncidencia,
        idEstudiante: _selectedEstudiante!.idEstudiante!,
        descripcionIncidente: _descripcionController.text,
        acuerdos: _acuerdosController.text,
        observaciones: _observacionesController.text,
        lugarIncidente: _lugarController.text,
        fechaIncidente: _fechaIncidente!.toIso8601String().split('T').first,
        horaIncidente: _formatTimeOfDay(_horaIncidente!),
      );

      if (_incidenciaToEdit != null) {
        await _incidenciasService.editarIncidencia(
          _incidenciaToEdit!.idIncidencia!,
          incidenciaPayload,
        );
      } else {
        await _incidenciasService.crearIncidencia(incidenciaPayload);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _incidenciaToEdit == null
                ? 'Incidencia registrada exitosamente.'
                : 'Incidencia actualizada exitosamente.',
          ),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar incidencia: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool esEscritorio = MediaQuery.of(context).size.width > 700;
    final double formWidth = esEscritorio ? 500 : double.infinity;

    // Determina si el campo de estudiante debe estar deshabilitado
    final bool estudianteFieldDisabled =
        (_idEstudianteFijoArg != null) || (_incidenciaToEdit != null);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.incidenciaToEdit == null
              ? 'Registrar Incidencia'
              : 'Editar Incidencia',
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
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
                        widget.incidenciaToEdit == null
                            ? 'Nueva Incidencia'
                            : 'Editar Incidencia',
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
                            return 'Por favor, selecciona un estudiante.';
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
                        controller: _descripcionController,
                        decoration: const InputDecoration(
                          labelText: 'Descripción del Incidente',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.description),
                        ),
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, describe la incidencia.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16.0),
                      TextFormField(
                        controller: _lugarController,
                        decoration: const InputDecoration(
                          labelText: 'Lugar del Incidente',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.place),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, indica el lugar.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16.0),
                      Row(
                        children: [
                          Expanded(
                            child: DatePickerFormField(
                              labelText: 'Fecha del Incidente',
                              initialDate: _fechaIncidente ?? DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime.now(), // <--- Cambia aquí para limitar la fecha máxima a hoy
                              onChanged: (date) {
                                setState(() {
                                  _fechaIncidente = date;
                                });
                              },
                              validator: (date) {
                                if (_fechaIncidente == null) {
                                  return 'Por favor, selecciona la fecha del incidente.';
                                }
                                if (_fechaIncidente!.isAfter(DateTime.now())) {
                                  return 'La fecha no puede ser mayor a la fecha actual.';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: InkWell(
                              onTap: () async {
                                final picked = await showTimePicker(
                                  context: context,
                                  initialTime:
                                      _horaIncidente ?? TimeOfDay.now(),
                                );
                                if (picked != null) {
                                  setState(() {
                                    _horaIncidente = picked;
                                  });
                                }
                              },
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'Hora del Incidente',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.access_time),
                                ),
                                child: Text(
                                  _horaIncidente != null
                                      ? _horaIncidente!.format(context)
                                      : 'Seleccionar hora',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16.0),
                      TextFormField(
                        controller: _acuerdosController,
                        decoration: const InputDecoration(
                          labelText: 'Acuerdos',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.handshake),
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 16.0),
                      TextFormField(
                        controller: _observacionesController,
                        decoration: const InputDecoration(
                          labelText: 'Observaciones',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.notes),
                        ),
                        maxLines: 2,
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
                            widget.incidenciaToEdit == null
                                ? 'Registrar Incidencia'
                                : 'Actualizar Incidencia',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: _isSaving ? null : _saveIncidencia,
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