// lib/layout/screens/estudiantes_screen.dart
import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/foundation.dart'; // Necesario para defaultTargetPlatform
import 'package:collection/collection.dart'; // Importa para firstWhereOrNull

import 'package:smged/api/models/estudiante.dart';
import 'package:smged/api/services/estudiantes_service.dart';
import 'package:smged/layout/widgets/custom_data_table.dart';
import 'package:smged/layout/widgets/custom_colors.dart';
import 'package:smged/layout/widgets/search_bar_widget.dart';
import 'package:smged/layout/utils/estudiantes_utils.dart';
import 'package:smged/layout/screens/forms/estudiante_form_screen.dart';

class EstudiantesScreen extends StatefulWidget {
  const EstudiantesScreen({super.key});

  @override
  State<EstudiantesScreen> createState() => _EstudiantesScreenState();
}

class _EstudiantesScreenState extends State<EstudiantesScreen> {
  final EstudiantesService _estudiantesService = EstudiantesService();
  List<Estudiante> _estudiantes = [];
  List<Estudiante> _filteredEstudiantes = [];
  bool _isLoading = true;
  String? _errorMessage;

  int? _sortColumnIndex;
  bool _sortAscending = true;

  final TextEditingController _searchController = TextEditingController();

  bool _isActionMode = false;

