import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:smged/api/models/usuario.dart';
import 'package:smged/config.dart';

class UsuariosService {
  final String _baseUrl = '${Config.apiUrl}/usuarios';

  Future<List<Usuario>> obtenerUsuarios() async {
    final response = await http.get(Uri.parse(_baseUrl));
    if (response.statusCode == 200) {
      List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => Usuario.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar usuarios: ${response.statusCode} - ${response.body}');
    }
  }

  Future<void> crearUsuario(Usuario usuario, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/registrar'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'nombre': usuario.nombre,
        'apellido': usuario.apellido,
        'cedula_usuario': usuario.cedulaUsuario,
        'password': password,
        'rol': usuario.rol,
      }),
    );
    if (response.statusCode != 201) {
      throw Exception('Error al crear usuario: ${response.statusCode} - ${response.body}');
    }
  }

  Future<void> actualizarUsuario(Usuario usuario, {String? password}) async {
    final body = {
      'nombre': usuario.nombre,
      'apellido': usuario.apellido,
      'cedula_usuario': usuario.cedulaUsuario,
      'rol': usuario.rol,
    };
    if (password != null && password.isNotEmpty) {
      body['password'] = password;
    }
    final response = await http.put(
      Uri.parse('$_baseUrl/${usuario.idUsuario}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    );
    if (response.statusCode != 200) {
      throw Exception('Error al actualizar usuario: ${response.statusCode} - ${response.body}');
    }
  }

  Future<void> eliminarUsuario(int idUsuario) async {
    final response = await http.delete(Uri.parse('$_baseUrl/$idUsuario'));
    if (response.statusCode != 200) {
      throw Exception('Error al eliminar usuario: ${response.statusCode} - ${response.body}');
    }
  }
}