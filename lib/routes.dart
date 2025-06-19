// lib/routes.dart
import 'package:flutter/material.dart';

import 'package:smged/layout/screens/estudiantes_screen.dart';
import 'package:smged/layout/screens/forms/estudiante_form_screen.dart';
import 'package:smged/layout/screens/citas_screen.dart'; 
import 'package:smged/layout/screens/forms/cita_form_screen.dart';
import 'package:smged/layout/screens/facultades_screen.dart';
import 'package:smged/layout/screens/carreras_screen.dart';
import 'package:smged/layout/screens/usuarios_screen.dart'; 
import 'package:smged/layout/screens/historial_medico_screen.dart';
import 'package:smged/layout/screens/forms/historial_medico_form_screen.dart';

// Clase que importa las rutas
class AppRoutes {
  // rutas estudiantes
  static const String estudiantesList = '/estudiantes'; 
  static const String estudianteForm = '/estudianteForm'; 
  // rutas citas
  static const String citasList = '/citas'; 
  static const String citaForm = '/citaForm'; 
  // ruta facultades
  static const String facultades = '/facultades'; 
  // ruta carreras
  static const String carreras = '/carreras'; 
  // ruta usuarios
  static const String usuarios = '/usuarios'; 
  // rutas historial médico
   static const String historialesMedicosList = '/historialesMedicos';
    static const String historialMedicoForm = '/historialMedicoForm';
}

// Esta función solo devuelve un mapa de rutas para navegación INTERNA.
Map<String, WidgetBuilder> getApplicationRoutes() {
  return <String, WidgetBuilder>{
    // Rutas de Estudiantes
    AppRoutes.estudiantesList: (BuildContext context) =>
        const EstudiantesScreen(),
    AppRoutes.estudianteForm: (BuildContext context) =>
        const EstudianteFormScreen(),

    // Rutas de Citas
    AppRoutes.citasList: (BuildContext context) =>
        const CitasScreen(), 
    AppRoutes.citaForm: (BuildContext context) =>
        const CitaFormScreen(), 

    // Rutas de Facultades
    AppRoutes.facultades: (BuildContext context) => const FacultadesScreen(), 

    // Rutas de Carreras
    AppRoutes.carreras: (BuildContext context) => const CarrerasScreen(), 

    // Rutas de Usuarios
    AppRoutes.usuarios: (BuildContext context) => const UsuariosScreen(), 

    // Rutas de Historial Médico
    // ¡Nuevas entradas en el mapa para Historial Médico!
    AppRoutes.historialesMedicosList: (BuildContext context) =>
        const HistorialMedicoScreen(),
    AppRoutes.historialMedicoForm: (BuildContext context) =>
        const HistorialMedicoFormScreen(),

  };
}