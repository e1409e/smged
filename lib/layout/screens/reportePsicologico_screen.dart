import 'package:flutter/material.dart';
import 'package:smged/api/models/reporte_psicologico.dart';
import 'package:smged/api/services/reporte_psicologico_service.dart';
import 'package:smged/layout/widgets/custom_colors.dart';

class ReportePsicologicoScreen extends StatefulWidget {
  const ReportePsicologicoScreen({super.key});

  @override
  State<ReportePsicologicoScreen> createState() => _ReportePsicologicoScreenState();
}

class _ReportePsicologicoScreenState extends State<ReportePsicologicoScreen> {
  final ReportePsicologicoService _service = ReportePsicologicoService();
  List<ReportePsicologico> _reportes = [];
  List<ReportePsicologico> _filteredReportes = [];
  bool _isLoading = true;
  String? _error;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchReportes();
    _searchController.addListener(_filterReportes);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterReportes);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchReportes() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data = await _service.obtenerReportesPsicologicos();
      setState(() {
        _reportes = data;
        _filteredReportes = data;
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

  void _filterReportes() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredReportes = List.from(_reportes);
      } else {
        _filteredReportes = _reportes.where((reporte) {
          final nombre = (reporte.nombreEstudiante ?? '').toLowerCase();
          final apellido = (reporte.apellidoEstudiante ?? '').toLowerCase();
          final motivo = reporte.motivoConsulta.toLowerCase();
          return nombre.contains(query) ||
              apellido.contains(query) ||
              motivo.contains(query);
        }).toList();
      }
    });
  }

  void _showForm({ReportePsicologico? reporte}) async {
    // Aquí puedes implementar el formulario de creación/edición si lo necesitas
    // Por ahora solo refresca la lista
    _fetchReportes();
  }

  void _deleteReporte(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Reporte Psicológico'),
        content: const Text('¿Estás seguro de eliminar este reporte?'),
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
      await _service.eliminarReportePsicologico(id);
      _fetchReportes();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool esEscritorio = MediaQuery.of(context).size.width > 700;
    final double cardWidth = esEscritorio ? 700 : 400;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'REPORTES PSICOLÓGICOS',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        actionsIconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refrescar',
            onPressed: _fetchReportes,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(),
        tooltip: 'Agregar Reporte',
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
                                hintText: 'Buscar por estudiante o motivo...',
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
                          child: _filteredReportes.isEmpty
                              ? const Center(
                                  child: Text('No se encontraron reportes psicológicos.'),
                                )
                              : ListView.separated(
                                  itemCount: _filteredReportes.length,
                                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                                  padding: const EdgeInsets.all(16),
                                  itemBuilder: (context, index) {
                                    final reporte = _filteredReportes[index];
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
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    const Icon(
                                                      Icons.psychology,
                                                      size: 36,
                                                      color: AppColors.primary,
                                                    ),
                                                    const SizedBox(width: 12),
                                                    Expanded(
                                                      child: Text(
                                                        '${reporte.nombreEstudiante ?? ''} ${reporte.apellidoEstudiante ?? ''} (${reporte.cedulaEstudiante ?? ''})',
                                                        style: const TextStyle(
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 16,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 8),
                                                _buildInfoRow(
                                                  'Motivo de Consulta:',
                                                  reporte.motivoConsulta,
                                                ),
                                                _buildInfoRow(
                                                  'Síntesis Diagnóstica:',
                                                  reporte.sintesisDiagnostica,
                                                ),
                                                _buildInfoRow(
                                                  'Recomendaciones:',
                                                  reporte.recomendaciones,
                                                ),
                                                const SizedBox(height: 8),
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.end,
                                                  children: [
                                                    IconButton(
                                                      icon: const Icon(Icons.edit, color: AppColors.primary),
                                                      onPressed: () => _showForm(reporte: reporte),
                                                    ),
                                                    IconButton(
                                                      icon: const Icon(Icons.delete, color: AppColors.error),
                                                      onPressed: () => _deleteReporte(reporte.idPsicologico!),
                                                    ),
                                                  ],
                                                ),
                                              ],
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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              value,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}