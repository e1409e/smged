// lib/layout/screens/historial_medico_screen.dart
import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/foundation.dart'; // Necesario para defaultTargetPlatform
import 'package:collection/collection.dart'; // Importa para firstWhereOrNull

import 'package:smged/api/models/historial_medico.dart';
import 'package:smged/api/services/historial_medico_service.dart';
import 'package:smged/layout/widgets/custom_data_table.dart';
import 'package:smged/layout/widgets/custom_colors.dart';
import 'package:smged/layout/widgets/search_bar_widget.dart';
import 'package:smged/layout/screens/forms/historial_medico_form_screen.dart';
import 'package:smged/layout/utils/historialMedico_utils.dart';

class HistorialMedicoScreen extends StatefulWidget {
  const HistorialMedicoScreen({super.key});

  @override
  State<HistorialMedicoScreen> createState() => _HistorialMedicoScreenState();
}

class _HistorialMedicoScreenState extends State<HistorialMedicoScreen> {
  final HistorialMedicoService _historialMedicoService = HistorialMedicoService(); // Instancia del servicio de historial médico
  List<HistorialMedico> _historiales = [];
  List<HistorialMedico> _filteredHistoriales = [];
  bool _isLoading = true;
  String? _errorMessage;

  int? _sortColumnIndex;
  bool _sortAscending = true;

  final TextEditingController _searchController = TextEditingController();

  bool _isActionMode = false; // Variable de estado para controlar la modalidad

