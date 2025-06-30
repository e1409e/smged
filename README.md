# 🎓 SISTEMA MULTIPLATAFORMAS PARA LA GESTIÓN DE ESTUDIANTES CON DISCAPACIDAD (SMGED)

**smged** es una aplicación **Flutter** para la gestión integral de estudiantes, citas, incidencias, reportes psicológicos, representantes, carreras, facultades y usuarios en una institución educativa. El sistema está diseñado para facilitar la administración y el seguimiento de información académica, médica y administrativa de los estudiantes.

---

## 📑 Tabla de Contenidos

- [✨ Características](#-características)
- [📁 Estructura del Proyecto](#-estructura-del-proyecto)
- [🗂️ Modelos de Datos](#️-modelos-de-datos)
- [🔗 Servicios API](#-servicios-api)
- [🖥️ Pantallas Principales](#️-pantallas-principales)
- [🧩 Utilidades y Widgets Personalizados](#-utilidades-y-widgets-personalizados)
- [📝 Reportes PDF](#-reportes-pdf)
- [⚙️ Configuración](#-configuración)
- [🗺️ Rutas de Navegación](#️-rutas-de-navegación)
- [🚀 Cómo Ejecutar](#-cómo-ejecutar)
- [🛠️ Notas de Desarrollo](#️-notas-de-desarrollo)
- [👥 Créditos](#-créditos)

---

## ✨ Características

- 👩‍🎓 Gestión de estudiantes, incluyendo datos personales, discapacidades y observaciones.
- 📅 Registro y seguimiento de citas médicas o administrativas.
- ⚠️ Administración de incidencias y reportes psicológicos.
- 👨‍👩‍👧‍👦 Gestión de representantes legales de los estudiantes.
- 🏛️ Administración de carreras, facultades y usuarios del sistema.
- 📝 Generación de reportes en PDF (listas, fichas, reportes psicológicos).
- 💻 Interfaz moderna y responsiva, con componentes personalizados.
- 🔗 Integración con servicios RESTful para persistencia de datos.

---

## 📁 Estructura del Proyecto

```text
lib/
├── api/
│   ├── exceptions/           # Excepciones personalizadas para manejo de errores API
│   ├── models/               # Modelos de datos (Estudiante, Cita, Incidencia, etc.)
│   └── services/             # Servicios para interactuar con la API REST
├── config.dart               # Configuración global (URLs, entornos)
├── layout/
│   ├── reports/              # Generación de reportes PDF
│   ├── screens/              # Pantallas principales y formularios
│   ├── utils/                # Utilidades para lógica de UI y helpers
│   └── widgets/              # Widgets personalizados (colores, tablas, etc.)
├── main.dart                 # Punto de entrada de la aplicación
└── routes.dart               # Definición de rutas de navegación
```

---

## 🗂️ Modelos de Datos

Ubicados en [`lib/api/models/`](lib/api/models):

- **Estudiante**: Datos personales, carrera, discapacidad, representante, etc.
- **Cita**: Fecha, motivo, estado (pendiente/realizada), estudiante asociado.
- **Incidencia**: Descripción, acuerdos, observaciones, fecha/hora, estudiante.
- **ReportePsicologico**: Motivo, síntesis, recomendaciones, estudiante.
- **Representante**: Datos personales y de contacto del representante legal.
- **Carrera** y **Facultad**: Información académica.
- **Usuario**: Datos de acceso y rol en el sistema.

---

## 🔗 Servicios API

Ubicados en [`lib/api/services/`](lib/api/services):

- **EstudiantesService**: CRUD de estudiantes.
- **CitasService**: Gestión de citas.
- **IncidenciasService**: Gestión de incidencias.
- **ReportePsicologicoService**: Gestión de reportes psicológicos.
- **RepresentantesService**: CRUD de representantes.
- **CarrerasService** y **FacultadesService**: Gestión académica.
- **AuthService**: Autenticación y manejo de sesión.
- **DiscapacidadesService**: Gestión de discapacidades.

---

## 🖥️ Pantallas Principales

Ubicadas en [`lib/layout/screens/`](lib/layout/screens):

- **EstudiantesScreen**: Listado y búsqueda de estudiantes.
- **CitasScreen**: Gestión y visualización de citas.
- **IncidenciasScreen**: Listado y registro de incidencias.
- **ReportePsicologicoScreen**: Visualización de reportes psicológicos.
- **RepresentantesScreen**: Gestión de representantes.
- **AdminDashboardScreen** y **HomeScreen**: Paneles de control según el rol.
- **Formularios**: Pantallas para crear/editar cada entidad (estudiante, cita, incidencia, etc.).

---

## 🧩 Utilidades y Widgets Personalizados

- **custom_colors.dart**: Paleta de colores personalizada.
- **custom_data_table.dart**: Tablas de datos adaptadas.
- **custom_dropdown_button.dart**: Dropdowns con búsqueda.
- **custom_dataPickerForm.dart**: Selector de fechas.
- **custom_drawer.dart**: Menú lateral con navegación y logout.
- **utils/**: Helpers para mostrar modales de información y lógica de UI.

---

## 📝 Reportes PDF

Ubicados en [`lib/layout/reports/`](lib/layout/reports):

- **estudiantes_report.dart**: Reporte detallado de estudiantes.
- **estudiante_lista_report.dart**: Listado masivo de estudiantes.
- **reporte_psicologico_report.dart**: Reporte PDF de informes psicológicos.

> Utilizan los paquetes [`pdf`](https://pub.dev/packages/pdf) y [`printing`](https://pub.dev/packages/printing) para la generación y previsualización/impresión de documentos.

---

## ⚙️ Configuración

El archivo [`lib/config.dart`](lib/config.dart) gestiona la URL base de la API, diferenciando entre entornos de desarrollo y producción, y soporta web, Android, iOS y escritorio.

---

## 🗺️ Rutas de Navegación

Definidas en [`lib/routes.dart`](lib/routes.dart) mediante la clase `AppRoutes`, que centraliza las rutas para cada pantalla y formulario.

---

## 🚀 Cómo Ejecutar

1. **Instala las dependencias:**
   ```sh
   flutter pub get
   ```

2. **Ejecuta la aplicación:**
   ```sh
   flutter run
   ```

3. **Compila para escritorio (ejemplo Windows):**
   ```sh
   flutter build windows
   ```

4. **Variables de entorno:**  
   Modifica `config.dart` si necesitas apuntar a una API diferente.

---

## 🛠️ Notas de Desarrollo

- El proyecto utiliza [`json_serializable`](https://pub.dev/packages/json_serializable) para la generación de modelos a partir de JSON.
- Los servicios API manejan errores y excepciones personalizadas.
- El diseño es responsivo y multiplataforma (web, móvil, escritorio).
- Los reportes PDF requieren permisos de almacenamiento en móvil/escritorio.
- El menú lateral (`CustomDrawer`) permite cerrar sesión y navegar entre módulos.
- El código está modularizado para facilitar el mantenimiento y la escalabilidad.

---

## 👥 Créditos

Desarrollado por el equipo de **smged**.

---

¿Tienes dudas o sugerencias?  
¡Contribuye o abre un issue!
