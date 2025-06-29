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
import 'package:smged/api/models/incidencia.dart';
import 'package:smged/api/services/incidencias_service.dart';
import 'package:smged/api/services/estudiantes_service.dart';
import 'package:smged/api/models/estudiante.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:smged/main.dart'; 
import 'package:url_launcher/url_launcher.dart';
import 'package:smged/layout/widgets/search_bar_widget.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onLogout;

  const HomeScreen({super.key, required this.onLogout});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with RouteAware {
  final CitasService _citasService = CitasService();
  final EstudiantesService _estudiantesService = EstudiantesService();
  int _citasPendientesCount = 0;
  int _totalEstudiantes = 0;

  String _userName = 'Cargando...';
  String _userRole = 'Cargando...';

  final AuthService _authService = AuthService();
  final UsuariosService _usuariosService = UsuariosService();
  final IncidenciasService _incidenciasService = IncidenciasService();
  int _incidenciasMesCount = 0;
  int _conapdisCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchCitasPendientesCount();
    _fetchIncidenciasMesCount();
    _fetchTotalEstudiantes();
    _fetchConapdisCount(); // <--- Agrega esta línea
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final int? userId = await _authService.getUserId();
      if (userId != null) {
        final List<Usuario> usuarios = await _usuariosService.obtenerUsuarios();
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

  Future<void> _fetchIncidenciasMesCount() async {
    try {
      final List<Incidencia> incidencias = await _incidenciasService.obtenerIncidencias();
      final now = DateTime.now();
      final count = incidencias.where((inc) {
        // Maneja el formato de fecha: puede ser '2025-06-20T04:00:00.000Z' o similar
        DateTime? fecha;
        try {
          fecha = DateTime.parse(inc.fechaIncidente);
        } catch (_) {
          return false;
        }
        return fecha.year == now.year && fecha.month == now.month;
      }).length;
      if (mounted) {
        setState(() {
          _incidenciasMesCount = count;
        });
      }
    } catch (e) {
      print('Error al cargar el conteo de incidencias del mes: $e');
    }
  }

  Future<void> _fetchTotalEstudiantes() async {
    try {
      final List<Estudiante> estudiantes = await _estudiantesService.obtenerTodosLosEstudiantes();
      if (mounted) {
        setState(() {
          _totalEstudiantes = estudiantes.length;
        });
      }
    } catch (e) {
      print('Error al cargar el conteo de estudiantes: $e');
    }
  }

  Future<void> _fetchConapdisCount() async {
    try {
      final List<Estudiante> estudiantes = await _estudiantesService.obtenerTodosLosEstudiantes();
      // El modelo Estudiante usa bool? para poseeConapdis, así que compara con true
      final int conapdis = estudiantes.where((e) => e.poseeConapdis == true).length;
      if (mounted) {
        setState(() {
          _conapdisCount = conapdis;
        });
      }
    } catch (e) {
      print('Error al cargar el conteo de estudiantes con CONAPDIS: $e');
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

  Future<void> _enviarCorreoAEstudiante(Estudiante estudiante) async {
    List<Cita> citas = [];
    try {
      citas = await _citasService.obtenerCitas();
    } catch (_) {}

    final ahora = DateTime.now();
    final citasPendientes = citas
        .where((c) =>
            c.id_estudiante == estudiante.idEstudiante &&
            c.pendiente == 1 &&
            c.fecha_cita.isAfter(ahora.subtract(const Duration(days: 1))))
        .toList();

    citasPendientes.sort((a, b) => a.fecha_cita.compareTo(b.fecha_cita));
    final proximaCita = citasPendientes.isNotEmpty ? citasPendientes.first : null;

    String asunto = 'Tienes una Cita';
    if (proximaCita != null) {
      final fecha = DateFormat('dd/MM/yyyy').format(proximaCita.fecha_cita);
      asunto = 'Tienes una Cita para $fecha';
    }

    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: estudiante.correo ?? '',
      query: 'subject=${Uri.encodeComponent(asunto)}',
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir el cliente de correo')),
      );
    }
  }

  void _mostrarDialogoSeleccionEstudiante() async {
    List<Estudiante> estudiantes = [];
    try {
      estudiantes = await _estudiantesService.obtenerTodosLosEstudiantes();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar estudiantes: $e')),
      );
      return;
    }

    if (!mounted) return;

    final TextEditingController searchController = TextEditingController();
    List<Estudiante> filteredEstudiantes = List.from(estudiantes);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return SimpleDialog(
              title: const Text('Selecciona un estudiante'),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: SearchBarWidget(
                    controller: searchController,
                    hintText: 'Buscar estudiante...',
                    onChanged: (value) {
                      setState(() {
                        filteredEstudiantes = estudiantes.where((est) {
                          final nombre = '${est.nombres} ${est.apellidos}'.toLowerCase();
                          final correo = (est.correo ?? '').toLowerCase();
                          return nombre.contains(value.toLowerCase()) || correo.contains(value.toLowerCase());
                        }).toList();
                      });
                    },
                  ),
                ),
                ...filteredEstudiantes.map((estudiante) {
                  return SimpleDialogOption(
                    child: Text('${estudiante.nombres} ${estudiante.apellidos}'),
                    onPressed: () {
                      Navigator.pop(context);
                      _enviarCorreoAEstudiante(estudiante);
                    },
                  );
                }),
                if (filteredEstudiantes.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('No se encontraron estudiantes.'),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool esEscritorio = MediaQuery.of(context).size.width > 700;
    final double cardWidth = esEscritorio ? 650 : double.infinity;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'INICIO',
        actions: [
          if (_citasPendientesCount > 0)
            Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.calendar_today), // Cambiado a icono de calendario
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
              icon: const Icon(Icons.calendar_today), // Cambiado a icono de calendario
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
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: cardWidth,
            maxHeight: esEscritorio ? 600 : 800,
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: esEscritorio ? 24 : 8),
                Text(
                  'Bienvenido al panel de control, $_userName',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 18),
                Card(
                  elevation: 6,
                  color: Colors.white70,
                  margin: const EdgeInsets.symmetric(vertical: 0, horizontal: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
                    child: Column(
                      children: [
                        // Card de Cantidad de Estudiantes con navegación
                        InfoCard(
                          title: 'Cantidad de Estudiantes',
                          value: '$_totalEstudiantes',
                          icon: Icons.people_alt,
                          color: AppColors.primary,
                          onTap: () {
                            Navigator.pushNamed(context, app_routes.AppRoutes.estudiantesList);
                          },
                        ),
                        // Card de CONAPDIS con indicador y porcentaje al lado
                        InfoCard(
                          title: 'Estudiantes registrados en el CONAPDIS',
                          value: _totalEstudiantes > 0
                              ? '$_conapdisCount / $_totalEstudiantes   (${((_conapdisCount / _totalEstudiantes) * 100).toStringAsFixed(1)}%)'
                              : '$_conapdisCount / $_totalEstudiantes',
                          iconWidget: _totalEstudiantes > 0
                              ? CircularPercentIndicator(
                                  radius: 28,
                                  lineWidth: 8,
                                  percent: _conapdisCount / _totalEstudiantes,
                                  center: const Icon(Icons.verified_user, color: AppColors.info, size: 22),
                                  progressColor: AppColors.primary,
                                  backgroundColor: Colors.grey[300]!,
                                  animation: true,
                                )
                              : const Icon(Icons.verified_user, color: AppColors.info, size: 32),
                          color: AppColors.info,
                          onTap: null,
                          extraContent: null,
                        ),
                        if (_totalEstudiantes > 0)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 18.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                            ),
                          ),
                        InfoCard(
                          title: 'Incidentes en el Mes',
                          value: '$_incidenciasMesCount',
                          icon: Icons.warning_amber,
                          color: AppColors.warning,
                          onTap: () {
                            Navigator.pushNamed(context, app_routes.AppRoutes.incidenciasList);
                          },
                        ),
                        InfoCard(
                          title: 'Informar a Estudiante de Cita',
                          value: 'Acción Rápida',
                          icon: Icons.calendar_today,
                          color: AppColors.success,
                          onTap: _mostrarDialogoSeleccionEstudiante,
                        ),
                        const SizedBox(height: 20),
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    // Se llama cuando regresas a HomeScreen
    _fetchCitasPendientesCount();
    _fetchIncidenciasMesCount();
    _fetchTotalEstudiantes();
    _fetchConapdisCount();
    _loadUserData();
    super.didPopNext();
  }
}