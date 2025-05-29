// lib/layout/widgets/custom_drawer.dart
import 'package:flutter/material.dart';

// Importa aquí todas las pantallas a las que el Drawer va a navegar
import 'package:smged/layout/screens/estudiantes_screen.dart';
import 'package:smged/layout/widgets/custom_TextStyles.dart';
import 'package:smged/layout/widgets/custom_colors.dart';
// import 'package:smged/layout/screens/citas_screen.dart';
// import 'package:smged/layout/screens/historial_medico_screen.dart';

class CustomDrawer extends StatelessWidget {
  final VoidCallback onLogout; // El callback de logout que se ejecuta al confirmar

  const CustomDrawer({super.key, required this.onLogout});

  // Función para mostrar el diálogo de confirmación antes de cerrar sesión
  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) { // Usamos dialogContext para evitar conflicto de nombre
        return AlertDialog(
          title: const Text('Cerrar Sesión'),
          content: const Text('¿Estás seguro de que quieres cerrar tu sesión?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Cierra el diálogo
              },
            ),
            TextButton(
              child: const Text('Sí, cerrar sesión'),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Cierra el diálogo
                onLogout(); // Llama al callback de logout que viene del HomeScreen (MyApp)
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: AppColors.primary,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.background,
                  child: Icon(Icons.person, size: 30, color: Colors.blue),
                ),
                const SizedBox(height: 10),
                Text(
                  'Nombre de Usuario',
                  style: TextStyles.title
                ),
                const Text(
                  'Rol (Ej. Psicólogo/Administrador)',
                  style: TextStyles.subtitle
                ),
              ],
            ),
          ),

          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.school),
            title: const Text('Estudiantes'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/estudiantes');
            },
          ),
          ListTile(
            leading: const Icon(Icons.event),
            title: const Text('Citas'),
            onTap: () {
              Navigator.pop(context);
              // Navigator.pushNamed(context, '/citas');
            },
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Historial Médico'),
            onTap: () {
              Navigator.pop(context);
              // Navigator.pushNamed(context, '/historialMedico');
            },
          ),
          ListTile(
            leading: const Icon(Icons.report),
            title: const Text('Reportes'),
            onTap: () {
              Navigator.pop(context);
              // Navigator.pushNamed(context, '/reportes');
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Configuración'),
            onTap: () {
              Navigator.pop(context);
              // Navigator.pushNamed(context, '/configuracion');
            },
          ),
          const Divider(),

          // Opción de Cerrar Sesión (únicamente aquí)
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Cerrar Sesión', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context); // Cierra el Drawer
              _confirmLogout(context); // Llama a la confirmación de logout
            },
          ),
        ],
      ),
    );
  }
}