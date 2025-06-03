// lib/config.dart
import 'package:flutter/foundation.dart' show kIsWeb; // Para detectar si es web
import 'dart:io' show Platform; // Para detectar si es Android, iOS, etc.

class Config {
  // Define tu URL base de la API aquí, dependiendo de la plataforma.
  // Asumo que tu API siempre usa el prefijo '/api'.
  // Si no usa el prefijo '/api', deberás quitarlo de cada ruta en tus servicios.

  static final String apiUrl = _getApiUrl();

  static String _getApiUrl() {
    String baseUrl;

    if (kIsWeb) {
      // Si la aplicación se ejecuta en un navegador web
      baseUrl = 'http://127.0.0.1:3000';
    } else if (Platform.isAndroid) {
      // Si la aplicación se ejecuta en un emulador o dispositivo Android
      // 10.0.2.2 es la dirección especial para que el emulador de Android acceda a localhost de la máquina host
      baseUrl = 'http://10.0.2.2:3000';
    } else {
      // Para iOS (simulador o dispositivo), o escritorio (Windows, macOS, Linux)
      // 127.0.0.1 (localhost) generalmente funciona bien para estos.
      baseUrl = 'http://127.0.0.1:3000';
    }
    
    // Aquí puedes añadir el prefijo global de tu API si lo necesitas
    // Por ejemplo, si todas tus rutas de API son '/api/carreras', '/api/estudiantes', etc.
    // Si tus rutas son directamente '/carreras', '/estudiantes', no añadas esto.
    return '$baseUrl'; // <--- ¡AÑADE O QUITA '/api' SEGÚN CÓMO ESTÉN DEFINIDAS TUS RUTAS EN EL BACKEND!
  }
}