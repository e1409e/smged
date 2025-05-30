// lib/layout/screens/forms/estudiante_form_screen.dart
import 'package:flutter/material.dart';
import 'package:collection/collection.dart'; // Necesario para firstWhereOrNull

import 'package:smged/api/models/estudiante.dart';
import 'package:smged/api/models/discapacidad.dart'; // Asegúrate de importar tu modelo Discapacidad
import 'package:smged/api/services/estudiantes_service.dart';
import 'package:smged/api/services/discapacidades_service.dart';
import 'package:smged/layout/widgets/custom_colors.dart'; // Asumo que lo usas para colores

class EstudianteFormScreen extends StatefulWidget {
  final Estudiante? estudianteToEdit;

  const EstudianteFormScreen({super.key, this.estudianteToEdit});

  @override
  State<EstudianteFormScreen> createState() => _EstudianteFormScreenState();
}

class _EstudianteFormScreenState extends State<EstudianteFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nombresController = TextEditingController();
  final TextEditingController _apellidosController = TextEditingController();
  final TextEditingController _cedulaController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _direccionController = TextEditingController();
  final TextEditingController _observacionesController = TextEditingController();
  final TextEditingController _seguimientoController = TextEditingController();

  DateTime? _fechaNacimiento;
  List<Discapacidad> _discapacidades = [];
  Discapacidad? _selectedDiscapacidad;

  final DiscapacidadesService _discapacidadesService = DiscapacidadesService();
  bool _isLoadingDiscapacidades = true;
  String? _discapacidadesError;

  final EstudiantesService _estudiantesService = EstudiantesService();

  @override
  void initState() {
    super.initState();
    _fetchDiscapacidades(); // Siempre carga las discapacidades

    // 1. Inicializar los controladores con los datos del estudiante si está en modo edición
    if (widget.estudianteToEdit != null) {
      final estudiante = widget.estudianteToEdit!;
      _nombresController.text = estudiante.nombres;
      _apellidosController.text = estudiante.apellidos;
      _cedulaController.text = estudiante.cedula;
      _correoController.text = estudiante.correo ?? '';
      _telefonoController.text = estudiante.telefono ?? '';
      _direccionController.text = estudiante.direccion ?? '';
      _observacionesController.text = estudiante.observaciones ?? '';
      _seguimientoController.text = estudiante.seguimiento ?? '';
      _fechaNacimiento = estudiante.fechaNacimiento;

      // Importante: No se puede seleccionar _selectedDiscapacidad aquí directamente,
      // porque _discapacidades aún no se han cargado.
      // Se hará después de _fetchDiscapacidades en _setInitialDiscapacidadSelection.
    }
  }

  @override
  void dispose() {
    _nombresController.dispose();
    _apellidosController.dispose();
    _cedulaController.dispose();
    _correoController.dispose();
    _telefonoController.dispose();
    _direccionController.dispose();
    _observacionesController.dispose();
    _seguimientoController.dispose();
    super.dispose();
  }

  // Método para seleccionar la discapacidad inicial
  void _setInitialDiscapacidadSelection() {
    // Solo intenta establecer la selección si estamos editando y tenemos un ID de discapacidad
    if (widget.estudianteToEdit != null && widget.estudianteToEdit!.idDiscapacidad != null) {
      final int idDiscapacidadToMatch = widget.estudianteToEdit!.idDiscapacidad!;

      // Busca la discapacidad en la lista cargada por su ID
      final Discapacidad? initialDiscapacidad = _discapacidades.firstWhereOrNull(
        (d) => d.idDiscapacidad == idDiscapacidadToMatch,
      );

      if (initialDiscapacidad != null) {
        // Usa setState para actualizar el estado del DropdownButtonFormField
        setState(() {
          
          _selectedDiscapacidad = initialDiscapacidad;
        });
        debugPrint('Discapacidad inicial seleccionada: ${_selectedDiscapacidad!.nombre}');
      } else {
        debugPrint('No se encontró la discapacidad con ID ${idDiscapacidadToMatch} en la lista cargada.');
        // Opcional: Mostrar un mensaje al usuario si la discapacidad no se encuentra
      }
    }
  }

  // Función asíncrona para obtener las discapacidades de la API
  Future<void> _fetchDiscapacidades() async {
    setState(() {
      _isLoadingDiscapacidades = true;
      _discapacidadesError = null;
    });
    try {
      final fetchedDiscapacidades = await _discapacidadesService.obtenerDiscapacidades();
      setState(() {
        _discapacidades = fetchedDiscapacidades;
        // 2. Llama a este método DESPUÉS de que _discapacidades esté poblada
        _setInitialDiscapacidadSelection();
      });
    } catch (e) {
      setState(() {
        _discapacidadesError = 'Error al cargar discapacidades: ${e.toString().replaceFirst('Exception: ', '')}';
      });
    } finally {
      setState(() {
        _isLoadingDiscapacidades = false;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fechaNacimiento ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      locale: const Locale('es', 'ES'),
      helpText: 'Selecciona la fecha de nacimiento',
      cancelText: 'Cancelar',
      confirmText: 'Aceptar',
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary, // Color principal del calendario
              onPrimary: AppColors.textTitle, // Color del texto en el encabezado
              onSurface: AppColors.textPrimary, // Color del texto del calendario
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary, // Color de los botones del calendario
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _fechaNacimiento) {
      setState(() {
        _fechaNacimiento = picked;
      });
    }
  }

  Future<void> _saveEstudiante() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Guardando estudiante...'), duration: Duration(seconds: 1)),
    );

    try {
      final String nombres = _nombresController.text;
      final String apellidos = _apellidosController.text;
      final String cedula = _cedulaController.text;
      final String correo = _correoController.text;
      final String telefono = _telefonoController.text;
      final String direccion = _direccionController.text;
      final String observaciones = _observacionesController.text;
      final String seguimiento = _seguimientoController.text;

      final int? idDiscapacidad = _selectedDiscapacidad?.idDiscapacidad;

      if (idDiscapacidad == null) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor, selecciona una discapacidad.'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      final bool isEditing = widget.estudianteToEdit != null;
      final int? currentEstudianteId = widget.estudianteToEdit?.idEstudiante;

      final Estudiante estudiantePayload = Estudiante(
        idEstudiante: currentEstudianteId,
        nombres: nombres,
        apellidos: apellidos,
        cedula: cedula,
        correo: correo,
        telefono: telefono,
        direccion: direccion,
        fechaNacimiento: _fechaNacimiento,
        idDiscapacidad: idDiscapacidad,
        observaciones: observaciones,
        seguimiento: seguimiento,
        discapacidad: _selectedDiscapacidad?.nombre, // Pasa el nombre de la discapacidad si está seleccionada
        // No asignes fechaRegistro, fechaActualizacion aquí si solo los lees de la API
      );

      Estudiante? savedEstudiante;

      if (isEditing) {
        savedEstudiante = await _estudiantesService.actualizarEstudiante(estudiantePayload);
      } else {
        savedEstudiante = await _estudiantesService.crearEstudiante(estudiantePayload);
      }

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Estudiante "${savedEstudiante?.nombres ?? 'Desconocido'}" ${isEditing ? 'actualizado' : 'guardado'} exitosamente.'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.of(context).pop(true);
    } catch (e) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al ${widget.estudianteToEdit != null ? 'actualizar' : 'guardar'} estudiante: ${e.toString().replaceFirst('Exception: ', '')}'),
          backgroundColor: Colors.red,
        ),
      );
      debugPrint('Error al guardar/actualizar estudiante: $e');
    }
  }

  void _submitForm() {
    _saveEstudiante();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.estudianteToEdit == null ? 'Registrar Estudiante' : 'Editar Estudiante'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textTitle,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Título
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Text(
                  widget.estudianteToEdit == null ? 'Ingresa los datos del nuevo estudiante' : 'Edita los datos del estudiante',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                  textAlign: TextAlign.center,
                ),
              ),

              // Campo Nombres
              TextFormField(
                controller: _nombresController,
                decoration: const InputDecoration(
                  labelText: 'Nombres',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa los nombres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),

              // Campo Apellidos
              TextFormField(
                controller: _apellidosController,
                decoration: const InputDecoration(
                  labelText: 'Apellidos',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa los apellidos';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),

              // Campo Cédula
              TextFormField(
                controller: _cedulaController,
                decoration: const InputDecoration(
                  labelText: 'Cédula',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.credit_card),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa la cédula';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),

              // Campo Fecha de Nacimiento
              InkWell(
                onTap: () => _selectDate(context),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Fecha de Nacimiento',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.calendar_today),
                    suffixIcon: _fechaNacimiento != null
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                _fechaNacimiento = null;
                              });
                            },
                          )
                        : null,
                  ),
                  child: Text(
                    _fechaNacimiento == null
                        ? 'Selecciona una fecha'
                        : '${_fechaNacimiento!.day}/${_fechaNacimiento!.month}/${_fechaNacimiento!.year}',
                    style: TextStyle(
                      color: _fechaNacimiento == null ? Colors.grey[700] : Colors.black,
                      fontSize: 16.0,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),

              // Campo Correo
              TextFormField(
                controller: _correoController,
                decoration: const InputDecoration(
                  labelText: 'Correo',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value != null && value.isNotEmpty && !value.contains('@')) {
                    return 'Introduce un correo válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),

              // Campo Teléfono
              TextFormField(
                controller: _telefonoController,
                decoration: const InputDecoration(
                  labelText: 'Teléfono',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16.0),

              // Campo Dirección
              TextFormField(
                controller: _direccionController,
                decoration: const InputDecoration(
                  labelText: 'Dirección',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.home),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16.0),

              // Campo Observaciones
              TextFormField(
                controller: _observacionesController,
                decoration: const InputDecoration(
                  labelText: 'Observaciones',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.notes),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16.0),

              // Campo Seguimiento
              TextFormField(
                controller: _seguimientoController,
                decoration: const InputDecoration(
                  labelText: 'Seguimiento',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.track_changes),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16.0),

              // Dropdown para Discapacidad
              _isLoadingDiscapacidades
                  ? const Center(child: CircularProgressIndicator())
                  : _discapacidadesError != null
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            _discapacidadesError!,
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                        )
                      : DropdownButtonFormField<Discapacidad>(
                          value: _selectedDiscapacidad,
                          decoration: const InputDecoration(
                            labelText: 'Discapacidad',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.wheelchair_pickup),
                          ),
                          hint: const Text('Selecciona una discapacidad'),
                          validator: (value) {
                            if (value == null) {
                              return 'Por favor selecciona una discapacidad';
                            }
                            return null;
                          },
                          items: _discapacidades.map((Discapacidad discapacidad) {
                            return DropdownMenuItem<Discapacidad>(
                              value: discapacidad,
                              child: Text(discapacidad.nombre),
                            );
                          }).toList(),
                          onChanged: (Discapacidad? newValue) {
                            setState(() {
                              _selectedDiscapacidad = newValue;
                            });
                          },
                          // Esto es clave: si `_selectedDiscapacidad` no es uno de los objetos en `_discapacidades`,
                          // el `DropdownButtonFormField` puede no mostrar nada.
                          // Asegurarse que el objeto seleccionado es una instancia de la lista.
                        ),
              const SizedBox(height: 20.0),

              // Botón de Guardar/Actualizar
              ElevatedButton.icon(
                onPressed: _submitForm,
                icon: Icon(widget.estudianteToEdit == null ? Icons.save : Icons.update),
                label: Text(widget.estudianteToEdit == null ? 'Guardar Estudiante' : 'Actualizar Estudiante'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textTitle,
                  padding: const EdgeInsets.symmetric(vertical: 15.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}