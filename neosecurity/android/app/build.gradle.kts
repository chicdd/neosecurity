import java.util.Properties //파일 시스템에 있는 실제 파일을 '데이터 스트림' 형태로 열기 위해 사용
import java.io.FileInputStream //key=value 형태로 작성된 텍스트 데이터를 'Key-Value 구조(사전 형식)'로 변환하여 다루기 위해 사용
//key.properties 파일 로드 하려면 import 해야함..
plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

// key.properties 파일 로드
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(keystorePropertiesFile.inputStream())
}

android {
    namespace = "com.neo.neosecurity"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    buildFeatures {
        buildConfig = true   // ← 이 줄을 꼭 추가
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.neo.neosecurity"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }


    flavorDimensions += "company-class"

    productFlavors {
        create("Neo") {
            dimension = "company-class"
            applicationId = "com.neo.Neo"
            manifestPlaceholders["appName"] = "네오테스트"
            buildConfigField("String", "APP_NAME", "\"네오테스트\"")
            buildConfigField("String", "GAETONG_CODE", "\"02121162\"")
        }

        create("Takra") {
            dimension = "company-class"
            applicationId = "com.neo.Takra"
            manifestPlaceholders["appName"] = "타크라보안"
            buildConfigField("String", "APP_NAME", "\"타크라보안\"")
            buildConfigField("String", "GAETONG_CODE", "\"31160078\"")
        }
        create("pocom") {
            dimension = "company-class"
            applicationId = "com.neo.pocom"
            manifestPlaceholders["appName"] = "포콤방범시스템"
            buildConfigField("String", "APP_NAME", "\"포콤방범시스템\"")
            buildConfigField("String", "GAETONG_CODE", "\"02111112\"")
        }
        create("C1") {
            dimension = "company-class"
            applicationId = "com.neo.C1"
            manifestPlaceholders["appName"] = "순천씨원"
            buildConfigField("String", "APP_NAME", "\"순천씨원\"")
            buildConfigField("String", "GAETONG_CODE", "\"61062298\"")
        }
        create("Kone") {
            dimension = "company-class"
            applicationId = "com.neo.Kone"
            manifestPlaceholders["appName"] = "한국안전시스템"
            buildConfigField("String", "APP_NAME", "\"한국안전시스템\"")
            buildConfigField("String", "GAETONG_CODE", "\"53220129\"")
        }

        create("Hanse") {
            dimension = "company-class"
            applicationId = "security"
            manifestPlaceholders["appName"] = "한세시큐리티"
            buildConfigField("String", "APP_NAME", "\"한세시큐리티\"")
            buildConfigField("String", "GAETONG_CODE", "\"62083651\"")
        }
    }

    // Release 서명 설정
    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
            storeFile = file(keystoreProperties["storeFile"] as String)
            storePassword = keystoreProperties["storePassword"] as String
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

flutter {
    source = "../.."
}
