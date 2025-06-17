class Facultad {
  final int idFacultad;
  final String facultad;
  final String siglas;

  Facultad({
    required this.idFacultad,
    required this.facultad,
    required this.siglas,
  });

  factory Facultad.fromJson(Map<String, dynamic> json) {
    return Facultad(
      idFacultad: json['id_facultad'] as int,
      facultad: (json['facultad'] as String).trim(),
      siglas: (json['siglas'] as String).trim(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_facultad': idFacultad,
      'facultad': facultad,
      'siglas': siglas,
    };
  }
}