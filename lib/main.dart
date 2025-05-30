// lib/main.dart
import 'package:flutter/material.dart';
import 'package:smged/layout/widgets/custom_colors.dart';
import 'package:smged/routes.dart'; // Asegúrate de que esta línea exista y la ruta sea correcta

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
    setState(() {
      _isLoggedIn = true;
    });
  }

  void _handleLogout(BuildContext context) {
    setState(() {
      _isLoggedIn = false;
    });
    // Usamos pushReplacementNamed para ir a la ruta inicial manejada por routes.dart
    Navigator.of(context).pushReplacementNamed(AppRoutes.initialRoute);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
      // ¡Llama a la función directamente, sin prefijo de clase!
      routes: getApplicationRoutes(
        _isLoggedIn,
        _handleLoginSuccess,
        _handleLogout,
      ),
    );
  }
}