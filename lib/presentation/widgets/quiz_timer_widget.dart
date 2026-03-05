import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/quiz_providers.dart';

/// Quiz timer widget with visual progress indicator
/// 
/// Features:
/// - Countdown timer display (MM:SS format)
/// - Circular progress indicator
/// - Color changes based on remaining time
/// - Auto-submit callback when time expires
class QuizTimerWidget extends ConsumerStatefulWidget {
  final int durationInMinutes;
  final VoidCallback onTimeUp;

  const QuizTimerWidget({
    super.key,
    required this.durationInMinutes,
    required this.onTimeUp,
  });

  @override
  ConsumerState<QuizTimerWidget> createState() => _QuizTimerWidgetState();
}

class _QuizTimerWidgetState extends ConsumerState<QuizTimerWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Start the timer
      final timerNotifier = ref.read(timerProvider(widget.durationInMinutes).notifier);
      timerNotifier.onTimeUp = widget.onTimeUp;
      timerNotifier.start();
    });
  }

  @override
  Widget build(BuildContext context) {
    final remainingSeconds = ref.watch(timerProvider(widget.durationInMinutes));
    final totalSeconds = widget.durationInMinutes * 60;
    final progress = remainingSeconds / totalSeconds;
    
    // Determine color based on remaining time
    Color timerColor;
    if (progress > 0.5) {
      timerColor = Colors.green;
    } else if (progress > 0.25) {
      timerColor = Colors.orange;
    } else {
      timerColor = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Circular progress indicator
          SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(timerColor),
              strokeWidth: 3,
            ),
          ),
          const SizedBox(width: 8),
          
          // Time display
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Time Left',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                _formatTime(remainingSeconds),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: timerColor,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}