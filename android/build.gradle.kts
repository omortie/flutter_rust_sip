group = "com.example.flutter_rust_sip"
version = "1.0"

plugins {
    id("com.android.library")
    id("kotlin-android")
}

android {
    namespace = "com.example.flutter_rust_sip"
    compileSdk = 36

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        minSdk = 24
    }
}

dependencies {
    implementation("org.jetbrains.kotlin:kotlin-stdlib:2.1.0")
}

apply(from = "../cargokit/gradle/plugin.gradle")

extensions.configure<Any>("cargokit") {
    withGroovyBuilder {
        setProperty("manifestDir", "../rust")
        setProperty("libname", "flutter_rust_sip")
    }
}
