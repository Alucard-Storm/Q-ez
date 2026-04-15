import 'dart:io';
import 'package:flutter/foundation.dart';

/// Platform detection utility for adaptive UI components.
///
/// Provides a centralized way to detect the current platform
/// and determine which design system to use (Material or Cupertino).
///
/// Requirements: 17.2, 17.7
class PlatformUtils {
  PlatformUtils._();

  /// Returns true if the app is running on iOS.
  /// On web, always returns false (uses Material design).
  static bool get isIOS {
    if (kIsWeb) return false;
    return Platform.isIOS;
  }

  /// Returns true if the app is running on Android.
  static bool get isAndroid {
    if (kIsWeb) return false;
    return Platform.isAndroid;
  }

  /// Returns true if the app is running on web.
  static bool get isWeb => kIsWeb;

  /// Returns true if the app should use Cupertino (iOS) design.
  static bool get useCupertino => isIOS;

  /// Returns true if the app should use Material design.
  static bool get useMaterial => !useCupertino;
}
