// lib/layout/screens/forms/historial_medico_form_screen.dart
import 'package:flutter/material.dart';
import 'package:smged/api/models/historial_medico.dart';
import 'package:smged/api/services/historial_medico_service.dart';
import 'package:smged/layout/widgets/custom_colors.dart';

class HistorialMedicoFormScreen extends StatefulWidget {
  final HistorialMedico? historialToEdit; // Historial médico para editar (opcional)

  const HistorialMedicoFormScreen({super.key, this.historialToEdit});

  @override
  State<HistorialMedicoFormScreen> createState() => _HistorialMedicoFormScreenState();
}

class _HistorialMedicoFormScreenState extends State<HistorialMedicoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final HistorialMedicoService _historialMedicoService = HistorialMedicoService();

  // Controladores para los campos del formulario
  late TextEditingController _idEstudianteController;
  late TextEditingController _informeMedicoController;
  late TextEditingController _tratamientoController;
  // Modificado para String
  late TextEditingController _certificadoConapdisController;

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Inicializar controladores con valores del historial a editar, si existe
    _idEstudianteController = TextEditingController(
        text: widget.historialToEdit?.idEstudiante.toString() ?? '');
    _informeMedicoController = TextEditingController(
        text: widget.historialToEdit?.informeMedico ?? '');
    _tratamientoController = TextEditingController(
        text: widget.historialToEdit?.tratamiento ?? '');
    // Modificado para String: Si el valor de tu modelo puede ser null, ajusta.
    // Asumo que si es null, quieres un string vacío.
    _certificadoConapdisController = TextEditingController(
        text: widget.historialToEdit?.certificadoConapdis ?? '');
  }

  @override
  void dispose() {
    _idEstudianteController.dispose();
    _informeMedicoController.dispose();
    _tratamientoController.dispose();
    _certificadoConapdisController.dispose(); // Disponer del nuevo controlador
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        final int idEstudiante = int.parse(_idEstudianteController.text);
        final String informeMedico = _informeMedicoController.text;
        final String tratamiento = _tratamientoController.text;
        // Obtener el valor del campo de texto para certificadoConapdis
        final String certificadoConapdis = _certificadoConapdisController.text;

        if (widget.historialToEdit == null) {
          // Crear nuevo historial médico
          final newHistorial = HistorialMedico(
            idHistorialMedico: 0, // El ID se generará en el backend
            idEstudiante: idEstudiante,
            certificadoConapdis: certificadoConapdis, // Ahora es un String
            informeMedico: informeMedico,
            tratamiento: tratamiento,
            fechaCreacion: DateTime.now(), // Se establecerá en el backend
            fechaActualizacion: DateTime.now(), // Se establecerá en el backend
          );

          await _historialMedicoService.crearHistorialMedico(newHistorial);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Historial médico creado exitosamente.'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).pop(true); // Indica éxito
          }
        } else {
          // Actualizar historial médico existente
          final updatedHistorial = HistorialMedico(
            idHistorialMedico: widget.historialToEdit!.idHistorialMedico, // Mantener el ID existente
            idEstudiante: idEstudiante,
            certificadoConapdis: certificadoConapdis, // Ahora es un String
            informeMedico: informeMedico,
            tratamiento: tratamiento,
            fechaCreacion: widget.historialToEdit!.fechaCreacion, // Mantener la fecha de creación original
            fechaActualizacion: DateTime.now(), // Actualizar la fecha de actualización
          );

          await _historialMedicoService.editarHistorialMedico(
              widget.historialToEdit!.idHistorialMedico, updatedHistorial);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Historial médico actualizado exitosamente.'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).pop(true); // Indica éxito
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _errorMessage = 'Error: ${e.toString().replaceFirst('Exception: ', '')}';
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_errorMessage!),
              backgroundColor: AppColors.error,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.historialToEdit == null
              ? 'Crear Historial Médico'
              : 'Editar Historial Médico',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textTitle,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Campo ID Estudiante
              TextFormField(
                controller: _idEstudianteController,
                decoration: InputDecoration(
                  labelText: 'ID del Estudiante',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  prefixIcon: const Icon(Icons.person),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese el ID del estudiante.';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Por favor, ingrese un número válido.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),

              // Campo Informe Médico
              TextFormField(
                controller: _informeMedicoController,
                decoration: InputDecoration(
                  labelText: 'Informe Médico',
                  alignLabelWithHint: true, // Alinea la etiqueta al principio para multilínea
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  prefixIcon: const Icon(Icons.description),
                ),
                maxLines: 5, // Permite múltiples líneas
                keyboardType: TextInputType.multiline,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese el informe médico.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),

              // Campo Tratamiento
              TextFormField(
                controller: _tratamientoController,
                decoration: InputDecoration(
                  labelText: 'Tratamiento',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  prefixIcon: const Icon(Icons.healing),
                ),
                maxLines: 5, // Permite múltiples líneas
                keyboardType: TextInputType.multiline,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese el tratamiento.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),

              // --- Campo de texto para Certificado CONAPDIS (antes Checkbox) ---
              TextFormField(
                controller: _certificadoConapdisController,
                decoration: InputDecoration(
                  labelText: 'Certificado CONAPDIS',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  prefixIcon: const Icon(Icons.assignment), // Icono más adecuado
                  hintText: 'Ej: Sí, No, o número de certificado', // Sugerencia para el usuario
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese el estado o número de certificado CONAPDIS.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24.0),

              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.textTitle,
                        padding: const EdgeInsets.symmetric(vertical: 15.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: Text(
                        widget.historialToEdit == null
                            ? 'Crear Historial Médico'
                            : 'Guardar Cambios',
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: AppColors.error, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}