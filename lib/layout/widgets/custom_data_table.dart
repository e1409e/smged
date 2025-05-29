// lib/layout/widgets/custom_data_table.dart
import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:smged/layout/widgets/custom_colors.dart'; // Asegúrate de que esta ruta sea correcta

// Define una interfaz o contrato para los datos que se mostrarán en la tabla.
// Tu modelo 'Estudiante' debe implementar esta interfaz.
abstract class TableData {
  int get id; // Necesario para identificar filas únicas
  // getCells ahora acepta la lista de columnas como parámetro
  List<DataCell> getCells(BuildContext context, List<DataColumn2> currentColumns);
}

class CustomDataTable<T extends TableData> extends StatelessWidget {
  final List<T> data;
  final List<DataColumn2> columns; // Estas son las columnas que se están mostrando
  final double? minWidth;
  final void Function(T item) onInfoPressed;
  final int? sortColumnIndex;
  final bool sortAscending;

  const CustomDataTable({
    super.key,
    required this.data,
    required this.columns,
    required this.onInfoPressed,
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
        // Obtiene las celdas de datos usando el nuevo método getCells
        List<DataCell> cells = item.getCells(context, columns);

        // AÑADE la celda de acción aquí en CustomDataTable.
        // Solo la añade si la columna 'Info' existe en la lista de columnas actuales
        if (columns.any((col) => (col.label as Text).data == 'Info')) {
          cells.add(
            DataCell(
              Align(
                alignment: Alignment.centerLeft, // Alinea el contenido de la celda a la izquierda
                child: IconButton(
                  padding: EdgeInsets.zero, // Elimina el padding por defecto del botón
                  constraints: const BoxConstraints(), // Elimina las restricciones de tamaño mínimo del botón
                  icon: const Icon(Icons.info_outline, size: 20, color: AppColors.primary),
                  tooltip: 'Ver información del estudiante',
                  onPressed: () {
                    onInfoPressed(item);
                  },
                ),
              ),
            ),
          );
        }

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