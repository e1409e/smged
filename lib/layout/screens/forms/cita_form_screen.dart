// lib/layout/screens/forms/cita_form_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // Para defaultTargetPlatform

import 'package:smged/layout/widgets/custom_colors.dart';
import 'package:smged/layout/widgets/custom_dataPickerForm.dart'; // widget de fecha
import 'package:smged/api/models/cita.dart'; // Importa el modelo de Cita
import 'package:smged/api/models/estudiante.dart'; // Importa el modelo de Estudiante
import 'package:smged/api/services/citas_service.dart'; // Importa el servicio de Citas
import 'package:smged/api/services/estudiantes_service.dart'; // Importa el servicio de Estudiantes
import 'package:collection/collection.dart'; // Para firstWhereOrNull

class CitaFormScreen extends StatefulWidget {
  final Cita? citaToEdit;

  const CitaFormScreen({super.key, this.citaToEdit});

  @override
  State<CitaFormScreen> createState() => _CitaFormScreenState();
}

class _CitaFormScreenState extends State<CitaFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _motivoCitaController = TextEditingController(); // Cambiado de _descripcionController
  DateTime? _fechaCita; // Solo fecha

  List<Estudiante> _estudiantes = [];
  Estudiante? _selectedEstudiante;
  int? _selectedPendiente; // Mapeado a 'pendiente' del modelo

  final EstudiantesService _estudiantesService = EstudiantesService();
  final CitasService _citasService = CitasService();

  bool _isLoadingEstudiantes = true;
  String? _estudiantesError;

  // Opciones predefinidas para Pendiente (0 = No, 1 = Sí)
  final List<Map<String, dynamic>> _estadosPendiente = [
    {'label': 'Cita Pendiente', 'value': 1},
    {'label': 'Cita Realizada', 'value': 0},
  ];


  @override
  void initState() {
    super.initState();
    _fetchEstudiantes();

    if (widget.citaToEdit != null) {
      final cita = widget.citaToEdit!;
      _motivoCitaController.text = cita.motivo_cita ?? ''; // Usa motivo_cita
      _fechaCita = cita.fecha_cita; // Asigna la fecha
      _selectedPendiente = cita.pendiente; // Asigna el valor de pendiente
      // La selección del estudiante se maneja en _setInitialEstudianteSelection()
    }
  }

