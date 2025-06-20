import 'package:flutter/material.dart';
import 'package:smged/api/models/incidencia.dart';
import 'package:smged/api/services/incidencias_service.dart';
import 'package:smged/layout/widgets/custom_colors.dart';

class IncidenciasScreen extends StatefulWidget {
  const IncidenciasScreen({super.key});

  @override
  State<IncidenciasScreen> createState() => _IncidenciasScreenState();
}

class _IncidenciasScreenState extends State<IncidenciasScreen> {
  final IncidenciasService _service = IncidenciasService();
  List<Incidencia> _incidencias = [];
  List<Incidencia> _filteredIncidencias = [];
  bool _isLoading = true;
  String? _error;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchIncidencias();
    _searchController.addListener(_filterIncidencias);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterIncidencias);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchIncidencias() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data = await _service.obtenerIncidencias();
      setState(() {
        _incidencias = data;
        _filteredIncidencias = data;
      });
    } catch (e) {
      setState(() {
        _error = 'Error al cargar incidencias: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterIncidencias() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredIncidencias = List.from(_incidencias);
      } else {
        _filteredIncidencias = _incidencias.where((inc) {
          final estudiante = '${inc.nombreEstudiante ?? ''} ${inc.apellidoEstudiante ?? ''}'.toLowerCase();
          final cedula = (inc.cedulaEstudiante ?? '').toLowerCase();
          final descripcion = inc.descripcionIncidente.toLowerCase();
          return estudiante.contains(query) ||
              cedula.contains(query) ||
              descripcion.contains(query);
        }).toList();
      }
    });
  }

  Future<void> _eliminarIncidencia(int idIncidencia) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar incidencia'),
        content: const Text('¿Estás seguro de eliminar esta incidencia?'),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.pop(context, false),
          ),
          TextButton(
            child: const Text('Eliminar', style: TextStyle(color: AppColors.error)),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );
    if (confirm == true) {
      try {
        await _service.eliminarIncidencia(idIncidencia);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Incidencia eliminada exitosamente')),
          );
          _fetchIncidencias();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al eliminar: $e')),
          );
        }
      }
    }
  }

  Widget _buildIncidenciaCard(Incidencia incidencia, double cardWidth) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: cardWidth),
        child: Card(
          elevation: 4,
          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Estudiante: ${incidencia.nombreEstudiante ?? ''} ${incidencia.apellidoEstudiante ?? ''} (${incidencia.cedulaEstudiante ?? ''})',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 6),
                Text('Fecha: ${incidencia.fechaIncidente.split('T').first}  Hora: ${incidencia.horaIncidente}'),
                const SizedBox(height: 6),
                Text('Lugar: ${incidencia.lugarIncidente}'),
                const SizedBox(height: 6),
                Text('Descripción: ${incidencia.descripcionIncidente}'),
                const SizedBox(height: 6),
                Text('Acuerdos: ${incidencia.acuerdos}'),
                const SizedBox(height: 6),
                Text('Observaciones: ${incidencia.observaciones}'),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center, // <-- Cambia a center
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.edit),
                      label: const Text('Editar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        // TODO: Navegar al formulario de edición de incidencia
                      },
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.delete),
                      label: const Text('Eliminar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => _eliminarIncidencia(incidencia.idIncidencia!),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
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
          'INCIDENCIAS',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        actionsIconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refrescar',
            onPressed: _fetchIncidencias,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // TODO: Navegar al formulario de agregar incidencia
            },
            tooltip: 'Añadir nueva incidencia',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      _error!,
                      style: const TextStyle(color: AppColors.error, fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: cardWidth),
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Buscar por estudiante, cédula o descripción...',
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
                        child: _filteredIncidencias.isEmpty
                            ? const Center(
                                child: Text('No se encontraron incidencias.'),
                              )
                            : ListView.separated(
                                itemCount: _filteredIncidencias.length,
                                separatorBuilder: (_, __) => const SizedBox(height: 16),
                                itemBuilder: (context, index) {
                                  final incidencia = _filteredIncidencias[index];
                                  return _buildIncidenciaCard(incidencia, cardWidth);
                                },
                              ),
                      ),
                    ],
                  ),
                ),
    );
  }
}