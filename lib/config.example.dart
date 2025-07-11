// lib/config.example.dart
// Este archivo sirve como plantilla para 'config.dart'.
// NO DEBE SUBIRSE AL CONTROL DE VERSIONES (Git).
// Se debe crear una copia de este archivo, renombrarla a 'config.dart' y personalizar las URLs.

import 'package:flutter/foundation.dart' show kIsWeb; // Importa para detectar si la aplicación se ejecuta en la web.
import 'dart:io' show Platform; // Importa para detectar la plataforma del dispositivo (Android, iOS, etc.).

class Config {
  // ===========================================================================
  // URLs de la API para diferentes entornos
  // ===========================================================================

  // URL de la API para el entorno de PRODUCCIÓN.
  // Esta URL es la que se utilizará cuando la aplicación se compile en modo 'release'
  // (por ejemplo, para subir a tiendas de aplicaciones o para despliegues finales).
  // Se debe reemplazar 'http://192.168.0.103:3000' con la URL real de la API en producción.
  static const String _url = 'http://192.168.0.103:3000';

  // ===========================================================================
  // Lógica para determinar la URL de la API en tiempo de ejecución
  // ===========================================================================

  // Variable final que contendrá la URL de la API que se utilizará.
  static final String apiUrl = _getApiUrl();

  /// Determina la URL de la API a utilizar basándose en el modo de compilación
  /// y la plataforma de ejecución.
  ///
  /// Retorna la URL de producción si la aplicación está en modo release.
  /// Retorna URLs de desarrollo específicas para web, emuladores o dispositivos físicos
  /// si la aplicación está en modo debug/profile.
  static String _getApiUrl() {
    // Detecta si la aplicación está compilada en modo de producción (release).
    // Esto es verdadero cuando se usa 'flutter build' o 'flutter run --release'.
    if (const bool.fromEnvironment('dart.vm.product')) {
      return _url; // Usa la URL de producción.
    }

    // --- Lógica para el modo de depuración (debug mode) o perfilación ---
    // En este modo, la aplicación se ejecuta localmente y necesita conectarse
    // a una instancia de la API también en desarrollo.

    if (kIsWeb) {
      // Si la aplicación se ejecuta en un navegador web en modo de desarrollo.
      // '127.0.0.1' (localhost) es la IP estándar para acceder a servicios
      // que se ejecutan en la misma máquina.
      // Si la API está en un servidor local accesible vía localhost (ej. con reenvío de puertos si es una VM),
      // '127.0.0.1:3000' en el navegador se mapeará a la API.
      return 'http://127.0.0.1:3000';
    } else if (Platform.isAndroid) {
      // Si la aplicación se ejecuta en un EMULADOR Android.
      // '10.0.2.2' es un alias especial del emulador que apunta al 'localhost'
      // de la máquina anfitriona. Si la API está en un servidor local accesible
      // desde la máquina anfitriona (ej. con reenvío de puertos si es una VM),
      // esto permitirá al emulador conectarse a la API a través de la máquina anfitriona.
      return 'http://10.0.2.2:3000';
    } else {
      // Para un SIMULADOR iOS (macOS), o aplicaciones de escritorio (Windows, macOS, Linux) en desarrollo.
      // '127.0.0.1' (localhost) se refiere a la máquina anfitriona.
      // Si la API está en un servidor local accesible vía localhost,
      // esto conectará el simulador/aplicación de escritorio con la API.
      return 'http://127.0.0.1:3000';
    }
  }
}
