// lib/main.dart
import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart'; // Ya eliminada, no la necesitamos aquí
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:smged/layout/widgets/custom_colors.dart';
import 'package:smged/layout/screens/login_screen.dart';
import 'package:smged/layout/screens/home_screen.dart';
import 'package:smged/layout/screens/admin_dashboard_screen.dart';
import 'package:smged/layout/screens/docente_dashboard_screen.dart';
import 'package:smged/routes.dart' as app_routes;
import 'package:smged/api/services/auth_service.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());

  // Configuración de la ventana
  doWhenWindowReady(() {
    const initialSize = Size(1000, 700); // Define el tamaño inicial deseado
    appWindow.minSize = initialSize; // Establece el tamaño mínimo
    appWindow.maxSize = initialSize; // Establece el tamaño máximo (igual al mínimo)
    appWindow.size = initialSize;   // Establece el tamaño de inicio
    
    appWindow.title = "SMGED";      // Opcional: define el título de la ventana

    // La ventana no será redimensionable porque minSize == maxSize.
    // Esto hace que los botones de maximizar/minimizar sean inactivos o no funcionales.
    
    appWindow.show(); // Inicia la ventana. Por defecto bitsdojo_window la centrará.
    // Si quieres ser explícito para centrar:
    // appWindow.center();
  });
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  bool _isLoggedIn = false;
  final AuthService _authService = AuthService();

  // --- NUEVO: Duración máxima de la sesión inactiva (ejemplo: 30 minutos) ---
  static const Duration _sessionTimeout = Duration(
    minutes: 1,
  ); // Puedes ajustar esto

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(
      this,
    ); // Añadir el observador del ciclo de vida
    _initializeApp(); // Llamar a la función de inicialización
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // Remover el observador
    super.dispose();
  }

  // --- Manejar cambios en el ciclo de vida de la app ---
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    debugPrint('[_MyAppState] didChangeAppLifecycleState: $state');
    if (state == AppLifecycleState.paused) {
      // La app se va a segundo plano o se está cerrando
      _authService
          .updateLastActivityTime(); // Actualizar el timestamp de última actividad
      debugPrint(
        '[_MyAppState] App pausada. Timestamp de actividad actualizado.',
      );
    } else if (state == AppLifecycleState.resumed) {
      // La app vuelve a primer plano
      debugPrint(
        '[_MyAppState] App reanudada. Verificando estado de login y caducidad.',
      );
      _checkLoginStatus(); // Volver a verificar el estado de login y la caducidad
    }
  }

  // --- Función de inicialización asíncrona para manejar la carga inicial ---
  Future<void> _initializeApp() async {
    await _checkLoginStatus(); // Ejecutar la comprobación de login/caducidad
  }

  Future<void> _checkLoginStatus() async {
    debugPrint(
      '[_MyAppState] _checkLoginStatus: Iniciando verificación de estado de login...',
    );
    final isLoggedInNow = await _authService.isLoggedIn();
    final currentToken = await _authService.getAuthToken();
    final currentRole = await _authService.getUserRole();
    final lastActivity = await _authService
        .getLastActivityTime(); // <-- ¡NUEVO: Obtener el timestamp!

    debugPrint(
      '[_MyAppState] DEBUG: Token al iniciar: ${currentToken != null && currentToken.isNotEmpty ? "EXISTE" : "NO EXISTE"}',
    );
    debugPrint('[_MyAppState] DEBUG: Rol al iniciar: $currentRole');
    debugPrint(
      '[_MyAppState] DEBUG: Última actividad registrada: $lastActivity',
    );

    bool shouldLogout = false;
    if (isLoggedInNow) {
      if (lastActivity != null) {
        final now = DateTime.now();
        final difference = now.difference(lastActivity);
        if (difference > _sessionTimeout) {
          debugPrint(
            '[_MyAppState] DEBUG: Sesión expirada por inactividad (${difference.inMinutes} minutos). Forzando cierre de sesión.',
          );
          shouldLogout = true;
        } else {
          debugPrint(
            '[_MyAppState] DEBUG: Sesión activa y dentro del timeout (${difference.inMinutes} minutos).',
          );
        }
      } else {
        // Esto podría ocurrir si el usuario se logueó antes de implementar _lastActivityTimeKey
        // o si hubo un error al guardar el timestamp. Forzar logout para limpiar.
        debugPrint(
          '[_MyAppState] DEBUG: Sesión activa pero sin timestamp de última actividad. Forzando cierre de sesión para limpiar.',
        );
        shouldLogout = true;
      }
    }

    if (shouldLogout) {
      await _authService.logout(); // Llama a logout para limpiar todo
      if (mounted) {
        setState(() {
          _isLoggedIn =
              false; // Actualiza el estado para que la UI refleje el logout
        });
      }
      debugPrint(
        '[_MyAppState] _checkLoginStatus: Sesión cerrada por caducidad. Redirigiendo a LoginScreen.',
      );
      // Forzar la navegación al login si la sesión caducó
      navigatorKey.currentState?.pushNamedAndRemoveUntil(
        '/login',
        (Route<dynamic> route) => false,
      );
    } else {
      if (mounted) {
        if (_isLoggedIn != isLoggedInNow) {
          setState(() {
            _isLoggedIn = isLoggedInNow;
          });
          debugPrint(
            '[_MyAppState] _checkLoginStatus: Estado de login actualizado a: $isLoggedInNow',
          );
        } else {
          debugPrint(
            '[_MyAppState] _checkLoginStatus: Estado de login sin cambios (ya era $_isLoggedIn).',
          );
        }
      } else {
        debugPrint(
          '[_MyAppState] Widget no montado al verificar estado de login. No se actualiza el estado.',
        );
      }
    }
  }

  Future<void> _handleLoginSuccess(String? rol) async {
    debugPrint(
      '[_MyAppState] _handleLoginSuccess: Login exitoso, rol recibido: $rol.',
    );

    if (mounted) {
      setState(() {
        _isLoggedIn = true;
      });

      final targetRoute = _getDashboardRoute(rol);
      debugPrint(
        '[_MyAppState] Navegando a dashboard: $targetRoute para el rol: $rol',
      );
      navigatorKey.currentState?.pushNamedAndRemoveUntil(
        targetRoute,
        (Route<dynamic> route) => false,
      );
    } else {
      debugPrint(
        '[_MyAppState] Widget no montado al manejar login exitoso. No se realiza navegación.',
      );
    }
  }

  Future<void> _handleLogout() async {
    debugPrint(
      '[_MyAppState] _handleLogout: Iniciando cierre de sesión. Llamando a AuthService.logout().',
    );
    await _authService.logout();

    if (mounted) {
      setState(() {
        _isLoggedIn = false;
      });
      debugPrint(
        '[_MyAppState] Procediendo con la navegación a /login después de logout.',
      );
      navigatorKey.currentState?.pushNamedAndRemoveUntil(
        '/login',
        (Route<dynamic> route) => false,
      );
    } else {
      debugPrint(
        '[_MyAppState] Widget no montado. No se realiza la navegación después de logout.',
      );
    }
    debugPrint('[_MyAppState] _handleLogout: Finalizado.');
  }

  String _getDashboardRoute(String? role) {
    final lowerCaseRole = role?.toLowerCase();
    debugPrint(
      '[_MyAppState] _getDashboardRoute: Determinando ruta para el rol: $lowerCaseRole',
    );
    switch (lowerCaseRole) {
      case 'administrador':
        return '/admin';
      case 'psicologo':
        return '/home';
      case 'docente':
        return '/docente';
      default:
        debugPrint(
          '[_MyAppState] Rol desconocido o nulo: $lowerCaseRole. Redirigiendo a /login por defecto.',
        );
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
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
        ).copyWith(primary: AppColors.primary),
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.backgroundSystem,
        inputDecorationTheme: InputDecorationTheme(
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.primary, width: 2.0),
            borderRadius: BorderRadius.circular(5.0),
          ),
          labelStyle: TextStyle(color: Colors.grey[600]),
          floatingLabelStyle: TextStyle(color: AppColors.primary),
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
        '/docente': (context) =>
            DocenteDashboardScreen(onLogout: _handleLogout),
        ...app_routes.getApplicationRoutes(),
      },
      navigatorObservers: [routeObserver],
    );
  }

  Widget _getScreenBasedOnAuthStatus() {
    if (!_isLoggedIn) {
      debugPrint(
        '[_MyAppState] _getScreenBasedOnAuthStatus: _isLoggedIn es false. Mostrando LoginScreen.',
      );
      return LoginScreen(onLoginSuccess: _handleLoginSuccess);
    }

    return FutureBuilder<String?>(
      future: _authService.getUserRole(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          debugPrint(
            '[_MyAppState] _getScreenBasedOnAuthStatus: Esperando rol de usuario...',
          );
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }

        if (snapshot.hasError) {
          debugPrint(
            '[_MyAppState] _getScreenBasedOnAuthStatus: Error al obtener rol: ${snapshot.error}',
          );
          return LoginScreen(onLoginSuccess: _handleLoginSuccess);
        }

        final userRole = snapshot.data;
        debugPrint(
          '[_MyAppState] _getScreenBasedOnAuthStatus: Rol obtenido de SharedPreferences: "$userRole"',
        );

        final targetRoute = _getDashboardRoute(userRole);
        debugPrint(
          '[_MyAppState] _getScreenBasedOnAuthStatus: Ruta objetivo DETERMINADA: "$targetRoute"',
        );

        switch (targetRoute) {
          case '/admin':
            debugPrint(
              '[_MyAppState] _getScreenBasedOnAuthStatus: Retornando AdminDashboardScreen.',
            );
            return AdminDashboardScreen(onLogout: _handleLogout);
          case '/home':
            debugPrint(
              '[_MyAppState] _getScreenBasedOnAuthStatus: Retornando HomeScreen (Psicologo).',
            );
            return HomeScreen(onLogout: _handleLogout);
          case '/docente':
            debugPrint(
              '[_MyAppState] _getScreenBasedOnAuthStatus: Retornando DocenteDashboardScreen.',
            );
            return DocenteDashboardScreen(onLogout: _handleLogout);
          case '/login':
          default:
            debugPrint(
              '[_MyAppState] _getScreenBasedOnAuthStatus: Retornando LoginScreen (rol no reconocido o nulo).',
            );
            return LoginScreen(onLoginSuccess: _handleLoginSuccess);
        }
      },
    );
  }
}

final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();
