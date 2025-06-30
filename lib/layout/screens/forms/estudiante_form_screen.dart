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
import 'package:smged/layout/widgets/custom_dropdown_button.dart';
// Importa para usar TextInputFormatter
import 'package:flutter/services.dart';

// NUEVAS IMPORTACIONES PARA CARRERAS
import 'package:smged/api/models/carrera.dart';
import 'package:smged/api/services/carreras_service.dart';
// Importación clave: las nuevas excepciones personalizadas
import 'package:smged/api/exceptions/api_exception.dart'; 

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
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _direccionController = TextEditingController();
  final TextEditingController _observacionesController =
      TextEditingController();
  final TextEditingController _seguimientoController = TextEditingController();

  // NUEVOS CONTROLADORES
  final TextEditingController _otroTelefonoController = TextEditingController();

  DateTime? _fechaNacimiento;
  List<Discapacidad> _discapacidades = [];
  Discapacidad? _selectedDiscapacidad;

  List<Carrera> _carreras = [];
  Carrera? _selectedCarrera;

  final DiscapacidadesService _discapacidadesService = DiscapacidadesService();
  final CarrerasService _carrerasService = CarrerasService();

  bool _isLoadingDiscapacidades = true;
  bool _isLoadingCarreras = true;

  String? _discapacidadesError;
  String? _carrerasError;

  final EstudiantesService _estudiantesService = EstudiantesService();

  // --- VARIABLES PARA LA CÉDULA ---
  String _cedulaPrefix = 'V-';
  // --- FIN VARIABLES CÉDULA ---

  // --- VARIABLE PARA POSEE CONAPDIS ---
  bool _poseeConapdis = false;
  // --- FIN POSEE CONAPDIS ---

  @override
  void initState() {
    super.initState();
    _fetchDiscapacidades();
    _fetchCarreras();

    if (widget.estudianteToEdit != null) {
      final estudiante = widget.estudianteToEdit!;
      _nombresController.text = estudiante.nombres;
      _apellidosController.text = estudiante.apellidos;

      // --- MODIFICACIÓN PARA CÉDULA AL EDITAR ---
      if (estudiante.cedula.startsWith('V-')) {
        _cedulaPrefix = 'V-';
        _cedulaController.text = estudiante.cedula.substring(2);
      } else if (estudiante.cedula.startsWith('E-')) {
        _cedulaPrefix = 'E-';
        _cedulaController.text = estudiante.cedula.substring(2);
      } else {
        _cedulaController.text = estudiante.cedula;
      }
      // --- FIN MODIFICACIÓN CÉDULA ---

      _correoController.text = estudiante.correo ?? '';
      _telefonoController.text = estudiante.telefono ?? '';
      _otroTelefonoController.text = estudiante.otroTelefono ?? '';
      _direccionController.text = estudiante.direccion ?? '';
      _observacionesController.text = estudiante.observaciones ?? '';
      _seguimientoController.text = estudiante.seguimiento ?? '';
      _fechaNacimiento = estudiante.fechaNacimiento;
      _poseeConapdis = estudiante.poseeConapdis ?? false;
    }
  }

  void _setInitialDiscapacidadSelection() {
    if (widget.estudianteToEdit != null) {
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

  void _setInitialCarreraSelection() {
    if (widget.estudianteToEdit != null) {
      final initialCarrera = _carreras.firstWhereOrNull(
        (c) => c.idCarrera == widget.estudianteToEdit!.idCarrera,
      );
      if (initialCarrera != null) {
        setState(() {
          _selectedCarrera = initialCarrera;
        });
      }
    }
  }

  Future<void> _fetchDiscapacidades() async {
    setState(() {
      _isLoadingDiscapacidades = true;
      _discapacidadesError = null;
    });
    try {
      final fetchedDiscapacidades = await _discapacidadesService
          .obtenerDiscapacidades();
      setState(() {
        _discapacidades = fetchedDiscapacidades;
        _setInitialDiscapacidadSelection();
      });
    } on NetworkException catch (e) {
      setState(() {
        _discapacidadesError = 'Error de red: ${e.message}';
      });
      _showErrorSnackBar('No se pudieron cargar las discapacidades debido a un problema de conexión.');
    } on ApiException catch (e) {
      setState(() {
        _discapacidadesError = 'Error al cargar discapacidades: ${e.message}';
      });
       _showErrorSnackBar('Ocurrió un error al cargar las discapacidades: ${e.message}');
    } catch (e) {
      setState(() {
        _discapacidadesError = 'Error inesperado al cargar discapacidades.';
      });
      _showErrorSnackBar('Ocurrió un error inesperado al cargar las discapacidades.');
    } finally {
      setState(() {
        _isLoadingDiscapacidades = false;
      });
    }
  }

  Future<void> _fetchCarreras() async {
    setState(() {
      _isLoadingCarreras = true;
      _carrerasError = null;
    });
    try {
      final fetchedCarreras = await _carrerasService.obtenerCarreras();
      setState(() {
        _carreras = fetchedCarreras;
        _setInitialCarreraSelection();
      });
    } on NetworkException catch (e) {
      setState(() {
        _carrerasError = 'Error de red: ${e.message}';
      });
      _showErrorSnackBar('No se pudieron cargar las carreras debido a un problema de conexión.');
    } on ApiException catch (e) {
      setState(() {
        _carrerasError = 'Error al cargar carreras: ${e.message}';
      });
      _showErrorSnackBar('Ocurrió un error al cargar las carreras: ${e.message}');
    } catch (e) {
      setState(() {
        _carrerasError = 'Error inesperado al cargar carreras.';
      });
      _showErrorSnackBar('Ocurrió un error inesperado al cargar las carreras.');
    } finally {
      setState(() {
        _isLoadingCarreras = false;
      });
    }
  }

  Future<void> _saveEstudiante() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Oculta el SnackBar anterior si existe y muestra el de "Guardando..."
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Guardando estudiante...'),
        duration: Duration(seconds: 1),
      ),
    );

    try {
      final String nombres = _nombresController.text;
      final String apellidos = _apellidosController.text;
      final String cedulaCompleta = _cedulaPrefix + _cedulaController.text;
      final String correo = _correoController.text;
      final String telefono = _telefonoController.text;
      final String otroTelefono = _otroTelefonoController.text;
      final String direccion = _direccionController.text;
      final String observaciones = _observacionesController.text;
      final String seguimiento = _seguimientoController.text;

      final int? idDiscapacidad = _selectedDiscapacidad?.idDiscapacidad;
      final int? idCarrera = _selectedCarrera?.idCarrera;

      if (idDiscapacidad == null) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        _showErrorSnackBar('Por favor, selecciona una discapacidad.');
        return;
      }

      if (idCarrera == null) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        _showErrorSnackBar('Por favor, selecciona una carrera.');
        return;
      }

      final bool isEditing = widget.estudianteToEdit != null;
      final int? currentEstudianteId = widget.estudianteToEdit?.idEstudiante;

      final Estudiante estudiantePayload = Estudiante(
        idEstudiante: currentEstudianteId,
        nombres: nombres,
        apellidos: apellidos,
        cedula: cedulaCompleta,
        correo: correo,
        telefono: telefono,
        otroTelefono: otroTelefono,
        direccion: direccion,
        fechaNacimiento: _fechaNacimiento,
        idDiscapacidad: idDiscapacidad,
        observaciones: observaciones,
        seguimiento: seguimiento,
        idCarrera: idCarrera,
        poseeConapdis: _poseeConapdis,
      );

      Estudiante? savedEstudiante;

      if (isEditing) {
        savedEstudiante = await _estudiantesService.actualizarEstudiante(
          estudiantePayload,
        );
      } else {
        savedEstudiante = await _estudiantesService.crearEstudiante(
          estudiantePayload,
        );
      }

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Estudiante "${savedEstudiante?.nombres ?? 'Desconocido'}" ${isEditing ? 'actualizado' : 'guardado'} exitosamente.',
          ),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.of(context).pop(true);
    } on NetworkException catch (e) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      _showErrorSnackBar(
        'Problema de conexión: ${e.message}',
      );
      debugPrint('Error de red al guardar/actualizar estudiante: $e');
    } on ValidationException catch (e) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      _showErrorSnackBar(
        'Error de validación: ${e.toString()}', // e.toString() ya formatea los errores de validación
      );
      debugPrint('Error de validación al guardar/actualizar estudiante: $e');
      // Aquí podrías incluso iterar sobre e.errors si quisieras mostrar errores debajo de cada TextFormField
      // Por ejemplo: _showValidationErrors(e.errors);
    } on NotFoundException catch (e) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      _showErrorSnackBar(
        'Estudiante no encontrado: ${e.message}',
      );
      debugPrint('Error: estudiante no encontrado al actualizar: $e');
    } on ApiException catch (e) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      _showErrorSnackBar(
        'Error de la API: ${e.message}',
      );
      debugPrint('Error general de la API al guardar/actualizar estudiante: $e');
    } catch (e) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      _showErrorSnackBar(
        'Ocurrió un error inesperado. Por favor, inténtalo de nuevo.',
      );
      debugPrint('Error inesperado al guardar/actualizar estudiante: $e');
    }
  }

  // Método auxiliar para mostrar SnackBar de error de forma consistente
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4), // Mostrar el error por más tiempo
      ),
    );
  }

  @override
  void dispose() {
    _nombresController.dispose();
    _apellidosController.dispose();
    _cedulaController.dispose();
    _correoController.dispose();
    _telefonoController.dispose();
    _otroTelefonoController.dispose();
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
      debugPrint('Cédula: $_cedulaPrefix${_cedulaController.text}');
      debugPrint('Correo: ${_correoController.text}');
      debugPrint('Teléfono: ${_telefonoController.text}');
      debugPrint('Otro Teléfono: ${_otroTelefonoController.text}');
      debugPrint('Dirección: ${_direccionController.text}');
      debugPrint('Fecha de Nacimiento: $_fechaNacimiento');
      debugPrint('Discapacidad ID: ${_selectedDiscapacidad?.idDiscapacidad}');
      debugPrint('Discapacidad Nombre: ${_selectedDiscapacidad?.nombre}');
      debugPrint('Carrera ID: ${_selectedCarrera?.idCarrera}');
      debugPrint('Carrera Nombre: ${_selectedCarrera?.carrera}');
      debugPrint('Posee CONAPDIS: $_poseeConapdis');
      debugPrint('Observaciones: ${_observacionesController.text}');
      debugPrint('Seguimiento: ${_seguimientoController.text}');

      _saveEstudiante();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop =
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux ||
        defaultTargetPlatform == TargetPlatform.fuchsia;

    final maxWidth = isDesktop ? 600.0 : double.infinity;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.estudianteToEdit == null
              ? 'Registrar Estudiante'
              : 'Editar Estudiante',
        ),
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
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
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
                                DropdownMenuItem(
                                  value: 'V-',
                                  child: Text('V-'),
                                ),
                                DropdownMenuItem(
                                  value: 'E-',
                                  child: Text('E-'),
                                ),
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
                          const SizedBox(
                            width: 8.0,
                          ), // Espacio entre el dropdown y el campo de texto
                          Expanded(
                            child: TextFormField(
                              controller: _cedulaController,
                              decoration: const InputDecoration(
                                labelText: 'Cédula',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.credit_card),
                              ),
                              keyboardType: TextInputType
                                  .number, // Solo números después del prefijo
                              inputFormatters: [
                                FilteringTextInputFormatter
                                    .digitsOnly, // Permite solo dígitos
                                LengthLimitingTextInputFormatter(
                                  9,
                                ), // Limita la longitud a 9 dígitos (ej: 012345678)
                              ],
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor, introduce la cédula.';
                                }
                                if (value.length < 7 || value.length > 9) {
                                  // Ajusta la longitud según tu necesidad
                                  return 'La cédula debe tener entre 7 y 9 dígitos.';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),

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
                          if (value != null &&
                              value.isNotEmpty &&
                              !value.contains('@')) {
                            return 'Introduce un correo electrónico válido.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16.0),
                      TextFormField(
                        controller: _telefonoController,
                        decoration: const InputDecoration(
                          labelText: 'Teléfono Principal',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.phone),
                        ),
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter
                              .digitsOnly, // Permite solo dígitos
                          LengthLimitingTextInputFormatter(
                            11,
                          ), // Limita la longitud a 11 (ej: 04141234567)
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, introduce el teléfono principal.';
                          }
                          if (value.length < 7) {
                            return 'El teléfono debe tener al menos 7 dígitos.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16.0),
                      TextFormField(
                        controller: _otroTelefonoController,
                        decoration: const InputDecoration(
                          labelText: 'Otro Teléfono (Opcional)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.phone_android),
                        ),
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(11),
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
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, introduce la dirección.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16.0),
                      Text(
                        'Datos Académicos y Médicos',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16.0),
                      // Dropdown de Carreras
                      CustomDropdownButton<Carrera>(
                        labelText: 'Carrera',
                        hintText: 'Selecciona una carrera',
                        prefixIcon: Icons.school,
                        isLoading: _isLoadingCarreras,
                        errorMessage: _carrerasError,
                        items: _carreras,
                        value: _selectedCarrera,
                        onChanged: (newValue) {
                          setState(() {
                            _selectedCarrera = newValue;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Por favor, selecciona una carrera.';
                          }
                          return null;
                        },

                        itemDisplayText: (carrera) =>
                            carrera.carrera, // Cómo mostrar el texto del item
                        itemSearchFilter: (carrera, query) {
                          return carrera.carrera.toLowerCase().contains(
                            query,
                          ); // Lógica de búsqueda
                        },
                      ),
                      const SizedBox(height: 16.0),
                      // Dropdown de Discapacidades
                      CustomDropdownButton<Discapacidad>(
                        labelText: 'Discapacidad',
                        hintText: 'Selecciona una discapacidad',
                        prefixIcon: Icons.accessible,
                        isLoading: _isLoadingDiscapacidades,
                        errorMessage: _discapacidadesError,
                        items: _discapacidades,
                        value: _selectedDiscapacidad,
                        onChanged: (newValue) {
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
                        
                        itemDisplayText: (discapacidad) =>
                            discapacidad.nombre, // Cómo mostrar el texto
                        itemSearchFilter: (discapacidad, query) {
                          return discapacidad.nombre.toLowerCase().contains(
                            query,
                          ); // Lógica de búsqueda
                        },
                      ),
                      const SizedBox(height: 16.0),
                      // Switch para "Posee CONAPDIS"
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '¿Posee certificado CONAPDIS?',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                          Switch(
                            value: _poseeConapdis,
                            onChanged: (bool value) {
                              setState(() {
                                _poseeConapdis = value;
                              });
                            },
                            activeColor: AppColors.primary,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16.0),
                      TextFormField(
                        controller: _observacionesController,
                        decoration: const InputDecoration(
                          labelText: 'Observaciones (Opcional)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.notes),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16.0),
                      TextFormField(
                        controller: _seguimientoController,
                        decoration: const InputDecoration(
                          labelText: 'Seguimiento (Opcional)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.track_changes),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 24.0),
                      ElevatedButton.icon(
                        onPressed: _submitForm,
                        icon: const Icon(Icons.save),
                        label: Text(
                          widget.estudianteToEdit == null
                              ? 'Guardar Estudiante'
                              : 'Actualizar Estudiante',
                        ),
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