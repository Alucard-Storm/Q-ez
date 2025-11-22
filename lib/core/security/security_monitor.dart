import 'package:flutter/foundation.dart';
import '../../../domain/entities/quiz_attempt.dart';
import '../../../domain/repositories/quiz_attempt_repository.dart';
import 'web_security_monitor.dart' if (dart.library.io) 'mobile_security_monitor.dart';
import 'mobile_security_monitor.dart' if (dart.library.html) 'web_security_monitor.dart';

/// Main security monitor service that coordinates platform-specific monitors
class SecurityMonitor {
  final QuizAttemptRepository _attemptRepository;
  final int violationThreshold;
  
  String? _currentAttemptId;
  int _violationCount = 0;
  bool _isMonitoring = false;
  
  // Platform-specific monitors
  WebSecurityMonitor? _webMonitor;
  MobileSecurityMonitor? _mobileMonitor;
  
  // Callbacks
  Function(int)? onViolationCountChanged;
  Function()? onAutoSubmit;

  SecurityMonitor({
    required QuizAttemptRepository attemptRepository,
    this.violationThreshold = 3,
    this.onViolationCountChanged,
    this.onAutoSubmit,
  }) : _attemptRepository = attemptRepository;

  /// Start monitoring for a quiz attempt
  void startMonitoring(String attemptId) {
    if (_isMonitoring) {
      stopMonitoring();
    }
    
    _currentAttemptId = attemptId;
    _violationCount = 0;
    _isMonitoring = true;
    
    // Initialize platform-specific monitor
    if (kIsWeb) {
      _webMonitor = WebSecurityMonitor(
        onViolation: _handleViolation,
      );
      _webMonitor!.initialize();
    } else {
      _mobileMonitor = MobileSecurityMonitor(
        onViolation: _handleViolation,
      );
      _mobileMonitor!.initialize();
      _mobileMonitor!.setQuizActive(true);
    }
  }

  /// Stop monitoring
  void stopMonitoring() {
    if (!_isMonitoring) return;
    
    _isMonitoring = false;
    _currentAttemptId = null;
    _violationCount = 0;
    
    // Clean up platform-specific monitors
    _webMonitor?.dispose();
    _webMonitor = null;
    
    _mobileMonitor?.setQuizActive(false);
    _mobileMonitor?.dispose();
    _mobileMonitor = null;
  }

  /// Handle a security violation
  Future<void> _handleViolation(SecurityViolationType type) async {
    if (!_isMonitoring || _currentAttemptId == null) return;
    
    // Increment violation count
    _violationCount++;
    
    // Record violation in repository
    try {
      await _attemptRepository.recordViolation(_currentAttemptId!, type);
    } catch (e) {
      debugPrint('Error recording violation: $e');
    }
    
    // Notify listeners of violation count change
    onViolationCountChanged?.call(_violationCount);
    
    // Check if threshold reached for auto-submit
    if (_violationCount >= violationThreshold) {
      await _triggerAutoSubmit();
    }
  }

  /// Trigger auto-submit when violation threshold is reached
  Future<void> _triggerAutoSubmit() async {
    if (_currentAttemptId == null) return;
    
    try {
      // Flag the attempt as suspicious
      await _attemptRepository.flagAttempt(_currentAttemptId!);
      
      // Notify that auto-submit should occur
      onAutoSubmit?.call();
      
      // Stop monitoring
      stopMonitoring();
    } catch (e) {
      debugPrint('Error during auto-submit: $e');
    }
  }

  /// Get current violation count
  int get violationCount => _violationCount;

  /// Check if monitoring is active
  bool get isMonitoring => _isMonitoring;

  /// Get the mobile security monitor (for building secure screens)
  MobileSecurityMonitor? get mobileMonitor => _mobileMonitor;

  /// Dispose of the security monitor
  void dispose() {
    stopMonitoring();
  }
}