  @override
  void initState() {
    super.initState();
    _fetchEstudiantes();
    _searchController.addListener(_filterEstudiantes);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterEstudiantes);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchEstudiantes() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final fetchedEstudiantes = await _estudiantesService
          .obtenerTodosLosEstudiantes();
      if (!mounted) return;
      setState(() {
        _estudiantes = fetchedEstudiantes;
        _filteredEstudiantes = fetchedEstudiantes;
        _sortColumnIndex = null;
        _sortAscending = true;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage =
            'Error al cargar estudiantes: ${e.toString().replaceFirst('Exception: ', '')}';
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
    final List<String> sortableColumnKeys = [
      'ID',
      'Nombres',
      'Apellidos',
      'Cédula',
    ];

    if (columnIndex < 0 || columnIndex >= sortableColumnKeys.length) {
      return;
    }

    final String sortKey = sortableColumnKeys[columnIndex];

    _estudiantes.sort((a, b) {
      Comparable valueA;
      Comparable valueB;

      switch (sortKey) {
        case 'ID':
          valueA = a.idEstudiante ?? 0;
          valueB = b.idEstudiante ?? 0;
          break;
        case 'Nombres':
          valueA = a.nombres;
          valueB = b.nombres;
          break;
        case 'Apellidos':
          valueA = a.apellidos;
          valueB = b.apellidos;
          break;
        case 'Cédula':
          valueA = a.cedula;
          valueB = b.cedula;
          break;
        default:
          return 0;
      }

      return ascending ? valueA.compareTo(valueB) : valueB.compareTo(valueA);
    });

    // Filtra nuevamente para aplicar el orden a la lista filtrada
    _filterEstudiantes();

    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
  }

  void _filterEstudiantes() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredEstudiantes = List.from(_estudiantes);
      } else {
        _filteredEstudiantes = _estudiantes.where((estudiante) {
          final nombreCompleto = '${estudiante.nombres} ${estudiante.apellidos}'
              .toLowerCase();
          final cedula = estudiante.cedula.toLowerCase();
          return nombreCompleto.contains(query) || cedula.contains(query);
        }).toList();
      }
    });
  }

  void _handleEditEstudiante(TableData item) async {
    final estudiante = item as Estudiante;
    debugPrint(
      'Editar estudiante: ${estudiante.nombres} ${estudiante.apellidos} (ID: ${estudiante.idEstudiante})',
    );

    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            EstudianteFormScreen(estudianteToEdit: estudiante),
      ),
    );

    if (!mounted) return;
    if (result == true) {
      _fetchEstudiantes();
    }
  }

  void _handleDeleteEstudiante(TableData item) {
    final estudiante = item as Estudiante;
    debugPrint(
      'Eliminar estudiante: ${estudiante.nombres} ${estudiante.apellidos}',
    );

    if (estudiante.idEstudiante == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se puede eliminar un estudiante sin un ID válido.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirmar Eliminación'),
          content: Text(
            '¿Estás seguro de que quieres eliminar a ${estudiante.nombres} ${estudiante.apellidos}?',
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
                Navigator.of(dialogContext).pop();

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Eliminando estudiante...'),
                    duration: Duration(seconds: 1),
                  ),
                );

                try {
                  await _estudiantesService.eliminarEstudiante(
                    estudiante.idEstudiante!,
                  );
                  debugPrint('Estudiante eliminado con éxito');

                  if (!mounted) {
                    debugPrint(
                      '[_EstudiantesScreenState] Widget desmontado. No se puede actualizar UI después de eliminar.',
                    );
                    return;
                  }

                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Estudiante "${estudiante.nombres} ${estudiante.apellidos}" eliminado exitosamente.',
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                  _fetchEstudiantes();
                } catch (e) {
                  if (!mounted) {
                    debugPrint(
                      '[_EstudiantesScreenState] Widget desmontado. No se puede actualizar UI después de error al eliminar.',
                    );
                    return;
                  }

                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  setState(() {
                    _errorMessage =
                        'Error al eliminar estudiante: ${e.toString().replaceFirst('Exception: ', '')}';
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Error al eliminar estudiante: ${e.toString().replaceFirst('Exception: ', '')}',
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

  void _handleInfoEstudiante(TableData item) {
    EstudiantesUtils.showEstudianteInfoModal(context, item as Estudiante);
  }

  void _toggleActionMode() {
    setState(() {
      _isActionMode = !_isActionMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<DataColumn2> estudianteColumns;
    DataColumn2 actionColumn;

    // Ajusta el fixedWidth de la columna de acciones para móviles
    if (_isActionMode) {
      actionColumn = DataColumn2(
        label: const Center(child: Text('Acciones')),
        fixedWidth:
            defaultTargetPlatform == TargetPlatform.android ||
                    defaultTargetPlatform == TargetPlatform.iOS
                ? 100 // Más compacto para móvil. Puedes probar 90 o incluso 80 si los iconos son pequeños.
                : 150, // Mantener para desktop/web
      );
    } else {
      actionColumn = DataColumn2(
        label: const Center(child: Text('Info')),
        fixedWidth:
            defaultTargetPlatform == TargetPlatform.android ||
                    defaultTargetPlatform == TargetPlatform.iOS
                ? 80 // Más compacto para móvil (solo un botón). Puedes probar 70.
                : 150, // Mantener para desktop/web
      );
    }

    // Ajusta las columnas y sus anchos para dispositivos móviles
    if (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS) {
      estudianteColumns = [
        DataColumn2(
          label: const Text('ID'),
          fixedWidth: 60, // Más pequeño para ID en móvil
          onSort: (columnIndex, ascending) => _onSort(columnIndex, ascending),
        ),
        DataColumn2(
          label: const Text('Nombres'),
          fixedWidth: 150, // Ajusta según el ancho de nombres
          onSort: (columnIndex, ascending) => _onSort(columnIndex, ascending),
        ),

        actionColumn, // Ya tiene el ajuste de ancho para móvil
      ];
    } else {
      // Columnas para desktop/web con tamaños más generosos
      estudianteColumns = [
        DataColumn2(
          label: const Text('ID'),
          fixedWidth: 80,
          onSort: (columnIndex, ascending) => _onSort(columnIndex, ascending),
        ),
        DataColumn2(
          label: const Text('Nombres'),
          size: ColumnSize.L,
          onSort: (columnIndex, ascending) => _onSort(columnIndex, ascending),
        ),
        DataColumn2(
          label: const Text('Apellidos'),
          size: ColumnSize.L,
          onSort: (columnIndex, ascending) => _onSort(columnIndex, ascending),
        ),
        DataColumn2(
          label: const Text('Cédula'),
          size: ColumnSize.M,
          onSort: (columnIndex, ascending) => _onSort(columnIndex, ascending),
        ),
        actionColumn,
      ];
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ESTUDIANTES',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textTitle,
        actions: [
          IconButton(
            icon: Icon(_isActionMode ? Icons.info_outline : Icons.build),
            onPressed: _toggleActionMode,
            tooltip: _isActionMode ? 'Ver información' : 'Activar acciones',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchEstudiantes,
            tooltip: 'Recargar estudiantes',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const EstudianteFormScreen(),
                ),
              );
              if (!mounted) return;
              if (result == true) {
                _fetchEstudiantes();
              }
            },
            tooltip: 'Añadir nuevo estudiante',
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
                  padding:
                      (defaultTargetPlatform == TargetPlatform.android ||
                              defaultTargetPlatform == TargetPlatform.iOS)
                          ? const EdgeInsets.all(8.0) // Menos padding general en móvil
                          : const EdgeInsets.all(15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SearchBarWidget(
                        controller: _searchController,
                        hintText: 'Buscar estudiante por nombre o cédula...',
                        onChanged: (query) => _filterEstudiantes(),
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
                                  left: 10.0,
                                  right: 10.0,
                                ),
                                child: Text(
                                  'LISTA DE ESTUDIANTES',
                                  textAlign: TextAlign.left,
                                  style: Theme.of(context).textTheme.headlineSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                ),
                              ),
                              const Divider(),
                              Expanded(
                                child: CustomDataTable<Estudiante>(
                                  data: _filteredEstudiantes,
                                  columns: estudianteColumns,
                                  // --- SOLUCIÓN CLAVE: Ajustar minWidth para móviles ---
                                  minWidth: (defaultTargetPlatform == TargetPlatform.android ||
                                          defaultTargetPlatform == TargetPlatform.iOS)
                                      ? 320 // Un ancho mínimo más ajustado para móviles
                                      : 700, // Mantener para desktop/web
                                  // --- Fin de ajuste minWidth ---
                                  actionCallbacks: {
                                    'info': _handleInfoEstudiante,
                                    'edit': _handleEditEstudiante,
                                    'delete': _handleDeleteEstudiante,
                                  },
                                  sortColumnIndex: _sortColumnIndex,
                                  sortAscending: _sortAscending,
                                  rowsPerPage: 10,
                                  showActions: true,
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