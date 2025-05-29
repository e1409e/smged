// lib/main.dart
import 'package:flutter/material.dart';
import 'package:smged/layout/screens/login_screen.dart';
import 'package:smged/layout/screens/home_screen.dart';
import 'package:smged/layout/widgets/custom_colors.dart';
import 'package:smged/layout/screens/estudiantes_screen.dart';

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
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => LoginScreen(onLoginSuccess: _handleLoginSuccess)),
      (Route<dynamic> route) => false,
    );
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
      initialRoute: '/',
      routes: {
        '/': (context) => _isLoggedIn
            ? HomeScreen(onLogout: () => _handleLogout(context))
            : LoginScreen(onLoginSuccess: _handleLoginSuccess),
        '/estudiantes': (context) => const EstudiantesScreen(),
      },
    );
  }
}