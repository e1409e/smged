class HistorialMedico {
  final int idHistorialMedico;
  final int idEstudiante;
  final bool certificadoConapdis;
  final String informeMedico;
  final String tratamiento;
  final DateTime fechaCreacion;
  final DateTime fechaActualizacion;

  HistorialMedico({
    required this.idHistorialMedico,
    required this.idEstudiante,
    required this.certificadoConapdis,
    required this.informeMedico,
    required this.tratamiento,
    required this.fechaCreacion,
    required this.fechaActualizacion,
  });

  // Constructor factory para crear una instancia de HistorialMedico desde un Map (JSON)
  factory HistorialMedico.fromJson(Map<String, dynamic> json) {
    return HistorialMedico(
      idHistorialMedico: json['id_historialmedico'],
      idEstudiante: json['id_estudiante'],
      // Asegúrate de que los booleanos se manejen correctamente (la API de PostgreSQL a menudo retorna 't'/'f' o 1/0, si es el caso, ajusta)
      certificadoConapdis: json['certificado_conapdis'] is bool ? json['certificado_conapdis'] : json['certificado_conapdis'] == 't',
      informeMedico: json['informe_medico'],
      tratamiento: json['tratamiento'],
      fechaCreacion: DateTime.parse(json['fecha_creacion']),
      fechaActualizacion: DateTime.parse(json['fecha_actualizacion']),
    );
  }

  // Método para convertir una instancia de HistorialMedico a un Map (para enviar a la API)
  Map<String, dynamic> toJson() {
    return {
      'id_historialmedico': idHistorialMedico, // Podría no ser necesario para POST (crear) si es SERIAL en DB
      'id_estudiante': idEstudiante,
      'certificado_conapdis': certificadoConapdis,
      'informe_medico': informeMedico,
      'tratamiento': tratamiento,
      // No incluimos fechas de creación/actualización aquí, ya que la DB las maneja automáticamente
    };
  }

  // Método para convertir una instancia a un Map para la creación (sin id_historialmedico)
  Map<String, dynamic> toCreateJson() {
    return {
      'id_estudiante': idEstudiante,
      'certificado_conapdis': certificadoConapdis,
      'informe_medico': informeMedico,
      'tratamiento': tratamiento,
    };
  }
}