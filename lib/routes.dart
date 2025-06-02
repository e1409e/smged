// lib/routes.dart
import 'package:flutter/material.dart';

// No necesitas importar LoginScreen o HomeScreen aquí,
// ya que la lógica principal de autenticación se maneja en main.dart
// import 'package:smged/layout/screens/login_screen.dart';
// import 'package:smged/layout/screens/home_screen.dart';

import 'package:smged/layout/screens/estudiantes_screen.dart';
import 'package:smged/layout/screens/forms/estudiante_form_screen.dart';

/// Una clase que contiene las constantes de las rutas de tu aplicación.
class AppRoutes {
  // initialRoute y loginRoute/homeRoute ya no son relevantes para el flujo principal de auth
  // static const String initialRoute = '/';
  // static const String loginRoute = '/login';
  // static const String homeRoute = '/home';

  static const String estudiantesList =
      '/estudiantes'; // Ruta para la lista de estudiantes
  static const String estudianteForm =
      '/estudianteForm'; // Ruta para el formulario de estudiante

  // Puedes definir aquí otras rutas para tus dashboards si las usas con Navigator.pushNamed
  // static const String adminDashboardRoute = '/adminDashboard';
  // static const String docenteDashboardRoute = '/docenteDashboard';
}

// Esta función ahora solo devuelve un mapa de rutas para navegación INTERNA.
// YA NO RECIBE NINGÚN PARÁMETRO DE AUTENTICACIÓN.
Map<String, WidgetBuilder> getApplicationRoutes() {
  // <--- ¡Sin parámetros aquí!
  return <String, WidgetBuilder>{
    // La ruta inicial para la decisión de auth se maneja en main.dart (propiedad 'home')
    // por lo tanto, no se define aquí.
    AppRoutes.estudiantesList: (BuildContext context) =>
        const EstudiantesScreen(),
    AppRoutes.estudianteForm: (BuildContext context) =>
        const EstudianteFormScreen(),

    // Agrega aquí el resto de tus rutas internas.
    // AppRoutes.adminDashboardRoute: (BuildContext context) => const AdminDashboardScreen(),
    // AppRoutes.docenteDashboardRoute: (BuildContext context) => const DocenteDashboardScreen(),
  };
}
