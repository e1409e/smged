import 'package:flutter/material.dart';
import 'package:smged/api/models/usuario.dart';
import 'package:smged/api/services/usuarios_service.dart';
import 'package:smged/layout/widgets/custom_colors.dart';
import 'forms/usuario_form_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UsuariosScreen extends StatefulWidget {
  const UsuariosScreen({super.key});

  @override
  State<UsuariosScreen> createState() => _UsuariosScreenState();
}

class _UsuariosScreenState extends State<UsuariosScreen> {
  final UsuariosService _service = UsuariosService();
  List<Usuario> _usuarios = [];
  List<Usuario> _filteredUsuarios = [];
  bool _isLoading = true;
  String? _error;
  final TextEditingController _searchController = TextEditingController();
  Set<String> _filtrosRol = {};
  String? _miCedula;
  int? _miIdUsuario;

  @override
  void initState() {
    super.initState();
    _fetchMiIdUsuario();
    _fetchUsuarios();
    _searchController.addListener(_filterUsuarios);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterUsuarios);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchMiCedula() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _miCedula = prefs.getString('cedula_usuario');
    });
  }

  Future<void> _fetchMiIdUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _miIdUsuario = prefs.getInt('id_usuario');
    });
  }

  Future<void> _fetchUsuarios() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data = await _service.obtenerUsuarios();
      setState(() {
        _usuarios = data;
        _filteredUsuarios = data;
      });
      _filterUsuarios();
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterUsuarios() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredUsuarios = _usuarios.where((usuario) {
        final matchesQuery = usuario.nombre.toLowerCase().contains(query) ||
            usuario.apellido.toLowerCase().contains(query) ||
            usuario.cedulaUsuario.toLowerCase().contains(query);
        final matchesRol = _filtrosRol.isEmpty || _filtrosRol.contains(usuario.rol);
        return matchesQuery && matchesRol;
      }).toList();
    });
  }

  void _showForm({Usuario? usuario}) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => UsuarioFormScreen(usuarioToEdit: usuario),
      ),
    );
    if (result == true) {
      // Si el usuario editado es el mismo que está en sesión, cerrar sesión
      if (usuario != null && usuario.cedulaUsuario == _miCedula) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('auth_token');
        await prefs.remove('user_role');
        await prefs.remove('cedula_usuario');
        if (mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
        }
        return;
      }
      _fetchUsuarios();
    }
  }

  // Cambia la función de eliminar para validar correctamente la cédula
  void _deleteUsuario(int idUsuario) async {
    if (idUsuario == _miIdUsuario) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Solo otro administrador puede eliminarte, no puedes eliminarte a ti mismo'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Usuario'),
        content: const Text('¿Estás seguro de eliminar este usuario?'),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.pop(context, false),
          ),
          TextButton(
            child: const Text('Eliminar', style: TextStyle(color: AppColors.error)),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await _service.eliminarUsuario(idUsuario);
      _fetchUsuarios();
    }
  }

  void _showPasswordDialog(Usuario usuario) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contraseña del usuario'),
        content: SelectableText(
          'Por seguridad, la contraseña no puede ser mostrada.\nSolicita al usuario que la restablezca si es necesario.',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            child: const Text('Cerrar'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  // Modifica el menú de acciones para pasar la cédula correcta
  void _showActionsMenu(Usuario usuario) {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Acciones'),
        children: [
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(context);
              _showForm(usuario: usuario);
            },
            child: Row(
              children: const [
                Icon(Icons.edit, color: AppColors.primary),
                SizedBox(width: 8),
                Text('Editar'),
              ],
            ),
          ),
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(context);
              _deleteUsuario(usuario.idUsuario);
            },
            child: Row(
              children: const [
                Icon(Icons.delete, color: AppColors.error),
                SizedBox(width: 8),
                Text('Eliminar'),
              ],
            ),
          ),
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(context);
              _showPasswordDialog(usuario);
            },
            child: Row(
              children: const [
                Icon(Icons.visibility, color: AppColors.primary),
                SizedBox(width: 8),
                Text('Ver contraseña'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Icon _iconoPorRol(String rol) {
    switch (rol.toLowerCase()) {
      case 'administrador':
        return const Icon(Icons.admin_panel_settings, size: 36, color: AppColors.primary);
      case 'psicologo':
        return const Icon(Icons.remove_red_eye, size: 36, color: AppColors.primary);
      case 'docente':
        return const Icon(Icons.menu_book, size: 36, color: AppColors.primary);
      default:
        return const Icon(Icons.person, size: 36, color: AppColors.primary);
    }
  }

  Widget _buildRoleChips() {
    final roles = ['administrador', 'psicologo', 'docente'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: roles.map((rol) {
        final isSelected = _filtrosRol.contains(rol);
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6.0),
          child: ChoiceChip(
            label: Text(
              rol[0].toUpperCase() + rol.substring(1),
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            selected: isSelected,
            selectedColor: AppColors.primary,
            backgroundColor: AppColors.surface,
            side: BorderSide(
              color: isSelected ? AppColors.primary : AppColors.greyLight,
              width: 1.5,
            ),
            onSelected: (selected) {
              setState(() {
                if (selected) {
                  _filtrosRol.add(rol);
                  if (_filtrosRol.length > 2) {
                    _filtrosRol.clear();
                  }
                } else {
                  _filtrosRol.remove(rol);
                }
                _filterUsuarios();
              });
            },
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool esEscritorio = MediaQuery.of(context).size.width > 700;
    final double cardWidth = esEscritorio ? 600 : 400;

    return Scaffold(
      appBar: AppBar(
        title: const Text('USUARIOS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        actionsIconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refrescar',
            onPressed: _fetchUsuarios,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : LayoutBuilder(
                  builder: (context, constraints) {
                    return Column(
                      children: [
                        const SizedBox(height: 24),
                        Center(
                          child: SizedBox(
                            width: cardWidth,
                            child: TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                hintText: 'Buscar por nombre, apellido o cédula...',
                                prefixIcon: const Icon(Icons.search),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                              ),
                              onChanged: (_) => _filterUsuarios(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildRoleChips(),
                        const SizedBox(height: 12),
                        Expanded(
                          child: _filteredUsuarios.isEmpty
                              ? const Center(child: Text('No se encontraron usuarios.'))
                              : ListView.separated(
                                  itemCount: _filteredUsuarios.length,
                                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                                  padding: const EdgeInsets.all(16),
                                  itemBuilder: (context, index) {
                                    final usuario = _filteredUsuarios[index];
                                    return Center(
                                      child: ConstrainedBox(
                                        constraints: BoxConstraints(
                                          maxWidth: cardWidth,
                                        ),
                                        child: Card(
                                          elevation: 6,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                                            child: ListTile(
                                              leading: _iconoPorRol(usuario.rol),
                                              title: Text('${usuario.nombre} ${usuario.apellido}'),
                                              subtitle: Text('Cédula: ${usuario.cedulaUsuario}\nRol: ${usuario.rol}'),
                                              isThreeLine: true,
                                              trailing: IconButton(
                                                icon: const Icon(Icons.settings, color: AppColors.primary),
                                                tooltip: 'Acciones',
                                                onPressed: () => _showActionsMenu(usuario),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    );
                  },
                ),
    );
  }
}