// lib/screens/admin_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:smged/layout/widgets/custom_drawer.dart';
import 'package:smged/layout/widgets/custom_colors.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'INICIO',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textTitle,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: AppColors.primary,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: AppColors.background,
                    child: Icon(Icons.admin_panel_settings, size: 30, color: AppColors.primary),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Administrador',
                    style: TextStyle(
                      color: AppColors.textTitle,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    'Panel de control',
                    style: TextStyle(
                      color: AppColors.textTitle,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Usuarios'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navega a la pantalla de usuarios
                // Navigator.pushNamed(context, '/usuarios');
              },
            ),
            ListTile(
              leading: const Icon(Icons.account_balance),
              title: const Text('Facultades'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navega a la pantalla de facultades
                // Navigator.pushNamed(context, '/facultades');
              },
            ),
            ListTile(
              leading: const Icon(Icons.school),
              title: const Text('Carreras'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navega a la pantalla de carreras
                // Navigator.pushNamed(context, '/carreras');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: AppColors.error),
              title: const Text('Cerrar Sesión', style: TextStyle(color: AppColors.error)),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implementa el logout real aquí si lo necesitas
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: const [
            SizedBox(height: 16),
          
            Center(
              child: Text(
                'Bienvenido al panel de administración',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}