Future<void> _fetchEstudiantes() async {
    setState(() {
      _isLoadingEstudiantes = true;
      _estudiantesError = null;
    });
    try {
      // ¡CAMBIO AQUÍ!
      final fetchedEstudiantes = await _estudiantesService.obtenerTodosLosEstudiantes(); // <-- Mismo nombre que en el servicio
      setState(() {
        _estudiantes = fetchedEstudiantes;
        _setInitialEstudianteSelection();
      });
    } catch (e) {
      setState(() {
        _estudiantesError = 'Error al cargar estudiantes: ${e.toString().replaceFirst('Exception: ', '')}';
      });
    } finally {
      setState(() {
        _isLoadingEstudiantes = false;
      });
    }
  }

  void _setInitialEstudianteSelection() {
    if (widget.citaToEdit != null && widget.citaToEdit!.id_estudiante != null) { // Usa id_estudiante
      final initialEstudiante = _estudiantes.firstWhereOrNull(
            (e) => e.idEstudiante == widget.citaToEdit!.id_estudiante, // Compara con id_estudiante
      );
      if (initialEstudiante != null) {
        setState(() {
          _selectedEstudiante = initialEstudiante;
        });
      }
    }
  }

  Future<void> _saveCita() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Guardando cita...'), duration: Duration(seconds: 1)),
    );

    try {
      final String? motivoCita = _motivoCitaController.text.isNotEmpty ? _motivoCitaController.text : null; // Usa motivo_cita
      final int? idEstudiante = _selectedEstudiante?.idEstudiante;

      if (_fechaCita == null) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor, selecciona la fecha de la cita.'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      if (_selectedPendiente == null) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor, selecciona el estado de la cita (Pendiente/Realizada).'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      if (idEstudiante == null) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor, selecciona un estudiante.'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      final bool isEditing = widget.citaToEdit != null;
      final int? currentCitaId = widget.citaToEdit?.id_citas; // Usa id_citas

      final Cita citaPayload = Cita(
        id_citas: currentCitaId,
        motivo_cita: motivoCita, // Usa motivo_cita
        fecha_cita: _fechaCita!, // Solo se envía la fecha
        pendiente: _selectedPendiente!, // Usa pendiente
        id_estudiante: idEstudiante, // Usa id_estudiante
      );

      Cita? savedCita;

      if (isEditing) {
        savedCita = await _citasService.actualizarCita(citaPayload);
      } else {
        savedCita = await _citasService.crearCita(citaPayload);
      }

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cita ${isEditing ? 'actualizada' : 'guardada'} exitosamente.'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.of(context).pop(true);
    } catch (e) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al ${widget.citaToEdit != null ? 'actualizar' : 'guardar'} cita: ${e.toString().replaceFirst('Exception: ', '')}'),
          backgroundColor: Colors.red,
        ),
      );
      debugPrint('Error al guardar/actualizar cita: $e');
    }
  }

  @override
  void dispose() {
    _motivoCitaController.dispose(); // Usa _motivoCitaController
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      debugPrint('Formulario de cita validado y listo para guardar/actualizar.');
      debugPrint('Motivo Cita: ${_motivoCitaController.text}'); // Usa motivo_cita
      debugPrint('Fecha Cita: $_fechaCita');
      debugPrint('Estado Pendiente: $_selectedPendiente');
      debugPrint('Estudiante ID: ${_selectedEstudiante?.idEstudiante}');
      debugPrint('Estudiante Nombre: ${_selectedEstudiante?.nombres} ${_selectedEstudiante?.apellidos}');

      _saveCita();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux ||
        defaultTargetPlatform == TargetPlatform.fuchsia;

    final maxWidth = isDesktop ? 600.0 : double.infinity;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.citaToEdit == null ? 'Registrar Cita' : 'Editar Cita'), // Título dinámico
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textTitle,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
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
                    children: <Widget>[
                      Text(
                        'Detalles de la Cita',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20.0),
                      TextFormField(
                        controller: _motivoCitaController, // Usa _motivoCitaController
                        decoration: const InputDecoration(
                          labelText: 'Motivo de la Cita', // Cambiado de 'Descripción'
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.description),
                        ),
                        maxLines: 3,
                        validator: (value) {
                          // No se requiere validador si el campo es opcional
                          return null;
                        },
                      ),
                      const SizedBox(height: 16.0),
                      DatePickerFormField(
                        labelText: 'Fecha de la Cita',
                        initialDate: _fechaCita,
                        firstDate: DateTime(2000), // Fecha mínima
                        lastDate: DateTime(2100), // Fecha máxima
                        prefixIcon: Icons.calendar_today,
                        helpText: 'Seleccionar Fecha de la Cita',
                        onChanged: (DateTime? newDate) {
                          setState(() {
                            _fechaCita = newDate;
                          });
                        },
                        validator: (value) {
                          if (_fechaCita == null) {
                            return 'Por favor, selecciona la fecha de la cita.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16.0),
                      DropdownButtonFormField<int>( // Cambiado a int para 'pendiente'
                        decoration: const InputDecoration(
                          labelText: 'Estado (Pendiente/Realizada)', // Nuevo label
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.check_circle_outline), // Icono más acorde
                        ),
                        value: _selectedPendiente,
                        hint: const Text('Selecciona el estado de la cita'),
                        isExpanded: true,
                        items: _estadosPendiente.map((estado) {
                          return DropdownMenuItem<int>(
                            value: estado['value'],
                            child: Text(estado['label']),
                          );
                        }).toList(),
                        onChanged: (int? newValue) {
                          setState(() {
                            _selectedPendiente = newValue;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Por favor, selecciona el estado de la cita.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16.0),
                      Text(
                        'Estudiante Asociado',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16.0),
                      _isLoadingEstudiantes
                          ? const Center(child: CircularProgressIndicator())
                          : _estudiantesError != null
                              ? Text(
                                  _estudiantesError!,
                                  style: const TextStyle(color: AppColors.error),
                                  textAlign: TextAlign.center,
                                )
                              : DropdownButtonFormField<Estudiante>(
                                  decoration: const InputDecoration(
                                    labelText: 'Estudiante',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.person_search),
                                  ),
                                  value: _selectedEstudiante,
                                  hint: const Text('Selecciona un estudiante'),
                                  isExpanded: true,
                                  items: _estudiantes.map((estudiante) {
                                    return DropdownMenuItem<Estudiante>(
                                      value: estudiante,
                                      child: Text('${estudiante.nombres} ${estudiante.apellidos}'),
                                    );
                                  }).toList(),
                                  onChanged: (Estudiante? newValue) {
                                    setState(() {
                                      _selectedEstudiante = newValue;
                                    });
                                  },
                                  validator: (value) {
                                    if (value == null) {
                                      return 'Por favor, selecciona un estudiante.';
                                    }
                                    return null;
                                  },
                                ),
                      const SizedBox(height: 24.0),
                      ElevatedButton.icon(
                        onPressed: _submitForm,
                        icon: const Icon(Icons.save),
                        label: Text(widget.citaToEdit == null ? 'Guardar Cita' : 'Actualizar Cita'), // Texto del botón dinámico
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.textTitle,
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
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