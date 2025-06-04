// lib/layout/widgets/custom_data_table.dart
import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:smged/layout/widgets/custom_data_table_source.dart'; // Importa la nueva fuente de datos

abstract class TableData {
  int get id; // Necesario para identificar filas únicas
  // getCells ahora acepta el callback para acciones con un tipo 'dynamic'
  List<DataCell> getCells(
    BuildContext context,
    List<DataColumn2> currentColumns,
    Map<String, Function(dynamic item)> actionCallbacks, // Cambiado de nuevo a dynamic
  );
}

class CustomDataTable<T extends TableData> extends StatelessWidget {
  final List<T> data;
  final List<DataColumn2> columns;
  final double? minWidth;
  final Map<String, Function(T item)> actionCallbacks;
  final int? sortColumnIndex;
  final bool sortAscending;
  final int rowsPerPage; // Nuevo parámetro para la paginación
  final bool showActions; // Nuevo parámetro para mostrar/ocultar los botones de acción del paginador

  const CustomDataTable({
    super.key,
    required this.data,
    required this.columns,
    required this.actionCallbacks,
    this.minWidth,
    this.sortColumnIndex,
    this.sortAscending = true,
    this.rowsPerPage = 10, // Valor por defecto
    this.showActions = true, // Por defecto se muestran los botones de acción
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(
        child: Text(
          'No hay datos para mostrar.',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      );
    }

    final CustomDataTableSource<T> source = CustomDataTableSource<T>(
      data: data,
      columns: columns,
      actionCallbacks: actionCallbacks,
      context: context, // Pasamos el BuildContext
    );

    return PaginatedDataTable2(
      columns: columns,
      source: source,
      minWidth: minWidth,
      sortColumnIndex: sortColumnIndex,
      sortAscending: sortAscending,
      rowsPerPage: rowsPerPage,
      availableRowsPerPage: const [5, 10, 20, 50], // Opciones de filas por página
      onRowsPerPageChanged: (int? value) {
        // Puedes agregar lógica aquí para guardar la preferencia del usuario,
        // o simplemente reconstruir el widget si es necesario.
        // setState(() => _rowsPerPage = value!); // Si estuvieras en un StatefulWidget
      },
      // Puedes personalizar los botones de acción del paginador
      // actions: showActions ? <Widget>[] : null, // Ejemplo para ocultar acciones
    );
  }
}