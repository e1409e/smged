class Representante {
  final int? idRepresentante;
  final int idEstudiante;
  final String nombreRepre;
  final String parentesco;
  final String cedulaRepre;
  final String telefonoRepre;
  final String correoRepre;
  final String lugarNacimiento;
  final String fechaNacimiento;
  final String direccion;
  final String ocupacion;
  final String lugarTrabajo;
  final String estado;
  final String municipio;
  final String departamento;
  final String estadoCivil;

  // Campos opcionales para visualización
  final String? nombreEstudiante;
  final String? apellidoEstudiante;

  Representante({
    this.idRepresentante,
    required this.idEstudiante,
    required this.nombreRepre,
    required this.parentesco,
    required this.cedulaRepre,
    required this.telefonoRepre,
    required this.correoRepre,
    required this.lugarNacimiento,
    required this.fechaNacimiento,
    required this.direccion,
    required this.ocupacion,
    required this.lugarTrabajo,
    required this.estado,
    required this.municipio,
    required this.departamento,
    required this.estadoCivil,
    this.nombreEstudiante,
    this.apellidoEstudiante,
  });

  factory Representante.fromJson(Map<String, dynamic> json) {
    return Representante(
      idRepresentante: json['id_representante'],
      idEstudiante: json['id_estudiante'],
      nombreRepre: json['nombre_repre'],
      parentesco: json['parentesco'],
      cedulaRepre: json['cedula_repre'],
      telefonoRepre: json['telefono_repre'],
      correoRepre: json['correo_repre'],
      lugarNacimiento: json['lugar_nacimiento'],
      fechaNacimiento: json['fecha_nacimiento'],
      direccion: json['direccion'],
      ocupacion: json['ocupacion'],
      lugarTrabajo: json['lugar_trabajo'],
      estado: json['estado'],
      municipio: json['municipio'],
      departamento: json['departamento'],
      estadoCivil: json['estado_civil'],
      nombreEstudiante: json['nombre_estudiante'],
      apellidoEstudiante: json['apellido_estudiante'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (idRepresentante != null) 'id_representante': idRepresentante,
      'id_estudiante': idEstudiante,
      'nombre_repre': nombreRepre,
      'parentesco': parentesco,
      'cedula_repre': cedulaRepre,
      'telefono_repre': telefonoRepre,
      'correo_repre': correoRepre,
      'lugar_nacimiento': lugarNacimiento,
      'fecha_nacimiento': fechaNacimiento,
      'direccion': direccion,
      'ocupacion': ocupacion,
      'lugar_trabajo': lugarTrabajo,
      'estado': estado,
      'municipio': municipio,
      'departamento': departamento,
      'estado_civil': estadoCivil,
    };
  }
}