// lib/layout/widgets/custom_data_table.dart
import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';

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
  // El tipo de la función en el mapa sigue siendo Function(T item)
  final Map<String, Function(T item)> actionCallbacks;
  final int? sortColumnIndex;
  final bool sortAscending;

  const CustomDataTable({
    super.key,
    required this.data,
    required this.columns,
    required this.actionCallbacks,
    this.minWidth,
    this.sortColumnIndex,
    this.sortAscending = true,
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

    return DataTable2(
      minWidth: minWidth,
      columns: columns,
      rows: data.map((item) {
        // Al pasar los actionCallbacks, necesitamos asegurar que el 'item' que recibe el callback
        // dentro de getCells sea el tipo T correcto.
        // Hacemos un mapeo para ajustar el tipo de entrada de Function(T item) a Function(dynamic item).
        // El 'item' que se pasa al callback dentro de DataCell será el 'this' (que es un Estudiante).
        final Map<String, Function(dynamic item)> dynamicActionCallbacks =
            actionCallbacks.map((key, value) {
          return MapEntry(key, (dynamic i) => value(i as T));
        });

        List<DataCell> cells = item.getCells(context, columns, dynamicActionCallbacks);


        return DataRow(
          key: ValueKey(item.id),
          cells: cells,
        );
      }).toList(),
      fixedTopRows: 1,
      sortColumnIndex: sortColumnIndex,
      sortAscending: sortAscending,
    );
  }
}