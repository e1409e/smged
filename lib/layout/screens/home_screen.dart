// lib/layout/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:smged/api/services/citas_service.dart';
import 'package:smged/api/models/cita.dart';
import 'package:smged/layout/widgets/custom_app_bar.dart';
import 'package:smged/layout/widgets/custom_drawer.dart';

/// La pantalla principal que se muestra después de un inicio de sesión exitoso.
///
/// Recibe un [VoidCallback] `onLogout` para permitir al usuario cerrar la sesión
/// y volver a la pantalla de login.
class HomeScreen extends StatefulWidget {
  final VoidCallback onLogout;

  const HomeScreen({super.key, required this.onLogout});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CitasService _citasService = CitasService();
  int _citasPendientesCount = 0;
  bool _showAlert = true;

  @override
  void initState() {
    super.initState();
    _fetchCitasPendientesCount();
  }

  Future<void> _fetchCitasPendientesCount() async {
    try {
      final List<Cita> citas = await _citasService.obtenerCitas();
      final int pendientes = citas.where((cita) => cita.pendiente == 1).length;
      setState(() {
        _citasPendientesCount = pendientes;
      });
    } catch (e) {
      print('Error al cargar el conteo de citas pendientes: $e');
      // Podrías mostrar un Snackbar o mensaje de error al usuario
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // --- Usando el AppBar personalizado sin botón de logout ---
      appBar: const CustomAppBar( // Ya no necesita onLogout ni showLogoutButton
        title: 'INICIO',
      ),
      // --- Usando el Drawer personalizado ---
      drawer: CustomDrawer(
        onLogout: widget.onLogout, // Pasa el callback de logout al CustomDrawer
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(0.0),
        child: Column(
          children: [
            if (_showAlert && _citasPendientesCount > 0)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0, bottom: 8.0),
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Colors.amber.shade100,
                  border: Border.all(color: Colors.amber.shade400),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.amber.shade500),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Tienes $_citasPendientesCount citas pendientes.',
                        style: TextStyle(color: Colors.amber.shade900, fontWeight: FontWeight.w500),
                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      color: Colors.amber.shade700,
                      onPressed: () {
                        setState(() {
                          _showAlert = false;
                        });
                      },
                      tooltip: 'Ocultar alerta',
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: Colors.green,
                    size: 80,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    '¡Has iniciado sesión exitosamente!',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Aquí se mostrará el contenido principal de tu aplicación.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}