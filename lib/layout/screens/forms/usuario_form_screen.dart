import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smged/api/models/usuario.dart';
import 'package:smged/api/services/usuarios_service.dart';
import 'package:smged/api/exceptions/api_exception.dart';
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
  Map<String, List<String>>? _validationErrors;

  // Prefijo de cédula (V- o E-)
  String _cedulaPrefix = 'V-';

  @override
  void initState() {
    super.initState();
    if (widget.usuarioToEdit != null) {
      _nombreController.text = widget.usuarioToEdit!.nombre;
      _apellidoController.text = widget.usuarioToEdit!.apellido;
      // Configuración del prefijo y número de cédula igual que en estudiantes
      if (widget.usuarioToEdit!.cedulaUsuario.startsWith('V-')) {
        _cedulaPrefix = 'V-';
        _cedulaController.text = widget.usuarioToEdit!.cedulaUsuario.substring(2);
      } else if (widget.usuarioToEdit!.cedulaUsuario.startsWith('E-')) {
        _cedulaPrefix = 'E-';
        _cedulaController.text = widget.usuarioToEdit!.cedulaUsuario.substring(2);
      } else {
        _cedulaController.text = widget.usuarioToEdit!.cedulaUsuario;
      }
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
    setState(() {
      _isSaving = true;
      _validationErrors = null;
    });

    final service = UsuariosService();
    try {
      final cedulaCompleta = _cedulaPrefix + _cedulaController.text;
      if (widget.usuarioToEdit == null) {
        await service.crearUsuario(
          Usuario(
            idUsuario: 0,
            nombre: _nombreController.text,
            apellido: _apellidoController.text,
            cedulaUsuario: cedulaCompleta,
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
            cedulaUsuario: cedulaCompleta,
            rol: _selectedRol!,
          ),
          password: _passwordController.text.isNotEmpty ? _passwordController.text : null,
        );
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.usuarioToEdit == null
                ? 'Usuario registrado exitosamente.'
                : 'Usuario actualizado exitosamente.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } on ValidationException catch (e) {
      setState(() {
        _validationErrors = e.errors;
      });
      if (e.errors['general'] != null) {
        _showErrorSnackBar(e.errors['general']!.join(', '));
      }
      _formKey.currentState!.validate();
    } on ApiException catch (e) {
      _showErrorSnackBar('Error: ${e.message}');
    } catch (e) {
      _showErrorSnackBar('Ocurrió un error inesperado. Intenta de nuevo.');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  String? _fieldError(String field) {
    if (_validationErrors != null && _validationErrors![field] != null) {
      return _validationErrors![field]!.join('\n');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final bool esEscritorio = MediaQuery.of(context).size.width > 700;
    final double formWidth = esEscritorio ? 400 : MediaQuery.of(context).size.width * 0.98;

    final bool isEditing = widget.usuarioToEdit != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'EDITAR USUARIO' : 'REGISTRAR USUARIO', style: const TextStyle(fontWeight: FontWeight.bold),),
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
                    Text(
                      isEditing ? 'Editando usuario' : 'Agregar Usuario',
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
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Campo requerido';
                        final err = _fieldError('nombre');
                        return err;
                      },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _apellidoController,
                      decoration: const InputDecoration(
                        labelText: 'Apellido',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Campo requerido';
                        final err = _fieldError('apellido');
                        return err;
                      },
                    ),
                    const SizedBox(height: 10),
                    // --- CAMPO CÉDULA IGUAL QUE EN ESTUDIANTES ---
                    Row(
                      children: [
                        DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _cedulaPrefix,
                            items: const [
                              DropdownMenuItem(
                                value: 'V-',
                                child: Text('V-'),
                              ),
                              DropdownMenuItem(
                                value: 'E-',
                                child: Text('E-'),
                              ),
                            ],
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  _cedulaPrefix = newValue;
                                });
                              }
                            },
                            dropdownColor: Theme.of(context).cardColor,
                            icon: const Icon(Icons.arrow_drop_down),
                            elevation: 8,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        Expanded(
                          child: TextFormField(
                            controller: _cedulaController,
                            decoration: const InputDecoration(
                              labelText: 'Cédula',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(9),
                            ],
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Campo requerido';
                              }
                              if (value.length < 7 || value.length > 9) {
                                return 'La cédula debe tener entre 7 y 9 dígitos.';
                              }
                              final err = _fieldError('cedula_usuario');
                              return err;
                            },
                          ),
                        ),
                      ],
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
                      validator: (v) {
                        if (v == null) return 'Selecciona un rol';
                        final err = _fieldError('rol');
                        return err;
                      },
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
                        final err = _fieldError('password');
                        return err;
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