// lib/layout/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show debugPrint; // Importa debugPrint
import 'package:smged/api/models/login_request.dart';
import 'package:smged/api/services/auth_service.dart';
import 'package:smged/layout/widgets/custom_colors.dart';
import 'package:smged/layout/widgets/custom_TextStyles.dart';
// No necesitas importar HomeScreen aquí, la navegación la maneja routes.dart

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
    debugPrint('[_LoginScreenState] Iniciando función _login...');
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    debugPrint('[_LoginScreenState] Estado de carga y error reseteados.');

    final cedulaUsuario = _cedulaUsuarioController.text;
    final password = _passwordController.text;

    if (cedulaUsuario.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Por favor, ingresa cédula y contraseña.';
        _isLoading = false;
      });
      debugPrint('[_LoginScreenState] Campos de login vacíos. Error: $_errorMessage');
      return;
    }

    debugPrint('[_LoginScreenState] Campos de login no vacíos. Cédula: $cedulaUsuario');

    try {
      debugPrint('[_LoginScreenState] Creando LoginRequest y llamando a AuthService.login...');
      final request = LoginRequest(
        cedula_usuario: cedulaUsuario,
        password: password,
      );
      final response = await _authService.login(request);
      debugPrint('[_LoginScreenState] AuthService.login completado. Respuesta success: ${response.success}');

      if (response.success) {
        debugPrint('[_LoginScreenState] Login exitoso. response.success es TRUE. Llamando a widget.onLoginSuccess().');
        widget.onLoginSuccess();
        debugPrint('[_LoginScreenState] widget.onLoginSuccess() llamado. Esperando reconstrucción de MaterialApp...');
      } else {
        setState(() {
          _errorMessage = response.message ?? 'Credenciales inválidas o error desconocido.';
        });
        debugPrint('[_LoginScreenState] Login fallido. Mensaje: $_errorMessage');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().contains('Exception:')
            ? e.toString().replaceFirst('Exception: ', '')
            : 'Error de conexión o inesperado.';
      });
      debugPrint('[_LoginScreenState] Excepción capturada durante el login: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
      debugPrint('[_LoginScreenState] Finalizado el bloque try-catch-finally de _login. _isLoading es false.');
    }
  }

  @override
  void dispose() {
    debugPrint('[_LoginScreenState] dispose() llamado. Limpiando controladores.');
    _cedulaUsuarioController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('[_LoginScreenState] build() llamado.');
    final double screenWidth = MediaQuery.of(context).size.width;
    final double cardWidth = screenWidth > 600 ? 400 : screenWidth * 0.9;

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
            width: cardWidth,
            child: Card(
              elevation: 8.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Bienvenido',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            color: AppColors.primary,
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
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.lock),
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
                          foregroundColor: Theme.of(context).colorScheme.onPrimary,
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