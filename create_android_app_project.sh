#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

LOCAL_MAVEN_DIR="/data/data/com.termux/files/home/storage/shared/Jay/app-dev/downloads"

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
        //      url = uri("${LOCAL_MAVEN_DIR}") 
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
        //      url = uri("${LOCAL_MAVEN_DIR}") 
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
import org.jetbrains.kotlin.gradle.dsl.JvmTarget

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

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
}

tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>().configureEach {
    compilerOptions {
        jvmTarget.set(JvmTarget.JVM_17)
    }
}

dependencies {
    implementation(platform("androidx.compose:compose-bom:2024.08.00"))
    implementation("androidx.compose.ui:ui")
    implementation("androidx.compose.material3:material3")
    implementation("androidx.activity:activity-compose:1.9.0")
    implementation("com.google.android.material:material:1.11.0")
}
EOF
}

add_manifest() {
    project_name_nospace="$1"
    package_name="$2"

    cat <<EOF >"$project_name_nospace/app/src/main/AndroidManifest.xml"
<manifest xmlns:android="http://schemas.android.com/apk/res/android">

    <application
        android:allowBackup="true"
        android:icon="@mipmap/ic_launcher"
        android:label="@string/app_name"
        android:roundIcon="@mipmap/ic_launcher_round"
        android:supportsRtl="true"
        android:theme="@style/AppTheme">
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
project_name="$2"

mkdir -p "${project_name_nospace}/app/src/main/res/values/"

cat <<EOF >"${project_name_nospace}/app/src/main/res/values/strings.xml"
<resources>
  <string name="app_name">$project_name</string>
</resources>
EOF

cat <<EOF >"${project_name_nospace}/app/src/main/res/values/themes.xml"
<resources xmlns:tools="http://schemas.android.com/tools">
  <style name="AppTheme" parent="Theme.Material3.DayNight.NoActionBar">
    </style>
</resources>
EOF
}

