plugins {
    id("com.android.application")
    id("kotlin-android")
    id("com.google.gms.google-services") // Đảm bảo plugin Google Services được kích hoạt
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.app"
    compileSdk = 34
    
    // Chỉ định phiên bản NDK để tránh xung đột giữa các plugin
    ndkVersion = "27.0.12077973"
    
    defaultConfig {
        applicationId = "com.example.app"
        minSdk = 21 // API 21 is required for Google Sign-In
        targetSdk = 34
        versionCode = 1
        versionName = "1.0"
    }

    buildTypes {
        release {
            isMinifyEnabled = false
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    buildFeatures {
        viewBinding = true
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("com.google.android.gms:play-services-auth:20.7.0") // Thêm phụ thuộc Play Services Auth
}
