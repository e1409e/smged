// lib/main.dart
import 'package:flutter/material.dart';
import 'package:smged/layout/widgets/custom_colors.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // Importa este paquete

// Importa todas las pantallas que serán la 'home' inicial o dashboards
import 'package:smged/layout/screens/login_screen.dart';
import 'package:smged/layout/screens/home_screen.dart'; // Para el rol de Psicólogo
import 'package:smged/layout/screens/admin_dashboard_screen.dart'; // Para el rol de Administrador
import 'package:smged/layout/screens/docente_dashboard_screen.dart'; // Para el rol de Docente

// Importa tu archivo de rutas con un alias para evitar conflictos
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
          return const AdminDashboardScreen();
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
    debugPrint('[_MyAppState] build() llamado. _isLoggedIn es: $_isLoggedIn, _userRole es: $_userRole');

    return MaterialApp(
      title: 'SMGED App',
      debugShowCheckedModeBanner: false,
      // --- Configuración de localización para español ---
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate, // Proporciona traducciones para widgets Material
        GlobalWidgetsLocalizations.delegate,  // Proporciona traducciones para widgets genéricos
        GlobalCupertinoLocalizations.delegate, // Proporciona traducciones para widgets de estilo iOS
        // Aquí puedes añadir tus propios delegados si tienes traducciones personalizadas
      ],
      supportedLocales: const [
        Locale('en', ''), // Soporte para inglés
        Locale('es', ''), // Soporte para español
      ],
      // Opcional: Si quieres forzar el idioma a español sin depender de la configuración del dispositivo
      // locale: const Locale('es', ''),
      //
      // Opcional: Callback para resolver el locale si el del dispositivo no está en supportedLocales
      localeResolutionCallback: (locale, supportedLocales) {
        if (locale != null && supportedLocales.contains(locale)) {
          return locale;
        }
        // Si el dispositivo no tiene un idioma compatible, usa español por defecto
        return const Locale('es', '');
      },
      // --- Fin de configuración de localización ---
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
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: AppColors.primary,
        ),
      ),
      home: _getScreenBasedOnAuthStatus(),
      routes: app_routes.getApplicationRoutes(),
    );
  }
}