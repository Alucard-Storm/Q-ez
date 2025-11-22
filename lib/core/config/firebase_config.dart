import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'firebase_options.dart';

/// Firebase configuration and initialization
class FirebaseConfig {
  /// Initialize Firebase with platform-specific configuration
  static Future<void> initialize() async {
    try {
      // Initialize Firebase
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // Set up Crashlytics
      await _initializeCrashlytics();

      if (kDebugMode) {
        print('Firebase initialized successfully');
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('Error initializing Firebase: $e');
        print('Stack trace: $stackTrace');
      }
      rethrow;
    }
  }

  /// Initialize Firebase Crashlytics for error reporting
  static Future<void> _initializeCrashlytics() async {
    // Pass all uncaught errors from the framework to Crashlytics
    FlutterError.onError = (errorDetails) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    };

    // Pass all uncaught asynchronous errors to Crashlytics
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };

    // Enable Crashlytics collection
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);

    if (kDebugMode) {
      print('Firebase Crashlytics initialized successfully');
    }
  }

  /// Check if Firebase is initialized
  static bool get isInitialized {
    try {
      return Firebase.apps.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}
