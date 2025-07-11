// android/build.gradle.kts
// Importar clases necesarias al principio del archivo
import java.io.FileInputStream
import java.util.Properties

// Cargar las propiedades del keystore desde key.properties
// Este bloque debe ir lo más arriba posible para asegurar que las propiedades
// estén disponibles para los subproyectos (como 'app') cuando sean necesarias.
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

// Configurar las propiedades a nivel de proyecto para que el módulo de la aplicación pueda acceder a ellas.
// Esto también debe ir temprano para que los subproyectos tengan acceso a estas propiedades.
subprojects {
    project.ext.set("MYAPP_UPLOAD_STORE_FILE", keystoreProperties["storeFile"])
    project.ext.set("MYAPP_UPLOAD_STORE_PASSWORD", keystoreProperties["storePassword"])
    project.ext.set("MYAPP_UPLOAD_KEY_ALIAS", keystoreProperties["keyAlias"])
    project.ext.set("MYAPP_UPLOAD_KEY_PASSWORD", keystoreProperties["keyPassword"])
}

// allprojects block (generalmente para definir repositorios)
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Configura el directorio de construcción para el proyecto raíz de Android.
rootProject.buildDir = file("../build")

// El subprojects block para configurar directorios de build internos.
subprojects {
    project.evaluationDependsOn(":app") // Asegura que 'app' se evalúe primero
    project.buildDir = file("${rootProject.buildDir}/${project.name}")
}

// Tarea clean
tasks.register<Delete>("clean") {
    delete(rootProject.buildDir)
}

// Nota: Las configuraciones de `buildscript { ... }` para las dependencias de classpath
// (como las versiones de gradle-plugin y kotlin-gradle-plugin) suelen ir al principio
// del archivo, a veces antes incluso de las importaciones si la plantilla de Gradle lo requiere.
// Si las tienes, asegúrate de que estén correctamente ubicadas.
// buildscript {
//     repositories {
//         google()
//         mavenCentral()
//     }
//     dependencies {
//         classpath("com.android.tools.build:gradle:8.x.x") // Ejemplo: Comprueba tu versión real
//         classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:1.x.x") // Ejemplo: Comprueba tu versión real
//     }
// }