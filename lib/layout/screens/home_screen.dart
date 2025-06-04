// lib/layout/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:smged/api/services/citas_service.dart'; // Mantener por el momento para el conteo de citas
import 'package:smged/api/models/cita.dart'; // Mantener por el momento para el conteo de citas
import 'package:smged/layout/widgets/custom_app_bar.dart';
import 'package:smged/layout/widgets/custom_drawer.dart';
import 'package:smged/layout/widgets/custom_colors.dart';
import 'package:smged/layout/widgets/info_card.dart'; // ¡Asegúrate de que esta esté importada!

class HomeScreen extends StatefulWidget {
  final VoidCallback onLogout;

  const HomeScreen({super.key, required this.onLogout});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Mantengo CitasService y _citasPendientesCount para el AppBar
  final CitasService _citasService = CitasService();
  int _citasPendientesCount = 0;

  @override
  void initState() {
    super.initState();
    // Solo carga el conteo de citas pendientes por ahora
    _fetchCitasPendientesCount();
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
          title: const Text('Citas Pendientes', style: TextStyle(fontWeight: FontWeight.bold)),
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
      ),
      body: SingleChildScrollView(
        // Removido RefreshIndicator por ahora, se puede añadir más adelante
        child: Column(
          children: [
            const SizedBox(height: 16), // Espacio superior

            // Tarjeta: Cantidad de Estudiantes (con valores estáticos por ahora)
            const InfoCard(
              title: 'Cantidad de Estudiantes',
              value: '120', // Valor estático
              icon: Icons.people_alt,
              color: AppColors.primary,
              onTap: null, // Sin funcionalidad por ahora
            ),

            // Tarjeta: Incidentes en el Mes (con valores estáticos por ahora)
            const InfoCard(
              title: 'Incidentes en el Mes',
              value: '5', // Valor estático
              icon: Icons.warning_amber,
              color: AppColors.warning,
              onTap: null, // Sin funcionalidad por ahora
            ),

            // Tarjeta: Informar a Estudiante de Cita (con texto estático)
            const InfoCard(
              title: 'Informar a Estudiante de Cita',
              value: 'Acción Rápida', // Texto estático descriptivo
              icon: Icons.calendar_today,
              color: AppColors.success,
              onTap: null, // Sin funcionalidad por ahora
            ),

            const SizedBox(height: 20), // Espacio inferior
          ],
        ),
      ),
    );
  }
}