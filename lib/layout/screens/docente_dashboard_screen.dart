import 'package:flutter/material.dart';
import 'package:smged/layout/widgets/custom_colors.dart';
import 'package:smged/api/services/estudiantes_service.dart';
import 'package:smged/api/models/estudiante.dart';
import 'lista_estudiantes_docentes.dart';

/// Pantalla de bienvenida para el rol de Docente.
class DocenteDashboardScreen extends StatefulWidget {
  final VoidCallback onLogout;

  const DocenteDashboardScreen({super.key, required this.onLogout});

  @override
  State<DocenteDashboardScreen> createState() => _DocenteDashboardScreenState();
}

class _DocenteDashboardScreenState extends State<DocenteDashboardScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;
  // Añadimos una variable para almacenar el número de estudiantes.
  int _totalEstudiantes = 0;
  // Añadimos una variable para controlar la carga inicial del conteo de estudiantes
  bool _isCountingStudents = true;

  @override
  void initState() {
    super.initState();
    // Llamar a la función para obtener el conteo de estudiantes cuando se inicialice la pantalla
    _obtenerTotalEstudiantes();
  }

  /// Función para confirmar el cierre de sesión.
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
            child: const Text(
              'Cerrar sesión',
              style: TextStyle(color: AppColors.error),
            ),
            onPressed: () {
              Navigator.of(context).pop();
              widget.onLogout();
            },
          ),
        ],
      ),
    );
  }

  /// Función para buscar estudiantes por un término.
  Future<void> _buscarEstudiante() async {
    final termino = _searchController.text.trim();
    if (termino.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      final estudiantes = await EstudiantesService().obtenerTodosLosEstudiantes();
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ListaEstudiantesDocentes(
            estudiantes: estudiantes,
            terminoBusqueda: termino,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al buscar estudiantes: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Nueva función para obtener el número total de estudiantes.
  Future<void> _obtenerTotalEstudiantes() async {
    setState(() {
      _isCountingStudents = true; // Indicar que estamos cargando el conteo
    });
    try {
      final estudiantes = await EstudiantesService().obtenerTodosLosEstudiantes();
      if (mounted) {
        setState(() {
          _totalEstudiantes = estudiantes.length; // Actualizar el contador con el número de estudiantes
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al obtener el total de estudiantes: $e')),
        );
      }
    } finally {
      setState(() {
        _isCountingStudents = false; // Indica que ha terminado de cargar el conteo
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.school, color: Colors.white),
            const SizedBox(width: 24),
            const Text(
              'Panel de Docente',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        backgroundColor: AppColors.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Cerrar sesión',
            onPressed: () => _confirmLogout(context),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final bool esEscritorio = constraints.maxWidth > 700;
              final double cardWidth = esEscritorio ? 600 : 400;

              return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: cardWidth,
                    ),
                    child: Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.school,
                              size: 80,
                              color: AppColors.primary,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              '¡Hola, Docente!',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Busca a un Estudiante',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _searchController,
                              decoration: const InputDecoration(
                                hintText: 'Ingrese nombre, apellido o cédula',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.search),
                              ),
                              onSubmitted: (_) => _buscarEstudiante(),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: _isLoading ? null : _buscarEstudiante,
                                icon: _isLoading
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                      )
                                    : const Icon(Icons.search),
                                label: const Text('Buscar'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: AppColors.textTitle,
                                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Texto centrado, en negrita, itálica y subrayado debajo de la card
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Center(
                      child: _isCountingStudents
                          ? const CircularProgressIndicator() // Mostrar un indicador de carga mientras se obtienen los datos
                          : Text(
                              'Hay un total de $_totalEstudiantes Estudiantes', // Usamos el valor del estado aquí
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                                fontSize: 18,
                              ),
                            ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}