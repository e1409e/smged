import 'package:flutter/material.dart';
import 'package:smged/api/services/historial_medico_service.dart';
import 'package:smged/api/models/historial_medico.dart';
import 'package:smged/layout/widgets/custom_colors.dart';
import 'package:smged/routes.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:smged/api/models/incidencia.dart';
import 'package:smged/api/services/incidencias_service.dart';
import 'package:smged/api/models/reporte_psicologico.dart';
import 'package:smged/api/services/reporte_psicologico_service.dart';
import 'package:smged/layout/reports/reporte_psicologico_report.dart';

class HistorialMedicoScreen extends StatefulWidget {
  const HistorialMedicoScreen({super.key});

  @override
  State<HistorialMedicoScreen> createState() => _HistorialMedicoScreenState();
}

class _HistorialMedicoScreenState extends State<HistorialMedicoScreen> {
  final HistorialMedicoService _service = HistorialMedicoService();
  final IncidenciasService _incidenciasService = IncidenciasService();
  final ReportePsicologicoService _reportePsicologicoService = ReportePsicologicoService();

  HistorialMedico? _historial;
  List<Incidencia> _incidencias = [];
  List<ReportePsicologico> _reportesPsicologicos = [];
  bool _isLoading = true;
  bool _isLoadingIncidencias = true;
  bool _isLoadingReportesPsicologicos = true;
  String? _error;
  String? _incidenciasError;
  String? _reportesPsicologicosError;
  int? _idEstudiante;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is int) {
      _idEstudiante = args;
      _fetchHistorialPorEstudiante(args);
      _fetchIncidenciasPorEstudiante(args);
      _fetchReportesPsicologicosPorEstudiante(args);
    } else {
      setState(() {
        _isLoading = false;
        _error = 'No se proporcionó el estudiante';
      });
    }
  }

  Future<void> _fetchHistorialPorEstudiante(int idEstudiante) async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final historial = await _service.obtenerHistorialPorEstudiante(idEstudiante);
      if (!mounted) return;
      setState(() {
        _historial = historial;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchIncidenciasPorEstudiante(int idEstudiante) async {
    setState(() {
      _isLoadingIncidencias = true;
      _incidenciasError = null;
    });
    try {
      final data = await _incidenciasService.obtenerIncidenciasPorEstudiante(idEstudiante);
      if (!mounted) return;
      setState(() {
        _incidencias = data;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _incidenciasError = e.toString();
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoadingIncidencias = false;
      });
    }
  }

  Future<void> _fetchReportesPsicologicosPorEstudiante(int idEstudiante) async {
    setState(() {
      _isLoadingReportesPsicologicos = true;
      _reportesPsicologicosError = null;
    });
    try {
      final data = await _reportePsicologicoService.obtenerReportesPorEstudiante(idEstudiante);
      setState(() {
        _reportesPsicologicos = data;
      });
    } catch (e) {
      setState(() {
        _reportesPsicologicosError = e.toString();
      });
    } finally {
      setState(() {
        _isLoadingReportesPsicologicos = false;
      });
    }
  }

  Future<void> _eliminarHistorial() async {
    if (_historial == null) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar historial médico'),
        content: const Text('¿Estás seguro de eliminar el historial médico? Esta acción no se puede deshacer.'),
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
        await _service.eliminarHistorialMedico(_historial!.idHistorialMedico!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Historial médico eliminado exitosamente')),
          );
          Navigator.of(context).pop(); // Regresa a la pantalla anterior (estudiantes)
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

  Widget _buildArchivoRow(String label, String? ruta) {
    final bool archivoDisponible = ruta != null && ruta.isNotEmpty;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$label ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              archivoDisponible ? ruta! : 'No disponible',
              style: TextStyle(
                color: archivoDisponible ? Colors.black87 : Colors.grey,
                fontStyle: archivoDisponible ? FontStyle.normal : FontStyle.italic,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistorialCard(HistorialMedico historial, double cardWidth) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: cardWidth,
        ),
        child: Card(
          elevation: 4,
          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Estudiante: ${historial.nombreEstudiante ?? ''} ${historial.apellidoEstudiante ?? ''}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  'Cédula: ${historial.cedulaEstudiante ?? ''}',
                  style: const TextStyle(fontSize: 15),
                  textAlign: TextAlign.center,
                ),
                const Divider(height: 20),
                _buildArchivoRow('Certificado CONAPDIS:', historial.certificadoConapdis),
                _buildArchivoRow('Informe Médico:', historial.informeMedico),
                _buildArchivoRow('Tratamiento:', historial.tratamiento),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.edit),
                      label: const Text('Editar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () async {
                        final result = await Navigator.of(context).pushNamed(
                          AppRoutes.historialMedicoForm,
                          arguments: {
                            'idEstudiante': _idEstudiante,
                            'historial': _historial, // Pasa el objeto completo
                          },
                        );
                        if (result == true && _idEstudiante != null) {
                          _fetchHistorialPorEstudiante(_idEstudiante!);
                        }
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
                      onPressed: _eliminarHistorial,
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
                  'Fecha: ${incidencia.fechaIncidente.split('T').first}  Hora: ${incidencia.horaIncidente}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
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
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.edit),
                      label: const Text('Editar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () async {
                        // Navegar al formulario de edición de incidencia
                        final result = await Navigator.of(context).pushNamed(
                          AppRoutes.incidenciasForm,
                          arguments: incidencia, // <-- pasa la incidencia completa
                        );
                        if (result == true && _idEstudiante != null) {
                          _fetchIncidenciasPorEstudiante(_idEstudiante!);
                        }
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
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Eliminar incidencia'),
                            content: const Text('¿Estás seguro de eliminar esta incidencia? Esta acción no se puede deshacer.'),
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
                            await _incidenciasService.eliminarIncidencia(incidencia.idIncidencia!);
                            if (mounted && _idEstudiante != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Incidencia eliminada exitosamente')),
                              );
                              _fetchIncidenciasPorEstudiante(_idEstudiante!);
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error al eliminar: $e')),
                              );
                            }
                          }
                        }
                      },
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

  Widget _buildReportePsicologicoCard(ReportePsicologico reporte, double cardWidth) {
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
                RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 15, color: Colors.black),
                    children: [
                      const TextSpan(
                        text: 'Motivo de Consulta: ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: reporte.motivoConsulta,
                        style: const TextStyle(fontWeight: FontWeight.normal),
                      ),
                    ],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 15, color: Colors.black),
                    children: [
                      const TextSpan(
                        text: 'Síntesis Diagnóstica: ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: reporte.sintesisDiagnostica,
                        style: const TextStyle(fontWeight: FontWeight.normal),
                      ),
                    ],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 15, color: Colors.black),
                    children: [
                      const TextSpan(
                        text: 'Recomendaciones: ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: reporte.recomendaciones,
                        style: const TextStyle(fontWeight: FontWeight.normal),
                      ),
                    ],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 14, color: Colors.black, fontStyle: FontStyle.italic),
                    children: [
                      const TextSpan(
                        text: 'Estudiante: ',
                        style: TextStyle(fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
                      ),
                      TextSpan(
                        text: '${reporte.nombreEstudiante ?? ''} ${reporte.apellidoEstudiante ?? ''}',
                        style: const TextStyle(fontWeight: FontWeight.normal, fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.edit),
                      label: const Text('Editar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () async {
                        final result = await Navigator.of(context).pushNamed(
                          AppRoutes.reportePsicologicoForm,
                          arguments: {'reporteToEdit': reporte, 'idEstudianteFijo': _idEstudiante},
                        );
                        if (result == true && _idEstudiante != null) {
                          _fetchReportesPsicologicosPorEstudiante(_idEstudiante!);
                        }
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
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Eliminar reporte psicológico'),
                            content: const Text('¿Estás seguro de eliminar este reporte psicológico? Esta acción no se puede deshacer.'),
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
                            await _reportePsicologicoService.eliminarReportePsicologico(reporte.idPsicologico!);
                            if (mounted && _idEstudiante != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Reporte psicológico eliminado exitosamente')),
                              );
                              _fetchReportesPsicologicosPorEstudiante(_idEstudiante!);
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error al eliminar: $e')),
                              );
                            }
                          }
                        }
                      },
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.picture_as_pdf),
                      label: const Text('PDF'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        minimumSize: const Size(40, 40),
                      ),
                      onPressed: () async {
                        await ReportePsicologicoReport.generateReportePsicologicoPdf(
                          reporte: reporte,
                          showPreview: true,
                        );
                      },
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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Center(
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionContent(Widget child) {
    return Center(child: child);
  }

  @override
  Widget build(BuildContext context) {
    final bool esEscritorio = MediaQuery.of(context).size.width > 700;
    final double cardWidth = esEscritorio ? 500 : MediaQuery.of(context).size.width * 0.95;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial Médico', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      _error!,
                      style: const TextStyle(color: Colors.red, fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      // --- SECCIÓN HISTORIAL MÉDICO ---
                      _buildSectionTitle('Historial Médico'),
                      _buildSectionContent(
                        _historial == null
                            ? Center(
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(maxWidth: cardWidth),
                                  child: Card(
                                    elevation: 4,
                                    margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                    child: Padding(
                                      padding: const EdgeInsets.all(24.0),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Text(
                                            'No hay historial médico registrado para este estudiante.',
                                            style: TextStyle(fontSize: 16, color: Colors.grey),
                                            textAlign: TextAlign.center,
                                          ),
                                          const SizedBox(height: 18),
                                          ElevatedButton.icon(
                                            icon: const Icon(Icons.add),
                                            label: const Text('Agregar historial médico'),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: AppColors.primary,
                                              foregroundColor: Colors.white,
                                            ),
                                            onPressed: () async {
                                              final result = await Navigator.of(context).pushNamed(
                                                AppRoutes.historialMedicoForm,
                                                arguments: {
                                                  'idEstudiante': _idEstudiante,
                                                },
                                              );
                                              if (result == true && _idEstudiante != null) {
                                                _fetchHistorialPorEstudiante(_idEstudiante!);
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : _buildHistorialCard(_historial!, cardWidth),
                      ),
                      const Divider(thickness: 2, height: 40),
                      _buildSectionTitle('Incidencias'),
                      _buildSectionContent(
                        _isLoadingIncidencias
                            ? const Center(child: CircularProgressIndicator())
                            : _incidenciasError != null
                                ? Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Text(
                                        _incidenciasError!,
                                        style: const TextStyle(color: Colors.red, fontSize: 18),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  )
                                : _incidencias.isEmpty
                                    ? Center(
                                        child: ConstrainedBox(
                                          constraints: BoxConstraints(maxWidth: cardWidth),
                                          child: Card(
                                            elevation: 4,
                                            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                            child: Padding(
                                              padding: const EdgeInsets.all(24.0),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Text(
                                                    'No hay incidencias registradas para este estudiante.',
                                                    style: TextStyle(fontSize: 16, color: Colors.grey),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                  const SizedBox(height: 18),
                                                  ElevatedButton.icon(
                                                    icon: const Icon(Icons.add),
                                                    label: const Text('Agregar incidencia'),
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor: AppColors.primary,
                                                      foregroundColor: Colors.white,
                                                    ),
                                                    onPressed: () async {
                                                      final result = await Navigator.of(context).pushNamed(
                                                        AppRoutes.incidenciasForm,
                                                        arguments: {'idEstudianteFijo': _idEstudiante}, // <-- SIEMPRE PASA EL MAPA
                                                      );
                                                      if (result == true && _idEstudiante != null) {
                                                        _fetchIncidenciasPorEstudiante(_idEstudiante!);
                                                      }
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                    : Column(
                                        children: [
                                          ..._incidencias.map((i) => _buildIncidenciaCard(i, cardWidth)).toList(),
                                          const SizedBox(height: 18),
                                          SizedBox(
                                            width: cardWidth,
                                            child: ElevatedButton.icon(
                                              icon: const Icon(Icons.add),
                                              label: const Text('Agregar incidencia'),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: AppColors.primary,
                                                foregroundColor: Colors.white,
                                              ),
                                              onPressed: () async {
                                                final result = await Navigator.of(context).pushNamed(
                                                  AppRoutes.incidenciasForm,
                                                  arguments: {'idEstudianteFijo': _idEstudiante}, // <-- SIEMPRE PASA EL MAPA
                                                );
                                                if (result == true && _idEstudiante != null) {
                                                  _fetchIncidenciasPorEstudiante(_idEstudiante!);
                                                }
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                      ),
                      const Divider(thickness: 2, height: 40),
                      _buildSectionTitle('Reportes Psicológicos'),
                      _buildSectionContent(
                        _isLoadingReportesPsicologicos
                            ? const Center(child: CircularProgressIndicator())
                            : _reportesPsicologicosError != null
                                ? Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Text(
                                        _reportesPsicologicosError!,
                                        style: const TextStyle(color: Colors.red, fontSize: 18),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  )
                                : _reportesPsicologicos.isEmpty
                                    ? Column(
                                        children: [
                                          Center(
                                            child: ConstrainedBox(
                                              constraints: BoxConstraints(maxWidth: cardWidth),
                                              child: Card(
                                                elevation: 4,
                                                margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                                child: Padding(
                                                  padding: const EdgeInsets.all(24.0),
                                                  child: Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      const Text(
                                                        'No hay reportes psicológicos registrados para este estudiante.',
                                                        style: TextStyle(fontSize: 16, color: Colors.grey),
                                                        textAlign: TextAlign.center,
                                                      ),
                                                      const SizedBox(height: 18),
                                                      SizedBox(
                                                        width: double.infinity,
                                                        child: ElevatedButton.icon(
                                                          icon: const Icon(Icons.add),
                                                          label: const Text('Agregar reporte psicológico'),
                                                          style: ElevatedButton.styleFrom(
                                                            backgroundColor: AppColors.primary,
                                                            foregroundColor: Colors.white,
                                                          ),
                                                          onPressed: () async {
                                                            final result = await Navigator.of(context).pushNamed(
                                                              AppRoutes.reportePsicologicoForm,
                                                              arguments: {'idEstudianteFijo': _idEstudiante},
                                                            );
                                                            if (result == true && _idEstudiante != null) {
                                                              _fetchReportesPsicologicosPorEstudiante(_idEstudiante!);
                                                            }
                                                          },
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    : Column(
                                        children: [
                                          ..._reportesPsicologicos.map((r) => _buildReportePsicologicoCard(r, cardWidth)).toList(),
                                          const SizedBox(height: 18),
                                          SizedBox(
                                            width: cardWidth,
                                            child: ElevatedButton.icon(
                                              icon: const Icon(Icons.add),
                                              label: const Text('Agregar reporte psicológico'),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: AppColors.primary,
                                                foregroundColor: Colors.white,
                                              ),
                                              onPressed: () async {
                                                final result = await Navigator.of(context).pushNamed(
                                                  AppRoutes.reportePsicologicoForm,
                                                  arguments: {'idEstudianteFijo': _idEstudiante},
                                                );
                                                if (result == true && _idEstudiante != null) {
                                                  _fetchReportesPsicologicosPorEstudiante(_idEstudiante!);
                                                }
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
    );
  }
}