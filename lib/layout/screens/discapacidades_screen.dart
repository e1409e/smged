import 'package:flutter/material.dart';
import 'package:smged/api/models/discapacidad.dart';
import 'package:smged/api/services/discapacidades_service.dart';
import 'package:smged/layout/widgets/custom_colors.dart';
import 'package:smged/api/exceptions/api_exception.dart';
import 'package:smged/layout/widgets/search_bar_widget.dart';

class DiscapacidadesScreen extends StatefulWidget {
  const DiscapacidadesScreen({super.key});

  @override
  State<DiscapacidadesScreen> createState() => _DiscapacidadesScreenState();
}

class _DiscapacidadesScreenState extends State<DiscapacidadesScreen> {
  final DiscapacidadesService _service = DiscapacidadesService();
  List<Discapacidad> _discapacidades = [];
  List<Discapacidad> _filteredDiscapacidades = [];
  bool _isLoading = true;
  String? _error;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchDiscapacidades();
    _searchController.addListener(_filterDiscapacidades);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterDiscapacidades);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchDiscapacidades() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data = await _service.obtenerDiscapacidades();
      setState(() {
        _discapacidades = data;
        _filteredDiscapacidades = data;
      });
    } on NetworkException catch (e) {
      _showSnackBar('Problema de conexión: ${e.message}', error: true);
    } on ApiException catch (e) {
      _showSnackBar('Error: ${e.message}', error: true);
    } catch (e) {
      _showSnackBar('Error inesperado al cargar discapacidades.', error: true);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterDiscapacidades() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredDiscapacidades = List.from(_discapacidades);
      } else {
        _filteredDiscapacidades = _discapacidades.where((discapacidad) {
          return discapacidad.nombre.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  void _showForm({Discapacidad? discapacidad}) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => DiscapacidadFormDialog(discapacidadToEdit: discapacidad),
    );
    if (result == true) {
      await _fetchDiscapacidades();
      _showSnackBar(
        discapacidad == null
            ? 'Discapacidad agregada correctamente'
            : 'Discapacidad actualizada correctamente',
        error: false,
      );
    }
  }

  void _deleteDiscapacidad(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Discapacidad'),
        content: const Text('¿Estás seguro de eliminar esta discapacidad?'),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.pop(context, false),
          ),
          TextButton(
            child: const Text(
              'Eliminar',
              style: TextStyle(color: AppColors.error),
            ),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );
    if (confirm == true) {
      try {
        await _service.eliminarDiscapacidad(id);
        await _fetchDiscapacidades();
        _showSnackBar('Discapacidad eliminada correctamente', error: false);
      } on ApiException catch (e) {
        _showSnackBar('Error: ${e.message}', error: true);
      } catch (e) {
        _showSnackBar('Error inesperado al eliminar discapacidad.', error: true);
      }
    }
  }

  // Cambia _showErrorSnackBar a _showSnackBar para mensajes de éxito y error
  void _showSnackBar(String message, {bool error = false}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? Colors.red : Colors.green,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool esEscritorio = MediaQuery.of(context).size.width > 700;
    final double cardWidth = esEscritorio ? 600 : 400;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'DISCAPACIDADES',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        actionsIconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refrescar',
            onPressed: _fetchDiscapacidades,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(),
        tooltip: 'Agregar Discapacidad',
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
              builder: (context, constraints) {
                return Column(
                  children: [
                    const SizedBox(height: 24),
                    Center(
                      child: SizedBox(
                        width: cardWidth,
                        child: SearchBarWidget(
                          controller: _searchController,
                          hintText: 'Buscar por discapacidad...',
                          onChanged: (_) => _filterDiscapacidades(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Expanded(
                      child: _filteredDiscapacidades.isEmpty
                          ? const Center(
                              child: Text('No se encontraron discapacidades.'),
                            )
                          : ListView.separated(
                              itemCount: _filteredDiscapacidades.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 16),
                              padding: const EdgeInsets.all(16),
                              itemBuilder: (context, index) {
                                final discapacidad = _filteredDiscapacidades[index];
                                return Center(
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                      maxWidth: cardWidth,
                                    ),
                                    child: Card(
                                      elevation: 6,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 16,
                                          horizontal: 20,
                                        ),
                                        child: ListTile(
                                          leading: const Icon(
                                            Icons.accessible,
                                            size: 36,
                                            color: AppColors.primary,
                                          ),
                                          title: Text(discapacidad.nombre),
                                          trailing: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.edit,
                                                  color: AppColors.primary,
                                                ),
                                                onPressed: () =>
                                                    _showForm(discapacidad: discapacidad),
                                              ),
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.delete,
                                                  color: AppColors.error,
                                                ),
                                                onPressed: () => _deleteDiscapacidad(
                                                  discapacidad.idDiscapacidad,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}

// Dialogo para crear/editar discapacidad
class DiscapacidadFormDialog extends StatefulWidget {
  final Discapacidad? discapacidadToEdit;

  const DiscapacidadFormDialog({super.key, this.discapacidadToEdit});

  @override
  State<DiscapacidadFormDialog> createState() => _DiscapacidadFormDialogState();
}

class _DiscapacidadFormDialogState extends State<DiscapacidadFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreController = TextEditingController();
  bool _isSaving = false;
  Map<String, List<String>>? _validationErrors;

  @override
  void initState() {
    super.initState();
    if (widget.discapacidadToEdit != null) {
      _nombreController.text = widget.discapacidadToEdit!.nombre;
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    super.dispose();
  }

  String? _fieldError(String field) {
    if (_validationErrors != null && _validationErrors![field] != null) {
      return _validationErrors![field]!.join('\n');
    }
    return null;
  }

  void _showSnackBar(String message, {bool error = false}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? Colors.red : Colors.green,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  Future<void> _save() async {
    setState(() {
      _validationErrors = null;
    });
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isSaving = true;
    });

    final service = DiscapacidadesService();
    try {
      if (widget.discapacidadToEdit == null) {
        await service.crearDiscapacidad(_nombreController.text.trim());
      } else {
        await service.editarDiscapacidad(
          widget.discapacidadToEdit!.idDiscapacidad,
          _nombreController.text.trim(),
        );
      }
      if (mounted) Navigator.pop(context, true);
    } on ValidationException catch (e) {
      setState(() {
        _validationErrors = e.errors;
      });
      if (e.errors['general'] != null) {
        _showSnackBar(e.errors['general']!.join(', '), error: true);
      }
      _formKey.currentState!.validate();
    } on ApiException catch (e) {
      _showSnackBar('Error: ${e.message}', error: true);
    } catch (e) {
      _showSnackBar('Error inesperado al guardar discapacidad.', error: true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool esEscritorio = MediaQuery.of(context).size.width > 700;
    final double formWidth = esEscritorio ? 400 : double.infinity;

    return AlertDialog(
      title: Text(widget.discapacidadToEdit == null ? 'Nueva Discapacidad' : 'Editar Discapacidad'),
      content: SizedBox(
        width: formWidth,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: InputDecoration(
                  labelText: 'Nombre de la Discapacidad',
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 12,
                  ),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Campo requerido';
                  final err = _fieldError('discapacidad');
                  return err;
                },
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
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(widget.discapacidadToEdit == null ? 'Agregar' : 'Guardar'),
        ),
      ],
    );
  }
}