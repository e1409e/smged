import 'package:flutter/material.dart';
import 'package:smged/api/models/usuario.dart';
import 'package:smged/api/services/usuarios_service.dart';
import 'package:smged/layout/widgets/custom_colors.dart';

class UsuarioFormScreen extends StatefulWidget {
  final Usuario? usuarioToEdit;

  const UsuarioFormScreen({super.key, this.usuarioToEdit});

  @override
  State<UsuarioFormScreen> createState() => _UsuarioFormScreenState();
}

class _UsuarioFormScreenState extends State<UsuarioFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _apellidoController = TextEditingController();
  final TextEditingController _cedulaController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _selectedRol;
  bool _isSaving = false;

  final List<String> _roles = ['administrador', 'psicologo', 'docente'];

  @override
  void initState() {
    super.initState();
    if (widget.usuarioToEdit != null) {
      _nombreController.text = widget.usuarioToEdit!.nombre;
      _apellidoController.text = widget.usuarioToEdit!.apellido;
      _cedulaController.text = widget.usuarioToEdit!.cedulaUsuario;
      _selectedRol = widget.usuarioToEdit!.rol;
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _cedulaController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _save() async {
    if (!_formKey.currentState!.validate() || _selectedRol == null) return;
    setState(() => _isSaving = true);

    final service = UsuariosService();
    try {
      if (widget.usuarioToEdit == null) {
        await service.crearUsuario(
          Usuario(
            idUsuario: 0,
            nombre: _nombreController.text,
            apellido: _apellidoController.text,
            cedulaUsuario: _cedulaController.text,
            rol: _selectedRol!,
          ),
          _passwordController.text,
        );
      } else {
        await service.actualizarUsuario(
          Usuario(
            idUsuario: widget.usuarioToEdit!.idUsuario,
            nombre: _nombreController.text,
            apellido: _apellidoController.text,
            cedulaUsuario: _cedulaController.text,
            rol: _selectedRol!,
          ),
          password: _passwordController.text.isNotEmpty ? _passwordController.text : null,
        );
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool esEscritorio = MediaQuery.of(context).size.width > 700;
    final double formWidth = esEscritorio ? 400 : MediaQuery.of(context).size.width * 0.98;

    final bool isEditing = widget.usuarioToEdit != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'EDITAR USUARIO' : 'REGISTRAR USUARIO', style: TextStyle(fontWeight: FontWeight.bold),),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textTitle,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Card(
            elevation: 8,
            margin: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Container(
              width: formWidth,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Título dentro de la card
                    Text(
                      isEditing ? 'Editando usuario' : 'Agregando Usuario',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _nombreController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                      ),
                      validator: (v) => v == null || v.isEmpty ? 'Campo requerido' : null,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _apellidoController,
                      decoration: const InputDecoration(
                        labelText: 'Apellido',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                      ),
                      validator: (v) => v == null || v.isEmpty ? 'Campo requerido' : null,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _cedulaController,
                      decoration: const InputDecoration(
                        labelText: 'Cédula',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                      ),
                      validator: (v) => v == null || v.isEmpty ? 'Campo requerido' : null,
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: _selectedRol,
                      items: _roles
                          .map((rol) => DropdownMenuItem(
                                value: rol,
                                child: Text(rol[0].toUpperCase() + rol.substring(1)),
                              ))
                          .toList(),
                      onChanged: (rol) => setState(() => _selectedRol = rol),
                      decoration: const InputDecoration(
                        labelText: 'Rol',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                      ),
                      validator: (v) => v == null ? 'Selecciona un rol' : null,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: isEditing ? 'Nueva Contraseña (opcional)' : 'Contraseña',
                        border: const OutlineInputBorder(),
                        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                      ),
                      validator: (v) {
                        if (!isEditing && (v == null || v.isEmpty)) {
                          return 'Campo requerido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: _isSaving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.save),
                        label: Text(isEditing ? 'Actualizar' : 'Registrar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: _isSaving ? null : _save,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}