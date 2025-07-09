// lib/main.dart
import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart'; // ¡Esta línea se elimina!
import 'package:flutter/foundation.dart' show debugPrint;

import 'package:smged/layout/widgets/custom_colors.dart';
import 'package:smged/layout/screens/login_screen.dart';
import 'package:smged/layout/screens/home_screen.dart';
import 'package:smged/layout/screens/admin_dashboard_screen.dart';
import 'package:smged/layout/screens/docente_dashboard_screen.dart';
import 'package:smged/routes.dart' as app_routes;
import 'package:smged/api/services/auth_service.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

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
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    debugPrint('[_MyAppState] _checkLoginStatus: Iniciando verificación de estado de login...');
    final isLoggedInNow = await _authService.isLoggedIn();

    if (mounted) {
      if (_isLoggedIn != isLoggedInNow) {
        setState(() {
          _isLoggedIn = isLoggedInNow;
        });
        debugPrint('[_MyAppState] _checkLoginStatus: Estado de login actualizado a: $isLoggedInNow');
      } else {
        debugPrint('[_MyAppState] _checkLoginStatus: Estado de login sin cambios.');
      }
    } else {
      debugPrint('[_MyAppState] Widget no montado al verificar estado de login. No se actualiza el estado.');
    }
  }

  Future<void> _handleLoginSuccess(String? rol) async {
    debugPrint('[_MyAppState] _handleLoginSuccess: Login exitoso, rol recibido: $rol.');

    if (mounted) {
      setState(() {
        _isLoggedIn = true;
      });

      final targetRoute = _getDashboardRoute(rol);
      debugPrint('[_MyAppState] Navegando a dashboard: $targetRoute para el rol: $rol');
      navigatorKey.currentState?.pushNamedAndRemoveUntil(
        targetRoute,
        (Route<dynamic> route) => false,
      );
    } else {
      debugPrint('[_MyAppState] Widget no montado al manejar login exitoso. No se realiza navegación.');
    }
  }

  Future<void> _handleLogout() async {
    debugPrint('[_MyAppState] _handleLogout: Iniciando cierre de sesión. Llamando a AuthService.logout().');
    await _authService.logout();

    if (mounted) {
      setState(() {
        _isLoggedIn = false;
      });
      debugPrint('[_MyAppState] Procediendo con la navegación a /login después de logout.');
      navigatorKey.currentState?.pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
    } else {
      debugPrint('[_MyAppState] Widget no montado. No se realiza la navegación después de logout.');
    }
    debugPrint('[_MyAppState] _handleLogout: Finalizado.');
  }

  String _getDashboardRoute(String? role) {
    debugPrint('[_MyAppState] _getDashboardRoute: Determinando ruta para el rol: $role');
    switch (role?.toLowerCase()) {
      case 'administrador':
        return '/admin';
      case 'psicologo':
        return '/home';
      case 'docente':
        return '/docente';
      default:
        debugPrint('[_MyAppState] Rol desconocido o nulo: $role. Redirigiendo a /login por defecto.');
        return '/login';
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('[_MyAppState] build() llamado. _isLoggedIn: $_isLoggedIn');
    return MaterialApp(
      navigatorKey: navigatorKey,
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

  Widget _getScreenBasedOnAuthStatus() {
    if (!_isLoggedIn) {
      debugPrint('[_MyAppState] _getScreenBasedOnAuthStatus: _isLoggedIn es false. Mostrando LoginScreen.');
      return LoginScreen(onLoginSuccess: _handleLoginSuccess);
    }

    return FutureBuilder<String?>(
      future: _authService.getUserRole(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          debugPrint('[_MyAppState] _getScreenBasedOnAuthStatus: Esperando rol de usuario...');
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }

        if (snapshot.hasError) {
          debugPrint('[_MyAppState] _getScreenBasedOnAuthStatus: Error al obtener rol: ${snapshot.error}');
          return LoginScreen(onLoginSuccess: _handleLoginSuccess);
        }

        final userRole = snapshot.data;
        debugPrint('[_MyAppState] _getScreenBasedOnAuthStatus: Rol obtenido: $userRole');

        switch (userRole?.toLowerCase()) {
          case 'administrador':
            return AdminDashboardScreen(onLogout: _handleLogout);
          case 'psicologo':
            return HomeScreen(onLogout: _handleLogout);
          case 'docente':
            return DocenteDashboardScreen(onLogout: _handleLogout);
          default:
            debugPrint('[_MyAppState] _getScreenBasedOnAuthStatus: Rol desconocido o nulo ($userRole). Redirigiendo a LoginScreen.');
            return LoginScreen(onLoginSuccess: _handleLoginSuccess);
        }
      },
    );
  }
}

final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();