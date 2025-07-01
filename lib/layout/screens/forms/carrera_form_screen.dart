import 'package:flutter/material.dart';
import 'package:smged/api/models/carrera.dart';
import 'package:smged/api/models/facultad.dart';
import 'package:smged/api/services/carreras_service.dart';
import 'package:smged/api/services/facultades_service.dart';
import 'package:smged/layout/widgets/custom_colors.dart';
import 'package:smged/layout/widgets/custom_dropdown_button.dart';
import 'package:collection/collection.dart';
import 'package:smged/api/exceptions/api_exception.dart';

class CarreraFormDialog extends StatefulWidget {
  final Carrera? carreraToEdit;

  const CarreraFormDialog({super.key, this.carreraToEdit});

  @override
  State<CarreraFormDialog> createState() => _CarreraFormDialogState();
}

class _CarreraFormDialogState extends State<CarreraFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _carreraController = TextEditingController();
  Facultad? _selectedFacultad;
  List<Facultad> _facultades = [];
  bool _isLoadingFacultades = true;
  bool _isSaving = false;

  // Errores de validación por campo
  Map<String, List<String>>? _validationErrors;

  @override
  void initState() {
    super.initState();
    _fetchFacultades();
    if (widget.carreraToEdit != null) {
      _carreraController.text = widget.carreraToEdit!.carrera;
    }
  }

  Future<void> _fetchFacultades() async {
    setState(() => _isLoadingFacultades = true);
    try {
      final data = await FacultadesService().obtenerFacultades();
      setState(() {
        _facultades = data;
        if (widget.carreraToEdit != null) {
          _selectedFacultad = data.firstWhereOrNull(
            (f) => f.idFacultad == widget.carreraToEdit!.idFacultad,
          );
        }
      });
    } catch (_) {
    } finally {
      setState(() => _isLoadingFacultades = false);
    }
  }

  void _save() async {
    // Limpia los errores antes de validar
    setState(() {
      _validationErrors = null;
    });
    if (!_formKey.currentState!.validate() || _selectedFacultad == null) return;
    setState(() {
      _isSaving = true;
    });

    final service = CarrerasService();
    try {
      if (widget.carreraToEdit == null) {
        await service.crearCarrera(
          _carreraController.text,
          _selectedFacultad!.idFacultad,
        );
      } else {
        await service.actualizarCarrera(
          widget.carreraToEdit!.idCarrera,
          _carreraController.text,
          _selectedFacultad!.idFacultad,
        );
      }
      if (mounted) Navigator.pop(context, true);
    } on ValidationException catch (e) {
      setState(() {
        _validationErrors = e.errors;
      });
      if (e.errors['general'] != null) {
        _showErrorSnackBar(e.errors['general']!.join(', '));
      }
      _formKey.currentState!.validate();
    } on ApiException catch (e) {
      _showErrorSnackBar('Error: ${e.message}');
    } catch (e) {
      _showErrorSnackBar('Error inesperado al guardar carrera.');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
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
  Widget build(BuildContext context) {
    final bool esEscritorio = MediaQuery.of(context).size.width > 700;
    final double formWidth = esEscritorio
        ? 400
        : MediaQuery.of(context).size.width * 0.98;

    return AlertDialog(
      title: Text(
        widget.carreraToEdit == null ? 'Nueva Carrera' : 'Editar Carrera',
      ),
      content: SizedBox(
        width: formWidth,
        child: _isLoadingFacultades
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _carreraController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre de la Carrera',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 12,
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Campo requerido';
                        final err = _fieldError('carrera');
                        return err;
                      },
                    ),
                    const SizedBox(height: 10),
                    CustomDropdownButton<Facultad>(
                      labelText: 'Facultad',
                      hintText: 'Selecciona una facultad',
                      prefixIcon: Icons.account_balance,
                      isLoading: _isLoadingFacultades,
                      errorMessage: null,
                      items: _facultades,
                      value: _selectedFacultad,
                      onChanged: (f) => setState(() => _selectedFacultad = f),
                      validator: (v) {
                        if (v == null) return 'Selecciona una facultad';
                        final err = _fieldError('id_facultad');
                        return err;
                      },
                      itemDisplayText: (f) => '${f.facultad} (${f.siglas})',
                      itemSearchFilter: (f, query) =>
                          f.facultad.toLowerCase().contains(
                            query.toLowerCase(),
                          ) ||
                          f.siglas.toLowerCase().contains(query.toLowerCase()),
                    ),
                  ],
                ),
              ),
      ),
      actions: [
        TextButton(
          child: const Text('Cancelar'),
          onPressed: () => Navigator.pop(context),
        ),
        ElevatedButton(
          onPressed: _isSaving ? null : _save,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          child: _isSaving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Guardar'),
        ),
      ],
    );
  }
}
