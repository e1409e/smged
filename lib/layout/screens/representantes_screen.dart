import 'package:flutter/material.dart';
import 'package:smged/api/models/representante.dart';
import 'package:smged/api/services/representantes_service.dart';
import 'package:smged/layout/widgets/custom_colors.dart';
import 'package:smged/routes.dart';
import 'package:smged/layout/screens/forms/representantes_form_screen.dart';

class RepresentantesScreen extends StatefulWidget {
  const RepresentantesScreen({super.key});

  @override
  State<RepresentantesScreen> createState() => _RepresentantesScreenState();
}

class _RepresentantesScreenState extends State<RepresentantesScreen> {
  final RepresentantesService _service = RepresentantesService();
  List<Representante> _representantes = [];
  bool _isLoading = true;
  String? _error;
  int? _idEstudiante;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is int) {
      _idEstudiante = args;
      _fetchRepresentantes();
    }
  }

  Future<void> _fetchRepresentantes() async {
    if (_idEstudiante == null) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final representante = await _service.obtenerRepresentantePorEstudiante(_idEstudiante!);
      setState(() {
        _representantes = representante != null ? [representante] : [];
      });
    } catch (e) {
      setState(() {
        _error = 'Error al cargar representantes: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _eliminarRepresentante(int idRepresentante) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar representante'),
        content: const Text('¿Estás seguro de eliminar este representante?'),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.pop(context, false),
          ),
          TextButton(
            child: const Text('Eliminar', style: TextStyle(color: AppColors.error)),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );
    if (confirm == true) {
      try {
        await _service.eliminarRepresentante(idRepresentante);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Representante eliminado exitosamente')),
          );
          _fetchRepresentantes();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al eliminar: $e')),
          );
        }
      }
    }
  }

  void _handleEditRepresentante(Representante representante) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => RepresentantesFormScreen(
          representanteToEdit: representante,
          idEstudianteFijo: _idEstudiante,
        ),
      ),
    );
    if (result == true) {
      _fetchRepresentantes();
    }
  }

  void _handleAddRepresentante() async {
    if (_idEstudiante == null) return;
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => RepresentantesFormScreen(
          idEstudianteFijo: _idEstudiante,
        ),
      ),
    );
    if (result == true) {
      _fetchRepresentantes();
    }
  }

  Widget _buildRepresentanteCard(Representante representante, double cardWidth) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: cardWidth),
        child: Card(
          elevation: 4,
          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nombre: ${representante.nombreRepre}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 6),
                Text('Parentesco: ${representante.parentesco}'),
                const SizedBox(height: 6),
                Text('Cédula: ${representante.cedulaRepre}'),
                const SizedBox(height: 6),
                Text('Teléfono: ${representante.telefonoRepre}'),
                const SizedBox(height: 6),
                Text('Correo: ${representante.correoRepre}'),
                const SizedBox(height: 6),
                Text('Lugar de Nacimiento: ${representante.lugarNacimiento}'),
                const SizedBox(height: 6),
                Text('Fecha de Nacimiento: ${representante.fechaNacimiento}'),
                const SizedBox(height: 6),
                Text('Dirección: ${representante.direccion}'),
                const SizedBox(height: 6),
                Text('Ocupación: ${representante.ocupacion}'),
                const SizedBox(height: 6),
                Text('Lugar de Trabajo: ${representante.lugarTrabajo}'),
                const SizedBox(height: 6),
                Text('Estado: ${representante.estado}'),
                const SizedBox(height: 6),
                Text('Municipio: ${representante.municipio}'),
                const SizedBox(height: 6),
                Text('Departamento: ${representante.departamento}'),
                const SizedBox(height: 6),
                Text('Estado Civil: ${representante.estadoCivil}'),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.edit),
                      label: const Text('Editar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => _handleEditRepresentante(representante),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.delete),
                      label: const Text('Eliminar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => _eliminarRepresentante(representante.idRepresentante!),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool esEscritorio = MediaQuery.of(context).size.width > 700;
    final double cardWidth = esEscritorio ? 600 : 400;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'REPRESENTANTES',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        actionsIconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refrescar',
            onPressed: _fetchRepresentantes,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      _error!,
                      style: const TextStyle(color: AppColors.error, fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: _representantes.isEmpty
                            ? Center(
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(maxWidth: cardWidth),
                                  child: Card(
                                    elevation: 4,
                                    margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                    child: Padding(
                                      padding: const EdgeInsets.all(24.0),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Text(
                                            'No hay representantes registrados para este estudiante.',
                                            style: TextStyle(fontSize: 16, color: Colors.grey),
                                            textAlign: TextAlign.center,
                                          ),
                                          const SizedBox(height: 18),
                                          SizedBox(
                                            width: double.infinity,
                                            child: ElevatedButton.icon(
                                              icon: const Icon(Icons.add),
                                              label: const Text('Agregar representante'),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: AppColors.primary,
                                                foregroundColor: Colors.white,
                                              ),
                                              onPressed: _handleAddRepresentante,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : ListView.separated(
                                itemCount: _representantes.length + 1,
                                separatorBuilder: (_, __) => const SizedBox(height: 16),
                                itemBuilder: (context, index) {
                                  if (index < _representantes.length) {
                                    final representante = _representantes[index];
                                    return _buildRepresentanteCard(representante, cardWidth);
                                  } else {
                                    // Botón debajo de la última card y con el mismo ancho
                                    return Center(
                                      child: SizedBox(
                                        width: cardWidth,
                                        child: ElevatedButton.icon(
                                          icon: const Icon(Icons.add),
                                          label: const Text('Agregar representante'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.primary,
                                            foregroundColor: Colors.white,
                                          ),
                                          onPressed: _handleAddRepresentante,
                                        ),
                                      ),
                                    );
                                  }
                                },
                              ),
                      ),
                    ],
                  ),
                ),
    );
  }
}