// lib/api/exceptions/api_exception.dart

/// Clase base para todas las excepciones de la API.
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic details; // Puede contener el mapa de errores de validación, etc.

  ApiException(this.message, {this.statusCode, this.details});

  @override
  String toString() {
    String output = 'Error de la API: $message';
    if (statusCode != null) {
      output += ' (Código: $statusCode)';
    }
    // No incluyas 'details' en el toString() por defecto para el usuario,
    // ya que 'details' es para uso interno o depuración avanzada.
    return output;
  }
}

/// Excepción para errores de validación (código 400 Bad Request)
class ValidationException extends ApiException {
  final Map<String, List<String>> errors; // { "campo": ["mensaje1", "mensaje2"] }

  ValidationException(String message, this.errors, {int? statusCode, dynamic details})
      : super(message, statusCode: statusCode, details: details);

  @override
  String toString() {
    // Formatea los errores de validación para una mejor legibilidad.
    final buffer = StringBuffer('Datos inválidos:');
    errors.forEach((field, messages) {
      buffer.write('\n  - Campo "$field": ${messages.join(', ')}');
    });
    return buffer.toString();
  }
}

/// Excepción para recursos no encontrados (código 404 Not Found)
class NotFoundException extends ApiException {
  NotFoundException(String message, {int? statusCode, dynamic details})
      : super(message, statusCode: statusCode, details: details);

  @override
  String toString() {
    return 'No se encontró el recurso solicitado: $message';
  }
}

/// Excepción para errores del servidor (códigos 5xx)
class ServerException extends ApiException {
  ServerException(String message, {int? statusCode, dynamic details})
      : super('Hubo un problema en el servidor: $message', statusCode: statusCode, details: details);
}

/// Excepción para errores de red o conexión
class NetworkException extends ApiException {
  NetworkException(String message, {int? statusCode, dynamic details})
      : super('Problema de conexión: $message', statusCode: statusCode, details: details);
}
class UnauthorizedException extends ApiException {
  UnauthorizedException(String message, {int? statusCode, dynamic details})
      : super(message, statusCode: statusCode, details: details);

  @override
  String toString() {
    return 'Acceso no autorizado: $message. Por favor, inicia sesión de nuevo.';
  }
}

/// Excepción para errores generales inesperados
class UnknownApiException extends ApiException {
  UnknownApiException(String message, {int? statusCode, dynamic details})
      : super('Ha ocurrido un error inesperado: $message', statusCode: statusCode, details: details);
}