plugins {
    id("com.android.library")
    id("org.jetbrains.kotlin.android")
}

android {
    namespace = "com.indianequipments.neonupdater"
    compileSdk = 36

    defaultConfig {
        minSdk = 23
        manifestPlaceholders["godotPluginName"] = "NeonAndroidUpdater"
        manifestPlaceholders["godotPluginPackageName"] = "com.indianequipments.neonupdater"
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
}

dependencies {
    implementation("org.godotengine:godot:4.6.3.stable")
    implementation("androidx.core:core:1.15.0")
}
