// lib/screens/admin_dashboard_screen.dart
import 'package:flutter/material.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard de Administrador'),
      ),
      body: const Center(
        child: Text('¡Bienvenido, Administrador!'),
      ),
    );
  }
}