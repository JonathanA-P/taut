import java.util.Base64

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Auto-inject .env variables into dart-defines if not passed via CLI
val envFile = rootProject.file("../.env")
if (envFile.exists()) {
    val encodedDefines = mutableListOf<String>()
    val existing = project.findProperty("dart-defines") as? String
    if (!existing.isNullOrBlank()) {
        encodedDefines.addAll(existing.split(","))
    }
    envFile.readLines().forEach { line ->
        val trimmed = line.trim()
        if (trimmed.isNotEmpty() && !trimmed.startsWith("#") && trimmed.contains("=")) {
            val b64 = Base64.getEncoder().encodeToString(trimmed.toByteArray(Charsets.UTF_8))
            if (!encodedDefines.contains(b64)) {
                encodedDefines.add(b64)
            }
        }
    }
    if (encodedDefines.isNotEmpty()) {
        project.extensions.extraProperties["dart-defines"] = encodedDefines.joinToString(",")
    }
}

android {
    namespace = "com.example.taut"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.example.taut"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    aaptOptions {
        noCompress.add("tflite")
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
