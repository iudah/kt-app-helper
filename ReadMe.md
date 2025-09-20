# 📱 Android Project Generator (Kotlin + Compose)

This Bash script automates the creation of a minimal Android project using Kotlin, Jetpack Compose, and Gradle Kotlin DSL. It's designed for use in Termux or any Unix-like environment and sets up everything from project structure to Gradle wrapper and Compose-ready MainActivity.

---

## 🚀 Features

- Kotlin-based Android app with Jetpack Compose
- Gradle Kotlin DSL configuration
- Customizable SDK versions
- Local Maven repository support
- Auto-generated:
  - `MainActivity.kt`
  - `AndroidManifest.xml`
  - Gradle wrapper
  - Compose-ready theme and strings
  - Project structure with sanitized package names

---

## 📦 Requirements

- Bash shell (Unix-like environment)
- `wget` installed
- Android SDK and build tools (configured externally)
- Termux (recommended for Android users)

---

## 🛠️ Usage

To generate a new Android project, run:

```bash
curl -s https://raw.githubusercontent.com/iudah/kt-app-helper/main/create_android_app_project.sh | sh
```

You'll be prompted for:

- Project Name (e.g. `MyApp`)
- Organisation Address (e.g. `com.example`)
- Compile SDK version (e.g. `34`)
- Target SDK version (e.g. `34`)
- Min SDK version (e.g. `24`)

If you leave any field blank, default values will be used.

---

## 📁 Output Structure

```
MyApp/
├── build.gradle.kts
├── settings.gradle.kts
├── gradlew
├── gradlew.bat
├── gradle/
│   └── wrapper/
│       ├── gradle-wrapper.jar
│       └── gradle-wrapper.properties
├── app/
│   ├── build.gradle.kts
│   ├── src/
│   │   └── main/
│   │       ├── AndroidManifest.xml
│   │       ├── java/
│   │       │   └── com/example/myapp/MainActivity.kt
│   │       └── res/
│   │           ├── layout/
│   │           └── values/
│   │               ├── strings.xml
│   │               └── themes.xml
└── gradle/libs.versions.toml
```

---

## 🧩 Notes

- The script uses a local Maven repository path:  
  `/data/data/com.termux/files/home/storage/shared/Jay/app-dev/downloads`  
  You can modify this in the script if needed.
- Gradle wrapper files are fetched from the `kt-app-helper` GitHub repo unless cached locally in `~/.kt_app_helper`.

---

## 📜 License

MIT License — feel free to use, modify, and share.
