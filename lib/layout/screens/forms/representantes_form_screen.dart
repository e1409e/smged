import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smged/layout/widgets/custom_colors.dart';
import 'package:smged/layout/widgets/custom_dropdown_button.dart';
import 'package:smged/layout/widgets/custom_dataPickerForm.dart';
import 'package:smged/api/models/estudiante.dart';
import 'package:smged/api/models/representante.dart';
import 'package:smged/api/services/estudiantes_service.dart';
import 'package:smged/api/services/representantes_service.dart';
import 'package:smged/api/exceptions/api_exception.dart';
import 'package:collection/collection.dart';

class RepresentantesFormScreen extends StatefulWidget {
  final Representante? representanteToEdit;
  final int? idEstudianteFijo;

  const RepresentantesFormScreen({
    super.key,
    this.representanteToEdit,
    this.idEstudianteFijo,
  });

  @override
  State<RepresentantesFormScreen> createState() => _RepresentantesFormScreenState();
}

class _RepresentantesFormScreenState extends State<RepresentantesFormScreen> {
  Representante? _representanteToEdit;
  int? _idEstudianteFijoArg;

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _parentescoController = TextEditingController();
  final TextEditingController _cedulaController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _lugarNacimientoController = TextEditingController();
  final TextEditingController _fechaNacimientoController = TextEditingController();
  final TextEditingController _direccionController = TextEditingController();
  final TextEditingController _ocupacionController = TextEditingController();
  final TextEditingController _lugarTrabajoController = TextEditingController();
  final TextEditingController _estadoController = TextEditingController();
  final TextEditingController _municipioController = TextEditingController();
  final TextEditingController _departamentoController = TextEditingController();
  final TextEditingController _estadoCivilController = TextEditingController();

  List<Estudiante> _estudiantes = [];
  Estudiante? _selectedEstudiante;

  final EstudiantesService _estudiantesService = EstudiantesService();
  final RepresentantesService _representantesService = RepresentantesService();

  bool _isLoadingEstudiantes = true;
  String? _estudiantesError;
  bool _isSaving = false;
  bool _initialized = false;
  DateTime? _fechaNacimientoDate;

  Map<String, List<String>>? _validationErrors; // Para errores de validación API

  // Reemplaza el campo de cédula por este bloque:
  String _cedulaPrefix = 'V-';

  @override
  void initState() {
    super.initState();
    _idEstudianteFijoArg = widget.idEstudianteFijo;
    _representanteToEdit = widget.representanteToEdit;
    _fetchEstudiantes();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      if (_representanteToEdit != null) {
        _nombreController.text = _representanteToEdit!.nombreRepre;
        _parentescoController.text = _representanteToEdit!.parentesco;
        if (_representanteToEdit!.cedulaRepre.startsWith('V-')) {
          _cedulaPrefix = 'V-';
          _cedulaController.text = _representanteToEdit!.cedulaRepre.substring(2);
        } else if (_representanteToEdit!.cedulaRepre.startsWith('E-')) {
          _cedulaPrefix = 'E-';
          _cedulaController.text = _representanteToEdit!.cedulaRepre.substring(2);
        } else {
          _cedulaController.text = _representanteToEdit!.cedulaRepre;
        }
        _telefonoController.text = _representanteToEdit!.telefonoRepre;
        _correoController.text = _representanteToEdit!.correoRepre;
        _lugarNacimientoController.text = _representanteToEdit!.lugarNacimiento;
        try {
          _fechaNacimientoDate = DateTime.tryParse(_representanteToEdit!.fechaNacimiento) ??
              _parseFecha(_representanteToEdit!.fechaNacimiento);
        } catch (_) {
          _fechaNacimientoDate = null;
        }
        _fechaNacimientoController.text = _representanteToEdit!.fechaNacimiento;
        _direccionController.text = _representanteToEdit!.direccion;
        _ocupacionController.text = _representanteToEdit!.ocupacion;
        _lugarTrabajoController.text = _representanteToEdit!.lugarTrabajo;
        _estadoController.text = _representanteToEdit!.estado;
        _municipioController.text = _representanteToEdit!.municipio;
        _departamentoController.text = _representanteToEdit!.departamento;
        _estadoCivilController.text = _representanteToEdit!.estadoCivil;
      }
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _parentescoController.dispose();
    _cedulaController.dispose();
    _telefonoController.dispose();
    _correoController.dispose();
    _lugarNacimientoController.dispose();
    _fechaNacimientoController.dispose();
    _direccionController.dispose();
    _ocupacionController.dispose();
    _lugarTrabajoController.dispose();
    _estadoController.dispose();
    _municipioController.dispose();
    _departamentoController.dispose();
    _estadoCivilController.dispose();
    super.dispose();
  }

