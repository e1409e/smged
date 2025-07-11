plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.smged"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"
    

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    // --- START SIGNING CONFIGURATION ---
    // This block defines the signing configurations for your build types.
    signingConfigs {
        create("release") {
            // Check if the signing properties are available from the root build.gradle.kts
            // This ensures Gradle can find your keystore and its passwords.
            if (project.hasProperty("MYAPP_UPLOAD_STORE_FILE")) {
                storeFile = file(project.property("MYAPP_UPLOAD_STORE_FILE") as String)
                storePassword = project.property("MYAPP_UPLOAD_STORE_PASSWORD") as String
                keyAlias = project.property("MYAPP_UPLOAD_KEY_ALIAS") as String
                keyPassword = project.property("MYAPP_UPLOAD_KEY_PASSWORD") as String
            }
        }
    }
    // --- END SIGNING CONFIGURATION ---

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.smged"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // Habilita la minificación del código para reducir el tamaño de la APK.
            isMinifyEnabled = false // Set to true if you want R8 enabled for release
            // Habilita la eliminación de recursos no utilizados para optimizar la APK.
            isShrinkResources = false // Set to true if you want R8 enabled for release
            // Define los archivos de reglas ProGuard para ofuscación y optimización.
            // Asegúrate de usar comillas dobles para las cadenas de texto.
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )

            // --- Apply the signing configuration to the release build type ---
            // This line tells Gradle to use the "release" signing config defined above
            // when building your release APK.
            signingConfig = signingConfigs.getByName("release")
        }
        // You can also add a debug block if needed, but signing isn't typically required for debug.
        // debug {
        //     isMinifyEnabled = false
        //     isShrinkResources = false
        // }
    }
}

flutter {
    source = "../.."
}