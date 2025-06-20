class Incidencia {
  final int? idIncidencia;
  final int idEstudiante;
  final String horaIncidente;
  final String fechaIncidente; // formato 'YYYY-MM-DD' o DateTime.parse(fechaIncidente)
  final String lugarIncidente;
  final String descripcionIncidente;
  final String acuerdos;
  final String observaciones;

  // Datos del estudiante (opcionales)
  final String? nombreEstudiante;
  final String? apellidoEstudiante;
  final String? cedulaEstudiante;

  Incidencia({
    this.idIncidencia,
    required this.idEstudiante,
    required this.horaIncidente,
    required this.fechaIncidente,
    required this.lugarIncidente,
    required this.descripcionIncidente,
    required this.acuerdos,
    required this.observaciones,
    this.nombreEstudiante,
    this.apellidoEstudiante,
    this.cedulaEstudiante,
  });

  factory Incidencia.fromJson(Map<String, dynamic> json) {
    return Incidencia(
      idIncidencia: json['id_incidencia'],
      idEstudiante: json['id_estudiante'],
      horaIncidente: json['hora_incidente'],
      fechaIncidente: json['fecha_incidente'],
      lugarIncidente: json['lugar_incidente'],
      descripcionIncidente: json['descripcion_incidente'],
      acuerdos: json['acuerdos'],
      observaciones: json['observaciones'],
      nombreEstudiante: json['nombre_estudiante'],
      apellidoEstudiante: json['apellido_estudiante'],
      cedulaEstudiante: json['cedula_estudiante'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (idIncidencia != null) 'id_incidencia': idIncidencia,
      'id_estudiante': idEstudiante,
      'hora_incidente': horaIncidente,
      'fecha_incidente': fechaIncidente,
      'lugar_incidente': lugarIncidente,
      'descripcion_incidente': descripcionIncidente,
      'acuerdos': acuerdos,
      'observaciones': observaciones,
    };
  }
}