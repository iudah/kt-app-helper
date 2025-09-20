# 📱 Android Project Generator (Kotlin + Compose)

This Bash script automates the creation of a minimal Android project using Kotlin, Jetpack Compose, and Gradle Kotlin DSL. It's designed for use in Termux or any Unix-like environment and sets up everything from project structure to Gradle wrapper and Compose-ready `MainActivity`.

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
  - `gradlew.sh` helper for simplified Gradle execution

---

## 📦 Requirements

- Bash shell (Unix-like environment)
- `wget`, `java`, `kotlin`, and `aapt2` installed (auto-installed via `pkg` if missing)
- Android SDK and build tools (configured externally)
- Termux (recommended for Android users)

---

## 🛠️ Usage

To generate a new Android project, run:

```bash
wget https://raw.githubusercontent.com/iudah/kt-app-helper/main/create_android_app_project.sh && bash create_android_app_project.sh
```

You'll be prompted for:

- Project Name (e.g. `MyApp`)
- Organisation Address (e.g. `com.example`)
- Compile SDK version (e.g. `34`)
- Target SDK version (e.g. `34`)
- Min SDK version (e.g. `24`)

If you leave any field blank, default values will be used.

---

## 🧪 Running Gradle Tasks

After project creation, use the included `gradlew.sh` script to run Gradle tasks:

```bash
bash gradlew.sh assembleDebug
```

This wrapper invokes the local `gradlew` script and sets the required AAPT2 override for compatibility.

---

## 📁 Output Structure

```
MyApp/
├── build.gradle.kts
├── settings.gradle.kts
├── gradlew
├── gradlew.bat
├── gradlew.sh
├── gradle/
│   ├── wrapper/
│   │   ├── gradle-wrapper.jar
│   │   └── gradle-wrapper.properties
│   └── libs.versions.toml
├── app/
│   ├── build.gradle.kts
│   └── src/
│       └── main/
│           ├── AndroidManifest.xml
│           ├── java/
│           │   └── com/example/myapp/MainActivity.kt
│           └── res/
│               ├── layout/
│               └── values/
│                   ├── strings.xml
│                   └── themes.xml
```

---

## 🧩 Notes

- The script uses a local Maven repository path:  
  `/data/data/com.termux/files/home/storage/shared/Jay/app-dev/downloads`  
  You can modify this in the script if needed.
- Gradle wrapper files are fetched from the `kt-app-helper` GitHub repo unless cached locally in `~/.kt_app_helper`.
- The `gradlew.sh` script simplifies Gradle execution by wrapping common tasks with required flags.

---

## 📜 License

MIT License — feel free to use, modify, and share.
