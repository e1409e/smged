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
class EstudianteFormScreen extends StatefulWidget {
  // 1. Añade un constructor para recibir un Estudiante opcional
  final Estudiante? estudianteToEdit; // Puede ser nulo si es una creación

  const EstudianteFormScreen({super.key, this.estudianteToEdit}); // Constructor modificado

  @override
  State<EstudianteFormScreen> createState() => _EstudianteFormScreenState();
}

class _EstudianteFormScreenState extends State<EstudianteFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controladores para los campos de texto
  final TextEditingController _nombresController = TextEditingController();
  final TextEditingController _apellidosController = TextEditingController();
  final TextEditingController _cedulaController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _direccionController = TextEditingController();
  final TextEditingController _observacionesController = TextEditingController();
  final TextEditingController _seguimientoController = TextEditingController();

  // Variables de estado para los campos específicos
  DateTime? _fechaNacimiento;
  List<Discapacidad> _discapacidades = []; // Lista de discapacidades para el Dropdown
  Discapacidad? _selectedDiscapacidad; // La discapacidad seleccionada en el Dropdown

  // Instancia del servicio para obtener las discapacidades
  final DiscapacidadesService _discapacidadesService = DiscapacidadesService();
  bool _isLoadingDiscapacidades = true; // Para mostrar un indicador de carga
  String? _discapacidadesError; // Para manejar errores al cargar las discapacidades

  final EstudiantesService _estudiantesService = EstudiantesService();


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

    // Determinar si estamos creando o editando
    final bool isEditing = widget.estudianteToEdit != null;
    final int? currentEstudianteId = widget.estudianteToEdit?.idEstudiante; // Obtén el ID si estamos editando

    // Crear la instancia del modelo Estudiante
    final Estudiante estudiantePayload = Estudiante(
      idEstudiante: currentEstudianteId, // El ID solo se incluirá si estamos editando
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
      // No asignes fechaRegistro, fechaActualizacion, discapacidad aquí si solo los lees de la API
      // El constructor de Estudiante ya los tiene como null si no se proporcionan
    );

    Estudiante? savedEstudiante; // Para guardar la respuesta de la API

    if (isEditing) {
      // Si estamos editando, llama al método de actualización
      savedEstudiante = await _estudiantesService.actualizarEstudiante(estudiantePayload);
    } else {
      // Si estamos creando, llama al método de creación
      savedEstudiante = await _estudiantesService.crearEstudiante(estudiantePayload);
    }

    // Si llega aquí, significa que la operación fue exitosa
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Estudiante "${savedEstudiante?.nombres ?? 'Desconocido'}" ${isEditing ? 'actualizado' : 'guardado'} exitosamente.'),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.of(context).pop(true); // Pasa 'true' para indicar éxito y refrescar la lista
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
  void initState() {
    super.initState();
    _fetchDiscapacidades(); // Siempre carga las discapacidades

    // 2. Inicializar el formulario si se está editando un estudiante
    if (widget.estudianteToEdit != null) {
      final estudiante = widget.estudianteToEdit!;
      _nombresController.text = estudiante.nombres;
      _apellidosController.text = estudiante.apellidos;
      _cedulaController.text = estudiante.cedula;
      _correoController.text = estudiante.correo ?? ''; // Usar '' si es nulo para los controladores
      _telefonoController.text = estudiante.telefono ?? '';
      _direccionController.text = estudiante.direccion ?? '';
      _observacionesController.text = estudiante.observaciones ?? '';
      _seguimientoController.text = estudiante.seguimiento ?? '';
      _fechaNacimiento = estudiante.fechaNacimiento;

      // Importante: Necesitas que _selectedDiscapacidad se seleccione basado en idDiscapacidad del estudiante
      // Esto se hará DESPUÉS de que _discapacidades se carguen.
      // Por eso, la llamada a _setInitialDiscapacidadSelection.
    }
  }
  // Nuevo método para seleccionar la discapacidad inicial (llamado después de cargar _discapacidades)
  void _setInitialDiscapacidadSelection() {
    if (widget.estudianteToEdit != null && widget.estudianteToEdit!.idDiscapacidad != null) {
      // Busca la discapacidad en la lista cargada por su ID
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
  // Función asíncrona para obtener las discapacidades de la API
  @override // Asegúrate que esta anotación este aqui
  Future<void> _fetchDiscapacidades() async {
    setState(() {
      _isLoadingDiscapacidades = true;
      _discapacidadesError = null;
    });
    try {
      final fetchedDiscapacidades = await _discapacidadesService.obtenerDiscapacidades();
      setState(() {
        _discapacidades = fetchedDiscapacidades;
        // 3. Llama a este método después de cargar las discapacidades
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
  @override
  void dispose() {
    // Liberar los controladores cuando el widget se destruye
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

  // Función para manejar el envío del formulario
  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      debugPrint('Formulario validado y listo para guardar/actualizar.');
      debugPrint('Nombres: ${_nombresController.text}');
      debugPrint('Apellidos: ${_apellidosController.text}');
      debugPrint('Cédula: ${_cedulaController.text}');
      debugPrint('Correo: ${_correoController.text}');
      debugPrint('Teléfono: ${_telefonoController.text}');
      debugPrint('Dirección: ${_direccionController.text}');
      debugPrint('Fecha de Nacimiento: $_fechaNacimiento');
      // Aquí es donde obtienes el ID de la discapacidad seleccionada:
      debugPrint('Discapacidad ID: ${_selectedDiscapacidad?.idDiscapacidad}');
      debugPrint('Discapacidad Nombre: ${_selectedDiscapacidad?.nombre}');
      debugPrint('Observaciones: ${_observacionesController.text}');
      debugPrint('Seguimiento: ${_seguimientoController.text}');

      // Aquí deberías llamar a tu servicio para guardar los datos en la API
      // Por ejemplo: await _estudianteService.crearEstudiante(...)
      _saveEstudiante();
      //Navigator.of(context).pop(); // Vuelve a la pantalla anterior
      
    }
  }

  @override
  Widget build(BuildContext context) {
    // Lógica para limitar el ancho en escritorio/web
    final isDesktop = defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux ||
        defaultTargetPlatform == TargetPlatform.fuchsia;

    final maxWidth = isDesktop ? 600.0 : double.infinity;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Formulario de Estudiante'),
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
                      TextFormField(
                        controller: _cedulaController,
                        decoration: const InputDecoration(
                          labelText: 'Cédula',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.credit_card),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, introduce la cédula.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16.0),
                      // Tu widget reutilizable para la fecha
                      DatePickerFormField( // Usamos el nombre actualizado del archivo
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
                        'Datos Adicionales',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16.0),

                      // --- ¡Aquí está el DropdownButtonFormField para Discapacidad! ---
                      _isLoadingDiscapacidades
                          ? const Center(child: CircularProgressIndicator()) // Muestra carga
                          : _discapacidadesError != null
                              ? Text( // Muestra error si falla la carga
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
                                  value: _selectedDiscapacidad, // El valor seleccionado
                                  hint: const Text('Selecciona una discapacidad'), // Texto cuando no hay selección
                                  isExpanded: true, // Para que ocupe todo el ancho
                                  items: _discapacidades.map((discapacidad) {
                                    return DropdownMenuItem<Discapacidad>(
                                      value: discapacidad, // El valor del ítem es el objeto Discapacidad
                                      child: Text(discapacidad.nombre), // Lo que se muestra es el nombre
                                    );
                                  }).toList(),
                                  onChanged: (Discapacidad? newValue) {
                                    // Cuando el usuario selecciona, actualiza el estado
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
                      // --- Fin del DropdownButtonFormField ---

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
                        label: const Text('Guardar Estudiante'),
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