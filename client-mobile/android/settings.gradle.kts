pluginManagement {
    val flutterSdkPath =
        run {
            val properties = java.util.Properties()
            file("local.properties").inputStream().use { properties.load(it) }
            val flutterSdkPath = properties.getProperty("flutter.sdk")
            require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
            flutterSdkPath
        }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    // Floors enforced by Flutter 3.47.3's DependencyVersionChecker: AGP >= 8.11.1, KGP >= 2.2.20.
    // AGP is capped at 8.12.x, not at the newest 8.x: under AGP 8.13 the `flutter_webrtc` plugin
    // fails `checkDebugAarMetadata`, because it hardcodes `compileSdkVersion 31` while its own
    // AndroidX dependencies demand 33+. Verified by building on 8.11.1, 8.12.3 and 8.13.2.
    // Raising this needs flutter_webrtc >= 1.2.0, which is a major bump of the calls plugin.
    id("com.android.application") version "8.12.3" apply false
    id("org.jetbrains.kotlin.android") version "2.2.21" apply false
}

include(":app")
