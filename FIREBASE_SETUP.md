# Firebase Setup Guide

This guide explains how to configure Firebase for the Q-ez Quiz Application across Android, iOS, and Web platforms.

## Prerequisites

1. A Firebase project created in the [Firebase Console](https://console.firebase.google.com/)
2. Flutter SDK installed (3.10+)
3. FlutterFire CLI installed: `dart pub global activate flutterfire_cli`

## Quick Setup (Recommended)

The easiest way to configure Firebase is using the FlutterFire CLI:

```bash
# Login to Firebase
firebase login

# Configure Firebase for all platforms
flutterfire configure
```

This will automatically:
- Create/update `lib/core/config/firebase_options.dart`
- Download platform-specific configuration files
- Configure your Firebase project

## Manual Setup

If you prefer to configure Firebase manually, follow these steps:

### 1. Android Configuration

1. In Firebase Console, add an Android app to your project
2. Download `google-services.json`
3. Place it in `android/app/google-services.json`
4. Update `android/app/build.gradle`:

```gradle
dependencies {
    // Add this line
    classpath 'com.google.gms:google-services:4.4.0'
}
```

5. Update `android/app/build.gradle`:

```gradle
apply plugin: 'com.android.application'
apply plugin: 'com.google.gms.google-services'  // Add this line
```

### 2. iOS Configuration

1. In Firebase Console, add an iOS app to your project
2. Download `GoogleService-Info.plist`
3. Open `ios/Runner.xcworkspace` in Xcode
4. Drag `GoogleService-Info.plist` into the Runner folder in Xcode
5. Ensure "Copy items if needed" is checked

### 3. Web Configuration

1. In Firebase Console, add a Web app to your project
2. Copy the Firebase configuration object
3. Update `lib/core/config/firebase_options.dart` with your web configuration
4. Update `web/firebase-config.js` with your configuration (optional)

### 4. Update Firebase Options

Edit `lib/core/config/firebase_options.dart` and replace placeholder values with your actual Firebase configuration:

```dart
static const FirebaseOptions android = FirebaseOptions(
  apiKey: 'YOUR_ACTUAL_ANDROID_API_KEY',
  appId: '1:YOUR_ACTUAL_APP_ID:android:YOUR_ACTUAL_ANDROID_APP_ID',
  messagingSenderId: 'YOUR_ACTUAL_MESSAGING_SENDER_ID',
  projectId: 'YOUR_ACTUAL_PROJECT_ID',
  storageBucket: 'YOUR_ACTUAL_PROJECT_ID.appspot.com',
);
```

## Enable Firebase Services

In the Firebase Console, enable the following services:

### 1. Authentication
- Go to Authentication > Sign-in method
- Enable Email/Password authentication

### 2. Firestore Database
- Go to Firestore Database
- Create database in production mode (or test mode for development)
- Set up security rules (see `firestore.rules`)

### 3. Crashlytics
- Go to Crashlytics
- Enable Crashlytics for your project

## Verify Setup

Run the app to verify Firebase is configured correctly:

```bash
flutter run
```

Check the console for "Firebase initialized successfully" message.

## Troubleshooting

### Android Issues
- Ensure `google-services.json` is in `android/app/` directory
- Check that Google Services plugin is applied in build.gradle
- Run `flutter clean` and rebuild

### iOS Issues
- Ensure `GoogleService-Info.plist` is added to Xcode project
- Check that the bundle ID matches your Firebase iOS app
- Run `pod install` in the ios directory

### Web Issues
- Ensure Firebase configuration is correct in `firebase_options.dart`
- Check browser console for Firebase initialization errors
- Verify Firebase Hosting is enabled if deploying to Firebase

## Security Notes

- Never commit actual Firebase configuration files to public repositories
- Use environment variables for sensitive configuration in CI/CD
- Keep `.example` files as templates for team members
- Add actual config files to `.gitignore`:
  - `android/app/google-services.json`
  - `ios/Runner/GoogleService-Info.plist`

## Next Steps

After Firebase is configured:
1. Set up Firestore security rules (see task 3.2)
2. Create Firestore indexes for optimized queries
3. Test authentication flow
4. Implement repository layer with Firebase
