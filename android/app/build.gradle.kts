import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

val envKeystorePath = System.getenv("ANDROID_KEYSTORE_PATH")
val envKeystorePassword = System.getenv("ANDROID_KEYSTORE_PASSWORD")
val envKeyAlias = System.getenv("ANDROID_KEY_ALIAS")
val envKeyPassword = System.getenv("ANDROID_KEY_PASSWORD")

val hasFileKeystore = keystorePropertiesFile.exists() &&
    keystoreProperties.getProperty("storeFile") != null &&
    rootProject.file(keystoreProperties.getProperty("storeFile")).exists()

val hasEnvKeystore = !envKeystorePath.isNullOrEmpty() &&
    file(envKeystorePath).exists() &&
    !envKeystorePassword.isNullOrEmpty() &&
    !envKeyAlias.isNullOrEmpty()

val hasReleaseSigning = hasFileKeystore || hasEnvKeystore

android {
    namespace = "com.jobprep.app"
    compileSdk = 37
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    signingConfigs {
        create("release") {
            if (hasFileKeystore) {
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
                val storeFilePath = keystoreProperties.getProperty("storeFile")
                storeFile = rootProject.file(storeFilePath)
                storePassword = keystoreProperties.getProperty("storePassword")
            } else if (hasEnvKeystore) {
                keyAlias = envKeyAlias
                keyPassword = envKeyPassword ?: envKeystorePassword
                storeFile = file(envKeystorePath)
                storePassword = envKeystorePassword
            }
        }
    }

    defaultConfig {
        applicationId = "com.jobprep.app"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = if (hasReleaseSigning) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
        }
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
