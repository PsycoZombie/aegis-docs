plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.aegis_docs"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    kotlin {
        jvmToolchain(17)
    }

    defaultConfig {
        applicationId = "com.example.aegis_docs"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        getByName("release") {
            isMinifyEnabled = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("com.itextpdf:itextpdf:5.5.13.3")
    implementation("androidx.core:core-ktx:1.6.0")  // Core extensions for Kotlin
    implementation("androidx.appcompat:appcompat:1.3.0")  // For backward compatibility with Android APIs
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-core:1.7.3")
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.7.3")
    implementation("org.bouncycastle:bcmail-jdk15to18:1.70")
    implementation("org.bouncycastle:bcpkix-jdk15to18:1.70")
}