  @override
  void initState() {
    super.initState();
    _fetchHistorialesMedicos();
    _searchController.addListener(_filterHistoriales);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterHistoriales);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchHistorialesMedicos() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final fetchedHistoriales = await _historialMedicoService.obtenerTodosLosHistorialesMedicos(); // Usamos el método del servicio
      if (!mounted) return;
      setState(() {
        _historiales = fetchedHistoriales;
        _filteredHistoriales = fetchedHistoriales;
        _sortColumnIndex = null; // Reiniciar ordenación
        _sortAscending = true;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Error al cargar historiales médicos: ${e.toString().replaceFirst('Exception: ', '')}';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _onSort(int columnIndex, bool ascending) {
    // Definimos las claves de las columnas que se pueden ordenar
    final List<String> sortableColumnKeys = [
      'ID', // idHistorialMedico
      'ID Estudiante', // idEstudiante
      'Certificado CONAPDIS', // certificadoConapdis
      'Informe Médico', // informeMedico
      'Tratamiento', // tratamiento
      'Fecha Creación', // fechaCreacion
    ];

    if (columnIndex < 0 || columnIndex >= sortableColumnKeys.length) {
      return;
    }

    final String sortKey = sortableColumnKeys[columnIndex];

    _historiales.sort((a, b) {
      Comparable valueA;
      Comparable valueB;

      switch (sortKey) {
        case 'ID':
          valueA = a.idHistorialMedico;
          valueB = b.idHistorialMedico;
          break;
        case 'ID Estudiante':
          valueA = a.idEstudiante;
          valueB = b.idEstudiante;
          break;
        case 'Certificado CONAPDIS':
          valueA = a.certificadoConapdis;
          valueB = b.certificadoConapdis;
          break;
        case 'Informe Médico':
          valueA = a.informeMedico;
          valueB = b.informeMedico;
          break;
        case 'Tratamiento':
          valueA = a.tratamiento;
          valueB = b.tratamiento;
          break;
        case 'Fecha Creación':
          valueA = a.fechaCreacion;
          valueB = b.fechaCreacion;
          break;
        default:
          return 0; // No se puede ordenar por esta columna
      }

      return ascending ? valueA.compareTo(valueB) : valueB.compareTo(valueA);
    });

    _filterHistoriales(); // Re-aplicar filtro después de ordenar

    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
  }

  void _filterHistoriales() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredHistoriales = List.from(_historiales);
      } else {
        _filteredHistoriales = _historiales.where((historial) {
          final idHistorial = historial.idHistorialMedico.toString().toLowerCase();
          final idEstudiante = historial.idEstudiante.toString().toLowerCase();
          final informeMedico = historial.informeMedico.toLowerCase();
          final tratamiento = historial.tratamiento.toLowerCase();
          final fechaCreacion = historial.fechaCreacion
              .toLocal()
              .toString()
              .split(' ')[0]
              .toLowerCase();

          return idHistorial.contains(query) ||
              idEstudiante.contains(query) ||
              informeMedico.contains(query) ||
              tratamiento.contains(query) ||
              fechaCreacion.contains(query);
        }).toList();
      }
    });
  }

  void _handleInfoHistorial(TableData item) {
    HistorialMedicoUtils.showHistorialMedicoInfoModal(context, item as HistorialMedico);
  }

  void _handleEditHistorial(TableData item) async {
    final historial = item as HistorialMedico;
    debugPrint('Editar historial médico: ID ${historial.idHistorialMedico}');

    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => HistorialMedicoFormScreen(historialToEdit: historial), // Pasa el historial a editar
      ),
    );

    if (!mounted) return;
    if (result == true) {
      // Si el formulario indicó un cambio exitoso
      _fetchHistorialesMedicos(); // Recargar historiales
    }
  }

  void _handleDeleteHistorial(TableData item) {
    final historial = item as HistorialMedico;
    debugPrint('Eliminar historial médico: ID ${historial.idHistorialMedico}');

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirmar Eliminación'),
          content: Text(
            '¿Estás seguro de que quieres eliminar el historial médico con ID ${historial.idHistorialMedico} del estudiante ID ${historial.idEstudiante}?',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: AppColors.error),
              child: const Text('Eliminar'),
              onPressed: () async {
                Navigator.of(dialogContext).pop(); // Cierra el diálogo

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Eliminando historial médico...'),
                    duration: Duration(seconds: 1),
                  ),
                );

                try {
                  await _historialMedicoService.eliminarHistorialMedico(historial.idHistorialMedico);
                  debugPrint('Historial médico eliminado con éxito');

                  if (!mounted) {
                    debugPrint('[_HistorialMedicoScreenState] Widget desmontado. No se puede actualizar UI después de eliminar.');
                    return;
                  }

                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Historial médico con ID ${historial.idHistorialMedico} eliminado exitosamente.',
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                  _fetchHistorialesMedicos(); // Vuelve a cargar la lista
                } catch (e) {
                  if (!mounted) {
                    debugPrint('[_HistorialMedicoScreenState] Widget desmontado. No se puede actualizar UI después de error al eliminar.');
                    return;
                  }

                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  setState(() {
                    _errorMessage = 'Error al eliminar historial médico: ${e.toString().replaceFirst('Exception: ', '')}';
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Error al eliminar historial médico: ${e.toString().replaceFirst('Exception: ', '')}',
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                } finally {
                  if (mounted) {
                    setState(() {
                      _isLoading = false;
                    });
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  // Nueva función para alternar el modo de acción
  void _toggleActionMode() {
    setState(() {
      _isActionMode = !_isActionMode;
    });
  }

  // Construye la interfaz de la tabla de historiales médicos
  @override
  Widget build(BuildContext context) {
    List<DataColumn2> historialMedicoColumns;
    DataColumn2 actionColumn;

    // Definir la columna de acciones basada en _isActionMode
    if (_isActionMode) {
      actionColumn = DataColumn2(
        label: Center(
          child: Text('Acciones'),
        ),
        fixedWidth: defaultTargetPlatform == TargetPlatform.android ||
                defaultTargetPlatform == TargetPlatform.iOS
            ? 190
            : 190, // Ajusta el ancho para los botones de acción
      );
    } else {
      actionColumn = DataColumn2(
        label: Center(
          child: Text('Info'),
        ),
        fixedWidth: defaultTargetPlatform == TargetPlatform.android ||
                defaultTargetPlatform == TargetPlatform.iOS
            ? 190
            : 190,
      );
    }

    // Columnas para la tabla de historiales médicos
    if (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS) {
      historialMedicoColumns = [
        DataColumn2(
          label: const Text('ID Estudiante'),
          fixedWidth: 140, // Ajuste para móvil
          onSort: (columnIndex, ascending) => _onSort(columnIndex, ascending),
        ),
        actionColumn, // Columna de acción dinámica
      ];
    } else {
      historialMedicoColumns = [
        DataColumn2(
          label: const Text('ID'),
          fixedWidth: 80,
          onSort: (columnIndex, ascending) => _onSort(columnIndex, ascending),
        ),
        DataColumn2(
          label: const Text('ID Estudiante'),
          fixedWidth: 140,
          onSort: (columnIndex, ascending) => _onSort(columnIndex, ascending),
        ),
        DataColumn2(
          label: const Text('Certificado CONAPDIS'),
          fixedWidth: 180,
          onSort: (columnIndex, ascending) => _onSort(columnIndex, ascending),
        ),
        DataColumn2(
          label: const Text('Informe Médico'),
          size: ColumnSize.L, // Puede ser más grande para el informe
          onSort: (columnIndex, ascending) => _onSort(columnIndex, ascending),
        ),
        DataColumn2(
          label: const Text('Tratamiento'),
          size: ColumnSize.L, // Puede ser más grande para el tratamiento
          onSort: (columnIndex, ascending) => _onSort(columnIndex, ascending),
        ),
        DataColumn2(
          label: const Text('Fecha Creación'),
          fixedWidth: 150,
          onSort: (columnIndex, ascending) => _onSort(columnIndex, ascending),
        ),
        actionColumn, // Columna de acción dinámica
      ];
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('HISTORIALES MÉDICOS', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textTitle,
        actions: [
          IconButton(
            icon: Icon(_isActionMode ? Icons.info_outline : Icons.build), // Icono dinámico
            onPressed: _toggleActionMode, // Llama a la función para alternar
            tooltip: _isActionMode ? 'Ver información' : 'Activar acciones', // Tooltip dinámico
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchHistorialesMedicos,
            tooltip: 'Recargar historiales médicos',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const HistorialMedicoFormScreen(), // Abrir formulario de historial
                ),
              );
              if (!mounted) return;
              if (result == true) {
                _fetchHistorialesMedicos(); // Recargar historiales si se añadió uno nuevo
              }
            },
            tooltip: 'Añadir nuevo historial médico',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      _errorMessage!,
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
                      SearchBarWidget(
                        controller: _searchController,
                        hintText: 'Buscar historial por ID, ID de estudiante, informe o tratamiento...',
                        onChanged: (query) => _filterHistoriales(),
                      ),
                      const SizedBox(height: 15.0),
                      Expanded(
                        child: Card(
                          elevation: 8.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                  bottom: 8.0,
                                  top: 8.0,
                                  left: 12.0,
                                  right: 12.0,
                                ),
                                child: Text(
                                  'LISTA DE HISTORIALES MÉDICOS',
                                  textAlign: TextAlign.left,
                                  style: Theme.of(context).textTheme.headlineSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                ),
                              ),
                              const Divider(),
                              _filteredHistoriales.isEmpty
                                  ? const Expanded(
                                      child: Center(
                                        child: Text(
                                          'No hay historiales médicos registrados o no se encontraron resultados.',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    )
                                  : Expanded(
                                      child: CustomDataTable<HistorialMedico>(
                                        data: _filteredHistoriales,
                                        columns: historialMedicoColumns,
                                        minWidth: 900, // Ajustar minWidth según las columnas
                                        actionCallbacks: _isActionMode
                                            ? {
                                                'edit': _handleEditHistorial,
                                                'delete': _handleDeleteHistorial,
                                              }
                                            : {
                                                'info': _handleInfoHistorial,
                                              },
                                        sortColumnIndex: _sortColumnIndex,
                                        sortAscending: _sortAscending,
                                      ),
                                    ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}