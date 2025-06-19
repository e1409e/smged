// lib/layout/screens/forms/historial_medico_form_screen.dart
import 'package:flutter/material.dart';

class HistorialMedicoFormScreen extends StatefulWidget {
  // Puedes pasar un ID de historial médico si estás editando
  final int? historialMedicoId;

  const HistorialMedicoFormScreen({super.key, this.historialMedicoId});

  @override
  State<HistorialMedicoFormScreen> createState() => _HistorialMedicoFormScreenState();
}

class _HistorialMedicoFormScreenState extends State<HistorialMedicoFormScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.historialMedicoId == null ? 'Crear Historial Médico' : 'Editar Historial Médico'),
      ),
      body: const Center(
        child: Text('Contenido del formulario de historial médico'),
      ),
    );
  }
}