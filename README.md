# Q-ez

A cross-platform quiz application built with Flutter that enables teachers to create quizzes, students to participate and track their progress, and administrators to manage the platform.

## Features

- **Role-Based Access**: Separate interfaces for Students, Teachers, and Admins
- **Quiz Management**: Create, edit, and manage quizzes with MCQ questions
- **Real-Time Participation**: Students join quizzes using unique PINs
- **Gamification**: Student levels, achievement badges, and leaderboards
- **Progress Tracking**: Visual dashboards showing performance over time
- **Anti-Cheating**: Security measures to detect and prevent cheating
- **Cross-Platform**: Runs on Android, iOS, and Web

## Tech Stack

- **Framework**: Flutter 3.10+ with Dart 3.0+
- **State Management**: Riverpod 2.x
- **Backend**: Firebase (Auth, Firestore, Crashlytics)
- **Local Storage**: Hive with encryption
- **Navigation**: GoRouter
- **UI**: Material Design 3 & Cupertino

## Project Structure

```
lib/
├── core/              # Core utilities, constants, and errors
│   ├── constants/     # App-wide constants
│   ├── errors/        # Custom error classes
│   └── utils/         # Utility functions
├── data/              # Data layer
│   ├── datasources/   # Firebase and Hive data sources
│   ├── models/        # Data models
│   └── repositories/  # Repository implementations
├── domain/            # Domain layer
│   ├── entities/      # Business entities
│   ├── repositories/  # Repository interfaces
│   └── usecases/      # Business logic use cases
└── presentation/      # Presentation layer
    ├── providers/     # Riverpod providers
    ├── screens/       # UI screens
    └── widgets/       # Reusable widgets
```

## Requirements

- Flutter SDK: 3.10 or higher
- Dart SDK: 3.0 or higher
- Android: SDK 32 (Android 12L) or higher
- iOS: 16.0 or higher

## Getting Started

1. **Install dependencies**:
   ```bash
   flutter pub get
   ```

2. **Configure Firebase**:
   - Add `google-services.json` to `android/app/`
   - Add `GoogleService-Info.plist` to `ios/Runner/`
   - Configure Firebase for web in `web/index.html`

3. **Run the app**:
   ```bash
   flutter run
   ```

## Development

- Run tests: `flutter test`
- Build for Android: `flutter build apk`
- Build for iOS: `flutter build ios`
- Build for Web: `flutter build web`

## License

This project is private and not licensed for public use.
