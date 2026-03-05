import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/router/navigation_extensions.dart';
import '../../../domain/entities/quiz.dart';
import '../../../domain/entities/quiz_attempt.dart';
import '../../../domain/entities/badge.dart' as domain;
import '../../../domain/entities/user.dart';
import '../../providers/auth_providers.dart';
import '../../providers/quiz_providers.dart';


/// Quiz results screen displaying final score, level progression, and badges
/// 
/// Features:
/// - Final score with percentage and pass/fail status
/// - Level up animation if student passed
/// - Newly earned badges with animations
/// - Correct vs incorrect answers breakdown
/// - Detailed answer review with correct answers highlighted
/// - "Return to Home" and "View Leaderboard" buttons
/// 
/// Requirements: 5.6, 6.3, 6.4, 7.2, 7.3, 13.4
class QuizResultsScreen extends ConsumerStatefulWidget {
  final String attemptId;

  const QuizResultsScreen({
    super.key,
    required this.attemptId,
  });

  @override
  ConsumerState<QuizResultsScreen> createState() => _QuizResultsScreenState();
}

class _QuizResultsScreenState extends ConsumerState<QuizResultsScreen>
    with TickerProviderStateMixin {
  late AnimationController _scoreAnimationController;
  late AnimationController _levelUpAnimationController;
  late AnimationController _badgeAnimationController;
  
  late Animation<double> _scoreAnimation;
  late Animation<double> _levelUpAnimation;
  late Animation<double> _badgeAnimation;

  bool _showLevelUpAnimation = false;
  bool _showBadgeAnimations = false;
  List<domain.Badge> _newBadges = [];

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controllers
    _scoreAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _levelUpAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _badgeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // Initialize animations
    _scoreAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scoreAnimationController, curve: Curves.easeOutBack),
    );
    
    _levelUpAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _levelUpAnimationController, curve: Curves.elasticOut),
    );
    
    _badgeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _badgeAnimationController, curve: Curves.bounceOut),
    );

    // Start score animation immediately
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scoreAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _scoreAnimationController.dispose();
    _levelUpAnimationController.dispose();
    _badgeAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final attemptAsync = ref.watch(attemptByIdProvider(widget.attemptId));
    final currentUserAsync = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Results'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        automaticallyImplyLeading: false, // Disable back button
      ),
      body: attemptAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorState(error),
        data: (attempt) => currentUserAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => _buildErrorState(error),
          data: (user) {
            if (user == null) {
              return _buildErrorState('No user logged in');
            }
            return _buildResultsContent(attempt, user);
          },
        ),
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text('Error: $error'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.goToStudentHome(),
            child: const Text('Back to Home'),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsContent(QuizAttempt attempt, User user) {
    final quizAsync = ref.watch(quizByIdProvider(attempt.quizId));
    
    return quizAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildErrorState(error),
      data: (quiz) => _buildResultsScreen(attempt, quiz, user),
    );
  }

  Widget _buildResultsScreen(QuizAttempt attempt, Quiz quiz, User user) {
    final scorePercentage = attempt.scorePercentage;
    final passed = scorePercentage >= 60.0;
    final correctAnswers = _calculateCorrectAnswers(attempt, quiz);
    final incorrectAnswers = attempt.totalQuestions - correctAnswers;

    // Check if we should show level up animation
    if (passed && !_showLevelUpAnimation) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _showLevelUpAnimation = true;
        });
        Future.delayed(const Duration(milliseconds: 800), () {
          _levelUpAnimationController.forward();
        });
      });
    }

    // Check for new badges (simulated for now)
    if (passed && !_showBadgeAnimations) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkForNewBadges(user.id);
      });
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Score display with animation
          _buildScoreCard(attempt, passed),
          const SizedBox(height: 24),

          // Level up animation (if applicable)
          if (_showLevelUpAnimation && passed)
            _buildLevelUpCard(),
          
          if (_showLevelUpAnimation && passed)
            const SizedBox(height: 24),

          // New badges (if any)
          if (_showBadgeAnimations && _newBadges.isNotEmpty)
            _buildNewBadgesCard(),
          
          if (_showBadgeAnimations && _newBadges.isNotEmpty)
            const SizedBox(height: 24),

          // Answers breakdown
          _buildAnswersBreakdown(correctAnswers, incorrectAnswers),
          const SizedBox(height: 24),

          // Detailed answer review
          _buildAnswerReview(attempt, quiz),
          const SizedBox(height: 24),

          // Action buttons
          _buildActionButtons(attempt.quizId),
        ],
      ),
    );
  }

  Widget _buildScoreCard(QuizAttempt attempt, bool passed) {
    return AnimatedBuilder(
      animation: _scoreAnimation,
      builder: (context, child) {
        final animatedScore = attempt.scorePercentage * _scoreAnimation.value;
        
        return Card(
          elevation: 8,
          child: Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: passed
                    ? [Colors.green.shade400, Colors.green.shade600]
                    : [Colors.red.shade400, Colors.red.shade600],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.grade,
                  size: 48,
                  color: Colors.white,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Final Score',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${animatedScore.toStringAsFixed(1)}%',
                  style: const TextStyle(
                    fontSize: 48,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    passed ? 'PASSED' : 'FAILED',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '${attempt.score.toInt()} out of ${attempt.totalQuestions} correct',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLevelUpCard() {
    return AnimatedBuilder(
      animation: _levelUpAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _levelUpAnimation.value,
          child: Card(
            elevation: 8,
            child: Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: [Colors.amber.shade400, Colors.orange.shade600],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.trending_up,
                    size: 48,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'LEVEL UP!',
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Congratulations! You\'ve reached a new level!',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNewBadgesCard() {
    return AnimatedBuilder(
      animation: _badgeAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _badgeAnimation.value,
          child: Card(
            elevation: 8,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const Icon(
                    Icons.emoji_events,
                    size: 48,
                    color: Colors.amber,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'New Badges Earned!',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: _newBadges.map((badge) => _buildBadgeChip(badge)).toList(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBadgeChip(domain.Badge badge) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.amber.shade100,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.amber.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.emoji_events, size: 20, color: Colors.amber),
          const SizedBox(width: 8),
          Text(
            badge.name,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.amber,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswersBreakdown(int correctAnswers, int incorrectAnswers) {
    final total = correctAnswers + incorrectAnswers;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Answer Breakdown',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildBreakdownItem(
                    'Correct',
                    correctAnswers,
                    total,
                    Colors.green,
                    Icons.check_circle,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildBreakdownItem(
                    'Incorrect',
                    incorrectAnswers,
                    total,
                    Colors.red,
                    Icons.cancel,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBreakdownItem(
    String label,
    int count,
    int total,
    Color color,
    IconData icon,
  ) {
    final percentage = total > 0 ? (count / total * 100) : 0.0;
    
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(height: 8),
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${percentage.toStringAsFixed(1)}%',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerReview(QuizAttempt attempt, Quiz quiz) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Detailed Answer Review',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...quiz.questions.asMap().entries.map((entry) {
              final index = entry.key;
              final question = entry.value;
              final studentAnswer = attempt.answers[question.id];
              final isCorrect = studentAnswer == question.correctOptionIndex;
              
              return _buildQuestionReview(
                index + 1,
                question,
                studentAnswer,
                isCorrect,
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionReview(
    int questionNumber,
    Question question,
    int? studentAnswer,
    bool isCorrect,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(
          color: isCorrect ? Colors.green.shade300 : Colors.red.shade300,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(12),
        color: isCorrect 
            ? Colors.green.shade50 
            : Colors.red.shade50,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isCorrect ? Colors.green : Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isCorrect ? Icons.check : Icons.close,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Question $questionNumber',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Question text
          Text(
            question.text,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          
          // Answer options
          ...question.options.asMap().entries.map((entry) {
            final optionIndex = entry.key;
            final optionText = entry.value;
            final isStudentAnswer = studentAnswer == optionIndex;
            final isCorrectAnswer = question.correctOptionIndex == optionIndex;
            final optionLabel = String.fromCharCode(65 + optionIndex); // A, B, C, D
            
            Color? backgroundColor;
            Color? textColor;
            IconData? icon;
            
            if (isCorrectAnswer) {
              backgroundColor = Colors.green.shade100;
              textColor = Colors.green.shade800;
              icon = Icons.check_circle;
            } else if (isStudentAnswer && !isCorrectAnswer) {
              backgroundColor = Colors.red.shade100;
              textColor = Colors.red.shade800;
              icon = Icons.cancel;
            }
            
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(8),
                border: (isStudentAnswer || isCorrectAnswer)
                    ? Border.all(
                        color: isCorrectAnswer ? Colors.green : Colors.red,
                        width: 2,
                      )
                    : null,
              ),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: (isStudentAnswer || isCorrectAnswer)
                          ? (isCorrectAnswer ? Colors.green : Colors.red)
                          : Colors.grey.shade300,
                    ),
                    child: Center(
                      child: Text(
                        optionLabel,
                        style: TextStyle(
                          color: (isStudentAnswer || isCorrectAnswer)
                              ? Colors.white
                              : Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      optionText,
                      style: TextStyle(
                        color: textColor ?? Colors.black87,
                        fontWeight: (isStudentAnswer || isCorrectAnswer)
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                  if (icon != null) ...[
                    const SizedBox(width: 8),
                    Icon(
                      icon,
                      color: isCorrectAnswer ? Colors.green : Colors.red,
                      size: 20,
                    ),
                  ],
                ],
              ),
            );
          }),
          
          // Answer explanation
          if (studentAnswer != null) ...[
            const SizedBox(height: 8),
            Text(
              isCorrect
                  ? 'Correct! You selected option ${String.fromCharCode(65 + studentAnswer)}.'
                  : 'Incorrect. You selected option ${String.fromCharCode(65 + studentAnswer)}, but the correct answer is ${String.fromCharCode(65 + question.correctOptionIndex)}.',
              style: TextStyle(
                fontSize: 13,
                color: isCorrect ? Colors.green.shade700 : Colors.red.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ] else ...[
            const SizedBox(height: 8),
            Text(
              'No answer selected. The correct answer is ${String.fromCharCode(65 + question.correctOptionIndex)}.',
              style: TextStyle(
                fontSize: 13,
                color: Colors.red.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButtons(String quizId) {
    return Column(
      children: [
        // Return to Home button
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: () => context.goToStudentHome(),
            icon: const Icon(Icons.home),
            label: const Text(
              'Return to Home',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        
        // View Leaderboard button
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton.icon(
            onPressed: () => context.goToQuizTopStudents(quizId),
            icon: const Icon(Icons.leaderboard),
            label: const Text(
              'View Leaderboard',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  int _calculateCorrectAnswers(QuizAttempt attempt, Quiz quiz) {
    int correctCount = 0;
    for (final question in quiz.questions) {
      final studentAnswer = attempt.answers[question.id];
      if (studentAnswer == question.correctOptionIndex) {
        correctCount++;
      }
    }
    return correctCount;
  }

  void _checkForNewBadges(String studentId) {
    // Simulate checking for new badges
    // In a real implementation, this would call the badge repository
    // For now, we'll simulate some badges being earned
    final simulatedNewBadges = [
      const domain.Badge(
        id: 'first_quiz',
        name: 'First Quiz',
        description: 'Complete your first quiz',
        iconAsset: 'assets/badges/first_quiz.png',
        type: domain.BadgeType.quizzesCompleted,
        requirement: 1,
      ),
    ];

    setState(() {
      _newBadges = simulatedNewBadges;
      _showBadgeAnimations = true;
    });

    Future.delayed(const Duration(milliseconds: 1200), () {
      _badgeAnimationController.forward();
    });
  }
}