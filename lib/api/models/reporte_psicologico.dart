class ReportePsicologico {
  final int? idPsicologico;
  final int idEstudiante;
  final String motivoConsulta;
  final String sintesisDiagnostica;
  final String recomendaciones;

  // Campos derivados (pueden venir o no)
  final String? nombreEstudiante;
  final String? apellidoEstudiante;
  final String? cedulaEstudiante;

  ReportePsicologico({
    this.idPsicologico,
    required this.idEstudiante,
    required this.motivoConsulta,
    required this.sintesisDiagnostica,
    required this.recomendaciones,
    this.nombreEstudiante,
    this.apellidoEstudiante,
    this.cedulaEstudiante,
  });

  factory ReportePsicologico.fromJson(Map<String, dynamic> json) {
    return ReportePsicologico(
      idPsicologico: json['id_psicologico'],
      idEstudiante: json['id_estudiante'],
      motivoConsulta: json['motivo_consulta'] ?? '',
      sintesisDiagnostica: json['sintesis_diagnostica'] ?? '',
      recomendaciones: json['recomendaciones'] ?? '',
      // Permite ambos nombres de campo para compatibilidad
      nombreEstudiante: json['nombre_estudiante'] ?? json['nombre'],
      apellidoEstudiante: json['apellido_estudiante'] ?? json['apellido'],
      cedulaEstudiante: json['cedula_estudiante'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (idPsicologico != null) 'id_psicologico': idPsicologico,
      'id_estudiante': idEstudiante,
      'motivo_consulta': motivoConsulta,
      'sintesis_diagnostica': sintesisDiagnostica,
      'recomendaciones': recomendaciones,
    };
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'id_estudiante': idEstudiante,
      'motivo_consulta': motivoConsulta,
      'sintesis_diagnostica': sintesisDiagnostica,
      'recomendaciones': recomendaciones,
    };
  }
}