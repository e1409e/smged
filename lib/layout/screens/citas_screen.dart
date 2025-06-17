// lib/layout/screens/citas_screen.dart
import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/foundation.dart'; // Necesario para defaultTargetPlatform
import 'package:collection/collection.dart'; // Importa para firstWhereOrNull

import 'package:smged/api/models/cita.dart'; // Importa el modelo Cita
import 'package:smged/api/services/citas_service.dart'; // Importa el servicio CitasService
import 'package:smged/layout/widgets/custom_data_table.dart';
import 'package:smged/layout/widgets/custom_colors.dart';
import 'package:smged/layout/widgets/search_bar_widget.dart';
import 'package:smged/layout/screens/forms/cita_form_screen.dart';
import 'package:smged/layout/utils/citas_utils.dart'; // Asegúrate de que este import esté correcto

class CitasScreen extends StatefulWidget {
  const CitasScreen({super.key});

  @override
  State<CitasScreen> createState() => _CitasScreenState();
}

class _CitasScreenState extends State<CitasScreen> {
  final CitasService _citasService = CitasService(); // Instancia del servicio de citas
  List<Cita> _citas = [];
  List<Cita> _filteredCitas = [];
  bool _isLoading = true;
  String? _errorMessage;

  int? _sortColumnIndex;
  bool _sortAscending = true;

  final TextEditingController _searchController = TextEditingController();

  // >>> INICIO DE CAMBIOS <<<
  bool _isActionMode = false; // Variable de estado para controlar la modalidad

  @override
  void initState() {
    super.initState();
    _fetchCitas(); // Cambiamos a _fetchCitas
    _searchController.addListener(_filterCitas); // Filtra citas
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterCitas);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchCitas() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final fetchedCitas = await _citasService.obtenerCitas(); // Usamos el método del servicio de citas
      if (!mounted) return;
      setState(() {
        _citas = fetchedCitas;
        _filteredCitas = fetchedCitas;
        _sortColumnIndex = null; // Reiniciar ordenación
        _sortAscending = true;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Error al cargar citas: ${e.toString().replaceFirst('Exception: ', '')}';
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
      'ID', // Cambiado de 'ID Cita' para coincidir con el index
      'Estudiante', // Nombre del estudiante para ordenar
      'Fecha Cita',
      'Motivo',
      'Realizada', // Añadir esta columna para ordenación
    ];

    if (columnIndex < 0 || columnIndex >= sortableColumnKeys.length) {
      return;
    }

    final String sortKey = sortableColumnKeys[columnIndex];

    _citas.sort((a, b) {
      Comparable valueA;
      Comparable valueB;

      switch (sortKey) {
        case 'ID':
          valueA = a.id_citas ?? 0;
          valueB = b.id_citas ?? 0;
          break;
        case 'Estudiante':
          valueA = a.nombre_estudiante ?? '';
          valueB = b.nombre_estudiante ?? '';
          break;
        case 'Fecha Cita':
          valueA = a.fecha_cita;
          valueB = b.fecha_cita;
          break;
        case 'Motivo':
          valueA = a.motivo_cita ?? '';
          valueB = b.motivo_cita ?? '';
          break;
        case 'Realizada':
          valueA = a.pendiente ?? 1; // 0 es realizada, 1 es pendiente
          valueB = b.pendiente ?? 1;
          break;
        default:
          return 0; // No se puede ordenar por esta columna
      }

      return ascending ? valueA.compareTo(valueB) : valueB.compareTo(valueA);
    });

    _filterCitas(); // Re-aplicar filtro después de ordenar

    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
  }