  DateTime? _parseFecha(String fecha) {
    try {
      final parts = fecha.split('/');
      if (parts.length == 3) {
        return DateTime(
          int.parse(parts[2]),
          int.parse(parts[1]),
          int.parse(parts[0]),
        );
      }
    } catch (_) {}
    return null;
  }

  Future<void> _fetchEstudiantes() async {
    setState(() {
      _isLoadingEstudiantes = true;
      _estudiantesError = null;
    });
    try {
      final fetchedEstudiantes = await _estudiantesService.obtenerTodosLosEstudiantes();
      if (!mounted) return;
      setState(() {
        _estudiantes = fetchedEstudiantes;
        _setInitialEstudianteSelection();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _estudiantesError = 'Error al cargar estudiantes: ${e.toString()}';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingEstudiantes = false;
        });
      }
    }
  }

  void _setInitialEstudianteSelection() {
    if (_representanteToEdit != null && _representanteToEdit!.idEstudiante != null) {
      final initialEstudiante = _estudiantes.firstWhereOrNull(
        (e) => e.idEstudiante == _representanteToEdit!.idEstudiante,
      );
      if (initialEstudiante != null) {
        _selectedEstudiante = initialEstudiante;
      }
    } else if (_idEstudianteFijoArg != null) {
      final estudianteFijo = _estudiantes.firstWhereOrNull(
        (e) => e.idEstudiante == _idEstudianteFijoArg,
      );
      if (estudianteFijo != null) {
        _selectedEstudiante = estudianteFijo;
      }
    }
  }

  Future<void> _saveRepresentante() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedEstudiante == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecciona un estudiante.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
      _validationErrors = null;
    });

    try {
      final representantePayload = Representante(
        idRepresentante: _representanteToEdit?.idRepresentante,
        idEstudiante: _selectedEstudiante!.idEstudiante!,
        nombreRepre: _nombreController.text.trim(),
        parentesco: _parentescoController.text.trim(),
        cedulaRepre: _cedulaPrefix + _cedulaController.text.trim(),
        telefonoRepre: _telefonoController.text.trim(),
        correoRepre: _correoController.text.trim(),
        lugarNacimiento: _lugarNacimientoController.text.trim(),
        fechaNacimiento: _fechaNacimientoDate != null
            ? _fechaNacimientoDate!.toIso8601String().split('T').first
            : '',
        direccion: _direccionController.text.trim(),
        ocupacion: _ocupacionController.text.trim(),
        lugarTrabajo: _lugarTrabajoController.text.trim(),
        estado: _estadoController.text.trim(),
        municipio: _municipioController.text.trim(),
        departamento: _departamentoController.text.trim(),
        estadoCivil: _estadoCivilController.text.trim(),
      );

      if (_representanteToEdit != null) {
        await _representantesService.editarRepresentante(
          _representanteToEdit!.idRepresentante!,
          representantePayload,
        );
      } else {
        await _representantesService.crearRepresentante(representantePayload);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _representanteToEdit == null
                ? 'Representante registrado exitosamente.'
                : 'Representante actualizado exitosamente.',
          ),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop(true);
    } on ValidationException catch (e) {
      setState(() {
        _validationErrors = e.errors;
        _isSaving = false; // <-- Asegúrate de poner esto aquí también
      });
      if (e.errors['general'] != null) {
        _showErrorSnackBar(e.errors['general']!.join(', '));
      }
      _formKey.currentState!.validate();
    } on ApiException catch (e) {
      setState(() {
        _isSaving = false;
      });
      _showErrorSnackBar('Error: ${e.message}');
    } catch (e) {
      setState(() {
        _isSaving = false;
      });
      _showErrorSnackBar('Error inesperado al guardar representante.');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  String? _fieldError(String field) {
    if (_validationErrors != null && _validationErrors![field] != null) {
      return _validationErrors![field]!.join('\n');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final bool esEscritorio = MediaQuery.of(context).size.width > 700;
    final double formWidth = esEscritorio ? 500 : double.infinity;

    final bool estudianteFieldDisabled =
        (_idEstudianteFijoArg != null) || (_representanteToEdit != null);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _representanteToEdit == null
              ? 'Registrar Representante'
              : 'Editar Representante',
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: formWidth),
            child: Card(
              elevation: 8.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        _representanteToEdit == null
                            ? 'Nuevo Representante'
                            : 'Editar Representante',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20.0),
                      CustomDropdownButton<Estudiante>(
                        labelText: 'Estudiante',
                        hintText: 'Selecciona un estudiante',
                        prefixIcon: Icons.person_search,
                        isLoading: _isLoadingEstudiantes,
                        errorMessage: _estudiantesError,
                        items: _estudiantes,
                        value: _selectedEstudiante,
                        onChanged: (newValue) {
                          if (!estudianteFieldDisabled) {
                            setState(() {
                              _selectedEstudiante = newValue;
                            });
                          }
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Por favor, selecciona un estudiante.';
                          }
                          return null;
                        },
                        itemDisplayText: (estudiante) =>
                            '${estudiante.nombres} ${estudiante.apellidos}',
                        itemSearchFilter: (estudiante, query) {
                          final fullText =
                              '${estudiante.nombres} ${estudiante.apellidos} ${estudiante.cedula}'
                                  .toLowerCase();
                          return fullText.contains(query.toLowerCase());
                        },
                        enabled: !estudianteFieldDisabled,
                      ),
                      const SizedBox(height: 16.0),
                      TextFormField(
                        controller: _nombreController,
                        decoration: const InputDecoration(
                          labelText: 'Nombre del Representante',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, introduce el nombre.';
                          }
                          final err = _fieldError('nombre_repre');
                          return err;
                        },
                      ),
                      const SizedBox(height: 16.0),
                      TextFormField(
                        controller: _parentescoController,
                        decoration: const InputDecoration(
                          labelText: 'Parentesco',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.family_restroom),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, indica el parentesco.';
                          }
                          final err = _fieldError('parentesco');
                          return err;
                        },
                      ),
                      const SizedBox(height: 16.0),
                      // CÉDULA (igual que en estudiantes, solo números, longitud 7-9)
                      Row(
                        children: [
                          DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _cedulaPrefix,
                              items: const [
                                DropdownMenuItem(value: 'V-', child: Text('V-')),
                                DropdownMenuItem(value: 'E-', child: Text('E-')),
                              ],
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  setState(() {
                                    _cedulaPrefix = newValue;
                                  });
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 8.0),
                          Expanded(
                            child: TextFormField(
                              controller: _cedulaController,
                              decoration: const InputDecoration(
                                labelText: 'Cédula',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.badge),
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(9),
                              ],
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor, introduce la cédula.';
                                }
                                if (value.length < 7 || value.length > 9) {
                                  return 'La cédula debe tener entre 7 y 9 dígitos.';
                                }
                                final err = _fieldError('cedula_repre');
                                return err;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16.0),
                      // TELÉFONO (solo números, longitud mínima 7, máxima 11)
                      TextFormField(
                        controller: _telefonoController,
                        decoration: const InputDecoration(
                          labelText: 'Teléfono',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.phone),
                        ),
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(11),
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, introduce el teléfono.';
                          }
                          if (value.length < 7) {
                            return 'El teléfono debe tener al menos 7 dígitos.';
                          }
                          final err = _fieldError('telefono_repre');
                          return err;
                        },
                      ),
                      const SizedBox(height: 16.0),
                      // CORREO (debe contener @ si no está vacío)
                      TextFormField(
                        controller: _correoController,
                        decoration: const InputDecoration(
                          labelText: 'Correo',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.email),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value != null && value.isNotEmpty && !value.contains('@')) {
                            return 'Introduce un correo electrónico válido.';
                          }
                          final err = _fieldError('correo_repre');
                          return err;
                        },
                      ),
                      const SizedBox(height: 16.0),
                      TextFormField(
                        controller: _lugarNacimientoController,
                        decoration: const InputDecoration(
                          labelText: 'Lugar de Nacimiento',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.location_city),
                        ),
                        validator: (value) {
                          final err = _fieldError('lugar_nacimiento');
                          return err;
                        },
                      ),
                      const SizedBox(height: 16.0),
                      DatePickerFormField(
                        labelText: 'Fecha de Nacimiento',
                        initialDate: _fechaNacimientoDate,
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                        prefixIcon: Icons.cake,
                        helpText: 'Selecciona la fecha de nacimiento',
                        onChanged: (date) {
                          setState(() {
                            _fechaNacimientoDate = date;
                          });
                        },
                        validator: (_) {
                          if (_fechaNacimientoDate == null) {
                            return 'Por favor, selecciona la fecha de nacimiento.';
                          }
                          final err = _fieldError('fecha_nacimiento');
                          return err;
                        },
                      ),
                      const SizedBox(height: 16.0),
                      TextFormField(
                        controller: _direccionController,
                        decoration: const InputDecoration(
                          labelText: 'Dirección',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.home),
                        ),
                        maxLines: 2,
                        validator: (value) {
                          final err = _fieldError('direccion');
                          return err;
                        },
                      ),
                      const SizedBox(height: 16.0),
                      TextFormField(
                        controller: _ocupacionController,
                        decoration: const InputDecoration(
                          labelText: 'Ocupación',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.work),
                        ),
                        validator: (value) {
                          final err = _fieldError('ocupacion');
                          return err;
                        },
                      ),
                      const SizedBox(height: 16.0),
                      TextFormField(
                        controller: _lugarTrabajoController,
                        decoration: const InputDecoration(
                          labelText: 'Lugar de Trabajo',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.business),
                        ),
                        validator: (value) {
                          final err = _fieldError('lugar_trabajo');
                          return err;
                        },
                      ),
                      const SizedBox(height: 16.0),
                      TextFormField(
                        controller: _estadoController,
                        decoration: const InputDecoration(
                          labelText: 'Estado',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.map),
                        ),
                        validator: (value) {
                          final err = _fieldError('estado');
                          return err;
                        },
                      ),
                      const SizedBox(height: 16.0),
                      TextFormField(
                        controller: _municipioController,
                        decoration: const InputDecoration(
                          labelText: 'Municipio',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.location_on),
                        ),
                        validator: (value) {
                          final err = _fieldError('municipio');
                          return err;
                        },
                      ),
                      const SizedBox(height: 16.0),
                      TextFormField(
                        controller: _departamentoController,
                        decoration: const InputDecoration(
                          labelText: 'Departamento',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.apartment),
                        ),
                        validator: (value) {
                          final err = _fieldError('departamento');
                          return err;
                        },
                      ),
                      const SizedBox(height: 16.0),
                      TextFormField(
                        controller: _estadoCivilController,
                        decoration: const InputDecoration(
                          labelText: 'Estado Civil',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.group),
                        ),
                        validator: (value) {
                          final err = _fieldError('estado_civil');
                          return err;
                        },
                      ),
                      const SizedBox(height: 24.0),
                      ElevatedButton.icon(
                        icon: _isSaving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.save),
                        label: Text(
                          _representanteToEdit == null
                              ? 'Registrar Representante'
                              : 'Actualizar Representante',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: _isSaving ? null : _saveRepresentante,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}