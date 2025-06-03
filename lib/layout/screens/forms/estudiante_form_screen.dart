// lib/layout/screens/forms/estudiante_form_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // Para defaultTargetPlatform
import 'package:smged/layout/widgets/custom_colors.dart';
import 'package:smged/layout/widgets/custom_dataPickerForm.dart'; // widget de fecha
import 'package:smged/api/models/discapacidad.dart'; // Importa el modelo de Discapacidad
import 'package:smged/api/services/discapacidades_service.dart'; // Importa el servicio de Discapacidades
import 'package:smged/api/models/estudiante.dart'; // ¡Asegúrate de importar tu modelo Estudiante!
import 'package:smged/api/services/estudiantes_service.dart'; // ¡Asegúrate de importar tu servicio EstudiantesService!
import 'package:collection/collection.dart'; // ¡Añade esta línea!

// Importa para usar TextInputFormatter
import 'package:flutter/services.dart';


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

  // --- NUEVAS VARIABLES PARA LA CÉDULA ---
  String _cedulaPrefix = 'V-'; // Prefijo inicial
  // --- FIN NUEVAS VARIABLES ---


  @override
  void initState() {
    super.initState();
    _fetchDiscapacidades();

    if (widget.estudianteToEdit != null) {
      final estudiante = widget.estudianteToEdit!;
      _nombresController.text = estudiante.nombres;
      _apellidosController.text = estudiante.apellidos;
      // --- MODIFICACIÓN PARA CÉDULA AL EDITAR ---
      // Si la cédula tiene un prefijo, extráelo
      if (estudiante.cedula.startsWith('V-')) {
        _cedulaPrefix = 'V-';
        _cedulaController.text = estudiante.cedula.substring(2); // Elimina "V-"
      } else if (estudiante.cedula.startsWith('E-')) {
        _cedulaPrefix = 'E-';
        _cedulaController.text = estudiante.cedula.substring(2); // Elimina "E-"
      } else {
        _cedulaController.text = estudiante.cedula; // Si no hay prefijo conocido
      }
      // --- FIN MODIFICACIÓN ---
      _correoController.text = estudiante.correo ?? '';
      _telefonoController.text = estudiante.telefono ?? '';
      _direccionController.text = estudiante.direccion ?? '';
      _observacionesController.text = estudiante.observaciones ?? '';
      _seguimientoController.text = estudiante.seguimiento ?? '';
      _fechaNacimiento = estudiante.fechaNacimiento;
    }
  }

  void _setInitialDiscapacidadSelection() {
    if (widget.estudianteToEdit != null && widget.estudianteToEdit!.idDiscapacidad != null) {
      final initialDiscapacidad = _discapacidades.firstWhereOrNull(
        (d) => d.idDiscapacidad == widget.estudianteToEdit!.idDiscapacidad,
      );
      if (initialDiscapacidad != null) {
        setState(() {
          _selectedDiscapacidad = initialDiscapacidad;
        });
      }
    }
  }

  @override
  Future<void> _fetchDiscapacidades() async {
    setState(() {
      _isLoadingDiscapacidades = true;
      _discapacidadesError = null;
    });
    try {
      final fetchedDiscapacidades = await _discapacidadesService.obtenerDiscapacidades();
      setState(() {
        _discapacidades = fetchedDiscapacidades;
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
      // --- MODIFICACIÓN PARA CÉDULA AL GUARDAR ---
      final String cedulaCompleta = _cedulaPrefix + _cedulaController.text;
      // --- FIN MODIFICACIÓN ---
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
        cedula: cedulaCompleta, // Usa la cédula con prefijo
        correo: correo,
        telefono: telefono,
        direccion: direccion,
        fechaNacimiento: _fechaNacimiento,
        idDiscapacidad: idDiscapacidad,
        observaciones: observaciones,
        seguimiento: seguimiento,
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

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      debugPrint('Formulario validado y listo para guardar/actualizar.');
      debugPrint('Nombres: ${_nombresController.text}');
      debugPrint('Apellidos: ${_apellidosController.text}');
      debugPrint('Cédula: $_cedulaPrefix${_cedulaController.text}'); // Muestra la cédula completa
      debugPrint('Correo: ${_correoController.text}');
      debugPrint('Teléfono: ${_telefonoController.text}');
      debugPrint('Dirección: ${_direccionController.text}');
      debugPrint('Fecha de Nacimiento: $_fechaNacimiento');
      debugPrint('Discapacidad ID: ${_selectedDiscapacidad?.idDiscapacidad}');
      debugPrint('Discapacidad Nombre: ${_selectedDiscapacidad?.nombre}');
      debugPrint('Observaciones: ${_observacionesController.text}');
      debugPrint('Seguimiento: ${_seguimientoController.text}');

      _saveEstudiante();
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
        title: Text(widget.estudianteToEdit == null ? 'Registrar Estudiante' : 'Editar Estudiante'), // Título dinámico
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
                        'Datos Personales',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20.0),
                      TextFormField(
                        controller: _nombresController,
                        decoration: const InputDecoration(
                          labelText: 'Nombres',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, introduce los nombres.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16.0),
                      TextFormField(
                        controller: _apellidosController,
                        decoration: const InputDecoration(
                          labelText: 'Apellidos',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, introduce los apellidos.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16.0),
                      // --- CAMBIOS PARA EL CAMPO DE CÉDULA ---
                      Row(
                        children: [
                          // Dropdown para el prefijo V- o E-
                          DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _cedulaPrefix,
                              items: const [
                                DropdownMenuItem(value: 'V-', child: Text('V-')),
                                DropdownMenuItem(value: 'E-', child: Text('E-')),
                              ],
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  setState(() {
                                    _cedulaPrefix = newValue;
                                  });
                                }
                              },
                              dropdownColor: Theme.of(context).cardColor, 
                              icon: const Icon(Icons.arrow_drop_down),
                              elevation: 8,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                          const SizedBox(width: 8.0), // Espacio entre el dropdown y el campo de texto
                          Expanded(
                            child: TextFormField(
                              controller: _cedulaController,
                              decoration: InputDecoration(
                                labelText: 'Cédula',
                                border: const OutlineInputBorder(),
                                prefixIcon: const Icon(Icons.credit_card),
                                
                              ),
                              keyboardType: TextInputType.number, // Solo números después del prefijo
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly, // Permite solo dígitos
                                LengthLimitingTextInputFormatter(9), // Limita la longitud a 9 dígitos (ej: 012345678)
                              ],
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor, introduce la cédula.';
                                }
                                // Puedes añadir una validación más específica aquí, por ejemplo, longitud exacta
                                if (value.length < 7 || value.length > 9) { // Ajusta la longitud según tu necesidad
                                  return 'La cédula debe tener entre 7 y 9 dígitos.';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      // --- FIN CAMBIOS PARA EL CAMPO DE CÉDULA ---
                      const SizedBox(height: 16.0),
                      DatePickerFormField(
                        labelText: 'Fecha de Nacimiento',
                        initialDate: _fechaNacimiento,
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                        prefixIcon: Icons.calendar_today,
                        helpText: 'Seleccionar Fecha de Nacimiento',
                        onChanged: (DateTime? newDate) {
                          setState(() {
                            _fechaNacimiento = newDate;
                          });
                        },
                        validator: (value) {
                          if (_fechaNacimiento == null) {
                            return 'Por favor, selecciona la fecha de nacimiento.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16.0),
                      Text(
                        'Información de Contacto',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16.0),
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
                            return 'Introduce un correo electrónico válido.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16.0),
                      TextFormField(
                        controller: _telefonoController,
                        decoration: const InputDecoration(
                          labelText: 'Teléfono',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.phone),
                        ),
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly, // Permite solo dígitos
                          LengthLimitingTextInputFormatter(11), // Limita la longitud a 11 (ej: 04141234567)
                        ],
                      ),
                      const SizedBox(height: 16.0),
                      TextFormField(
                        controller: _direccionController,
                        decoration: const InputDecoration(
                          labelText: 'Dirección',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.location_on),
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 16.0),
                      Text(
                        'Datos Medicos',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16.0),
                      _isLoadingDiscapacidades
                          ? const Center(child: CircularProgressIndicator())
                          : _discapacidadesError != null
                              ? Text(
                                  _discapacidadesError!,
                                  style: const TextStyle(color: AppColors.error),
                                  textAlign: TextAlign.center,
                                )
                              : DropdownButtonFormField<Discapacidad>(
                                  decoration: const InputDecoration(
                                    labelText: 'Discapacidad',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.accessible),
                                  ),
                                  value: _selectedDiscapacidad,
                                  hint: const Text('Selecciona una discapacidad'),
                                  isExpanded: true,
                                  items: _discapacidades.map((discapacidad) {
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
                                  validator: (value) {
                                    if (value == null) {
                                      return 'Por favor, selecciona una discapacidad.';
                                    }
                                    return null;
                                  },
                                ),
                      const SizedBox(height: 16.0),
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
                      TextFormField(
                        controller: _seguimientoController,
                        decoration: const InputDecoration(
                          labelText: 'Seguimiento',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.track_changes),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 24.0),
                      ElevatedButton.icon(
                        onPressed: _submitForm,
                        icon: const Icon(Icons.save),
                        label: Text(widget.estudianteToEdit == null ? 'Guardar Estudiante' : 'Actualizar Estudiante'), // Texto del botón dinámico
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