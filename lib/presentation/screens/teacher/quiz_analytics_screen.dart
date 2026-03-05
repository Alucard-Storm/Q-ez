import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/user.dart';
import '../../providers/auth_providers.dart';
import '../../providers/quiz_providers.dart';
import '../../providers/teacher_providers.dart';

/// Quiz analytics screen
/// 
/// Features:
/// - Quiz statistics (total attempts, average score, pass rate, completion rate)
/// - Top 10 students for this quiz
/// - Question-level analytics (most missed questions, average time per question)
/// - Chart showing score distribution
/// - List all attempts with student names, scores, and violation flags
/// - Filter and sort options
/// 
/// Requirements: 6.1, 8.1, 15.7, 16.1, 16.2, 16.4
class QuizAnalyticsScreen extends ConsumerStatefulWidget {
  final String quizId;

  const QuizAnalyticsScreen({
    super.key,
    required this.quizId,
  });

  @override
  ConsumerState<QuizAnalyticsScreen> createState() => _QuizAnalyticsScreenState();
}

class _QuizAnalyticsScreenState extends ConsumerState<QuizAnalyticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _sortBy = 'score'; // score, date, violations
  bool _sortAscending = false;
  bool _showOnlyFlagged = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUserAsync = ref.watch(currentUserProvider);
    final quizAsync = ref.watch(quizByIdProvider(widget.quizId));
    final analyticsAsync = ref.watch(quizAnalyticsProvider(widget.quizId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Analytics'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview', icon: Icon(Icons.analytics)),
            Tab(text: 'Students', icon: Icon(Icons.people)),
            Tab(text: 'Attempts', icon: Icon(Icons.list)),
          ],
        ),
      ),
      body: currentUserAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (user) {
          if (user == null || user.role != UserRole.teacher) {
            return const Center(child: Text('Access denied'));
          }

          return quizAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Failed to load quiz: $error'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ref.refresh(quizByIdProvider(widget.quizId)),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
            data: (quiz) {
              return analyticsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('Failed to load analytics: $error'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => ref.refresh(quizAnalyticsProvider(widget.quizId)),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
                data: (analytics) => RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(quizAnalyticsProvider(widget.quizId));
                  },
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildOverviewTab(quiz, analytics),
                      _buildStudentsTab(analytics),
                      _buildAttemptsTab(analytics),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildOverviewTab(dynamic quiz, QuizAnalyticsData analytics) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quiz info card
          _buildQuizInfoCard(quiz),
          const SizedBox(height: 24),

          // Statistics cards
          _buildStatisticsSection(analytics),
          const SizedBox(height: 24),

          // Score distribution chart
          _buildScoreDistributionSection(analytics),
          const SizedBox(height: 24),

          // Question analytics (placeholder)
          _buildQuestionAnalyticsSection(analytics),
        ],
      ),
    );
  }

  Widget _buildStudentsTab(QuizAnalyticsData analytics) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Top 10 Students',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          if (analytics.topStudents.isEmpty)
            _buildEmptyState('No students have completed this quiz yet')
          else
            ...analytics.topStudents.asMap().entries.map(
              (entry) => _buildTopStudentCard(entry.key + 1, entry.value),
            ),
        ],
      ),
    );
  }

  Widget _buildAttemptsTab(QuizAnalyticsData analytics) {
    final filteredAttempts = _getFilteredAttempts(analytics.allAttempts);

    return Column(
      children: [
        // Filter and sort controls
        _buildFilterControls(),
        
        // Attempts list
        Expanded(
          child: filteredAttempts.isEmpty
              ? _buildEmptyState('No attempts match your filters')
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: filteredAttempts.length,
                  itemBuilder: (context, index) => _buildAttemptCard(filteredAttempts[index]),
                ),
        ),
      ],
    );
  }

  Widget _buildQuizInfoCard(dynamic quiz) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              quiz.title ?? 'Untitled Quiz',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            if (quiz.description?.isNotEmpty == true) ...[
              const SizedBox(height: 8),
              Text(
                quiz.description!,
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                _buildInfoChip('PIN: ${quiz.pin}', Icons.pin),
                const SizedBox(width: 12),
                _buildInfoChip('${quiz.questions?.length ?? 0} Questions', Icons.quiz),
                if (quiz.timeLimitMinutes != null) ...[
                  const SizedBox(width: 12),
                  _buildInfoChip('${quiz.timeLimitMinutes} min', Icons.timer),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildStatisticsSection(QuizAnalyticsData analytics) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Statistics',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Total Attempts',
                analytics.totalAttempts.toString(),
                Icons.people,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Average Score',
                '${analytics.averageScore.toStringAsFixed(1)}%',
                Icons.grade,
                Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Pass Rate',
                '${(analytics.passRate * 100).toStringAsFixed(1)}%',
                Icons.check_circle,
                Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Completion Rate',
                '${(analytics.completionRate * 100).toStringAsFixed(1)}%',
                Icons.task_alt,
                Colors.purple,
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
                fontSize: 18,
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

  Widget _buildScoreDistributionSection(QuizAnalyticsData analytics) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Score Distribution',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (analytics.scoreDistribution.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Text('No completed attempts yet'),
                ),
              )
            else
              SizedBox(
                height: 200,
                child: _buildScoreChart(analytics.scoreDistribution),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreChart(Map<int, int> scoreDistribution) {
    // Simple bar chart representation
    final maxCount = scoreDistribution.values.fold(0, (max, count) => count > max ? count : max);
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(10, (index) {
        final scoreRange = index * 10;
        final count = scoreDistribution[scoreRange] ?? 0;
        final height = maxCount > 0 ? (count / maxCount) * 150 : 0.0;
        
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              count.toString(),
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 4),
            Container(
              width: 20,
              height: height,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${scoreRange}-${scoreRange + 9}',
              style: const TextStyle(fontSize: 10),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildQuestionAnalyticsSection(QuizAnalyticsData analytics) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Question Analytics',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Column(
                  children: [
                    Icon(Icons.analytics_outlined, size: 48, color: Colors.grey),
                    SizedBox(height: 12),
                    Text(
                      'Question-level analytics coming soon',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopStudentCard(int rank, dynamic attempt) {
    final score = attempt.score ?? 0.0;
    final isPassed = score >= 60.0;
    final completedAt = attempt.completedAt ?? DateTime.now();

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: rank <= 3 
              ? (rank == 1 ? Colors.amber : rank == 2 ? Colors.grey : Colors.brown)
              : Theme.of(context).colorScheme.primaryContainer,
          child: Text(
            rank.toString(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: rank <= 3 ? Colors.white : null,
            ),
          ),
        ),
        title: Text('Student ${attempt.studentId ?? 'Unknown'}'),
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
                '⚠️ ${attempt.securityViolations}',
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

  Widget _buildFilterControls() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _sortBy,
                  decoration: const InputDecoration(
                    labelText: 'Sort by',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'score', child: Text('Score')),
                    DropdownMenuItem(value: 'date', child: Text('Date')),
                    DropdownMenuItem(value: 'violations', child: Text('Violations')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _sortBy = value;
                      });
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: () {
                  setState(() {
                    _sortAscending = !_sortAscending;
                  });
                },
                icon: Icon(
                  _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                ),
                tooltip: _sortAscending ? 'Ascending' : 'Descending',
              ),
            ],
          ),
          const SizedBox(height: 12),
          CheckboxListTile(
            title: const Text('Show only flagged attempts'),
            value: _showOnlyFlagged,
            onChanged: (value) {
              setState(() {
                _showOnlyFlagged = value ?? false;
              });
            },
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  Widget _buildAttemptCard(dynamic attempt) {
    final score = attempt.score ?? 0.0;
    final isPassed = score >= 60.0;
    final completedAt = attempt.completedAt ?? DateTime.now();
    final isFlagged = attempt.isFlagged ?? false;

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
        title: Row(
          children: [
            Text('Student ${attempt.studentId ?? 'Unknown'}'),
            if (isFlagged) ...[
              const SizedBox(width: 8),
              const Icon(Icons.flag, color: Colors.red, size: 16),
            ],
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Completed on ${_formatDate(completedAt)}',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            if (attempt.securityViolations > 0)
              Text(
                '⚠️ ${attempt.securityViolations} security violations',
                style: const TextStyle(color: Colors.orange, fontSize: 12),
              ),
          ],
        ),
        trailing: Text(
          '${score.toStringAsFixed(1)}%',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isPassed ? Colors.green : Colors.red,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  List<dynamic> _getFilteredAttempts(List<dynamic> attempts) {
    var filtered = attempts.where((attempt) => attempt.completedAt != null).toList();

    if (_showOnlyFlagged) {
      filtered = filtered.where((attempt) => attempt.isFlagged == true).toList();
    }

    // Sort attempts
    filtered.sort((a, b) {
      int comparison = 0;
      
      switch (_sortBy) {
        case 'score':
          comparison = (a.score ?? 0.0).compareTo(b.score ?? 0.0);
          break;
        case 'date':
          comparison = (a.completedAt ?? DateTime.now()).compareTo(b.completedAt ?? DateTime.now());
          break;
        case 'violations':
          comparison = (a.securityViolations ?? 0).compareTo(b.securityViolations ?? 0);
          break;
      }

      return _sortAscending ? comparison : -comparison;
    });

    return filtered;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}