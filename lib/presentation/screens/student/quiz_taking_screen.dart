import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/router/navigation_extensions.dart';
import '../../../domain/entities/quiz.dart';
import '../../../domain/entities/quiz_attempt.dart';
import '../../providers/auth_providers.dart';
import '../../providers/quiz_providers.dart';
import '../../widgets/quiz_timer_widget.dart';
import '../../widgets/security_violation_banner.dart';

/// Quiz taking screen with timer and security monitoring
/// 
/// Features:
/// - Question display with four option buttons
/// - Countdown timer with visual progress
/// - Question navigation (current/total)
/// - Security monitoring (disable copy, detect tab/app switches)
/// - Auto-submit when time expires
/// - Violation warnings to student
/// 
/// Requirements: 5.2, 5.3, 5.4, 5.5, 15.1, 15.2, 15.3, 15.4, 15.5
class QuizTakingScreen extends ConsumerStatefulWidget {
  final String quizId;

  const QuizTakingScreen({
    super.key,
    required this.quizId,
  });

  @override
  ConsumerState<QuizTakingScreen> createState() => _QuizTakingScreenState();
}

class _QuizTakingScreenState extends ConsumerState<QuizTakingScreen> {
  int _currentQuestionIndex = 0;
  final Map<String, int> _selectedAnswers = {};
  bool _isSubmitting = false;
  bool _showViolationWarning = false;
  Timer? _violationWarningTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeQuizTaking();
    });
  }

  @override
  void dispose() {
    _violationWarningTimer?.cancel();
    // Stop security monitoring when leaving screen
    ref.read(securityMonitorProvider).stopMonitoring();
    super.dispose();
  }

  Future<void> _initializeQuizTaking() async {
    final currentUser = ref.read(currentUserProvider).value;
    if (currentUser == null) return;

    // Start security monitoring
    final activeAttempt = ref.read(activeAttemptProvider);
    if (activeAttempt != null) {
      final securityMonitor = ref.read(securityMonitorProvider);
      securityMonitor.onViolationCountChanged = _handleViolationCountChanged;
      securityMonitor.onAutoSubmit = _handleAutoSubmit;
      securityMonitor.startMonitoring(activeAttempt.id);
    }
  }

  void _handleViolationCountChanged(int count) {
    setState(() {
      _showViolationWarning = true;
    });
    
    // Hide warning after 3 seconds
    _violationWarningTimer?.cancel();
    _violationWarningTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showViolationWarning = false;
        });
      }
    });
  }

  void _handleAutoSubmit() {
    if (mounted) {
      _submitQuiz(autoSubmit: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final quizAsync = ref.watch(quizByIdProvider(widget.quizId));
    final activeAttempt = ref.watch(activeAttemptProvider);

    return quizAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Failed to load quiz: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.goToStudentHome(),
                child: const Text('Back to Home'),
              ),
            ],
          ),
        ),
      ),
      data: (quiz) => _buildQuizScreen(quiz, activeAttempt),
    );
  }

  Widget _buildQuizScreen(Quiz quiz, QuizAttempt? attempt) {
    if (attempt == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Quiz Error')),
        body: const Center(
          child: Text('No active quiz attempt found'),
        ),
      );
    }

    // Build secure screen wrapper for mobile
    final securityMonitor = ref.read(securityMonitorProvider);
    final child = _buildQuizContent(quiz, attempt);
    
    return securityMonitor.mobileMonitor?.buildSecureScreen(child) ?? child;
  }

  Widget _buildQuizContent(Quiz quiz, QuizAttempt attempt) {
    final currentQuestion = quiz.questions[_currentQuestionIndex];
    final progress = (_currentQuestionIndex + 1) / quiz.questions.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(quiz.title),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        automaticallyImplyLeading: false, // Disable back button during quiz
        actions: [
          // Timer widget
          if (quiz.timeLimitMinutes != null)
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: QuizTimerWidget(
                durationInMinutes: quiz.timeLimitMinutes!,
                onTimeUp: () => _submitQuiz(autoSubmit: true),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Security violation banner
          if (_showViolationWarning)
            SecurityViolationBanner(
              violationCount: attempt.securityViolations,
              maxViolations: 3,
            ),

          // Progress indicator
          _buildProgressIndicator(progress, quiz.questions.length),

          // Question content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Question text
                  _buildQuestionCard(currentQuestion),
                  
                  const SizedBox(height: 24),
                  
                  // Answer options
                  Expanded(
                    child: _buildAnswerOptions(currentQuestion),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Navigation buttons
                  _buildNavigationButtons(quiz.questions.length),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(double progress, int totalQuestions) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Progress bar
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          
          // Question counter
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Question ${_currentQuestionIndex + 1} of $totalQuestions',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${(progress * 100).round()}% Complete',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(Question question) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.help_outline,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Question',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              question.text,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w500,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnswerOptions(Question question) {
    return ListView.builder(
      itemCount: question.options.length,
      itemBuilder: (context, index) {
        final option = question.options[index];
        final isSelected = _selectedAnswers[question.id] == index;
        final optionLabel = String.fromCharCode(65 + index); // A, B, C, D

        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Card(
            elevation: isSelected ? 4 : 2,
            color: isSelected 
                ? Theme.of(context).colorScheme.primaryContainer
                : null,
            child: InkWell(
              onTap: () => _selectAnswer(question.id, index),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    // Option label (A, B, C, D)
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey.shade300,
                      ),
                      child: Center(
                        child: Text(
                          optionLabel,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    
                    // Option text
                    Expanded(
                      child: Text(
                        option,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          color: isSelected 
                              ? Theme.of(context).colorScheme.onPrimaryContainer
                              : null,
                        ),
                      ),
                    ),
                    
                    // Selection indicator
                    if (isSelected)
                      Icon(
                        Icons.check_circle,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavigationButtons(int totalQuestions) {
    final isFirstQuestion = _currentQuestionIndex == 0;
    final isLastQuestion = _currentQuestionIndex == totalQuestions - 1;
    // Check if current question is answered (for future use)
    // final hasAnsweredCurrent = _selectedAnswers.containsKey(
    //   ref.read(quizByIdProvider(widget.quizId)).value?.questions[_currentQuestionIndex].id,
    // );

    return Row(
      children: [
        // Previous button
        if (!isFirstQuestion)
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _previousQuestion,
              icon: const Icon(Icons.arrow_back),
              label: const Text('Previous'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        
        if (!isFirstQuestion) const SizedBox(width: 16),
        
        // Next/Submit button
        Expanded(
          flex: isFirstQuestion ? 1 : 1,
          child: ElevatedButton.icon(
            onPressed: _isSubmitting ? null : (isLastQuestion ? _submitQuiz : _nextQuestion),
            icon: _isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(isLastQuestion ? Icons.check : Icons.arrow_forward),
            label: Text(
              _isSubmitting 
                  ? 'Submitting...'
                  : (isLastQuestion ? 'Submit Quiz' : 'Next'),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: isLastQuestion 
                  ? Colors.green 
                  : Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  void _selectAnswer(String questionId, int optionIndex) {
    setState(() {
      _selectedAnswers[questionId] = optionIndex;
    });

    // Submit answer to repository
    ref.read(activeAttemptProvider.notifier).submitAnswer(questionId, optionIndex);
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
      });
    }
  }

  void _nextQuestion() {
    final quiz = ref.read(quizByIdProvider(widget.quizId)).value;
    if (quiz != null && _currentQuestionIndex < quiz.questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    }
  }

  Future<void> _submitQuiz({bool autoSubmit = false}) async {
    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Complete the quiz attempt
      final completedAttempt = await ref.read(activeAttemptProvider.notifier).completeAttempt();
      
      // Stop security monitoring
      ref.read(securityMonitorProvider).stopMonitoring();
      
      // Navigate to results screen
      if (mounted) {
        context.goToQuizResults(completedAttempt.id);
      }
    } catch (e) {
      setState(() {
        _isSubmitting = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error submitting quiz: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}