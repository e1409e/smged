// lib/screens/admin_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:smged/layout/widgets/custom_drawer.dart';
import 'package:smged/layout/widgets/custom_colors.dart';
import 'package:smged/routes.dart';
import 'package:smged/api/services/usuarios_service.dart';
import 'package:smged/api/services/facultades_service.dart';
import 'package:smged/api/services/carreras_service.dart';
import 'package:smged/api/models/facultad.dart';
import 'package:smged/api/models/carrera.dart';

class AdminDashboardScreen extends StatefulWidget {
  final VoidCallback? onLogout;
  const AdminDashboardScreen({super.key, this.onLogout});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _totalUsuarios = 0;
  List<Facultad> _facultades = [];
  List<Carrera> _carreras = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    setState(() => _isLoading = true);
    try {
      final usuarios = await UsuariosService().obtenerUsuarios();
      final facultades = await FacultadesService().obtenerFacultades();
      final carreras = await CarrerasService().obtenerCarreras();
      setState(() {
        _totalUsuarios = usuarios.length;
        _facultades = facultades;
        _carreras = carreras;
      });
    } catch (e) {
      setState(() {
        _totalUsuarios = 0;
        _facultades = [];
        _carreras = [];
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Cerrar sesión?'),
        content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text('Cerrar sesión', style: TextStyle(color: AppColors.error)),
            onPressed: () {
              Navigator.of(context).pop();
              widget.onLogout!();
            },
          ),
        ],
      ),
    );
  }

  int _cantidadCarrerasPorFacultad(int idFacultad) {
    return _carreras.where((c) => c.idFacultad == idFacultad).length;
  }

  @override
  Widget build(BuildContext context) {
    final bool esEscritorio = MediaQuery.of(context).size.width > 700;
    final double cardWidth = esEscritorio ? 500 : MediaQuery.of(context).size.width * 0.95;

    return Scaffold(
      appBar: AppBar(
        title: const Text('INICIO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),

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
                Navigator.pushNamed(context, '/usuarios');
              },
            ),
            ListTile(
              leading: const Icon(Icons.account_balance),
              title: const Text('Facultades'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, AppRoutes.facultades);
              },
            ),
            ListTile(
              leading: const Icon(Icons.school),
              title: const Text('Carreras'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, AppRoutes.carreras);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: AppColors.error),
              title: const Text('Cerrar Sesión', style: TextStyle(color: AppColors.error)),
              onTap: () {
                Navigator.pop(context); // Cierra el Drawer
                _confirmLogout(context); // Muestra el diálogo de confirmación
              },
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        '¡Bienvenido al Panel de Administración!',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      // Card de usuarios activos
                      Card(
                        elevation: 6,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        child: Container(
                          width: cardWidth,
                          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Hay un total de:',
                                style: TextStyle(fontSize: 18),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                '$_totalUsuarios',
                                style: const TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                'Usuarios Activos',
                                style: TextStyle(fontSize: 18),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Card de facultades y carreras
                      Card(
                        elevation: 6,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        child: Container(
                          width: cardWidth,
                          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ..._facultades.map((facultad) => Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                                    child: Text(
                                      'La Facultad de ${facultad.facultad} tiene ${_cantidadCarrerasPorFacultad(facultad.idFacultad)} carreras',
                                      style: const TextStyle(fontSize: 16),
                                      textAlign: TextAlign.start,
                                    ),
                                  )),
                              if (_facultades.isEmpty)
                                const Text(
                                  'No hay facultades registradas.',
                                  style: TextStyle(fontSize: 16, color: Colors.grey),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}