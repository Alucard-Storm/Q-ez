import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/router/navigation_extensions.dart';
import '../../../domain/entities/quiz.dart';
import '../../../domain/usecases/progress/get_quiz_top_students_use_case.dart';
import '../../providers/auth_providers.dart';
import '../../providers/quiz_providers.dart';
import '../../providers/student_providers.dart';

/// Quiz-specific top 10 screen displaying the highest performers for a particular quiz
/// 
/// Features:
/// - Ranked list of top 10 students for the quiz
/// - Student names, scores, completion times, and ranks
/// - Highlighted current user position if in top 10
/// - "Try Again" button to retake the quiz
/// - Quiz information header
/// - Pull-to-refresh functionality
/// 
/// Requirements: 8.1, 8.2, 8.3, 8.4, 8.5
class QuizTopStudentsScreen extends ConsumerStatefulWidget {
  final String quizId;

  const QuizTopStudentsScreen({
    super.key,
    required this.quizId,
  });

  @override
  ConsumerState<QuizTopStudentsScreen> createState() => _QuizTopStudentsScreenState();
}

class _QuizTopStudentsScreenState extends ConsumerState<QuizTopStudentsScreen> {
  @override
  Widget build(BuildContext context) {
    final currentUserAsync = ref.watch(currentUserProvider);
    final quizAsync = ref.watch(quizByIdProvider(widget.quizId));
    final topStudentsAsync = ref.watch(quizTopStudentsProvider(widget.quizId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Top 10 Students'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 0,
      ),
      body: currentUserAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorWidget(error),
        data: (currentUser) {
          if (currentUser == null) {
            return const Center(child: Text('Please log in to view rankings'));
          }

          return quizAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => _buildErrorWidget(error),
            data: (quiz) => topStudentsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => _buildErrorWidget(error),
              data: (topStudents) => _buildTopStudentsContent(
                context,
                quiz,
                topStudents,
                currentUser.id,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorWidget(Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Error loading top students',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => ref.invalidate(quizTopStudentsProvider),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildTopStudentsContent(
    BuildContext context,
    Quiz quiz,
    List<QuizTopStudentEntry> topStudents,
    String currentUserId,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(quizTopStudentsProvider);
      },
      child: Column(
        children: [
          // Quiz information header
          _buildQuizHeader(quiz),
          
          // Top students list or empty state
          Expanded(
            child: topStudents.isEmpty
                ? _buildEmptyState()
                : _buildTopStudentsList(topStudents, currentUserId),
          ),
          
          // Try Again button
          _buildTryAgainButton(quiz),
        ],
      ),
    );
  }

  Widget _buildQuizHeader(Quiz quiz) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      margin: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.emoji_events,
                  size: 28,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Top Performers',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      quiz.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.quiz,
                  size: 16,
                  color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.8),
                ),
                const SizedBox(width: 8),
                Text(
                  '${quiz.questions.length} questions',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(width: 16),
                if (quiz.timeLimitMinutes != null) ...[
                  Icon(
                    Icons.timer,
                    size: 16,
                    color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.8),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${quiz.timeLimitMinutes} min limit',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.leaderboard_outlined,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 24),
            Text(
              'No students have completed this quiz yet',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Be the first to complete this quiz and claim the top spot!',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopStudentsList(
    List<QuizTopStudentEntry> topStudents,
    String currentUserId,
  ) {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemCount: topStudents.length,
      itemBuilder: (context, index) {
        final entry = topStudents[index];
        final isCurrentUser = entry.student.id == currentUserId;
        
        return _buildTopStudentItem(
          context,
          entry,
          isCurrentUser,
        );
      },
    );
  }

  Widget _buildTopStudentItem(
    BuildContext context,
    QuizTopStudentEntry entry,
    bool isCurrentUser,
  ) {
    final rank = entry.rank;
    final student = entry.student;
    final scorePercentage = (entry.score / entry.attempt.totalQuestions * 100);
    
    // Determine rank styling
    Widget rankWidget;
    Color? cardColor;
    Color? borderColor;
    
    if (rank == 1) {
      rankWidget = Container(
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
          color: Colors.amber,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.emoji_events, color: Colors.white, size: 24),
      );
      cardColor = Colors.amber.withValues(alpha: 0.1);
      borderColor = Colors.amber.withValues(alpha: 0.3);
    } else if (rank == 2) {
      rankWidget = Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey.shade400,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.emoji_events, color: Colors.white, size: 22),
      );
      cardColor = Colors.grey.withValues(alpha: 0.1);
      borderColor = Colors.grey.withValues(alpha: 0.3);
    } else if (rank == 3) {
      rankWidget = Container(
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
          color: Colors.brown,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.emoji_events, color: Colors.white, size: 20),
      );
      cardColor = Colors.brown.withValues(alpha: 0.1);
      borderColor = Colors.brown.withValues(alpha: 0.3);
    } else {
      rankWidget = Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
          shape: BoxShape.circle,
          border: Border.all(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            rank.toString(),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      );
    }

    // Highlight current user
    if (isCurrentUser) {
      cardColor = Theme.of(context).colorScheme.primary.withValues(alpha: 0.15);
      borderColor = Theme.of(context).colorScheme.primary;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: Card(
        color: cardColor,
        elevation: isCurrentUser ? 6 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: borderColor != null
              ? BorderSide(color: borderColor, width: isCurrentUser ? 2 : 1)
              : BorderSide.none,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              // Rank indicator
              rankWidget,
              
              const SizedBox(width: 20),
              
              // Student avatar
              CircleAvatar(
                radius: 28,
                backgroundColor: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.2),
                child: Text(
                  student.name.isNotEmpty ? student.name[0].toUpperCase() : 'S',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ),
              
              const SizedBox(width: 20),
              
              // Student info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            student.name,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isCurrentUser 
                                  ? Theme.of(context).colorScheme.primary
                                  : null,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isCurrentUser)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              'You',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.grade,
                          size: 18,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${entry.score.toInt()}/${entry.attempt.totalQuestions} correct',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    if (entry.completionTime != null)
                      Row(
                        children: [
                          Icon(
                            Icons.timer,
                            size: 18,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _formatDuration(entry.completionTime!),
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              
              // Score display
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getScoreColor(scorePercentage).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _getScoreColor(scorePercentage).withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      '${scorePercentage.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _getScoreColor(scorePercentage),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    scorePercentage >= 60 ? 'PASSED' : 'FAILED',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _getScoreColor(scorePercentage),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTryAgainButton(Quiz quiz) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton.icon(
        onPressed: () => context.goToQuizTaking(quiz.id),
        icon: const Icon(Icons.refresh, size: 20),
        label: const Text(
          'Try Again',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
      ),
    );
  }

  Color _getScoreColor(double percentage) {
    if (percentage >= 80) {
      return Colors.green;
    } else if (percentage >= 60) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    
    if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }
}