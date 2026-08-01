import org.jetbrains.kotlin.gradle.dsl.JvmTarget
import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    id("com.google.firebase.firebase-perf")
    id("com.google.firebase.crashlytics")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.bloot.app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlin {
        compilerOptions {
            jvmTarget.set(JvmTarget.JVM_17)
        }
    }

    defaultConfig {
        applicationId = "com.bloot.app"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        missingDimensionStrategy("default", "production")
    }

    signingConfigs {
        create("release") {
            // Reads the upload-key credentials from key.properties (gitignored).
            // See docs/release_checklist.md for how to recreate the keystore.
            val keystoreProperties = Properties()
            val keyPropsFile = rootProject.file("key.properties")
            if (keyPropsFile.exists()) {
                keystoreProperties.load(FileInputStream(keyPropsFile))
            }

            val storeFilePath = keystoreProperties.getProperty("storeFile")
            storeFile = if (storeFilePath != null) {
                rootProject.file(storeFilePath)
            } else {
                logger.warn(
                    "No release keystore configured in key.properties; " +
                        "falling back to the Android debug keystore for this build.",
                )
                file("${System.getProperty("user.home")}/.android/debug.keystore")
            }

            keyAlias = keystoreProperties.getProperty("keyAlias", "androiddebugkey")
            keyPassword = keystoreProperties.getProperty("keyPassword", "android")
            storePassword = keystoreProperties.getProperty("storePassword", "android")
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
            // Disable Crashlytics mapping file upload during local builds to avoid
            // network errors. Re-enable when building on CI with proper credentials.
            configure<com.google.firebase.crashlytics.buildtools.gradle.CrashlyticsExtension> {
                mappingFileUploadEnabled = false
            }
        }
    }
}

dependencies {
    // Firebase App Distribution Feedback SDK.
    // The API artifact is a no-op stub required in all builds so MainActivity
    // and the Flutter plugin compile and run safely. The full SDK stays
    // debug-only: it adds REQUEST_INSTALL_PACKAGES, which Play Console
    // rejects for apps that are not installers/updaters, so it must not ship
    // in release builds. Dart-side calls degrade gracefully (failures are
    // caught in AppInitializer.initAppDistribution).
    implementation("com.google.firebase:firebase-appdistribution-api:16.0.0-beta14")
    debugImplementation("com.google.firebase:firebase-appdistribution:16.0.0-beta14")
}

flutter {
    source = "../.."
}
