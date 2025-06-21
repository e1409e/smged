// lib/config.dart
import 'package:flutter/foundation.dart' show kIsWeb; // Para detectar si es web
import 'dart:io' show Platform; // Para detectar si es Android, iOS, etc.

class Config {
  // URL de la API en Render.
  static const String _renderApiUrl = 'https://api-smged.onrender.com';


  static final String apiUrl = _getApiUrl();

  static String _getApiUrl() {
    // Cuando se compile la aplicación para producción (release mode), usara la URL de Render.
    // En Flutter, `kReleaseMode` es true cuando se compila con `--release`.
    if (const bool.fromEnvironment('dart.vm.product')) {
      return _renderApiUrl;
    }

    // --- en modo de depuración (debug mode) o perfilación, usa la URL local ---
    if (kIsWeb) {
      // Para la aplicación web en desarrollo (si estás ejecutando en el navegador)
      return 'http://127.0.0.1:3000';
    } else if (Platform.isAndroid) {
      // Para un emulador o dispositivo Android en desarrollo
      return 'http://10.0.2.2:3000';
    } else {
      // Para iOS (simulador o dispositivo), o escritorio (Windows, macOS, Linux) en desarrollo
      return 'http://127.0.0.1:3000';
    }
  }
}