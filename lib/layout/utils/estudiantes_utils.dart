// lib/layout/utils/estudiantes_utils.dart
import 'package:flutter/material.dart';
import 'package:smged/api/models/estudiante.dart'; // Asegúrate de importar tu modelo Estudiante

class EstudiantesUtils {
  static void showEstudianteInfoModal(BuildContext context, dynamic item) {
    // Es crucial castear el item a Estudiante para acceder a sus propiedades.
    final estudiante = item as Estudiante;

    // Formatear la fecha de nacimiento si existe
    String fechaNacimientoFormateada = estudiante.fechaNacimiento != null
        ? '${estudiante.fechaNacimiento!.day}/${estudiante.fechaNacimiento!.month}/${estudiante.fechaNacimiento!.year}'
        : 'N/A';

    // Formatear la fecha de registro si existe
    String fechaRegistroFormateada = estudiante.fechaRegistro != null
        ? '${estudiante.fechaRegistro!.day}/${estudiante.fechaRegistro!.month}/${estudiante.fechaRegistro!.year}'
        : 'N/A';

    // Formatear la fecha de actualización si existe
    String fechaActualizacionFormateada = estudiante.fechaActualizacion != null
        ? '${estudiante.fechaActualizacion!.day}/${estudiante.fechaActualizacion!.month}/${estudiante.fechaActualizacion!.year}'
        : 'N/A';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Información Detallada del Estudiante'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                // Campos obligatorios
                Text('Nombres: ${estudiante.nombres}'),
                Text('Apellidos: ${estudiante.apellidos}'),
                Text('Cédula: ${estudiante.cedula}'),
                Text('ID Estudiante: ${estudiante.idEstudiante}'),
                const Divider(), // Separador para legibilidad

                // Campos opcionales con manejo de N/A
                Text('Fecha de Nacimiento: $fechaNacimientoFormateada'),
                Text('Correo: ${estudiante.correo ?? 'N/A'}'),
                Text('Teléfono: ${estudiante.telefono ?? 'N/A'}'),
                //Text('Dirección: ${estudiante.direccion ?? 'N/A'}'),
                Text('Discapacidad: ${estudiante.discapacidad ?? 'N/A'}'),
                Text('Observaciones: ${estudiante.observaciones ?? 'N/A'}'),
                Text('Seguimiento: ${estudiante.seguimiento ?? 'N/A'}'),
                const Divider(),

                // Fechas de sistema
                Text('Fecha de Registro: $fechaRegistroFormateada'),
                
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cerrar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}