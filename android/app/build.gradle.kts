plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("com.google.gms.google-services")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.trackmyread"
    compileSdk = 36

    defaultConfig {
        applicationId = "com.example.trackmyread"
        minSdk = flutter.minSdkVersion
        targetSdk = 36
        versionCode = 1
        versionName = "1.0"
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = "11"
    }

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

// App-level repositories
repositories {
    google()
    mavenCentral()
}

dependencies {
    // Only include what Flutter cannot manage natively
    // For your Flutter project with firebase_auth and firebase_core,
    // you do NOT need any Firebase dependencies here
}

flutter {
    source = "../.."
}
