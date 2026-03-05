import 'package:flutter/material.dart';

/// Security violation warning banner
/// 
/// Displays warnings to students when security violations are detected
/// Shows current violation count and warns about auto-submit
class SecurityViolationBanner extends StatelessWidget {
  final int violationCount;
  final int maxViolations;

  const SecurityViolationBanner({
    super.key,
    required this.violationCount,
    required this.maxViolations,
  });

  @override
  Widget build(BuildContext context) {
    final remainingViolations = maxViolations - violationCount;
    final isNearLimit = remainingViolations <= 1;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: isNearLimit ? Colors.red.shade100 : Colors.orange.shade100,
        border: Border(
          bottom: BorderSide(
            color: isNearLimit ? Colors.red.shade300 : Colors.orange.shade300,
            width: 2,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isNearLimit ? Icons.warning : Icons.info_outline,
            color: isNearLimit ? Colors.red.shade700 : Colors.orange.shade700,
            size: 24,
          ),
          const SizedBox(width: 12),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isNearLimit 
                      ? 'FINAL WARNING: Security Violation Detected!'
                      : 'Security Violation Detected!',
                  style: TextStyle(
                    color: isNearLimit ? Colors.red.shade800 : Colors.orange.shade800,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  remainingViolations > 0
                      ? 'You have $remainingViolations warning${remainingViolations == 1 ? '' : 's'} left before auto-submit.'
                      : 'Quiz will be auto-submitted due to security violations.',
                  style: TextStyle(
                    color: isNearLimit ? Colors.red.shade700 : Colors.orange.shade700,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          
          // Violation counter
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isNearLimit ? Colors.red.shade200 : Colors.orange.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$violationCount/$maxViolations',
              style: TextStyle(
                color: isNearLimit ? Colors.red.shade800 : Colors.orange.shade800,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}