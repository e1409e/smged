// lib/main.dart
import 'package:flutter/material.dart';
import 'package:smged/layout/widgets/custom_colors.dart';
import 'package:smged/routes.dart'; // Asegúrate de que esta línea exista y la ruta sea correcta
import 'package:flutter/foundation.dart' show debugPrint; // Importa debugPrint

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isLoggedIn = false;

  void _handleLoginSuccess() {
    debugPrint('[_MyAppState] _handleLoginSuccess llamado. Cambiando _isLoggedIn a true.');
    setState(() {
      _isLoggedIn = true;
    });
    debugPrint('[_MyAppState] _isLoggedIn ahora es: $_isLoggedIn');
    // NO ES NECESARIO NAVEGAR AQUÍ. El cambio de _isLoggedIn
    // hará que MaterialApp se reconstruya y reevalúe su initialRoute.
  }

  void _handleLogout(BuildContext context) {
    debugPrint('[_MyAppState] _handleLogout llamado. Cambiando _isLoggedIn a false.');
    setState(() {
      _isLoggedIn = false;
    });
    debugPrint('[_MyAppState] _isLoggedIn ahora es: $_isLoggedIn. Navegando a initialRoute (LoginScreen).');
    // Esta navegación es correcta para limpiar la pila y asegurar que se vea el LoginScreen.
    Navigator.of(context).pushReplacementNamed(AppRoutes.initialRoute);
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('[_MyAppState] build() llamado. _isLoggedIn es: $_isLoggedIn');

    // ¡Importante! Añadir una llave al MaterialApp que cambie según el estado de login.
    // Esto fuerza a Flutter a reconstruir el MaterialApp y, por lo tanto, reevaluar sus rutas.
    return MaterialApp(
      key: ValueKey(_isLoggedIn), // La clave cambia si el estado de login cambia
      title: 'SMGED App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary).copyWith(
          primary: AppColors.primary,
        ),
        useMaterial3: true,
        inputDecorationTheme: InputDecorationTheme(
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: AppColors.primary,
              width: 2.0,
            ),
            borderRadius: BorderRadius.circular(5.0),
          ),
          labelStyle: TextStyle(
            color: Colors.grey[600],
          ),
          floatingLabelStyle: TextStyle(
            color: AppColors.primary,
          ),
        ),
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: AppColors.primary,
        ),
      ),
      initialRoute: AppRoutes.initialRoute,
      // Pasa el estado y los callbacks a la función que define tus rutas
      routes: getApplicationRoutes(
        _isLoggedIn,
        _handleLoginSuccess,
        _handleLogout,
      ),
    );
  }
}