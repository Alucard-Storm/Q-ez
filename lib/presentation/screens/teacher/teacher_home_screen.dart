import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/router/navigation_extensions.dart';
import '../../../core/widgets/skeleton_loader.dart';
import '../../../domain/entities/user.dart';
import '../../providers/auth_providers.dart';
import '../../providers/teacher_providers.dart';

/// Teacher home dashboard screen
/// 
/// Displays:
/// - Quiz statistics (total quizzes created, total attempts, average scores)
/// - List of created quizzes with quick actions (edit, delete, view analytics)
/// - "Create New Quiz" floating action button
/// - Recent student activity
/// 
/// Requirements: 2.5, 16.3
class TeacherHomeScreen extends ConsumerWidget {
  const TeacherHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserAsync = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Teacher Dashboard'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final authRepository = ref.read(authRepositoryProvider);
              await authRepository.signOut();
            },
          ),
        ],
      ),
      body: currentUserAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(currentUserProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (user) {
          if (user == null) {
            return const Center(child: Text('No user logged in'));
          }

          if (user.role != UserRole.teacher) {
            return const Center(child: Text('Access denied: Teacher role required'));
          }

          return _buildDashboard(context, ref, user.id);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.goToCreateQuiz(),
        icon: const Icon(Icons.add),
        label: const Text('Create Quiz'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
    );
  }

  Widget _buildDashboard(BuildContext context, WidgetRef ref, String teacherId) {
    final dashboardAsync = ref.watch(teacherDashboardProvider(teacherId));
    final quizzesAsync = ref.watch(teacherQuizzesProvider(teacherId));

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(teacherDashboardProvider(teacherId));
        ref.invalidate(teacherQuizzesProvider(teacherId));
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Statistics cards
            dashboardAsync.when(
              loading: () => _buildStatsSkeleton(),
              error: (error, stack) => _buildErrorCard('Failed to load statistics', error),
              data: (data) => _buildStatisticsSection(data),
            ),
            const SizedBox(height: 24),

            // Quiz list
            quizzesAsync.when(
              loading: () => _buildQuizListSkeleton(),
              error: (error, stack) => _buildErrorCard('Failed to load quizzes', error),
              data: (quizzes) => _buildQuizListSection(context, ref, quizzes),
            ),
            const SizedBox(height: 24),

            // Recent activity
            dashboardAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (error, stack) => const SizedBox.shrink(),
              data: (data) => _buildRecentActivitySection(context, data.recentActivity),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSkeleton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SkeletonLoader(width: 80, height: 20),
        const SizedBox(height: 12),
        Row(
          children: const [
            Expanded(child: SkeletonLoader(height: 90, borderRadius: 12)),
            SizedBox(width: 12),
            Expanded(child: SkeletonLoader(height: 90, borderRadius: 12)),
            SizedBox(width: 12),
            Expanded(child: SkeletonLoader(height: 90, borderRadius: 12)),
          ],
        ),
      ],
    );
  }

  Widget _buildQuizListSkeleton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SkeletonLoader(width: 100, height: 20),
        const SizedBox(height: 12),
        ...List.generate(3, (_) => const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: CardSkeleton(),
        )),
      ],
    );
  }

  Widget _buildStatisticsSection(TeacherDashboardData data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Overview',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Total Quizzes',
                data.totalQuizzes.toString(),
                Icons.quiz,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Total Attempts',
                data.totalAttempts.toString(),
                Icons.people,
                Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Average Score',
                '${data.averageScore.toStringAsFixed(1)}%',
                Icons.grade,
                Colors.orange,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizListSection(BuildContext context, WidgetRef ref, List<dynamic> quizzes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'My Quizzes',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        if (quizzes.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.quiz_outlined,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No quizzes created yet',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Create your first quiz to get started!',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          ...quizzes.map((quiz) => _buildQuizCard(context, ref, quiz)),
      ],
    );
  }

  Widget _buildQuizCard(BuildContext context, WidgetRef ref, dynamic quiz) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        quiz.title ?? 'Untitled Quiz',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (quiz.description?.isNotEmpty == true) ...[
                        const SizedBox(height: 4),
                        Text(
                          quiz.description!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'PIN: ${quiz.pin ?? 'N/A'}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.quiz,
                  size: 16,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 4),
                Text(
                  '${quiz.questions?.length ?? 0} questions',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(width: 16),
                if (quiz.timeLimitMinutes != null) ...[
                  Icon(
                    Icons.timer,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${quiz.timeLimitMinutes} min',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
                const Spacer(),
                Text(
                  _formatDate(quiz.createdAt ?? DateTime.now()),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => context.goToQuizAnalytics(quiz.id ?? ''),
                    icon: const Icon(Icons.analytics, size: 16),
                    label: const Text('Analytics'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => context.goToEditQuiz(quiz.id ?? ''),
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Edit'),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _showDeleteConfirmation(context, ref, quiz),
                  icon: const Icon(Icons.delete, color: Colors.red),
                  tooltip: 'Delete Quiz',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivitySection(BuildContext context, List<dynamic> recentActivity) {
    if (recentActivity.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Student Activity',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...recentActivity.take(5).map((attempt) => _buildActivityItem(attempt)),
      ],
    );
  }

  Widget _buildActivityItem(dynamic attempt) {
    final score = attempt.score ?? 0.0;
    final isPassed = score >= 60.0;
    final completedAt = attempt.completedAt ?? DateTime.now();

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isPassed ? Colors.green.shade100 : Colors.red.shade100,
          child: Icon(
            isPassed ? Icons.check : Icons.close,
            color: isPassed ? Colors.green : Colors.red,
            size: 20,
          ),
        ),
        title: Text('Student completed quiz'),
        subtitle: Text(
          'Completed on ${_formatDate(completedAt)}',
          style: TextStyle(color: Colors.grey.shade600),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${score.toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isPassed ? Colors.green : Colors.red,
              ),
            ),
            if (attempt.securityViolations > 0)
              Text(
                '⚠️ ${attempt.securityViolations} violations',
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.orange,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard(String title, Object error) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Icon(Icons.error, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: TextStyle(color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref, dynamic quiz) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Quiz'),
        content: Text('Are you sure you want to delete "${quiz.title}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                final deleteUseCase = ref.read(deleteQuizUseCaseProvider);
                await deleteUseCase(quiz.id);
                
                // Refresh the quiz list
                ref.invalidate(teacherQuizzesProvider);
                ref.invalidate(teacherDashboardProvider);
                
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Quiz deleted successfully')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to delete quiz: $e')),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}