generate_icons() {
    project_name_nospace="$1"
    res_dir="$project_name_nospace/app/src/main/res"

    mkdir -p "$res_dir/mipmap-anydpi-v26"
    mkdir -p "$res_dir/drawable"

    cat <<EOF >"$res_dir/mipmap-anydpi-v26/ic_launcher.xml"
<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@drawable/ic_launcher_background"/>
    <foreground android:drawable="@drawable/ic_launcher_foreground"/>
</adaptive-icon>
EOF

    cp "$res_dir/mipmap-anydpi-v26/ic_launcher.xml" "$res_dir/mipmap-anydpi-v26/ic_launcher_round.xml"

    cat <<EOF >"$res_dir/drawable/ic_launcher_background.xml"
<?xml version="1.0" encoding="utf-8"?>
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="108dp"
    android:height="108dp"
    android:viewportWidth="108"
    android:viewportHeight="108">
    <path
        android:fillColor="#3DDC84"
        android:pathData="M0,0h108v108h-108z"/>
</vector>
EOF

    cat <<EOF >"$res_dir/drawable/ic_launcher_foreground.xml"
<?xml version="1.0" encoding="utf-8"?>
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="108dp"
    android:height="108dp"
    android:viewportWidth="108"
    android:viewportHeight="108">
    <path
        android:fillColor="#FFFFFF"
        android:pathData="M66,66L66,66c0,0,0,0,0,0c-1.7,0-3.2-0.9-4.2-2.3l-5.6-8.2c-0.6-0.9-0.8-1.9-0.6-2.9L60,66z M41.9,66 h-0.1L41.9,66L41.9,66z M47,44.3L47,44.3c-1.7,0-3.2,0.9-4.2,2.3L32,62.7c-0.1,0.1-0.1,0.2-0.2,0.3L47,44.3z M61.1,44.3 L61.1,44.3c1.7,0,3.2,0.9,4.2,2.3l10.8,16.1c0.1,0.1,0.1,0.2,0.2,0.3L61.1,44.3z M54,34L54,34c-1.8,0-3.5,0.7-4.8,2l-6.5,6.5 l11.3,0l11.3,0l-6.5-6.5C57.5,34.7,55.8,34,54,34z"/>
</vector>
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

generate_gradle_wrapper() {
    project_name_nospace="$1"

    mkdir -p "${project_name_nospace}/gradle/wrapper"

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
}

generate_gradle_properties(){
    project_name_nospace="$1"
    
    cat <<EOF >"${project_name_nospace}/gradle.properties"
# Project-wide Gradle settings.
# IDE (e.g. Android Studio) users:
# Gradle settings configured through the IDE *will override*
# any settings specified in this file.
# For more details on how to configure your build environment visit
# http://www.gradle.org/docs/current/userguide/build_environment.html

# Specifies the JVM arguments used for the daemon process.
org.gradle.jvmargs=-Xmx1048m -Dfile.encoding=UTF-8

# When configured, Gradle will run in incubating parallel mode.
# This option should only be used with decoupled projects. More details, visit
# http://www.gradle.org/docs/current/userguide/multi_project_builds.html#sec:decoupled_projects
org.gradle.parallel=true

# Caching: Speeds up the configuration phase of the build
org.gradle.configuration-cache=true

# AndroidX package structure to make it clearer which packages are bundled with the
# Android operating system, and which are packaged with your app's APK
# https://developer.android.com/topic/libraries/support-library/androidx-rn
android.useAndroidX=true

# Kotlin code style for this project: "official" or "obsolete":
kotlin.code.style=official

# Enables namespacing of each library's R class so that its R class includes only the
# resources declared in the library itself and none from the library's dependencies,
# thereby reducing the size of the R class for that library
android.nonTransitiveRClass=true

# Jetifier is disabled by default. Only enable if using legacy libraries
# that haven't migrated to AndroidX.
# android.enableJetifier=true

EOF
}

generate_gitignore(){
    project_name_nospace="$1"
    
    cat <<EOF >"${project_name_nospace}/.gitignore"
# Built application files
*.apk
*.aar
*.ap_
*.aab

# Android / Gradle Build Artifacts
/build
.gradle/
**/build/
!libs/

# Android Studio / IntelliJ IDEA
# Uncomment the following line prevent sharing project settings
# .idea/
.idea/modules.xml
.idea/jarRepositories.xml
.idea/compiler.xml
.idea/encodings.xml
.idea/misc.xml
.idea/vcs.xml
.idea/workspace.xml
.idea/tasks.xml
.idea/gradle.xml
.idea/assetWizardSettings.xml
.idea/dictionaries
.idea/libraries
.idea/caches
# Android Studio Navigation Editor
.idea/navEditor.xml

# Local configuration file (contains SDK/NDK paths - NEVER COMMIT THIS)
local.properties

# Modern CMake/Gradle Native Builds (AGP 4.x+)
.cxx/

# Legacy CMake/Gradle Native Builds
.externalNativeBuild/

# Legacy 'ndk-build' artifacts (if using Android.mk)
# These are often created in the module root if running ndk-build manually
obj/
# Be careful with 'libs/'. 
# If you use 'libs/' for third-party jars/so files, keep it. 
# If it only contains build output from ndk-build, ignore it.
# The standard practice now is to put prebuilts in 'src/main/jniLibs'.
# So usually we ignore the generated build output:
app/src/main/libs
app/src/main/obj

# CMake manual generation artifacts (if running cmake outside gradle)
CMakeCache.txt
CMakeFiles/
cmake_install.cmake
Makefile
CTestTestfile.cmake

# Profiling and Benchmarking
*.hprof
*.html
# Ignore simpleperf reports if you do native profiling
perf.data
simpleperf_report.html

# Kotlin / Java
*.class

# Log files
*.log

# System files
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db

# VS Code (if you edit C++ files there)
.vscode/

# Capture files (layout inspector)
captures/
EOF
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

    add_gradle_kts "$project_name_nospace" "$project_name_nospace_lower" "$org_url_rev" "$compile_sdk" "$target_sdk" "$min_sdk"
    add_manifest "$project_name_nospace" "$package_name"
    add_main_activity "$project_name_nospace" "$package_name"
    add_theme_string "$project_name_nospace" "$project_name"
    generate_icons "$project_name_nospace"
    generate_gradle_wrapper "$project_name_nospace"
    generate_gradle_properties "$project_name_nospace"
    generate_gitignore "$project_name_nospace"

    echo Changing directory to \"$project_name_nospace\"
    cd "$project_name_nospace"

    echo "Project created successfully."
    echo "Run \"gradle -Pandroid.aapt2FromMavenOverride=aapt2 assembleDebug\" to build."
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
    read -p "Compile SDK version [34]: " compile_sdk
    read -p "Target SDK version [34]: " target_sdk
    read -p "Min SDK version [24]: " min_sdk

    if [[ -z "${project_name}" ]]; then
        project_name="MyProject"
    fi
    if [[ -z "$organisation_url" ]]; then
        organisation_url="com.example"
    fi
    if [[ -z "$compile_sdk" ]]; then
        compile_sdk=34
    fi
    if [[ -z "$target_sdk" ]]; then
        target_sdk=34
    fi
    if [[ -z "$min_sdk" ]]; then
        min_sdk=24
    fi

    create_project_structure "${project_name}" "$organisation_url" "$compile_sdk" "$target_sdk" "$min_sdk"
}

main "$@"
