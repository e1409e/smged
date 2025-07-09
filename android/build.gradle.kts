// android/build.gradle
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Configura el directorio de construcción para el proyecto raíz de Android.
// Esto moverá el directorio 'build' de Android a la raíz de tu proyecto Flutter.
// Por ejemplo, si tu proyecto Flutter es 'mi_app', el build de Android estará en 'mi_app/build'.
rootProject.buildDir = file('../build')

subprojects {
    project.evaluationDependsOn(":app") // Asegura que 'app' se evalúe primero
    // Opcional: Si quieres que los subproyectos tengan sus builds dentro del nuevo buildDir raíz.
    // Esto es común si tienes módulos Gradle en tu proyecto Android.
    // Si solo tienes un módulo 'app', esta línea puede no ser estrictamente necesaria
    // para el funcionamiento básico, pero es una buena práctica para proyectos multi-módulo.
    project.buildDir = file("${rootProject.buildDir}/${project.name}")
}


tasks.register<Delete>("clean") {
    // Esto eliminará el directorio de construcción configurado para el rootProject de Android
    // que ahora está en la raíz de tu proyecto Flutter (mi_app/build).
    // También limpiará los subdirectorios de los módulos si la línea de subproject.buildDir se aplica.
    delete(rootProject.buildDir)
}