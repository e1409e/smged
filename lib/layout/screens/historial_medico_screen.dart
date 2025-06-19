// lib/layout/screens/historial_medico_screen.dart
import 'package:flutter/material.dart';

class HistorialMedicoScreen extends StatefulWidget {
  const HistorialMedicoScreen({super.key});

  @override
  State<HistorialMedicoScreen> createState() => _HistorialMedicoScreenState();
}

class _HistorialMedicoScreenState extends State<HistorialMedicoScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historiales Médicos'),
      ),
      body: const Center(
        child: Text('Contenido de la lista de historiales médicos'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Aquí irá la navegación para agregar un nuevo historial
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}