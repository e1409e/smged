import 'dart:ui';

import 'package:flutter/material.dart';

class AppColors{
  //Colores principales
  static const Color primary = Color(0xFF2081C2);
  static const Color secondary = Color(0xFF1F587D);
  static const Color backgroundSystem = Color.fromARGB(255, 226, 232, 236);
 // Colores de estado/feedback
  static const Color success = Colors.green; // Verde para éxito
  static const Color error = Colors.red;     // Rojo para errores
  static const Color warning = Colors.orange; // Naranja para advertencias
  static const Color info = Colors.blue;      // <-- ¡AÑADIDO ESTE COLOR! Azul para información
  static const Color background = Color(0xFFF5F5F5); // Fondo claro
  static const Color surface = Colors.white; // Superficies como tarjetas o dialogos

  // Otros colores 
  static const Color greyLight = Color(0xFFE0E0E0);
  static const Color greyDark = Color(0xFF424242);

  //widget
  static const Color indicator = Color(0xFF2030C2);

  //Textos
  static const Color textPrimary = Color(0xFF000000);
  static const Color textTitle = Color(0xFFFFFDFD);
}