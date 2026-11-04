plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.calltotodo.call_to_todo"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        // flutter_local_notifications 가 요구 (java.time 등 desugaring).
        isCoreLibraryDesugaringEnabled = true
    }

    defaultConfig {
        applicationId = "com.calltotodo.call_to_todo"
        // 계획: minSdk 26 / targetSdk 35 (compileSdk 는 Flutter 가 요구하는 버전을 따른다)
        minSdk = 26
        targetSdk = 35
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Pigeon @async 호스트 API 가 suspend 함수로 생성되므로 코루틴이 필요하다.
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.10.2")
    implementation("androidx.core:core-ktx:1.17.0")
    // 3단계: 수집기 → Dart 파이프라인 사이의 영속 큐 (capture/CaptureDispatcher, CaptureWorker).
    implementation("androidx.work:work-runtime-ktx:2.10.5")
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
}
