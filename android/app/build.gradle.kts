
import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.minseok.bangtal_memory.bangtal_memory"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    val keystoreProps = Properties()
    val keystoreFile = rootProject.file("key.properties")
    if (keystoreFile.exists()) {              // 없으면 debug keystore로 빌드
        keystoreProps.load(FileInputStream(keystoreFile))
    }

    signingConfigs {
        create("release") {                   // ★ 새 릴리스 서명
            keyAlias      = keystoreProps["keyAlias"]      as String?
            keyPassword   = keystoreProps["keyPassword"]   as String?
            storePassword = keystoreProps["storePassword"] as String?
            storeFile     = keystoreProps["storeFile"]     // String? → File?
                    ?.let { file(it as String) }
        }
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.minseok.bangtal_memory"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        getByName("release") {
            /* 4. 릴리스에 우리가 만든 signingConfig 지정 */
            signingConfig = signingConfigs.getByName("release")   // ★
            // 필요 시 ProGuard:
            // isMinifyEnabled = true
            // proguardFiles(getDefaultProguardFile("proguard-android.txt"),
            //               "proguard-rules.pro")
        }
        // debug 타입은 그대로
    }
}

flutter {
    source = "../.."
}
