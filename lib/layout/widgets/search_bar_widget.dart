// lib/layout/widgets/search_bar_widget.dart
import 'package:flutter/material.dart';

class SearchBarWidget extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged; // Permite notificar al padre sobre los cambios

  const SearchBarWidget({
    super.key,
    required this.controller,
    this.hintText = 'Buscar...',
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0), // Padding horizontal para hacerla más pequeña
      child: Container(
        height: 48.0, // Altura fija para la barra de búsqueda
        decoration: BoxDecoration(
          color: Colors.blue, // Color de fondo azul como en la imagen
          borderRadius: BorderRadius.circular(8.0), // Bordes redondeados
          border: Border.all(color: Colors.blue, width: 1.0), // Borde azul fino
        ),
        child: Row(
          children: [
            Expanded(
              flex: 8, // El TextField ocupa 8/9 partes del espacio (ajuste aquí)
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: hintText,
                  hintStyle: const TextStyle(color: Colors.grey), // Color del hint text
                  filled: true,
                  fillColor: Colors.white, // Fondo blanco para el campo de texto
                  contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8.0),
                      bottomLeft: Radius.circular(8.0),
                    ),
                    borderSide: BorderSide.none, // Eliminar el borde predeterminado
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8.0),
                      bottomLeft: Radius.circular(8.0),
                    ),
                    borderSide: BorderSide.none, // Eliminar el borde cuando no está enfocado
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8.0),
                      bottomLeft: Radius.circular(8.0),
                    ),
                    borderSide: BorderSide(color: Colors.blue, width: 2.0), // Borde azul al enfocar
                  ),
                  suffixIcon: controller.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.grey), // Color del icono de borrar
                          onPressed: () {
                            controller.clear();
                            if (onChanged != null) {
                              onChanged!(''); // Notificar al padre que el texto está vacío
                            }
                          },
                        )
                      : null,
                ),
                onChanged: onChanged, // Pasa el onChanged del padre
              ),
            ),
            // Sección del icono de búsqueda
            Expanded(
              flex: 1, // El icono de búsqueda ocupa 1/9 parte del espacio (se mantiene igual, pero la proporción cambia por el flex del TextField)
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.blue, // Fondo azul para esta sección
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(8.0),
                    bottomRight: Radius.circular(8.0),
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.search,
                    color: Colors.white, // Color blanco para el icono de búsqueda
                    size: 28.0, // Tamaño del icono de búsqueda
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}