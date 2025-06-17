import 'package:flutter/material.dart';
import 'package:smged/api/models/estudiante.dart';
import 'package:smged/api/models/cita.dart';
import 'package:smged/api/services/citas_service.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';
import 'package:smged/layout/widgets/custom_colors.dart';

class ListaEstudiantesDocentes extends StatefulWidget {
  final List<Estudiante> estudiantes;
  final String terminoBusqueda;

  const ListaEstudiantesDocentes({
    super.key,
    required this.estudiantes,
    required this.terminoBusqueda,
  });

  @override
  State<ListaEstudiantesDocentes> createState() => _ListaEstudiantesDocentesState();
}

class _ListaEstudiantesDocentesState extends State<ListaEstudiantesDocentes> {
  final Map<int, String> _citasPorEstudiante = {};
  bool _loadingCitas = false;

  @override
  void initState() {
    super.initState();
    _fetchCitas();
  }

  Future<void> _fetchCitas() async {
    setState(() => _loadingCitas = true);
    try {
      final citas = await CitasService().obtenerCitas();
      for (final estudiante in widget.estudiantes) {
        final cita = citas.firstWhereOrNull(
          (c) => c.id_estudiante == estudiante.idEstudiante,
        );
        // Si hay cita y está pendiente, mostrar la fecha; si no, mostrar 'ninguna'
        if (cita != null && cita.pendiente == 1) {
          final fecha = DateFormat('dd/MM/yyyy').format(cita.fecha_cita);
          _citasPorEstudiante[estudiante.idEstudiante ?? -1] = fecha;
        } else {
          _citasPorEstudiante[estudiante.idEstudiante ?? -1] = 'ninguna';
        }
      }
    } catch (_) {
      for (final estudiante in widget.estudiantes) {
        _citasPorEstudiante[estudiante.idEstudiante ?? -1] = 'ninguna';
      }
    } finally {
      if (mounted) setState(() => _loadingCitas = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final resultados = widget.estudiantes.where((e) {
      final query = widget.terminoBusqueda.toLowerCase();
      return e.nombres.toLowerCase().contains(query) ||
          e.apellidos.toLowerCase().contains(query) ||
          e.cedula.toLowerCase().contains(query);
    }).toList();

    final bool esEscritorio = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Estudiantes Encontrados',
          style: TextStyle(
            color: Colors.white,
            fontSize: esEscritorio ? 24 : 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: AppColors.primary, 
        actionsIconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _loadingCitas
          ? const Center(child: CircularProgressIndicator())
          : resultados.isEmpty
              ? const Center(child: Text('No se encontraron estudiantes.'))
              : ListView.separated(
                  itemCount: resultados.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  padding: const EdgeInsets.all(16),
                  itemBuilder: (context, index) {
                    final estudiante = resultados[index];
                    final citaTexto = _citasPorEstudiante[estudiante.idEstudiante ?? -1] ?? 'ninguna';
                    return Card(
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                        child: ListTile(
                          leading: const Icon(Icons.person, size: 36, color: Colors.blueAccent),
                          title: Text('${estudiante.nombres} ${estudiante.apellidos}'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Cédula: ${estudiante.cedula}'),
                              if (esEscritorio)
                                Text('Teléfono: ${estudiante.telefono ?? "N/A"}'),
                              Text('Cita: $citaTexto'),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

void navegarAListaEstudiantesDocentes(BuildContext context, List<Estudiante> listaDeEstudiantes, String textoBuscado) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => ListaEstudiantesDocentes(
        estudiantes: listaDeEstudiantes,
        terminoBusqueda: textoBuscado,
      ),
    ),
  );
}