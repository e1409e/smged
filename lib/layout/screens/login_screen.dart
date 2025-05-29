import 'package:flutter/material.dart';
import 'package:smged/api/models/login_request.dart';
import 'package:smged/api/services/auth_service.dart';
import 'package:smged/layout/widgets/custom_colors.dart';
import 'package:smged/layout/widgets/custom_TextStyles.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onLoginSuccess;

  const LoginScreen({super.key, required this.onLoginSuccess});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _cedulaUsuarioController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final cedulaUsuario = _cedulaUsuarioController.text;
    final password = _passwordController.text;

    if (cedulaUsuario.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Por favor, ingresa cédula y contraseña.';
        _isLoading = false;
      });
      return;
    }

    try {
      final request = LoginRequest(
        cedula_usuario: cedulaUsuario,
        password: password,
      );
      final response = await _authService.login(request);

      if (response.success) {
        widget.onLoginSuccess();
      } else {
        setState(() {
          _errorMessage =
              response.message ?? 'Credenciales inválidas o error desconocido.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().contains('Exception:')
            ? e.toString().replaceFirst('Exception: ', '')
            : 'Error de conexión o inesperado.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _cedulaUsuarioController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Obtenemos el ancho de la pantalla
    final double screenWidth = MediaQuery.of(context).size.width;
    // Definimos un ancho máximo para la Card en pantallas grandes.
    // Esto asegura que la Card no se estire demasiado.
    final double cardWidth = screenWidth > 600
        ? 400
        : screenWidth *
              0.9; // 400px en pantallas grandes, 90% del ancho en pequeñas

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Iniciar Sesión',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: SizedBox(
            // Usamos SizedBox para limitar el ancho de la Card
            width: cardWidth,
            child: Card(
              // <--- Aquí usamos Card
              elevation: 8.0, // Elevación para el efecto de sombra
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0), // Bordes redondeados
              ),
              child: Padding(
                padding: const EdgeInsets.all(
                  24.0,
                ), // Padding dentro de la Card
                child: Column(
                  mainAxisSize: MainAxisSize
                      .min, // La columna ocupará el espacio mínimo necesario
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Bienvenido',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            color: AppColors.primary, // Color del título
                            fontWeight: FontWeight.bold,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48.0),

                    TextField(
                      controller: _cedulaUsuarioController,
                      decoration: InputDecoration(
                        labelText: 'Cédula',
                        hintText: 'Ingrese su número de cédula',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.person),

                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: AppColors.primary,
                            width: 2.0,
                          ),
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        labelStyle: TextStyles.label,
                        floatingLabelStyle: TextStyles.labelfocus,
                      ),
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      cursorColor: AppColors.primary,
                    ),
                    const SizedBox(height: 16.0),

                    TextField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        hintText: 'Ingrese su contraseña',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.lock),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: AppColors.primary,
                            width: 2.0,
                          ),
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        labelStyle: TextStyles.label,
                        floatingLabelStyle: TextStyles.labelfocus,
                        
                      ),

                      obscureText: true,
                      keyboardType: TextInputType.visiblePassword,
                      textInputAction: TextInputAction.done,
                      cursorColor: AppColors.primary,
                      onSubmitted: (_) => _login(),
                    ),
                    const SizedBox(height: 24.0),

                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(
                            color: AppColors.error,
                            fontSize: 14.0,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                    SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Theme.of(
                            context,
                          ).colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: AppColors.indicator,
                              )
                            : const Text(
                                'Ingresar',
                                style: TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
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
