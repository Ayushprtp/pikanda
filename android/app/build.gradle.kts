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
    namespace = "com.ayushprtp.pikanda"
    compileSdk = flutter.compileSdkVersion
//     ndkVersion = flutter.ndkVersion
    ndkVersion = "29.0.13113456"
        compileOptions {
            // Required by flutter_local_notifications (and other plugins) to
            // backport newer java.time APIs to older Android versions.
            isCoreLibraryDesugaringEnabled = true
            sourceCompatibility = JavaVersion.VERSION_17
            targetCompatibility = JavaVersion.VERSION_17
        }

        kotlinOptions {
            jvmTarget = "17"
        }

    defaultConfig {
        applicationId = "com.ayushprtp.pikanda"
        // Android 6.0+ — covers effectively every device in use.
        // (mobile_scanner/record require 23; don't go lower.)
        minSdk = maxOf(23, flutter.minSdkVersion)
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
    }

    buildTypes {
        getByName("release") {
            // Signed with the debug key so `flutter build apk --release` is
            // installable out of the box. Replace with a real upload keystore
            // before publishing to the Play Store.
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
