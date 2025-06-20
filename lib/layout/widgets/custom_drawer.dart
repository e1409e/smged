// lib/layout/widgets/custom_drawer.dart
import 'package:flutter/material.dart';

// Importa las utilidades de diseño
import 'package:smged/layout/widgets/custom_TextStyles.dart';
import 'package:smged/layout/widgets/custom_colors.dart';

// Importa tu archivo de rutas con un alias para evitar conflictos
import 'package:smged/routes.dart' as app_routes;

class CustomDrawer extends StatelessWidget {
  final VoidCallback onLogout; // El callback de logout que se ejecuta al confirmar
  final String userName; // Parámetro para el nombre del usuario
  final String userRole; // Parámetro para el rol del usuario

  const CustomDrawer({
    super.key,
    required this.onLogout,
    this.userName = 'Usuario', // Valor por defecto en caso de no ser pasado
    this.userRole = 'Rol Desconocido', // Valor por defecto
  });

  // Función para mostrar el diálogo de confirmación antes de cerrar sesión
  void _confirmLogout(BuildContext context) {
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
                // Llama directamente al onLogout que desencadena la lógica en MyApp.
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
        padding: EdgeInsets.zero, // Elimina el padding por defecto del ListView
        children: <Widget>[
          // Encabezado del Drawer con información de usuario
          DrawerHeader(
            decoration: BoxDecoration(
              color: AppColors.primary, // Usa tu color primario personalizado
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.background, // Color de fondo del avatar
                  child: Icon(Icons.person, size: 30, color: AppColors.primary), // Icono de persona
                ),
                const SizedBox(height: 10), // Espacio entre el avatar y el texto
                Text(
                  userName, // ¡Ahora muestra el nombre de usuario pasado como parámetro!
                  style: TextStyles.title.copyWith(color: AppColors.textTitle), // Estilo de texto del título
                ),
                Text(
                  userRole, // ¡Ahora muestra el rol pasado como parámetro!
                  style: TextStyles.subtitle.copyWith(color: AppColors.textTitle), // Estilo de texto del subtítulo
                ),
              ],
            ),
          ),

          // Elemento del menú: Dashboard (se mantiene la navegación original)
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Inicio'),
            onTap: () {
              Navigator.pop(context); // Cierra el Drawer
              // No hay cambio en la navegación para "Inicio", se mantiene como estaba.
            },
          ),

          // Elemento del menú: Estudiantes
          ListTile(
            leading: const Icon(Icons.school),
            title: const Text('Estudiantes'),
            onTap: () {
              Navigator.pop(context); // Cierra el Drawer
              Navigator.pushNamed(context, app_routes.AppRoutes.estudiantesList);  // Navega a la ruta de la lista de estudiantes usando la constante
            },
          ),

          // Elemento del menú: Citas
          ListTile(
            leading: const Icon(Icons.event),
            title: const Text('Citas'),
            onTap: () {
              Navigator.pop(context); // Cierra el Drawer
              Navigator.pushNamed(context, app_routes.AppRoutes.citasList); // Navega a la ruta de la lista de citas usando la constante
            },
          ),


          const Divider(), // Línea divisoria entre opciones

          // Opción de Cerrar Sesión
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.error), // Icono de logout en color de error
            title: const Text('Cerrar Sesión', style: TextStyle(color: AppColors.error)), // Texto de logout en color de error
            onTap: () {
              // Cierra el Drawer inmediatamente para una mejor experiencia de usuario
              Navigator.pop(context);
              // Luego, muestra el diálogo de confirmación antes de realmente cerrar la sesión
              _confirmLogout(context);
            },
          ),
        ],
      ),
    );
  }
}