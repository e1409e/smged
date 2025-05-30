// lib/routes.dart
import 'package:flutter/material.dart';
import 'package:smged/layout/screens/login_screen.dart'; // Asegúrate de que esta ruta sea correcta
import 'package:smged/layout/screens/home_screen.dart'; // Asegúrate de que esta ruta sea correcta
import 'package:smged/layout/screens/estudiantes_screen.dart'; // Asegúrate de que esta ruta sea correcta
import 'package:smged/layout/screens/forms/estudiante_form_screen.dart'; // ¡La ruta a tu formulario de estudiante!

/// Una clase que contiene las constantes de las rutas de tu aplicación.
/// Usar constantes ayuda a prevenir errores tipográficos y facilita refactorizar.
class AppRoutes {
  static const String initialRoute = '/'; // Ruta de inicio de la aplicación
  static const String loginRoute = '/login'; // Ruta para la pantalla de login
  static const String homeRoute = '/home'; // Ruta para la pantalla principal (home)
  static const String estudiantesList = '/estudiantes'; // Ruta para la lista de estudiantes
  static const String estudianteForm = '/estudianteForm'; // Ruta para el formulario de estudiante
}

/// Función de nivel superior que devuelve el mapa de todas las rutas de la aplicación.
/// Recibe el estado de autenticación y los callbacks para que la ruta inicial
/// pueda decidir qué pantalla mostrar (Login o Home).
Map<String, WidgetBuilder> getApplicationRoutes(
  bool isLoggedIn, // Indica si el usuario está logueado
  VoidCallback onLoginSuccess, // Callback cuando el login es exitoso
  void Function(BuildContext) onLogout, // Callback para cerrar sesión
) {
  return <String, WidgetBuilder>{
    // La ruta inicial de la aplicación.
    // Decide entre LoginScreen o HomeScreen basándose en el estado de isLoggedIn.
    AppRoutes.initialRoute: (BuildContext context) => isLoggedIn
        ? HomeScreen(onLogout: () => onLogout(context))
        : LoginScreen(onLoginSuccess: onLoginSuccess),

    // Ruta explícita para la pantalla de estudiantes.
    AppRoutes.estudiantesList: (BuildContext context) => const EstudiantesScreen(),

    // Ruta explícita para el formulario de estudiante.
    AppRoutes.estudianteForm: (BuildContext context) => const EstudianteFormScreen(),

    // Opcional: Si necesitaras navegar directamente a login o home desde otro lugar
    // (aparte del flujo inicial), podrías definirlas aquí también:
    // AppRoutes.loginRoute: (BuildContext context) => LoginScreen(onLoginSuccess: onLoginSuccess),
    // AppRoutes.homeRoute: (BuildContext context) => HomeScreen(onLogout: () => onLogout(context)),
  };
}