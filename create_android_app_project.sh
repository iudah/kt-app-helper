#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# LOCAL_MAVEN_DIR="/data/data/com.termux/files/home/storage/shared/Jay/app-dev/downloads"

url_to_dir() { echo "$1" | tr '.' '/'; }

sanitize_project_name() {
    # keep letters, numbers, underscore and dash; remove spaces and others and lowercase
    echo "$1" | tr -cd '[:alnum:]._-' | tr '[:upper:]' '[:lower:]'
}

sanitize_package() {
    # remove spaces, duplicate dots, leading/trailing dots, lowercase
    pkg=$(echo "$1" | tr -d ' ' | tr '[:upper:]' '[:lower:]')
    # remove invalid characters (keep letters, digits, underscore and dot)
    pkg=$(echo "$pkg" | tr -cd '[:alnum:]._')
    # collapse multiple dots and trim
    pkg=$(echo "$pkg" | sed -E 's/\.{2,}/./g; s/^\.+//; s/\.+$//')
    echo "$pkg"
}

is_integer() {
    [[ "$1" =~ ^[0-9]+$ ]]
}

add_gradle_kts() {
    project_name_nospace="$1"
    project_name_nospace_lower="$2"
    org_url_rev="$3"
    compile_sdk="$4"
    target_sdk="$5"
    min_sdk="$6"

    cat <<EOF >"$project_name_nospace/settings.gradle.kts"
pluginManagement {
    repositories {
        // maven {
        //     url = uri("${LOCAL_MAVEN_DIR}") 
        // }
        gradlePluginPortal()
        google()
        mavenCentral()
    }
}

dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        // maven {
        //     url = uri("${LOCAL_MAVEN_DIR}") 
        // }
        google()
        mavenCentral()
    }
}

rootProject.name = "$project_name_nospace"
include(":app")
EOF

    cat <<EOF >"$project_name_nospace/build.gradle.kts"
plugins {
    id("com.android.application") version "8.13.0" apply false

    id("com.android.library") version "8.13.0" apply false
    id("org.jetbrains.kotlin.android") version "2.2.20" apply false
    id("org.jetbrains.kotlin.plugin.compose") version "2.2.20" apply false
}



EOF

    cat <<EOF >"$project_name_nospace/app/build.gradle.kts"
plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("org.jetbrains.kotlin.plugin.compose")
}

android {
    namespace = "$org_url_rev.$project_name_nospace_lower"
    compileSdk = $compile_sdk

    defaultConfig {
        applicationId = "$org_url_rev.$project_name_nospace_lower"
        minSdk = $min_sdk
        targetSdk = $target_sdk
        versionCode = 1
        versionName = "1.0"
    }

    buildFeatures {
        compose = true
    }

    // composeOptions {
    //     kotlinCompilerExtensionVersion = "1.7.0"
    // }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }
}

dependencies {
    implementation(platform("androidx.compose:compose-bom:2024.08.00"))
    implementation("androidx.compose.ui:ui")
    implementation("androidx.compose.material3:material3")
    implementation("androidx.activity:activity-compose:1.9.0")
}
EOF
}

add_manifest() {
    project_name_nospace="$1"
    package_name="$2"

    cat <<EOF >"$project_name_nospace/app/src/main/AndroidManifest.xml"
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="$package_name">

    <application
        android:allowBackup="true"
        android:icon="@mipmap/ic_launcher"
        android:label="$package_name"
        android:roundIcon="@mipmap/ic_launcher_round"
        android:supportsRtl="true"
        android:theme="@style/Theme.MaterialComponents.DayNight.NoActionBar">
        <activity
            android:name=".MainActivity"
            android:exported="true">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>
    </application>

</manifest>
EOF
}

add_theme_string() {
    project_name_nospace="$1"
    package_name="$2"

    mkdir -p "$project_name_nospace/app/src/main/res/values"

    cat <<EOF >"$project_name_nospace/app/src/main/res/values/strings.xml"
<resources>
  <string name="app_name">MyApp</string>
</resources>
EOF

    cat <<EOF >"$project_name_nospace/app/src/main/res/values/themes.xml"
<resources>
  <style name="Theme.App" parent="Theme.MaterialComponents.DayNight.NoActionBar"/>
</resources>
EOF
}

add_main_activity() {
    project_name_nospace="$1"
    package_name="$2"

    dir_path="$project_name_nospace/app/src/main/java/$(url_to_dir "$package_name")"
    mkdir -p "$dir_path"

    cat <<EOF >"$dir_path/MainActivity.kt"
package $package_name

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text

class MainActivity : ComponentActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            // Simple Compose UI
            MaterialTheme {
                Surface {
                    Text(
                        text = "Hello Compose from CLI!",
                        style = MaterialTheme.typography.headlineMedium
                    )
                }
            }
        }
    }
}
EOF
}

add_layout() {
    project_name_nospace="$1"

    mkdir -p "$project_name_nospace/app/src/main/res/layout"
}

