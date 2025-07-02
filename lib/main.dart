// lib/main.dart
import 'package:flutter/material.dart';
import 'package:smged/layout/widgets/custom_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:smged/layout/screens/login_screen.dart';
import 'package:smged/layout/screens/home_screen.dart';
import 'package:smged/layout/screens/admin_dashboard_screen.dart';
import 'package:smged/layout/screens/docente_dashboard_screen.dart';
import 'package:smged/routes.dart' as app_routes;

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
  String? _userRole;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    debugPrint('[_MyAppState] _checkLoginStatus: Iniciando verificación de estado de login...');
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final role = prefs.getString('user_role');

    if (token != null && token.isNotEmpty && role != null && role.isNotEmpty) {
      debugPrint('[_MyAppState] _checkLoginStatus: Token y rol encontrados. Estableciendo _isLoggedIn a true, rol: $role');
      setState(() {
        _isLoggedIn = true;
        _userRole = role;
      });
    } else {
      debugPrint('[_MyAppState] _checkLoginStatus: No se encontró token o rol. Estableciendo _isLoggedIn a false.');
      setState(() {
        _isLoggedIn = false;
        _userRole = null;
      });
    }
  }

  Future<void> _handleLoginSuccess(String? rol) async {
    debugPrint('[_MyAppState] _handleLoginSuccess: Login exitoso, rol recibido: $rol. Guardando rol y actualizando estado.');
    final prefs = await SharedPreferences.getInstance();
    if (rol != null) {
      await prefs.setString('user_role', rol);
    }
    setState(() {
      _isLoggedIn = true;
      _userRole = rol;
    });
    debugPrint('[_MyAppState] _isLoggedIn ahora es: $_isLoggedIn, _userRole: $_userRole');
  }

  Future<void> _handleLogout() async {
    debugPrint('[_MyAppState] _handleLogout: Iniciando cierre de sesión. Limpiando SharedPreferences.');
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_role');
    setState(() {
      _isLoggedIn = false;
      _userRole = null;
    });
    debugPrint('[_MyAppState] _isLoggedIn ahora es: $_isLoggedIn, _userRole: $_userRole. Forzando reconstrucción.');
  }

  Widget _getScreenBasedOnAuthStatus() {
    if (_isLoggedIn) {
      switch (_userRole?.toLowerCase()) {
        case 'administrador':
          return AdminDashboardScreen(onLogout: _handleLogout);
        case 'psicologo':
          return HomeScreen(onLogout: _handleLogout);
        case 'docente':
          return DocenteDashboardScreen(onLogout: _handleLogout);
        default:
          debugPrint('[_MyAppState] Rol desconocido: $_userRole. Redirigiendo a LoginScreen por defecto.');
          return LoginScreen(onLoginSuccess: _handleLoginSuccess);
      }
    } else {
      return LoginScreen(onLoginSuccess: _handleLoginSuccess);
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('[_MyAppState] build() llamado. _isLoggedIn: $_isLoggedIn, _userRole: $_userRole');
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary).copyWith(
          primary: AppColors.primary,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.backgroundSystem, 
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
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: AppColors.primary,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => _getScreenBasedOnAuthStatus(),
        '/login': (context) => LoginScreen(onLoginSuccess: _handleLoginSuccess),
        '/admin': (context) => AdminDashboardScreen(onLogout: _handleLogout),
        '/home': (context) => HomeScreen(onLogout: _handleLogout),
        '/docente': (context) => DocenteDashboardScreen(onLogout: _handleLogout),
        ...app_routes.getApplicationRoutes(),
      },
      navigatorObservers: [routeObserver],
    );
  }
}

final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();