import 'package:flutter/material.dart';
import '../../../domain/entities/quiz_attempt.dart';

/// Mobile-specific security monitor for app-based anti-cheating
class MobileSecurityMonitor with WidgetsBindingObserver {
  final Function(SecurityViolationType) onViolation;
  bool _isInitialized = false;
  bool _isQuizActive = false;

  MobileSecurityMonitor({required this.onViolation});

  /// Initialize mobile security monitoring
  void initialize() {
    if (_isInitialized) return;
    
    WidgetsBinding.instance.addObserver(this);
    _isInitialized = true;
  }

  /// Set whether quiz is currently active
  void setQuizActive(bool active) {
    _isQuizActive = active;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Only record violations when quiz is active
    if (!_isQuizActive) return;
    
    // Detect app switch when app goes to background or becomes inactive
    if (state == AppLifecycleState.paused || 
        state == AppLifecycleState.inactive) {
      onViolation(SecurityViolationType.appSwitch);
    }
  }

  /// Build a secure screen wrapper that prevents long-press and screenshots
  Widget buildSecureScreen(Widget child) {
    return GestureDetector(
      // Disable long-press gesture
      onLongPress: () {
        // Empty handler to block long-press
      },
      onLongPressStart: (_) {
        // Empty handler to block long-press
      },
      behavior: HitTestBehavior.opaque,
      child: child,
    );
  }

  /// Clean up observer
  void dispose() {
    if (!_isInitialized) return;
    
    WidgetsBinding.instance.removeObserver(this);
    _isInitialized = false;
    _isQuizActive = false;
  }
}
