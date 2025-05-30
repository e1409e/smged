// lib/api/models/discapacidad.dart

/// Clase que representa una Discapacidad en el sistema.
/// Contiene el ID único de la discapacidad y su nombre.
class Discapacidad {
  final int idDiscapacidad;
  final String nombre;

  /// Constructor para crear una instancia de [Discapacidad].
  ///
  /// Requiere [idDiscapacidad] y [nombre].
  Discapacidad({
    required this.idDiscapacidad,
    required this.nombre,
  });

  factory Discapacidad.fromJson(Map<String, dynamic> json) {
    return Discapacidad(
      idDiscapacidad: json['discapacidad_id'] as int, // Mapea 'discapacidad_id' del JSON a 'idDiscapacidad'
      nombre: json['discapacidad'] as String, // Mapea 'discapacidad' del JSON a 'nombre'
    );
  }

  /// Método para convertir una instancia de [Discapacidad] a un mapa JSON.
  ///
  /// Esto es útil si necesitas enviar un objeto Discapacidad de vuelta a tu API,
  /// por ejemplo, para una operación de actualización.
  Map<String, dynamic> toJson() {
    return {
      'discapacidad_id': idDiscapacidad,
      'discapacidad': nombre,
    };
  }

  /// Sobreescribe el método toString para una mejor representación en depuración.
  @override
  String toString() {
    return 'Discapacidad(idDiscapacidad: $idDiscapacidad, nombre: $nombre)';
  }

  /// Sobreescribe el operador de igualdad (==) y hashCode para comparar objetos Discapacidad.
  ///
  /// Esto es útil, por ejemplo, para determinar si un objeto Discapacidad ya está
  /// en una lista o si dos objetos son el mismo. Es particularmente importante
  /// para el `DropdownButtonFormField` para que pueda identificar el ítem seleccionado
  /// correctamente por su valor.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Discapacidad &&
        other.idDiscapacidad == idDiscapacidad; // Solo compara por ID para la igualdad lógica
  }

  @override
  int get hashCode => idDiscapacidad.hashCode; // Solo usa el ID para el hashCode
}