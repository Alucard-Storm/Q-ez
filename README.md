# Q-ez — Cross-Platform Quiz Application

Q-ez is a Flutter-based quiz platform that lets teachers create and manage quizzes, students participate and track their progress, and administrators oversee the entire platform. It features gamification (levels, badges, leaderboards), an anti-cheating system, and runs natively on Android, iOS, and the web.

---

## Table of Contents

- [Features](#features)
- [Prerequisites](#prerequisites)
- [Getting Started](#getting-started)
- [Firebase Configuration](#firebase-configuration)
- [Environment Variables](#environment-variables)
- [Running the App](#running-the-app)
- [Building for Production](#building-for-production)
- [Project Structure](#project-structure)
- [Contributing](#contributing)

---

## Features

**For Students**
- Join quizzes using a 6-digit PIN
- Timed quiz sessions with auto-submit
- Score tracking, level progression, and achievement badges
- Global leaderboard and per-quiz top-10 rankings
- Progress dashboard with score trend charts

**For Teachers**
- Create and manage multiple-choice quizzes
- Auto-generate or manually set quiz PINs
- View quiz analytics and per-student progress
- Monitor security violations and flagged attempts

**For Admins**
- Full user and quiz management
- Audit logs for all administrative actions
- Platform-wide statistics dashboard

**Platform & Technical**
- Cross-platform: Android (SDK 32+), iOS (16.0+), Web
- Offline support with Hive local caching and background sync
- Biometric authentication (fingerprint / Face ID)
- Anti-cheating: tab-switch detection, copy prevention, auto-submit on violations
- Material Design 3 (Android) and Cupertino (iOS) adaptive UI

---

## Prerequisites

| Tool | Version | Notes |
|------|---------|-------|
| Flutter SDK | 3.10+ | [Install Flutter](https://docs.flutter.dev/get-started/install) |
| Dart SDK | 3.0+ | Bundled with Flutter |
| Android Studio / Xcode | Latest stable | For platform builds |
| Firebase CLI | Latest | `npm install -g firebase-tools` |
| FlutterFire CLI | Latest | `dart pub global activate flutterfire_cli` |
| Node.js | 18+ | Required for Firebase CLI |

Verify your Flutter installation:

```bash
flutter doctor
```

All items should show a green checkmark before proceeding.

---

## Getting Started

### 1. Clone the repository

```bash
git clone <repository-url>
cd q_ez
```

### 2. Install Flutter dependencies

```bash
flutter pub get
```

### 3. Run code generation

The project uses `build_runner` for Freezed models, Riverpod generators, and Hive adapters:

```bash
dart run build_runner build --delete-conflicting-outputs
```

### 4. Configure Firebase

See [Firebase Configuration](#firebase-configuration) below.

### 5. Run the app

```bash
# Android
flutter run -d android

# iOS
flutter run -d ios

# Web
flutter run -d chrome
```

---

## Firebase Configuration

Q-ez uses Firebase for authentication, Firestore database, and Crashlytics. Full setup instructions are in [FIREBASE_SETUP.md](FIREBASE_SETUP.md).

### Quick setup (recommended)

```bash
firebase login
flutterfire configure
```

This generates `lib/core/config/firebase_options.dart` and downloads platform config files automatically.

### Manual setup

1. Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
2. Enable **Email/Password** authentication
3. Create a **Firestore** database
4. Enable **Crashlytics**
5. Download platform config files:
   - Android: `google-services.json` → `android/app/google-services.json`
   - iOS: `GoogleService-Info.plist` → `ios/Runner/GoogleService-Info.plist`
   - Web: update `lib/core/config/firebase_options.dart`

An example file is provided at `android/app/google-services.json.example`.

### Deploy Firestore rules and indexes

```bash
firebase deploy --only firestore:rules,firestore:indexes
```

See [FIRESTORE_DEPLOYMENT.md](FIRESTORE_DEPLOYMENT.md) for the full Firestore deployment guide and [FIRESTORE_SCHEMA.md](FIRESTORE_SCHEMA.md) for the database schema.

---

## Environment Variables

Q-ez uses Dart's `--dart-define` mechanism for environment-specific configuration. No `.env` file is required.

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `FIREBASE_API_KEY` | String | — | Firebase Web API key |
| `FIREBASE_PROJECT_ID` | String | — | Firebase project ID |
| `PRODUCTION` | bool | `false` | Enables production mode (stricter logging, Crashlytics) |

Pass variables at build/run time:

```bash
flutter run \
  --dart-define=FIREBASE_API_KEY=your_api_key \
  --dart-define=FIREBASE_PROJECT_ID=your_project_id \
  --dart-define=PRODUCTION=false
```

See [docs/ENVIRONMENT.md](docs/ENVIRONMENT.md) for the full environment reference.

---

## Running the App

### Android

```bash
flutter run -d android
```

Requires a connected device or emulator running Android 12L (API 32) or higher.

### iOS

```bash
flutter run -d ios
```

Requires a connected device or simulator running iOS 16.0 or higher. Run `pod install` in the `ios/` directory if dependencies are out of date:

```bash
cd ios && pod install && cd ..
```

### Web

```bash
flutter run -d chrome
```

Or target a specific browser:

```bash
flutter run -d web-server --web-port 8080
```

---

## Building for Production

See [docs/DEPLOYMENT.md](docs/DEPLOYMENT.md) for the complete deployment guide. Quick reference:

### Android APK / AAB

```bash
# App Bundle (recommended for Play Store)
flutter build appbundle --release \
  --dart-define=PRODUCTION=true

# APK (for direct distribution)
flutter build apk --release \
  --dart-define=PRODUCTION=true
```

### iOS

```bash
flutter build ios --release \
  --dart-define=PRODUCTION=true
```

Then archive and upload via Xcode or `xcrun altool`.

### Web

```bash
flutter build web --release \
  --dart-define=PRODUCTION=true

firebase deploy --only hosting
```

---

## Project Structure

```
q_ez/
├── android/                    # Android platform project
│   ├── app/
│   │   ├── build.gradle.kts    # minSdk 32, signing config
│   │   └── google-services.json.example
│   └── keystore.properties.example
├── ios/                        # iOS platform project
│   ├── Podfile                 # iOS 16.0 deployment target
│   └── Runner/
├── web/                        # Web platform files
├── lib/
│   ├── main.dart               # App entry point
│   ├── core/
│   │   ├── config/             # Firebase & Hive initialization
│   │   ├── constants/          # Firestore collection names
│   │   ├── errors/             # Exception types & error handler
│   │   ├── router/             # GoRouter navigation & route guards
│   │   ├── security/           # Anti-cheating monitors (web & mobile)
│   │   ├── theme/              # Material 3 & Cupertino themes
│   │   ├── utils/              # Logger, debouncer, retry helper
│   │   └── widgets/            # Shared widgets (offline banner, skeleton)
│   ├── data/
│   │   ├── models/             # Hive-cached data models
│   │   ├── repositories/       # Firebase & Hive repository implementations
│   │   └── services/           # Biometric auth, connectivity, sync
│   ├── domain/
│   │   ├── entities/           # Core domain models (User, Quiz, Badge, etc.)
│   │   ├── repositories/       # Repository interfaces
│   │   └── usecases/           # Business logic use cases
│   └── presentation/
│       ├── providers/          # Riverpod providers
│       ├── screens/            # UI screens (auth, student, teacher, admin)
│       └── widgets/            # Reusable UI widgets
├── docs/
│   ├── USER_GUIDE.md           # Guide for students, teachers, and admins
│   ├── DEPLOYMENT.md           # Platform deployment guide
│   └── ENVIRONMENT.md          # Environment variables reference
├── FIREBASE_SETUP.md           # Firebase project setup guide
├── FIRESTORE_DEPLOYMENT.md     # Firestore rules & indexes deployment
├── FIRESTORE_SCHEMA.md         # Firestore database schema reference
├── firestore.rules             # Firestore security rules
├── firestore.indexes.json      # Firestore composite indexes
└── pubspec.yaml                # Flutter dependencies
```

### Architecture

The project follows **Clean Architecture** with three layers:

- **Presentation** — Riverpod providers, screens, and widgets
- **Domain** — Entities, repository interfaces, and use cases (no framework dependencies)
- **Data** — Firebase and Hive repository implementations, data models

---

## Contributing

1. Fork the repository and create a feature branch from `main`.
2. Run `flutter pub get` and `dart run build_runner build --delete-conflicting-outputs`.
3. Follow the existing code style — run `flutter analyze` before committing.
4. Write tests for new functionality (unit tests in `test/`, widget tests alongside screens).
5. Ensure all tests pass: `flutter test`.
6. Open a pull request with a clear description of the change.

### Code generation

After modifying any Freezed model, Riverpod provider, or Hive adapter, regenerate code:

```bash
dart run build_runner build --delete-conflicting-outputs
```

### Linting

```bash
flutter analyze
```

The project uses `flutter_lints` with the rules defined in `analysis_options.yaml`.