  void _filterCitas() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredCitas = List.from(_citas);
      } else {
        _filteredCitas = _citas.where((cita) {
          final nombreEstudiante = cita.nombre_estudiante?.toLowerCase() ?? '';
          final motivoCita = cita.motivo_cita?.toLowerCase() ?? '';
          final fechaCita = cita.fecha_cita
              .toLocal()
              .toString()
              .split(' ')[0]
              .toLowerCase(); // Filtra por fecha también

          return nombreEstudiante.contains(query) ||
              motivoCita.contains(query) ||
              fechaCita.contains(query);
        }).toList();
      }
    });
  }

  void _handleInfoCita(TableData item) {
    CitasUtils.showCitaInfoModal(context, item as Cita);
  }

  void _handleEditCita(TableData item) async {
    final cita = item as Cita;
    debugPrint('Editar cita: ID ${cita.id_citas}');

    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            CitaFormScreen(citaToEdit: cita), // Pasa la cita a editar
      ),
    );

    if (!mounted) return;
    if (result == true) {
      // Si el formulario indicó un cambio exitoso
      _fetchCitas(); // Recargar citas
    }
  }

  void _handleDeleteCita(TableData item) {
    final cita = item as Cita;
    debugPrint('Eliminar cita: ID ${cita.id_citas}');

    if (cita.id_citas == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se puede eliminar una cita sin un ID válido.'),
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
            '¿Estás seguro de que quieres eliminar la cita con ${cita.nombre_estudiante ?? 'N/A'} del ${cita.fecha_cita.toLocal().toString().split(' ')[0]}?',
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
                    content: Text('Eliminando cita...'),
                    duration: Duration(seconds: 1),
                  ),
                );

                try {
                  await _citasService.eliminarCita(cita.id_citas!);
                  debugPrint('Cita eliminada con éxito');

                  if (!mounted) {
                    debugPrint(
                      '[_CitasScreenState] Widget desmontado. No se puede actualizar UI después de eliminar.',
                    );
                    return;
                  }

                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Cita con ID ${cita.id_citas} eliminada exitosamente.',
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                  _fetchCitas(); // Vuelve a cargar la lista
                } catch (e) {
                  if (!mounted) {
                    debugPrint(
                      '[_CitasScreenState] Widget desmontado. No se puede actualizar UI después de error al eliminar.',
                    );
                    return;
                  }

                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  setState(() {
                    _errorMessage =
                        'Error al eliminar cita: ${e.toString().replaceFirst('Exception: ', '')}';
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Error al eliminar cita: ${e.toString().replaceFirst('Exception: ', '')}',
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

  void _handleMarkAsRealized(TableData item) async {
    final cita = item as Cita;
    debugPrint('Marcar cita como realizada: ID ${cita.id_citas}');

    if (cita.id_citas == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se puede marcar una cita sin un ID válido.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (cita.pendiente == 0) {
      // Si ya está realizada
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La cita ya está marcada como realizada.'),
          backgroundColor: AppColors.info, // Un color informativo
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirmar Cita Realizada'),
          content: Text(
            '¿Estás seguro de que quieres marcar la cita con ID ${cita.id_citas} (${cita.nombre_estudiante ?? 'N/A'}) del ${cita.fecha_cita.toLocal().toString().split(' ')[0]} como realizada?',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
              ), // O un color de éxito
              child: const Text('Marcar como Realizada'),
              onPressed: () async {
                Navigator.of(dialogContext).pop(); // Cierra el diálogo

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Marcando cita como realizada...'),
                    duration: Duration(seconds: 1),
                  ),
                );

                try {
                  final success = await _citasService.marcarCitaComoRealizada(
                    cita.id_citas!,
                  );
                  debugPrint('Cita marcada como realizada: $success');

                  if (!mounted) {
                    debugPrint(
                      '[_CitasScreenState] Widget desmontado. No se puede actualizar UI después de marcar como realizada.',
                    );
                    return;
                  }

                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Cita con ID ${cita.id_citas} marcada como realizada exitosamente.',
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );
                    _fetchCitas(); // Vuelve a cargar la lista para reflejar el cambio de estado
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'No se pudo marcar la cita como realizada. Inténtalo de nuevo.',
                        ),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  }
                } catch (e) {
                  if (!mounted) {
                    debugPrint(
                      '[_CitasScreenState] Widget desmontado. No se puede actualizar UI después de error al marcar como realizada.',
                    );
                    return;
                  }

                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  setState(() {
                    _errorMessage =
                        'Error al marcar cita como realizada: ${e.toString().replaceFirst('Exception: ', '')}';
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Error al marcar cita como realizada: ${e.toString().replaceFirst('Exception: ', '')}',
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
  // <<< FIN DE CAMBIOS >>>

  // Construye la interfaz de la tabla de citas
  @override
  Widget build(BuildContext context) {
    List<DataColumn2> citaColumns;
    DataColumn2 actionColumn;

    
    // Definir la columna de acciones basada en _isActionMode
    if (_isActionMode) {
  actionColumn = DataColumn2(
    label:  Center( // <--- Agrega Center aquí
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

    // Columnas para la tabla de citas (se mantienen las definiciones anteriores, pero la última se asigna dinámicamente)
    if (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS) {
      citaColumns = [
        DataColumn2(
          label: const Text('Estudiante'),
          fixedWidth: 140, // Ajuste para móvil
          onSort: (columnIndex, ascending) => _onSort(columnIndex, ascending),
        ),
        actionColumn, // Columna de acción dinámica
      ];
    } else {
      citaColumns = [
        DataColumn2(
          label: const Text('ID'),
          fixedWidth: 80,
          onSort: (columnIndex, ascending) => _onSort(columnIndex, ascending),
        ),
        DataColumn2(
          label: const Text('Estudiante'), // ¡Mostrar nombre del estudiante!
          size: ColumnSize.L, // Puede ser más grande para el nombre
          onSort: (columnIndex, ascending) => _onSort(columnIndex, ascending),
        ),
        DataColumn2(
          label: const Text('Fecha Cita'),
          fixedWidth: 150,
          onSort: (columnIndex, ascending) => _onSort(columnIndex, ascending),
        ),
        DataColumn2(
          label: const Text('Motivo'),
          size: ColumnSize.L, // Cambiado a L para más espacio
          onSort: (columnIndex, ascending) => _onSort(columnIndex, ascending),
        ),
        DataColumn2(
          label: const Text('Realizada'),
          fixedWidth: 150,
          onSort: (columnIndex, ascending) => _onSort(columnIndex, ascending),
        ),
        actionColumn, // Columna de acción dinámica
      ];
    }
    // <<< FIN DE CAMBIOS EN EL BUILD >>>

    return Scaffold(
      appBar: AppBar(
        title: Text('CITAS', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textTitle,
        actions: [
          // >>> INICIO DE CAMBIOS EN APPBAR ACTIONS <<<
          IconButton(
            icon: Icon(_isActionMode ? Icons.info_outline : Icons.build), // Icono dinámico
            onPressed: _toggleActionMode, // Llama a la función para alternar
            tooltip: _isActionMode ? 'Ver información' : 'Activar acciones', // Tooltip dinámico
          ),
          // <<< FIN DE CAMBIOS EN APPBAR ACTIONS <<<
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchCitas,
            tooltip: 'Recargar citas',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) =>
                      const CitaFormScreen(), // Abrir formulario de cita
                ),
              );
              if (!mounted) return;
              if (result == true) {
                _fetchCitas(); // Recargar citas si se añadió una nueva
              }
            },
            tooltip: 'Añadir nueva cita',
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
                        hintText: 'Buscar cita por estudiante, motivo o fecha...',
                        onChanged: (query) => _filterCitas(),
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
                                  'LISTA DE CITAS',
                                  textAlign: TextAlign.left,
                                  style: Theme.of(context).textTheme.headlineSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                ),
                              ),
                              const Divider(),
                              _filteredCitas.isEmpty
                                  ? const Expanded(
                                      child: Center(
                                        child: Text(
                                          'No hay citas registradas o no se encontraron resultados.',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    )
                                  : Expanded(
                                      child: CustomDataTable<Cita>(
                                        data: _filteredCitas,
                                        columns: citaColumns,
                                        minWidth:
                                            900, // Ajustar minWidth según las columnas
                                        // >>> INICIO DE CAMBIOS EN ACTIONCALLBACKS <<<
                                        actionCallbacks: _isActionMode
                                            ? {
                                                'edit': _handleEditCita,
                                                'delete': _handleDeleteCita,
                                                'mark_realized':
                                                    _handleMarkAsRealized,
                                              }
                                            : {
                                                'info': _handleInfoCita, // Solo info en modo de información
                                              },
                                        // <<< FIN DE CAMBIOS EN ACTIONCALLBACKS <<<
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