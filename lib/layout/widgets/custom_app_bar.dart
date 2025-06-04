// lib/layout/widgets/custom_app_bar.dart
import 'package:flutter/material.dart';
import 'package:smged/layout/widgets/custom_TextStyles.dart'; // Mantener tu importación de estilos
import 'package:smged/layout/widgets/custom_colors.dart'; // Mantener tu importación de colores

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions; // Hacer que 'actions' sea opcional

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions, // Ahora se puede pasar una lista de acciones
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: TextStyles.title, // Usando tu estilo personalizado
      ),
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.textTitle, // Usando tu color de texto personalizado para el AppBar
      // Si 'actions' es nulo, usará una lista vacía por defecto,
      // de lo contrario, usará las acciones proporcionadas.
      actions: actions ?? const [],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}