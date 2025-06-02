import 'package:flutter/material.dart';

/// Pantalla de bienvenida para el rol de Docente.
class DocenteDashboardScreen extends StatelessWidget {
  const DocenteDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Panel de Docente',
          style: TextStyle(color: Colors.white), // Puedes ajustar el color y estilo
        ),
        backgroundColor: Colors.blueAccent, // Un color distintivo para el AppBar
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.school, // Un icono relacionado con docentes
              size: 80,
              color: Colors.blueAccent,
            ),
            SizedBox(height: 24),
            Text(
              '¡Hola, Docente!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            Text(
              'Bienvenido a tu panel de control.',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}