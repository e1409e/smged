import 'package:flutter/material.dart';
import 'package:smged/layout/widgets/custom_colors.dart';
import 'package:smged/layout/widgets/search_bar_widget.dart'; // Importa tu SearchBarWidget

/// Un widget de "Dropdown" personalizable con funcionalidad de búsqueda,
/// que simula un DropdownButtonFormField pero con un AlertDialog para la selección.
class CustomDropdownButton<T> extends StatefulWidget {
  const CustomDropdownButton({
    super.key,
    required this.labelText,
    required this.hintText,
    this.prefixIcon,
    required this.isLoading,
    this.errorMessage,
    required this.items,
    required this.value,
    required this.onChanged,
    this.validator,
    required this.itemDisplayText, // Función para obtener el texto a mostrar en la lista
    required this.itemSearchFilter, // Función para filtrar elementos en la búsqueda
  });

  final String labelText;
  final String hintText;
  final IconData? prefixIcon;
  final bool isLoading;
  final String? errorMessage;
  final List<T> items;
  final T? value;
  final ValueChanged<T?> onChanged;
  final String? Function(T?)? validator;

  // Una función que toma un objeto T y devuelve la String que se mostrará en el DropdownMenuItem
  final String Function(T) itemDisplayText;

  // Una función que toma un objeto T y un String de búsqueda,
  // y devuelve true si el objeto coincide con la búsqueda.
  final bool Function(T, String) itemSearchFilter;

  @override
  State<CustomDropdownButton<T>> createState() => _CustomDropdownButtonState<T>();
}

class _CustomDropdownButtonState<T> extends State<CustomDropdownButton<T>> {
  final TextEditingController _searchController = TextEditingController();
  List<T> _filteredItems = [];
  T? _selectedValue; // Estado interno para el valor seleccionado

  @override
  void initState() {
    super.initState();
    _filteredItems = List.from(widget.items); // Inicializar con todos los items
    _selectedValue = widget.value; // Sincronizar con el valor inicial
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void didUpdateWidget(covariant CustomDropdownButton<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.items != oldWidget.items) {
      _filteredItems = List.from(widget.items);
      _searchController.clear(); // Limpiar búsqueda si los items cambian
    }
    if (widget.value != oldWidget.value) {
      _selectedValue = widget.value; // Actualizar valor seleccionado si viene del padre
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredItems = List.from(widget.items);
      } else {
        _filteredItems = widget.items
            .where((item) => widget.itemSearchFilter(item, query))
            .toList();
      }
    });
  }

  // Muestra el diálogo de selección con la barra de búsqueda
  void _showSelectionDialog(BuildContext context) {
    _searchController.clear(); // Limpiar búsqueda al abrir el diálogo
    setState(() {
      _filteredItems = List.from(widget.items); // Reiniciar filtro
    });

    showDialog<T?>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(widget.labelText),
          content: StatefulBuilder( // Usa StatefulBuilder para reconstruir solo el contenido del diálogo
            builder: (BuildContext context, StateSetter setStateDialog) {
              return SizedBox(
                width: MediaQuery.of(context).size.width * 0.8, // Ancho adaptable
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SearchBarWidget(
                      controller: _searchController,
                      hintText: 'Buscar ${widget.labelText.toLowerCase()}',
                      onChanged: (query) {
                        setStateDialog(() { // Reconstruye el diálogo al buscar
                          _onSearchChanged();
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    if (_filteredItems.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('No se encontraron resultados.'),
                      )
                    else
                      Flexible(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: _filteredItems.length,
                          itemBuilder: (context, index) {
                            final item = _filteredItems[index];
                            return ListTile(
                              title: Text(widget.itemDisplayText(item)),
                              onTap: () {
                                Navigator.pop(dialogContext, item); // Devuelve el item seleccionado
                              },
                            );
                          },
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cerrar'),
              onPressed: () {
                Navigator.pop(dialogContext, null); // Cierra sin seleccionar
              },
            ),
          ],
        );
      },
    ).then((selectedItem) {
      if (selectedItem != null && selectedItem != _selectedValue) {
        setState(() {
          _selectedValue = selectedItem;
        });
        widget.onChanged(_selectedValue); // Notificar al padre
      }
    });
  }

  // Validación del campo (reutilizado del DropdownButtonFormField)
  String? _validate() {
    if (widget.validator != null) {
      return widget.validator!(_selectedValue);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (widget.errorMessage != null) {
      return Text(
        widget.errorMessage!,
        style: const TextStyle(color: AppColors.error),
        textAlign: TextAlign.center,
      );
    } else {
      // Usamos un GestureDetector o un TextFormField con onTap
      return TextFormField(
        readOnly: true, // No permitir escribir directamente en el campo
        controller: TextEditingController(
          text: _selectedValue != null ? widget.itemDisplayText(_selectedValue!) : '',
        ),
        decoration: InputDecoration(
          labelText: widget.labelText,
          hintText: widget.hintText,
          border: const OutlineInputBorder(),
          prefixIcon: widget.prefixIcon != null ? Icon(widget.prefixIcon) : null,
          suffixIcon: const Icon(Icons.arrow_drop_down), // Ícono de dropdown
        ),
        onTap: () => _showSelectionDialog(context),
        validator: (text) => _validate(), // Llama a la validación personalizada
      );
    }
  }
}