class HistorialMedico {
  final int? idHistorialMedico;
  final int idEstudiante;
  /// Ruta al archivo de certificado CONAPDIS (pdf, doc, imagen, etc)
  final String certificadoConapdis;
  /// Ruta al archivo de informe médico (pdf, doc, imagen, etc)
  final String informeMedico;
  /// Ruta al archivo de tratamiento (pdf, doc, imagen, etc)
  final String tratamiento;
  final String? nombreEstudiante;
  final String? apellidoEstudiante;
  final String? cedulaEstudiante;

  HistorialMedico({
    this.idHistorialMedico,
    required this.idEstudiante,
    required this.certificadoConapdis,
    required this.informeMedico,
    required this.tratamiento,
    this.nombreEstudiante,
    this.apellidoEstudiante,
    this.cedulaEstudiante,
  });

  factory HistorialMedico.fromJson(Map<String, dynamic> json) {
    return HistorialMedico(
      idHistorialMedico: json['id_historialmedico'],
      idEstudiante: json['id_estudiante'],
      certificadoConapdis: json['certificado_conapdis'] ?? '',
      informeMedico: json['informe_medico'] ?? '',
      tratamiento: json['tratamiento'] ?? '',
      nombreEstudiante: json['nombre_estudiante'],
      apellidoEstudiante: json['apellido_estudiante'],
      cedulaEstudiante: json['cedula_estudiante'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (idHistorialMedico != null) 'id_historialmedico': idHistorialMedico,
      'id_estudiante': idEstudiante,
      'certificado_conapdis': certificadoConapdis,
      'informe_medico': informeMedico,
      'tratamiento': tratamiento,
      'nombre_estudiante': nombreEstudiante,
      'apellido_estudiante': apellidoEstudiante,
      'cedula_estudiante': cedulaEstudiante,
    };
  }

  /// Para crear (sin id_historialmedico ni campos derivados)
  Map<String, dynamic> toCreateJson() {
    return {
      'id_estudiante': idEstudiante,
      'certificado_conapdis': certificadoConapdis,
      'informe_medico': informeMedico,
      'tratamiento': tratamiento,
    };
  }
}
