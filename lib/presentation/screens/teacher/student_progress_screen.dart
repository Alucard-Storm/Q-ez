import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/debouncer.dart';
import '../../../domain/entities/user.dart';
import '../../providers/auth_providers.dart';
import '../../providers/student_providers.dart';

/// Student progress viewer screen
/// 
/// Features:
/// - Student search and selection interface
/// - Display selected student's progress dashboard
/// - Show student's earned badges
/// - Display quiz history for that student
/// - Export functionality for student reports
/// 
/// Requirements: 16.1, 16.2, 16.4
class StudentProgressScreen extends ConsumerStatefulWidget {
  final String? studentId;

  const StudentProgressScreen({
    super.key,
    this.studentId,
  });

  @override
  ConsumerState<StudentProgressScreen> createState() => _StudentProgressScreenState();
}

class _StudentProgressScreenState extends ConsumerState<StudentProgressScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  final _debouncer = Debouncer(delay: const Duration(milliseconds: 400));
  String? _selectedStudentId;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _selectedStudentId = widget.studentId;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _debouncer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUserAsync = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Progress'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        bottom: _selectedStudentId != null
            ? TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Overview', icon: Icon(Icons.dashboard)),
                  Tab(text: 'Badges', icon: Icon(Icons.emoji_events)),
                  Tab(text: 'History', icon: Icon(Icons.history)),
                ],
              )
            : null,
        actions: _selectedStudentId != null
            ? [
                IconButton(
                  onPressed: _exportStudentReport,
                  icon: const Icon(Icons.download),
                  tooltip: 'Export Report',
                ),
              ]
            : null,
      ),
      body: currentUserAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (user) {
          if (user == null || user.role != UserRole.teacher) {
            return const Center(child: Text('Access denied'));
          }

          if (_selectedStudentId == null) {
            return _buildStudentSearchView();
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildOverviewTab(_selectedStudentId!),
              _buildBadgesTab(_selectedStudentId!),
              _buildHistoryTab(_selectedStudentId!),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStudentSearchView() {
    final studentsAsync = ref.watch(allStudentsProvider);

    return Column(
      children: [
        // Search bar
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(
              bottom: BorderSide(color: Colors.grey.shade300),
            ),
          ),
          child: TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              labelText: 'Search students',
              hintText: 'Enter student name or email',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              _debouncer.run(() {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              });
            },
          ),
        ),

        // Students list
        Expanded(
          child: studentsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Failed to load students: $error'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ref.refresh(allStudentsProvider),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
            data: (students) {
              final filteredStudents = students.where((student) {
                if (_searchQuery.isEmpty) return true;
                return student.name.toLowerCase().contains(_searchQuery) ||
                       student.email.toLowerCase().contains(_searchQuery);
              }).toList();

              if (filteredStudents.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.person_search,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _searchQuery.isEmpty
                            ? 'No students found'
                            : 'No students match your search',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: filteredStudents.length,
                itemBuilder: (context, index) {
                  final student = filteredStudents[index];
                  return _buildStudentCard(student);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStudentCard(dynamic student) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Text(
            student.name.isNotEmpty ? student.name[0].toUpperCase() : 'S',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(student.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(student.email),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  'Level ${student.level}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  '${student.totalQuizzesTaken} quizzes',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  '${student.averageScore.toStringAsFixed(1)}% avg',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          setState(() {
            _selectedStudentId = student.id;
          });
        },
      ),
    );
  }

  Widget _buildOverviewTab(String studentId) {
    final progressAsync = ref.watch(progressDashboardProvider(studentId));

    return progressAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Failed to load progress: $error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.refresh(progressDashboardProvider(studentId)),
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
              // Student info card
              _buildStudentInfoCard(progressData.student),
              const SizedBox(height: 24),

              // Statistics
              _buildStatisticsSection(progressData),
              const SizedBox(height: 24),

              // Performance chart
              _buildPerformanceChartSection(progressData),
              const SizedBox(height: 24),

              // Recent activity
              _buildRecentActivitySection(progressData.recentAttempts),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadgesTab(String studentId) {
    final badgesAsync = ref.watch(studentBadgesProvider(studentId));

    return badgesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Failed to load badges: $error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.refresh(studentBadgesProvider(studentId)),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
      data: (badges) => RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(studentBadgesProvider(studentId));
        },
        child: badges.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.emoji_events_outlined,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No badges earned yet',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              )
            : GridView.builder(
                padding: const EdgeInsets.all(16.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.2,
                ),
                itemCount: badges.length,
                itemBuilder: (context, index) => _buildBadgeCard(badges[index]),
              ),
      ),
    );
  }

  Widget _buildHistoryTab(String studentId) {
    final attemptsAsync = ref.watch(studentAttemptsProvider(studentId));

    return attemptsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Failed to load history: $error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.refresh(studentAttemptsProvider(studentId)),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
      data: (attempts) => RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(studentAttemptsProvider(studentId));
        },
        child: attempts.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.history,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No quiz attempts yet',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: attempts.length,
                itemBuilder: (context, index) => _buildAttemptCard(attempts[index]),
              ),
      ),
    );
  }

  Widget _buildStudentInfoCard(dynamic student) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
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
                    student.name,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    student.email,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Level ${student.level}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Joined ${_formatDate(student.createdAt)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsSection(dynamic progressData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Statistics',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
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
                Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Current Level',
                progressData.currentLevel.toString(),
                Icons.trending_up,
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

  Widget _buildPerformanceChartSection(dynamic progressData) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Performance Trend',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.show_chart,
                      size: 48,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Performance chart coming soon',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                      ),
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

  Widget _buildRecentActivitySection(List<dynamic> recentAttempts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Activity',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        if (recentAttempts.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.history,
                      size: 48,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No recent activity',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          ...recentAttempts.take(5).map((attempt) => _buildAttemptCard(attempt)),
      ],
    );
  }

  Widget _buildBadgeCard(dynamic badge) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.emoji_events,
              size: 48,
              color: Colors.amber,
            ),
            const SizedBox(height: 12),
            Text(
              badge.name ?? 'Badge',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              badge.description ?? '',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttemptCard(dynamic attempt) {
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
          ),
        ),
        title: Text('Quiz ${attempt.quizId ?? 'Unknown'}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Completed on ${_formatDate(completedAt)}',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            if (attempt.securityViolations > 0)
              Text(
                '⚠️ ${attempt.securityViolations} violations',
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

  void _exportStudentReport() {
    // Placeholder for export functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Export functionality coming soon'),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}