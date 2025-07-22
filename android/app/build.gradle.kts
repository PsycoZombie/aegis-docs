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
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {

}
