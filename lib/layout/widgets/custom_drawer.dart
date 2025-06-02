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
    // Almacenamos el context del Drawer antes de que se cierre
    final drawerContext = context;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) { // Usamos dialogContext para el diálogo
        return AlertDialog(
          title: const Text('Cerrar Sesión'),
          content: const Text('¿Estás seguro de que quieres cerrar tu sesión?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Cierra solo el diálogo
              },
            ),
            TextButton(
              child: const Text('Sí, cerrar sesión'),
              onPressed: () {
                // Primero cierra el diálogo de confirmación
                Navigator.of(dialogContext).pop(); 
                // Asegúrate de que el Drawer esté cerrado antes de llamar a onLogout.
                // En este escenario, el Drawer ya fue cerrado por el onTap del ListTile.
                // Llamamos directamente al onLogout que desencadena la lógica en MyApp.
                onLogout(); 
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
              Navigator.pop(context); // Cierra el Drawer
              // En este caso, el "Dashboard" es la Home o el Dashboard específico del rol.
              // Si el usuario ya está en su Dashboard, simplemente cierra el Drawer.
              // Si no, podrías usar Navigator.pushReplacement o Navigator.push si quieres añadirlo al stack.
            },
          ),
          ListTile(
            leading: const Icon(Icons.school),
            title: const Text('Estudiantes'),
            onTap: () {
              Navigator.pop(context); // Cierra el Drawer
              Navigator.pushNamed(context, '/estudiantes'); // Navega usando rutas nombradas
            },
          ),
          ListTile(
            leading: const Icon(Icons.event),
            title: const Text('Citas'),
            onTap: () {
              Navigator.pop(context); // Cierra el Drawer
              // Navigator.pushNamed(context, '/citas'); // Descomentar cuando la ruta esté definida
            },
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Historial Médico'),
            onTap: () {
              Navigator.pop(context); // Cierra el Drawer
              // Navigator.pushNamed(context, '/historialMedico'); // Descomentar cuando la ruta esté definida
            },
          ),
          ListTile(
            leading: const Icon(Icons.report),
            title: const Text('Reportes'),
            onTap: () {
              Navigator.pop(context); // Cierra el Drawer
              // Navigator.pushNamed(context, '/reportes'); // Descomentar cuando la ruta esté definida
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Configuración'),
            onTap: () {
              Navigator.pop(context); // Cierra el Drawer
              // Navigator.pushNamed(context, '/configuracion'); // Descomentar cuando la ruta esté definida
            },
          ),
          const Divider(),

          // Opción de Cerrar Sesión
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Cerrar Sesión', style: TextStyle(color: Colors.red)),
            onTap: () {
              // Primero, cierra el Drawer inmediatamente.
              // Esto asegura que la navegación principal no se vea obstaculizada por un Drawer abierto.
              Navigator.pop(context); 
              // Luego, muestra el diálogo de confirmación.
              _confirmLogout(context); 
            },
          ),
        ],
      ),
    );
  }
}