# Q-ez Deployment Guide

This guide covers building and deploying Q-ez to Android, iOS, and the web for production.

---

## Table of Contents

- [Prerequisites](#prerequisites)
- [Pre-Deployment Checklist](#pre-deployment-checklist)
- [Android Deployment](#android-deployment)
- [iOS Deployment](#ios-deployment)
- [Web Deployment](#web-deployment)
- [Environment Configuration for Production](#environment-configuration-for-production)
- [Firebase Production Setup](#firebase-production-setup)
- [CI/CD Integration](#cicd-integration)

---

## Prerequisites

| Tool | Version | Purpose |
|------|---------|---------|
| Flutter SDK | 3.10+ | Build toolchain |
| Android Studio | Latest | Android builds, keystore management |
| Xcode | 15+ | iOS builds |
| Firebase CLI | Latest | Web hosting, Firestore deployment |
| `firebase-tools` | Latest | `npm install -g firebase-tools` |

Verify your environment:

```bash
flutter doctor -v
```

---

## Pre-Deployment Checklist

Before building for any platform:

- [ ] Firebase project configured for production (see [Firebase Production Setup](#firebase-production-setup))
- [ ] `lib/core/config/firebase_options.dart` contains production credentials
- [ ] Firestore security rules deployed: `firebase deploy --only firestore:rules`
- [ ] Firestore indexes deployed: `firebase deploy --only firestore:indexes`
- [ ] `PRODUCTION=true` dart-define set in build command
- [ ] App version and build number updated in `pubspec.yaml`
- [ ] Code generation up to date: `dart run build_runner build --delete-conflicting-outputs`
- [ ] All tests passing: `flutter test`
- [ ] `flutter analyze` reports no issues

---

## Android Deployment

### Platform Requirements

- **Minimum SDK**: 32 (Android 12L)
- **Target SDK**: 34
- **Application ID**: `com.qez.q_ez`

These are configured in `android/app/build.gradle.kts`.

### Step 1: Create a Signing Keystore

If you do not already have a release keystore:

```bash
keytool -genkey -v \
  -keystore android/app/release.keystore \
  -alias q_ez_key \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000
```

> Store the keystore file and passwords securely. Losing the keystore means you cannot publish updates to the same Play Store listing.

### Step 2: Configure Keystore Properties

Copy the example file and fill in your values:

```bash
cp android/keystore.properties.example android/keystore.properties
```

Edit `android/keystore.properties`:

```properties
storeFile=app/release.keystore
storePassword=your_store_password
keyAlias=q_ez_key
keyPassword=your_key_password
```

`android/keystore.properties` is listed in `.gitignore` and must not be committed.

### Step 3: Build the App Bundle

An App Bundle (`.aab`) is required for Google Play Store submission:

```bash
flutter build appbundle --release \
  --dart-define=PRODUCTION=true \
  --dart-define=FIREBASE_PROJECT_ID=your_project_id
```

The output is at `build/app/outputs/bundle/release/app-release.aab`.

### Step 4: Build an APK (optional)

For direct distribution or testing outside the Play Store:

```bash
flutter build apk --release \
  --dart-define=PRODUCTION=true \
  --split-per-abi
```

Split APKs are generated per ABI at `build/app/outputs/flutter-apk/`.

### Step 5: Publish to Google Play Store

1. Open [Google Play Console](https://play.google.com/console).
2. Create a new app or select the existing Q-ez listing.
3. Go to **Release > Production > Create new release**.
4. Upload the `.aab` file.
5. Fill in release notes and submit for review.

### ProGuard / R8

ProGuard rules are in `android/app/proguard-rules.pro`. The release build has minification and resource shrinking enabled:

```kotlin
isMinifyEnabled = true
isShrinkResources = true
```

If you encounter runtime crashes after enabling minification, add keep rules to `proguard-rules.pro` for the affected classes.

### CI/CD Environment Variables for Android

When building in CI (GitHub Actions, Bitrise, etc.), pass keystore values as environment variables instead of a properties file:

| Variable | Description |
|----------|-------------|
| `KEY_ALIAS` | Keystore key alias |
| `KEY_PASSWORD` | Key password |
| `STORE_FILE` | Path to keystore file |
| `STORE_PASSWORD` | Keystore store password |

The `build.gradle.kts` falls back to these environment variables automatically when `keystore.properties` is absent.

---

## iOS Deployment

### Platform Requirements

- **Minimum deployment target**: iOS 16.0
- **Bundle ID**: `com.qez.q_ez` (update to match your Apple Developer account)
- **Xcode**: 15 or later

The deployment target is set in `ios/Podfile`:

```ruby
platform :ios, '16.0'
```

And enforced for all pods in the `post_install` hook:

```ruby
config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '16.0'
```

### Step 1: Configure Apple Developer Account

1. Log in to [developer.apple.com](https://developer.apple.com).
2. Create an **App ID** with bundle identifier `com.qez.q_ez` (or your chosen ID).
3. Create a **Distribution Certificate** and a **Provisioning Profile** for App Store distribution.

### Step 2: Add Firebase iOS Configuration

1. Download `GoogleService-Info.plist` from the Firebase Console.
2. Open `ios/Runner.xcworkspace` in Xcode.
3. Drag `GoogleService-Info.plist` into the **Runner** group in the project navigator.
4. Ensure **Copy items if needed** is checked.

### Step 3: Install CocoaPods Dependencies

```bash
cd ios
pod install
cd ..
```

### Step 4: Configure Signing in Xcode

1. Open `ios/Runner.xcworkspace` in Xcode.
2. Select the **Runner** target > **Signing & Capabilities**.
3. Set your **Team** and ensure **Automatically manage signing** is enabled (or configure manual signing with your provisioning profile).
4. Verify the **Bundle Identifier** matches your App ID.

### Step 5: Build for Release

```bash
flutter build ios --release \
  --dart-define=PRODUCTION=true \
  --dart-define=FIREBASE_PROJECT_ID=your_project_id
```

### Step 6: Archive and Upload

**Via Xcode:**
1. Open `ios/Runner.xcworkspace`.
2. Select **Product > Archive**.
3. In the Organizer, click **Distribute App > App Store Connect**.
4. Follow the upload wizard.

**Via command line (requires `xcrun altool` or `xcrun notarytool`):**

```bash
xcodebuild -workspace ios/Runner.xcworkspace \
  -scheme Runner \
  -configuration Release \
  -archivePath build/Runner.xcarchive \
  archive

xcodebuild -exportArchive \
  -archivePath build/Runner.xcarchive \
  -exportOptionsPlist ios/ExportOptions.plist \
  -exportPath build/ios-release
```

### Step 7: Submit on App Store Connect

1. Open [App Store Connect](https://appstoreconnect.apple.com).
2. Select your app and go to **TestFlight** or **App Store > + Version**.
3. Select the uploaded build and complete the submission form.

### Required Permissions (Info.plist)

The following permissions may be required depending on features used:

| Key | Reason |
|-----|--------|
| `NSFaceIDUsageDescription` | Biometric authentication |
| `NSCameraUsageDescription` | Profile photo (if implemented) |

These are configured in `ios/Runner/Info.plist`.

---

## Web Deployment

### Platform Requirements

- Modern browsers: Chrome, Firefox, Safari with ES6 support
- Firebase Hosting (recommended)

### Step 1: Build the Web App

```bash
flutter build web --release \
  --dart-define=PRODUCTION=true \
  --dart-define=FIREBASE_API_KEY=your_api_key \
  --dart-define=FIREBASE_PROJECT_ID=your_project_id
```

The output is in `build/web/`.

### Step 2: Initialize Firebase Hosting

If not already initialized:

```bash
firebase init hosting
```

When prompted:
- **Public directory**: `build/web`
- **Single-page app**: Yes (rewrite all URLs to `index.html`)
- **Overwrite `index.html`**: No

This creates `firebase.json` and `.firebaserc`.

### Step 3: Deploy to Firebase Hosting

```bash
firebase deploy --only hosting
```

Your app is live at `https://<project-id>.web.app` and `https://<project-id>.firebaseapp.com`.

### Step 4: Configure a Custom Domain (optional)

1. Go to Firebase Console > Hosting > Add custom domain.
2. Follow the DNS verification steps.
3. Firebase provisions an SSL certificate automatically.

### PWA Support

The web build includes a `manifest.json` for Progressive Web App support. Users can install Q-ez as a PWA from their browser. Verify the manifest is correct in `web/manifest.json`:

```json
{
  "name": "Q-ez",
  "short_name": "Q-ez",
  "start_url": "/",
  "display": "standalone",
  "background_color": "#FFFFFF",
  "theme_color": "#1976D2",
  "icons": [...]
}
```

### Web Performance Optimization

The release build automatically applies:
- **Tree shaking** — removes unused Dart code
- **Minification** — reduces JavaScript bundle size
- **CanvasKit renderer** — for consistent rendering (default for web)

To use the HTML renderer instead (smaller initial download, less fidelity):

```bash
flutter build web --release --web-renderer html
```

---

## Environment Configuration for Production

### Dart Define Variables

All environment-specific values are passed via `--dart-define` at build time. They are accessed in code via:

```dart
class Environment {
  static const String firebaseApiKey =
      String.fromEnvironment('FIREBASE_API_KEY');
  static const String firebaseProjectId =
      String.fromEnvironment('FIREBASE_PROJECT_ID');
  static const bool isProduction =
      bool.fromEnvironment('PRODUCTION', defaultValue: false);
}
```

See [docs/ENVIRONMENT.md](ENVIRONMENT.md) for the full variable reference.

### Production vs. Development

| Setting | Development | Production |
|---------|-------------|------------|
| `PRODUCTION` | `false` | `true` |
| Crashlytics | Disabled | Enabled |
| Verbose logging | Enabled | Disabled |
| Firebase project | Dev project | Prod project |

---

## Firebase Production Setup

For production deployments, use a **separate Firebase project** from your development project.

1. Create a new Firebase project named `q-ez-production` (or similar).
2. Run `flutterfire configure` and select the production project.
3. Re-deploy Firestore rules and indexes to the production project:
   ```bash
   firebase use production
   firebase deploy --only firestore:rules,firestore:indexes
   ```
4. Enable **Firebase App Check** to protect against abuse:
   ```bash
   firebase deploy --only appcheck
   ```
5. Configure **Firestore backups** in the Firebase Console > Firestore > Backups.
6. Set up **billing alerts** in Firebase Console > Usage and billing.

---

## CI/CD Integration

### GitHub Actions Example

```yaml
name: Build and Deploy

on:
  push:
    branches: [main]

jobs:
  build-android:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.10.0'
      - run: flutter pub get
      - run: dart run build_runner build --delete-conflicting-outputs
      - run: flutter test
      - name: Build App Bundle
        env:
          KEY_ALIAS: ${{ secrets.KEY_ALIAS }}
          KEY_PASSWORD: ${{ secrets.KEY_PASSWORD }}
          STORE_FILE: ${{ secrets.STORE_FILE }}
          STORE_PASSWORD: ${{ secrets.STORE_PASSWORD }}
        run: |
          flutter build appbundle --release \
            --dart-define=PRODUCTION=true \
            --dart-define=FIREBASE_PROJECT_ID=${{ secrets.FIREBASE_PROJECT_ID }}

  deploy-web:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.10.0'
      - run: flutter pub get
      - run: dart run build_runner build --delete-conflicting-outputs
      - name: Build Web
        run: |
          flutter build web --release \
            --dart-define=PRODUCTION=true \
            --dart-define=FIREBASE_API_KEY=${{ secrets.FIREBASE_API_KEY }} \
            --dart-define=FIREBASE_PROJECT_ID=${{ secrets.FIREBASE_PROJECT_ID }}
      - uses: FirebaseExtended/action-hosting-deploy@v0
        with:
          repoToken: ${{ secrets.GITHUB_TOKEN }}
          firebaseServiceAccount: ${{ secrets.FIREBASE_SERVICE_ACCOUNT }}
          channelId: live
```

Store all secrets in your repository's **Settings > Secrets and variables > Actions**.
