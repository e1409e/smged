import 'package:flutter/material.dart';
import 'package:smged/api/models/facultad.dart';
import 'package:smged/api/services/facultades_service.dart';
import 'package:smged/layout/widgets/custom_colors.dart';
import 'package:smged/api/exceptions/api_exception.dart';

class FacultadesScreen extends StatefulWidget {
  const FacultadesScreen({super.key});

  @override
  State<FacultadesScreen> createState() => _FacultadesScreenState();
}

class _FacultadesScreenState extends State<FacultadesScreen> {
  final FacultadesService _service = FacultadesService();
  List<Facultad> _facultades = [];
  List<Facultad> _filteredFacultades = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchFacultades();
    _searchController.addListener(_filterFacultades);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterFacultades);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchFacultades() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final data = await _service.obtenerFacultades();
      setState(() {
        _facultades = data;
        _filteredFacultades = data;
      });
    } on NetworkException catch (e) {
      _showErrorSnackBar('Problema de conexión: ${e.message}');
    } on ApiException catch (e) {
      _showErrorSnackBar('Error: ${e.message}');
    } catch (e) {
      _showErrorSnackBar('Error inesperado al cargar facultades.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterFacultades() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredFacultades = List.from(_facultades);
      } else {
        _filteredFacultades = _facultades.where((facultad) {
          return facultad.facultad.toLowerCase().contains(query) ||
              facultad.siglas.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  void _showForm({Facultad? facultad}) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => FacultadFormDialog(facultad: facultad),
    );
    if (result == true) {
      _fetchFacultades();
    }
  }

  void _deleteFacultad(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Facultad'),
        content: const Text('¿Estás seguro de eliminar esta facultad?'),
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
        await _service.eliminarFacultad(id);
        _fetchFacultades();
      } on ApiException catch (e) {
        _showErrorSnackBar('Error: ${e.message}');
      } catch (e) {
        _showErrorSnackBar('Error inesperado al eliminar facultad.');
      }
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

  @override
  Widget build(BuildContext context) {
    final bool esEscritorio = MediaQuery.of(context).size.width > 700;
    final double cardWidth = esEscritorio ? 600 : 400;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'FACULTADES',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        actionsIconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refrescar',
            onPressed: _fetchFacultades,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(),
        tooltip: 'Agregar Facultad',
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
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Buscar por nombre o siglas...',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 12.0,
                              horizontal: 16.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Expanded(
                      child: _filteredFacultades.isEmpty
                          ? const Center(
                              child: Text('No se encontraron facultades.'),
                            )
                          : ListView.separated(
                              itemCount: _filteredFacultades.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 16),
                              padding: const EdgeInsets.all(16),
                              itemBuilder: (context, index) {
                                final facultad = _filteredFacultades[index];
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
                                            Icons.account_balance,
                                            size: 36,
                                            color: AppColors.primary,
                                          ),
                                          title: Text(facultad.facultad),
                                          subtitle: Text(
                                            'Siglas: ${facultad.siglas}',
                                          ),
                                          trailing: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.edit,
                                                  color: AppColors.primary,
                                                ),
                                                onPressed: () => _showForm(
                                                  facultad: facultad,
                                                ),
                                              ),
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.delete,
                                                  color: AppColors.error,
                                                ),
                                                onPressed: () => _deleteFacultad(
                                                  facultad.idFacultad,
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

class FacultadFormDialog extends StatefulWidget {
  final Facultad? facultad;
  const FacultadFormDialog({super.key, this.facultad});

  @override
  State<FacultadFormDialog> createState() => _FacultadFormDialogState();
}

class _FacultadFormDialogState extends State<FacultadFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _facultadController;
  late TextEditingController _siglasController;
  bool _isSaving = false;
  Map<String, List<String>>? _validationErrors;

  @override
  void initState() {
    super.initState();
    _facultadController = TextEditingController(
      text: widget.facultad?.facultad ?? '',
    );
    _siglasController = TextEditingController(
      text: widget.facultad?.siglas ?? '',
    );
  }

  @override
  void dispose() {
    _facultadController.dispose();
    _siglasController.dispose();
    super.dispose();
  }

  void _save() async {
    setState(() {
      _validationErrors = null;
    });
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final service = FacultadesService();
    try {
      if (widget.facultad == null) {
        await service.crearFacultad(
          _facultadController.text,
          _siglasController.text,
        );
      } else {
        await service.actualizarFacultad(
          widget.facultad!.idFacultad,
          _facultadController.text,
          _siglasController.text,
        );
      }
      Navigator.pop(context, true);
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
      _showErrorSnackBar('Error inesperado al guardar facultad.');
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
    return AlertDialog(
      title: Text(
        widget.facultad == null ? 'Nueva Facultad' : 'Editar Facultad',
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _facultadController,
              decoration: const InputDecoration(
                labelText: 'Nombre de la Facultad',
                border: OutlineInputBorder(),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Campo requerido';
                final err = _fieldError('facultad');
                return err;
              },
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _siglasController,
              decoration: const InputDecoration(
                labelText: 'Siglas',
                border: OutlineInputBorder(),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Campo requerido';
                final err = _fieldError('siglas');
                return err;
              },
            ),
          ],
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
