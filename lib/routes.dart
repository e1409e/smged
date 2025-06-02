// lib/routes.dart
import 'package:flutter/material.dart';

import 'package:smged/layout/screens/estudiantes_screen.dart';
import 'package:smged/layout/screens/forms/estudiante_form_screen.dart';
import 'package:smged/layout/screens/citas_screen.dart'; // <-- ¡IMPORTA LA PANTALLA DE CITAS!
import 'package:smged/layout/screens/forms/cita_form_screen.dart'; // <-- ¡IMPORTA LA PANTALLA DEL FORMULARIO DE CITAS!


/// Una clase que contiene las constantes de las rutas de tu aplicación.
class AppRoutes {
  static const String estudiantesList =
      '/estudiantes'; // Ruta para la lista de estudiantes
  static const String estudianteForm =
      '/estudianteForm'; // Ruta para el formulario de estudiante

  static const String citasList = '/citas'; // <-- ¡NUEVA RUTA PARA LA LISTA DE CITAS!
  static const String citaForm = '/citaForm'; // <-- ¡NUEVA RUTA PARA EL FORMULARIO DE CITAS!

  // Puedes definir aquí otras rutas para tus dashboards si las usas con Navigator.pushNamed
  // static const String adminDashboardRoute = '/adminDashboard';
  // static const String adminDashboardRoute = '/adminDashboard';
  // static const String docenteDashboardRoute = '/docenteDashboard';
}

// Esta función ahora solo devuelve un mapa de rutas para navegación INTERNA.
Map<String, WidgetBuilder> getApplicationRoutes() {
  return <String, WidgetBuilder>{
    // Rutas de Estudiantes
    AppRoutes.estudiantesList: (BuildContext context) =>
        const EstudiantesScreen(),
    AppRoutes.estudianteForm: (BuildContext context) =>
        const EstudianteFormScreen(),

    // Rutas de Citas
    AppRoutes.citasList: (BuildContext context) =>
        const CitasScreen(), // <-- ¡AÑADE LA RUTA DE LA LISTA DE CITAS!
    AppRoutes.citaForm: (BuildContext context) =>
        const CitaFormScreen(), // <-- ¡AÑADE LA RUTA DEL FORMULARIO DE CITAS!

    // Agrega aquí el resto de tus rutas internas (Historial Médico, Reportes, Configuración, etc.).
    // AppRoutes.adminDashboardRoute: (BuildContext context) => const AdminDashboardScreen(),
    // AppRoutes.docenteDashboardRoute: (BuildContext context) => const DocenteDashboardScreen(),
  };
}