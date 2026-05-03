import 'dart:html' as html;
import 'package:flutter/foundation.dart';
import '../../../domain/entities/quiz_attempt.dart';

/// Web-specific security monitor for browser-based anti-cheating
class WebSecurityMonitor {
  final Function(SecurityViolationType) onViolation;
  bool _isInitialized = false;
  
  WebSecurityMonitor({required this.onViolation});

  /// Initialize all web security measures
  void initialize() {
    if (!kIsWeb || _isInitialized) return;
    
    _disableRightClick();
    _disableTextSelection();
    _monitorTabVisibility();
    _blockKeyboardShortcuts();
    
    _isInitialized = true;
  }

  /// Disable right-click context menu
  void _disableRightClick() {
    html.document.onContextMenu.listen((event) {
      event.preventDefault();
    });
  }

  /// Disable text selection and copy functionality
  void _disableTextSelection() {
    final body = html.document.body;
    if (body != null) {
      body.style.userSelect = 'none';
      body.style.setProperty('-webkit-user-select', 'none');
      body.style.setProperty('-moz-user-select', 'none');
      body.style.setProperty('-ms-user-select', 'none');
    }
  }

  /// Monitor tab visibility changes
  void _monitorTabVisibility() {
    html.document.onVisibilityChange.listen((event) {
      if (html.document.hidden ?? false) {
        onViolation(SecurityViolationType.tabSwitch);
      }
    });
  }

  /// Block keyboard shortcuts for copy, cut, and select all
  void _blockKeyboardShortcuts() {
    html.document.onKeyDown.listen((event) {
      // Block Ctrl+C, Ctrl+X, Ctrl+A (and Cmd on Mac)
      if ((event.ctrlKey || event.metaKey) && 
          ['c', 'x', 'a'].contains(event.key?.toLowerCase())) {
        event.preventDefault();
        onViolation(SecurityViolationType.copyAttempt);
      }
    });
  }

  /// Clean up and restore normal browser behavior
  void dispose() {
    if (!kIsWeb || !_isInitialized) return;
    
    // Re-enable text selection
    final body = html.document.body;
    if (body != null) {
      body.style.userSelect = 'auto';
      body.style.setProperty('-webkit-user-select', 'auto');
      body.style.setProperty('-moz-user-select', 'auto');
      body.style.setProperty('-ms-user-select', 'auto');
    }
    
    _isInitialized = false;
  }
}
