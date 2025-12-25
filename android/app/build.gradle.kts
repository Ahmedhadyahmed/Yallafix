plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.yala_fix"
    // Some plugins require compiling against Android SDK 36 (or higher). Bump compileSdk to 36.
    compileSdk = 35  // ✅ Updated for Firebase and plugin compatibility

    // ✅ Force NDK 27 (required by Firebase plugins)
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.yala_fix"
        // Firebase Auth requires minSdk 23; set explicitly instead of using flutter.minSdkVersion
        minSdk = 23
        // Align targetSdk with compileSdk so plugins that require SDK 36 build without warnings
        targetSdk = 35
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // ✅ Enable multidex (required for Firebase/Firestore)
        multiDexEnabled = true
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

// ✅ Add Firebase dependencies
dependencies {
    // Firebase BoM (Bill of Materials) - manages versions automatically
    implementation(platform("com.google.firebase:firebase-bom:32.7.4"))

    // Firebase products (versions managed by BoM)
    implementation("com.google.firebase:firebase-auth")
    implementation("com.google.firebase:firebase-firestore")

    // Multidex support
    implementation("androidx.multidex:multidex:2.0.1")
}
