import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/router/navigation_extensions.dart';
import '../../../core/widgets/skeleton_loader.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/entities/badge.dart' as domain_badge;
import '../../../domain/usecases/progress/get_progress_dashboard_use_case.dart';
import '../../providers/auth_providers.dart';
import '../../providers/student_providers.dart';

/// Student home dashboard screen
/// 
/// Displays:
/// - Quick stats (level, total quizzes, average score)
/// - Prominent "Join Quiz" button
/// - Recent quiz history with scores
/// - Recently earned badges
/// 
/// Requirements: 4.4, 6.2, 6.3, 13.6
class StudentHomeScreen extends ConsumerWidget {
  const StudentHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserAsync = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Q-ez'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () => context.pushSettings(),
          ),
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

          if (user.role != UserRole.student) {
            return const Center(child: Text('Access denied: Student role required'));
          }

          return _buildDashboard(context, ref, user.id);
        },
      ),
    );
  }

  Widget _buildDashboard(BuildContext context, WidgetRef ref, String studentId) {
    final progressAsync = ref.watch(progressDashboardProvider(studentId));

    return progressAsync.when(
      loading: () => _buildHomeSkeleton(),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error loading dashboard: $error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.invalidate(progressDashboardProvider(studentId)),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
      data: (progressData) => RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(progressDashboardProvider(studentId));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome message
              _buildWelcomeSection(progressData.student),
              const SizedBox(height: 24),

              // Join Quiz button (prominent)
              _buildJoinQuizButton(context),
              const SizedBox(height: 24),

              // Quick stats
              _buildQuickStats(progressData),
              const SizedBox(height: 24),

              // Recent quiz history
              _buildRecentQuizHistory(context, progressData.recentAttempts),
              const SizedBox(height: 24),

              // Recently earned badges
              _buildRecentBadges(context, progressData.earnedBadges),
              const SizedBox(height: 24),

              // Quick navigation buttons
              _buildQuickNavigation(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHomeSkeleton() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome card skeleton
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  SkeletonLoader(width: 60, height: 60, borderRadius: 30),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonLoader(height: 20),
                        SizedBox(height: 8),
                        SkeletonLoader(width: 80, height: 14),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Join quiz button skeleton
          const SkeletonLoader(height: 60, borderRadius: 12),
          const SizedBox(height: 24),
          // Stats skeleton
          const SkeletonLoader(width: 100, height: 20),
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
          const SizedBox(height: 24),
          // Recent history skeleton
          const SkeletonLoader(width: 160, height: 20),
          const SizedBox(height: 12),
          ...List.generate(3, (_) => const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: SkeletonLoader(height: 72, borderRadius: 12),
          )),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection(Student student) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.blue.shade100,
              child: Text(
                student.name.isNotEmpty ? student.name[0].toUpperCase() : 'S',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back, ${student.name}!',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Level ${student.level}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJoinQuizButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton.icon(
        onPressed: () => context.goToJoinQuiz(),
        icon: const Icon(Icons.quiz, size: 28),
        label: const Text(
          'Join Quiz',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStats(ProgressDashboardData progressData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Stats',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Level',
                progressData.currentLevel.toString(),
                Icons.trending_up,
                Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Total Quizzes',
                progressData.totalQuizzes.toString(),
                Icons.quiz,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Average Score',
                '${progressData.averageScore.toStringAsFixed(1)}%',
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

  Widget _buildRecentQuizHistory(BuildContext context, List<dynamic> recentAttempts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Quiz History',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () => context.goToProgressDashboard(),
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (recentAttempts.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.quiz_outlined,
                      size: 48,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No quizzes taken yet',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Take your first quiz to see your progress here!',
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
          ...recentAttempts.take(5).map((attempt) => _buildQuizHistoryItem(attempt)),
      ],
    );
  }

  Widget _buildQuizHistoryItem(dynamic attempt) {
    // For now, we'll handle this as a generic dynamic type
    // In a real implementation, this would be properly typed
    final score = attempt.scorePercentage ?? 0.0;
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
          ),
        ),
        title: Text('Quiz ${attempt.quizId ?? 'Unknown'}'),
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
            Text(
              isPassed ? 'Passed' : 'Failed',
              style: TextStyle(
                fontSize: 12,
                color: isPassed ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentBadges(BuildContext context, List<domain_badge.Badge> earnedBadges) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Badges',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () => context.goToBadges(),
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (earnedBadges.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.emoji_events_outlined,
                      size: 48,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No badges earned yet',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Complete quizzes to earn your first badge!',
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
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: earnedBadges.take(5).length,
              itemBuilder: (context, index) {
                final badge = earnedBadges[index];
                return _buildBadgeItem(badge);
              },
            ),
          ),
      ],
    );
  }

  Widget _buildBadgeItem(domain_badge.Badge badge) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.emoji_events,
                size: 32,
                color: Colors.amber,
              ),
              const SizedBox(height: 8),
              Text(
                badge.name,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickNavigation(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Navigation',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildNavigationCard(
                context,
                'Leaderboard',
                'See how you rank',
                Icons.leaderboard,
                Colors.purple,
                () => context.goToLeaderboard(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildNavigationCard(
                context,
                'Badges',
                'View achievements',
                Icons.emoji_events,
                Colors.amber,
                () => context.goToBadges(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNavigationCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}