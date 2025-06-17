import 'package:flutter/material.dart';
import 'package:smged/api/models/carrera.dart';
import 'package:smged/api/services/carreras_service.dart';
import 'package:smged/layout/widgets/custom_colors.dart';
import 'forms/carrera_form_screen.dart';

class CarrerasScreen extends StatefulWidget {
  const CarrerasScreen({super.key});

  @override
  State<CarrerasScreen> createState() => _CarrerasScreenState();
}

class _CarrerasScreenState extends State<CarrerasScreen> {
  final CarrerasService _service = CarrerasService();
  List<Carrera> _carreras = [];
  List<Carrera> _filteredCarreras = [];
  bool _isLoading = true;
  String? _error;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchCarreras();
    _searchController.addListener(_filterCarreras);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterCarreras);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchCarreras() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data = await _service.obtenerCarreras();
      setState(() {
        _carreras = data;
        _filteredCarreras = data;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterCarreras() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredCarreras = List.from(_carreras);
      } else {
        _filteredCarreras = _carreras.where((carrera) {
          return carrera.carrera.toLowerCase().contains(query) ||
              carrera.nombreFacultad.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  void _showForm({Carrera? carrera}) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => CarreraFormDialog(carreraToEdit: carrera),
    );
    if (result == true) {
      _fetchCarreras();
    }
  }

  void _deleteCarrera(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Carrera'),
        content: const Text('¿Estás seguro de eliminar esta carrera?'),
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
      await _service.eliminarCarrera(id);
      _fetchCarreras();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool esEscritorio = MediaQuery.of(context).size.width > 700;
    final double cardWidth = esEscritorio ? 600 : 400;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'CARRERAS',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        actionsIconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refrescar',
            onPressed: _fetchCarreras,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(),
        tooltip: 'Agregar Carrera',
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text(_error!))
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
                            hintText: 'Buscar por carrera o facultad...',
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
                      child: _filteredCarreras.isEmpty
                          ? const Center(
                              child: Text('No se encontraron carreras.'),
                            )
                          : ListView.separated(
                              itemCount: _filteredCarreras.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 16),
                              padding: const EdgeInsets.all(16),
                              itemBuilder: (context, index) {
                                final carrera = _filteredCarreras[index];
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
                                            Icons.school,
                                            size: 36,
                                            color: AppColors.primary,
                                          ),
                                          title: Text(carrera.carrera),
                                          subtitle: Text(
                                            'Facultad: ${carrera.nombreFacultad}',
                                          ),
                                          trailing: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.edit,
                                                  color: AppColors.primary,
                                                ),
                                                onPressed: () =>
                                                    _showForm(carrera: carrera),
                                              ),
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.delete,
                                                  color: AppColors.error,
                                                ),
                                                onPressed: () => _deleteCarrera(
                                                  carrera.idCarrera,
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
