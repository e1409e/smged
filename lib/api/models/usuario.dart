class Usuario {
  final int idUsuario;
  final String nombre;
  final String apellido;
  final String cedulaUsuario;
  final String rol;

  Usuario({
    required this.idUsuario,
    required this.nombre,
    required this.apellido,
    required this.cedulaUsuario,
    required this.rol,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      idUsuario: json['id_usuario'],
      nombre: json['nombre'],
      apellido: json['apellido'],
      cedulaUsuario: json['cedula_usuario'],
      rol: json['rol'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_usuario': idUsuario,
      'nombre': nombre,
      'apellido': apellido,
      'cedula_usuario': cedulaUsuario,
      'rol': rol,
    };
  }
}