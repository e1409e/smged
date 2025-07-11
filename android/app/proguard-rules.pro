# Reglas de ProGuard/R8 para las bibliotecas de WindowManager de AndroidX

# Mantener todas las clases y sus miembros del paquete androidx.window y sus subpaquetes.
# Esto es crucial para bibliotecas como WindowManager, Activity Embedding, y Extension APIs.
-keep class androidx.window.** { *; }

# Estas reglas específicas ya no son estrictamente necesarias si la de arriba está,
# pero no hacen daño y pueden servir como recordatorio.
-keep class androidx.window.extensions.** { *; }
-keep class androidx.window.sidecar.** { *; }
-keep class androidx.window.embedding.** { *; }
-keep class androidx.window.area.** { *; }

# Mantener todas las clases anotadas con @Keep (una buena práctica general)
-keepnames @androidx.annotation.Keep class *
-keepclassmembers class * {
    @androidx.annotation.Keep <methods>;
}