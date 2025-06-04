// lib/layout/widgets/custom_data_table_source.dart
import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:smged/layout/widgets/custom_data_table.dart'; // Asegúrate de que esta ruta sea correcta

class CustomDataTableSource<T extends TableData> extends DataTableSource {
  final List<T> data;
  final List<DataColumn2> columns;
  final Map<String, Function(T item)> actionCallbacks;
  final BuildContext context;

  CustomDataTableSource({
    required this.data,
    required this.columns,
    required this.actionCallbacks,
    required this.context,
  });

  @override
  DataRow? getRow(int index) {
    if (index >= data.length) {
      return null;
    }
    final item = data[index];

    // Mapeo para ajustar el tipo de entrada de Function(T item) a Function(dynamic item)
    final Map<String, Function(dynamic item)> dynamicActionCallbacks =
        actionCallbacks.map((key, value) {
      return MapEntry(key, (dynamic i) => value(i as T));
    });

    List<DataCell> cells = item.getCells(context, columns, dynamicActionCallbacks);

    return DataRow(
      key: ValueKey(item.id),
      cells: cells,
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => data.length;

  @override
  int get selectedRowCount => 0; // No estamos manejando filas seleccionadas en este ejemplo
}