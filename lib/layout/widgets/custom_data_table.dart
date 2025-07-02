// lib/layout/widgets/custom_data_table.dart
import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:smged/layout/widgets/custom_data_table_source.dart';

abstract class TableData {
  int get id;
  List<DataCell> getCells(
    BuildContext context,
    List<DataColumn2> currentColumns,
    Map<String, Function(dynamic item)> actionCallbacks,
  );
}

class CustomDataTable<T extends TableData> extends StatelessWidget {
  final List<T> data;
  final List<DataColumn2> columns;
  final double? minWidth;
  final Map<String, Function(T item)> actionCallbacks;
  final int? sortColumnIndex;
  final bool sortAscending;
  final int rowsPerPage;
  final bool showActions;

  const CustomDataTable({
    super.key,
    required this.data,
    required this.columns,
    required this.actionCallbacks,
    this.minWidth,
    this.sortColumnIndex,
    this.sortAscending = true,
    this.rowsPerPage = 10,
    this.showActions = true,
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
      context: context,
    );

    return Theme( // <--- Envolvemos con un Theme
      data: Theme.of(context).copyWith( // Copiamos el tema actual
        dataTableTheme: DataTableThemeData( // Y definimos el tema para las tablas de datos
          dataRowColor: MaterialStateProperty.all(Colors.white), // Color de fondo para las filas de datos
          headingRowColor: MaterialStateProperty.all(Colors.white), // Color de fondo para la fila de encabezado
          // También puedes ajustar el estilo del texto si es necesario
          // headingTextStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
          // dataTextStyle: TextStyle(color: Colors.black87),
        ),
      ),
      child: PaginatedDataTable2(
        columns: columns,
        source: source,
        minWidth: minWidth,
        sortColumnIndex: sortColumnIndex,
        sortAscending: sortAscending,
        rowsPerPage: rowsPerPage,
        availableRowsPerPage: const [5, 10, 20, 50],
        onRowsPerPageChanged: (int? value) {
          // Lógica para cambio de filas por página
        },
        // Aquí NO usamos dataRowColor ni headingRowColor, se aplican desde el Theme
      ),
    );
  }
}