generate_gradle_wrapper() {
    project_name_nospace="$1"

    mkdir -p "${project_name_nospace}/gradle/wrapper"

    GRADLEW_URL="https://raw.githubusercontent.com/iudah/kt-app-helper/main/gradlew"
    GRADLEW_BAT_URL="https://raw.githubusercontent.com/iudah/kt-app-helper/main/gradlew.bat"
    WRAPPER_JAR_URL="https://raw.githubusercontent.com/iudah/kt-app-helper/main/gradle/wrapper/gradle-wrapper.jar"

    # if [[ -f ~/.kt_app_helper/gradlew ]]; then
    #     cp ~/.kt_app_helper/gradlew "${project_name_nospace}/gradlew"
    # else
    #     wget "$GRADLEW_URL" -O "${project_name_nospace}/gradlew"
    # fi
    # chmod +x "${project_name_nospace}/gradlew"

    # if [[ -f ~/.kt_app_helper/gradlew.bat ]]; then
    #     cp ~/.kt_app_helper/gradlew.bat "${project_name_nospace}/gradlew.bat"
    # else
    #     wget "$GRADLEW_BAT_URL" -O "${project_name_nospace}/gradlew.bat"
    # fi

    # if [[ -f ~/.kt_app_helper/gradle/wrapper/gradle-wrapper.jar ]]; then
    #     cp ~/.kt_app_helper/gradle/wrapper/gradle-wrapper.jar "${project_name_nospace}/gradle/wrapper/gradle-wrapper.jar"
    # else
    #     wget "$WRAPPER_JAR_URL" -O "${project_name_nospace}/gradle/wrapper/gradle-wrapper.jar"
    # fi

    cat <<EOF >"${project_name_nospace}/gradle/wrapper/gradle-wrapper.properties"
distributionBase=GRADLE_USER_HOME
distributionPath=wrapper/dists
distributionUrl=https\://services.gradle.org/distributions/gradle-8.13-bin.zip
networkTimeout=10000
validateDistributionUrl=true
zipStoreBase=GRADLE_USER_HOME
zipStorePath=wrapper/dists
EOF

    cat <<EOF >"${project_name_nospace}/gradle/libs.versions.toml"
[versions]
guava = "33.3.1-jre"
junit-jupiter-engine = "5.11.3"

[libraries]
guava = { module = "com.google.guava:guava", version.ref = "guava" }
junit-jupiter-engine = { module = "org.junit.jupiter:junit-jupiter-engine", version.ref = "junit-jupiter-engine" }

[plugins]
kotlin-jvm = { id = "org.jetbrains.kotlin.jvm", version = "2.1.0" }
EOF

    cat <<EOF >"${project_name_nospace}/gradlew.sh"
function gradlew {
    file="./gradlew"
    if [[ -f "\$file" ]]; then
        bash "\$file" -Pandroid.aapt2FromMavenOverride=aapt2 "\$@"
    else
        echo "Invoke this command from a project's root directory."
    fi
}

gradlew "\$@"
EOF

echo Run `gradle wrapper` to make wrapper
echo Run `bash gradlew.sh assembleDebug` or `gradle -Pandroid.aapt2FromMavenOverride=aapt2 assembleDebug` to build

}

create_project_structure() {
    project_name="$1"
    org_url_rev="$2"
    compile_sdk="$3"
    target_sdk="$4"
    min_sdk="$5"

    project_name_nospace=$(sanitize_project_name "${project_name}")
    project_name_nospace_lower=$(echo "$project_name_nospace" | tr '[:upper:]' '[:lower:]')

    org_url_rev=$(sanitize_package "$org_url_rev")

    package_name="$org_url_rev.$project_name_nospace_lower"

    if ! is_integer "$compile_sdk" || ! is_integer "$target_sdk" || ! is_integer "$min_sdk"; then
        echo "SDK values must be integers" >&2
        exit 1
    fi

    mkdir -p "$project_name_nospace"
    mkdir -p "$project_name_nospace/app/src/main/res/values"

    add_gradle_kts "$project_name_nospace" "$project_name_nospace_lower" "$org_url_rev" "$compile_sdk" "$target_sdk" "$min_sdk"
    add_manifest "$project_name_nospace" "$package_name"
    add_main_activity "$project_name_nospace" "$package_name"
    add_layout "$project_name_nospace"
    generate_gradle_wrapper "$project_name_nospace"
}

main() {
    missing_pkgs=""
    for missing_pkg in wget java kotlin aapt2 aapt gradle; do
        if ! command -v "$missing_pkg" >/dev/null 2>&1; then
            missing_pkgs="${missing_pkgs} ${missing_pkg}"
        fi
    done

    if [[ -n "$missing_pkgs" ]]; then
        echo "Installing missing packages: $missing_pkgs"
        pkg install -y $missing_pkgs
    fi

    read -p "Project Name: " project_name
    read -p "Organisation Address (e.g. com.example): " organisation_url
    read -p "Compile SDK version: " compile_sdk
    read -p "Target SDK version: " target_sdk
    read -p "Min SDK version: " min_sdk

    if [[ -z "${project_name}" ]]; then
        project_name="Project Name"
    fi
    if [[ -z "$organisation_url" ]]; then
        organisation_url="com.example"
    fi
    if [[ -z "$compile_sdk" ]]; then
        compile_sdk=34
    fi
    if [[ -z "$target_sdk" ]]; then
        target_sdk=24
    fi
    if [[ -z "$min_sdk" ]]; then
        min_sdk=24
    fi

    create_project_structure "${project_name}" "$organisation_url" "$compile_sdk" "$target_sdk" "$min_sdk"
}

main "$@"
