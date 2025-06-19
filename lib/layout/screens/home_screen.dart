// lib/layout/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:smged/api/services/citas_service.dart';
import 'package:smged/api/models/cita.dart';
import 'package:smged/layout/widgets/custom_app_bar.dart';
import 'package:smged/layout/widgets/custom_drawer.dart';
import 'package:smged/layout/widgets/custom_colors.dart';
import 'package:smged/layout/widgets/info_card.dart';
import 'package:smged/routes.dart' as app_routes;
import 'package:smged/api/services/auth_service.dart';
import 'package:smged/api/services/usuarios_service.dart';
import 'package:smged/api/models/usuario.dart';
import 'package:collection/collection.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onLogout;

  const HomeScreen({super.key, required this.onLogout});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CitasService _citasService = CitasService();
  int _citasPendientesCount = 0;

  String _userName = 'Cargando...';
  String _userRole = 'Cargando...';

  final AuthService _authService = AuthService();
  final UsuariosService _usuariosService = UsuariosService();

  @override
  void initState() {
    super.initState();
    _fetchCitasPendientesCount();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final int? userId = await _authService.getUserId();
      if (userId != null) {
        final List<Usuario> usuarios = await _usuariosService.obtenerUsuarios();
        // CUIDADO AQUÍ: Asegúrate de que 'idUsuario' coincida con la propiedad en tu modelo Usuario
        final Usuario? currentUser = usuarios.firstWhereOrNull((user) => user.idUsuario == userId);

        if (currentUser != null && mounted) {
          setState(() {
            _userName = currentUser.nombre;
            _userRole = currentUser.rol;
          });
        } else if (mounted) {
          setState(() {
            _userName = 'Usuario Desconocido';
            _userRole = 'Rol Desconocido';
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _userName = 'Invitado';
            _userRole = 'Visitante';
          });
        }
      }
    } catch (e) {
      print('Excepción al cargar datos del usuario: $e');
      if (mounted) {
        setState(() {
          _userName = 'Error';
          _userRole = 'Error';
        });
      }
    }
  }

  Future<void> _fetchCitasPendientesCount() async {
    try {
      final List<Cita> citas = await _citasService.obtenerCitas();
      final int pendientes = citas.where((cita) => cita.pendiente == 1).length;
      if (mounted) {
        setState(() {
          _citasPendientesCount = pendientes;
        });
      }
    } catch (e) {
      print('Error al cargar el conteo de citas pendientes: $e');
    }
  }

  void _showCitasPendientesAlert() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Citas Pendientes', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          content: _citasPendientesCount > 0
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.info_outline, color: AppColors.warning, size: 40),
                    const SizedBox(height: 10),
                    Text(
                      'Tienes $_citasPendientesCount citas pendientes.',
                      style: const TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(
                          context,
                          app_routes.AppRoutes.citasList,
                        );
                      },
                      child: const Text('Ver Citas'),
                    ),
                  ],
                )
              : const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle_outline, color: AppColors.success, size: 40),
                    SizedBox(height: 10),
                    Text(
                      'No tienes citas pendientes.',
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'INICIO',
        actions: [
          if (_citasPendientesCount > 0)
            Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_active),
                  onPressed: _showCitasPendientesAlert,
                  tooltip: 'Ver citas pendientes',
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 14,
                      minHeight: 14,
                    ),
                    child: Text(
                      '$_citasPendientesCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              ],
            )
          else
            IconButton(
              icon: const Icon(Icons.notifications_none),
              onPressed: _showCitasPendientesAlert,
              tooltip: 'No hay citas pendientes',
            ),
        ],
      ),
      drawer: CustomDrawer(
        onLogout: widget.onLogout,
        userName: _userName,
        userRole: _userRole,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),

            const InfoCard(
              title: 'Cantidad de Estudiantes',
              value: '120',
              icon: Icons.people_alt,
              color: AppColors.primary,
              onTap: null,
            ),

            const InfoCard(
              title: 'Incidentes en el Mes',
              value: '5',
              icon: Icons.warning_amber,
              color: AppColors.warning,
              onTap: null,
            ),

            const InfoCard(
              title: 'Informar a Estudiante de Cita',
              value: 'Acción Rápida',
              icon: Icons.calendar_today,
              color: AppColors.success,
              onTap: null,
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}