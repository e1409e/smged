// lib/layout/screens/estudiantes_screen.dart
import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart'; // ¡Importa esto para defaultTargetPlatform!

import 'package:smged/api/models/estudiante.dart';
import 'package:smged/api/services/estudiantes_service.dart';
import 'package:smged/layout/widgets/custom_data_table.dart';
import 'package:smged/layout/widgets/custom_colors.dart';
import 'package:smged/layout/widgets/search_bar_widget.dart';

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
      final fetchedEstudiantes = await _estudiantesService.obtenerTodosLosEstudiantes();
      setState(() {
        _estudiantes = fetchedEstudiantes;
        _filteredEstudiantes = fetchedEstudiantes;
        _sortColumnIndex = null;
        _sortAscending = true;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar estudiantes: ${e.toString().replaceFirst('Exception: ', '')}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onSort(int columnIndex, bool ascending) {
    // Es importante que la lógica de ordenación coincida con el orden de las columnas cuando
    // se usan las columnas reducidas. Para simplificar, ordenaremos la lista completa
    // y luego aplicaremos el filtro, y la tabla solo mostrará las columnas relevantes.

    // Primero, definimos las columnas "base" para los índices de ordenación
    // sin importar si se muestran o no.
    final List<DataColumn2> baseColumns = [
      DataColumn2(label: const Text('ID')),
      DataColumn2(label: const Text('Nombres')),
      DataColumn2(label: const Text('Apellidos')),
      DataColumn2(label: const Text('Cédula')),
      DataColumn2(label: const Text('Info')),
    ];

    // Ahora, mapeamos el `columnIndex` recibido a la columna real que se está ordenando.
    // Esto es crucial porque si solo mostramos 3 columnas, el índice 1 (Nombres)
    // sigue siendo el índice 1 para la ordenación de la lista original.
    String sortKey = '';
    if (columnIndex >= 0 && columnIndex < baseColumns.length) {
      sortKey = (baseColumns[columnIndex].label as Text).data!;
    }

    if (sortKey == 'ID') {
      _estudiantes.sort((a, b) => ascending
          ? a.idEstudiante.compareTo(b.idEstudiante)
          : b.idEstudiante.compareTo(a.idEstudiante));
    } else if (sortKey == 'Nombres') {
      _estudiantes.sort((a, b) => ascending
          ? a.nombres.compareTo(b.nombres)
          : b.nombres.compareTo(a.nombres));
    } else if (sortKey == 'Apellidos') {
      _estudiantes.sort((a, b) => ascending
          ? a.apellidos.compareTo(b.apellidos)
          : b.apellidos.compareTo(a.apellidos));
    } else if (sortKey == 'Cédula') {
      _estudiantes.sort((a, b) => ascending
          ? a.cedula.compareTo(b.cedula)
          : b.cedula.compareTo(a.cedula));
    }

    _filterEstudiantes(); // Vuelve a filtrar para aplicar el nuevo orden

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
          final nombreCompleto = '${estudiante.nombres} ${estudiante.apellidos}'.toLowerCase();
          final cedula = estudiante.cedula.toLowerCase();
          return nombreCompleto.contains(query) || cedula.contains(query);
        }).toList();
      }
    });
  }

  void showEstudianteInfoModal(Estudiante estudiante) {
    final DateFormat dateFormatter = DateFormat('dd/MM/yyyy');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Información de ${estudiante.nombres} ${estudiante.apellidos}',
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                _buildInfoRow('ID:', estudiante.idEstudiante.toString()),
                _buildInfoRow('Nombres:', estudiante.nombres),
                _buildInfoRow('Apellidos:', estudiante.apellidos),
                _buildInfoRow('Cédula:', estudiante.cedula),
                _buildInfoRow('Correo:', estudiante.correo ?? 'N/A'),
                _buildInfoRow('Teléfono:', estudiante.telefono ?? 'N/A'),
                //_buildInfoRow('Dirección:', estudiante.direccion ?? 'N/A'),
                _buildInfoRow(
                  'Fecha Nacimiento:',
                  estudiante.fechaNacimiento != null
                      ? dateFormatter.format(estudiante.fechaNacimiento!)
                      : 'N/A',
                ),
                _buildInfoRow(
                  'Observaciones:',
                  estudiante.observaciones ?? 'N/A',
                ),
                _buildInfoRow('Seguimiento:', estudiante.seguimiento ?? 'N/A'),
                _buildInfoRow(
                  'Discapacidad:',
                  estudiante.discapacidad ?? 'Ninguna',
                ),
                _buildInfoRow(
                  'Fecha Registro:',
                  estudiante.fechaRegistro != null
                      ? dateFormatter.format(estudiante.fechaRegistro!)
                      : 'N/A',
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cerrar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<DataColumn2> estudianteColumns;

    // Lógica condicional para las columnas según la plataforma
    if (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS) {
      // Columnas para Android y iOS
      estudianteColumns = [
        DataColumn2(
          label: const Text('ID'),
          fixedWidth: 60,
          onSort: (columnIndex, ascending) => _onSort(columnIndex, ascending),
        ),
        DataColumn2(
          label: const Text('Nombres'),
          //size: ColumnSize.S,
          fixedWidth: 200,
          onSort: (columnIndex, ascending) => _onSort(columnIndex, ascending),
        ),
        DataColumn2(
          label: const Text('Info'), // Columna de acciones
          //size: ColumnSize.S,
          fixedWidth: 100,
        ),
      ];
      // Ajustar el sortColumnIndex para la ordenación si las columnas son diferentes
      // Si la columna "Nombres" en el conjunto reducido es la 1, y en el completo también,
      // la lógica de _onSort() ya debería manejarlo si está basada en el texto del label.
      // Si no, podríamos necesitar mapear los índices.
    } else {
      // Columnas para otras plataformas (Web, Desktop)
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
        DataColumn2(
          label: const Text('Info'),
          fixedWidth: 80,
        ),
      ];
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Estudiantes'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textTitle,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchEstudiantes,
            tooltip: 'Recargar estudiantes',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              debugPrint('Navegar a pantalla para añadir estudiante');
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
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SearchBarWidget(
                        controller: _searchController,
                        hintText: 'Buscar estudiante por nombre o cédula...',
                        onChanged: (query) => _filterEstudiantes(),
                      ),
                      const SizedBox(height: 16.0),
                      Expanded(
                        child: Card(
                          elevation: 8.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                  bottom: 8.0,
                                  top: 8.0,
                                  left: 16.0,
                                  right: 16.0,
                                ),
                                child: Text(
                                  'LISTA DE ESTUDIANTES',
                                  textAlign: TextAlign.left,
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                              const Divider(),
                              _filteredEstudiantes.isEmpty
                                  ? const Expanded(
                                      child: Center(
                                        child: Text(
                                          'No hay estudiantes registrados o no se encontraron resultados.',
                                          style: TextStyle(fontSize: 16, color: Colors.grey),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    )
                                  : Expanded(
                                      child: CustomDataTable<Estudiante>(
                                        data: _filteredEstudiantes,
                                        columns: estudianteColumns,
                                        minWidth: 700, // minWidth puede que necesite ajuste para pantallas pequeñas
                                        onInfoPressed: (item) {
                                          showEstudianteInfoModal(item);
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