import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../domain/entities/quiz_attempt.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/usecases/progress/get_progress_dashboard_use_case.dart';
import '../../providers/auth_providers.dart';
import '../../providers/student_providers.dart';

/// Filter options for progress dashboard
enum ProgressFilter {
  last10('Last 10 Quizzes'),
  last30Days('Last 30 Days'),
  allTime('All Time');

  const ProgressFilter(this.label);
  final String label;
}

/// Progress dashboard screen showing detailed student performance analytics
/// 
/// Features:
/// - Line chart showing score trends over time
/// - Key statistics cards (total quizzes, average score, current level, improvement trend)
/// - Pass/fail ratio with visual chart
/// - Recent quiz history list
/// - Filter options (last 10, last 30 days, all time)
/// 
/// Requirements: 14.1, 14.2, 14.3, 14.4, 14.5, 14.6
class ProgressDashboardScreen extends ConsumerStatefulWidget {
  const ProgressDashboardScreen({super.key});

  @override
  ConsumerState<ProgressDashboardScreen> createState() => _ProgressDashboardScreenState();
}

class _ProgressDashboardScreenState extends ConsumerState<ProgressDashboardScreen> {
  ProgressFilter _selectedFilter = ProgressFilter.allTime;

  @override
  Widget build(BuildContext context) {
    final currentUserAsync = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress Dashboard'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          PopupMenuButton<ProgressFilter>(
            icon: const Icon(Icons.filter_list),
            onSelected: (filter) {
              setState(() {
                _selectedFilter = filter;
              });
            },
            itemBuilder: (context) => ProgressFilter.values
                .map((filter) => PopupMenuItem(
                      value: filter,
                      child: Row(
                        children: [
                          Icon(
                            _selectedFilter == filter
                                ? Icons.radio_button_checked
                                : Icons.radio_button_unchecked,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(filter.label),
                        ],
                      ),
                    ))
                .toList(),
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
      loading: () => const Center(child: CircularProgressIndicator()),
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
              // Filter indicator
              _buildFilterIndicator(),
              const SizedBox(height: 16),

              // Key statistics cards
              _buildStatisticsCards(progressData),
              const SizedBox(height: 24),

              // Score trends chart
              _buildScoreTrendsChart(progressData),
              const SizedBox(height: 24),

              // Pass/fail ratio chart
              _buildPassFailChart(progressData),
              const SizedBox(height: 24),

              // Recent quiz history
              _buildQuizHistory(progressData),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.filter_list,
            size: 16,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
          const SizedBox(width: 4),
          Text(
            'Showing: ${_selectedFilter.label}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsCards(ProgressDashboardData progressData) {
    final filteredData = _getFilteredData(progressData);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Key Statistics',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.5,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: [
            _buildStatCard(
              'Current Level',
              progressData.currentLevel.toString(),
              Icons.trending_up,
              Colors.green,
            ),
            _buildStatCard(
              'Total Quizzes',
              filteredData.totalQuizzes.toString(),
              Icons.quiz,
              Colors.blue,
            ),
            _buildStatCard(
              'Average Score',
              '${filteredData.averageScore.toStringAsFixed(1)}%',
              Icons.grade,
              Colors.orange,
            ),
            _buildStatCard(
              'Improvement',
              '${filteredData.improvementTrend >= 0 ? '+' : ''}${filteredData.improvementTrend.toStringAsFixed(1)}%',
              filteredData.improvementTrend >= 0 ? Icons.trending_up : Icons.trending_down,
              filteredData.improvementTrend >= 0 ? Colors.green : Colors.red,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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

  Widget _buildScoreTrendsChart(ProgressDashboardData progressData) {
    final filteredAttempts = _getFilteredAttempts(progressData.recentAttempts);
    
    if (filteredAttempts.isEmpty) {
      return _buildEmptyChart('No quiz data available for the selected period');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Score Trends Over Time',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              height: 250,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    horizontalInterval: 20,
                    verticalInterval: 1,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey.shade300,
                        strokeWidth: 1,
                      );
                    },
                    getDrawingVerticalLine: (value) {
                      return FlLine(
                        color: Colors.grey.shade300,
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < filteredAttempts.length) {
                            return SideTitleWidget(
                              meta: meta,
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            );
                          }
                          return SideTitleWidget(
                            meta: meta,
                            child: const Text(''),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 20,
                        getTitlesWidget: (value, meta) {
                          return SideTitleWidget(
                            meta: meta,
                            child: Text(
                              '${value.toInt()}%',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          );
                        },
                        reservedSize: 42,
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  minX: 0,
                  maxX: (filteredAttempts.length - 1).toDouble(),
                  minY: 0,
                  maxY: 100,
                  lineBarsData: [
                    LineChartBarData(
                      spots: filteredAttempts
                          .asMap()
                          .entries
                          .map((entry) => FlSpot(
                                entry.key.toDouble(),
                                entry.value.scorePercentage,
                              ))
                          .toList(),
                      isCurved: true,
                      gradient: LinearGradient(
                        colors: [
                          Colors.blue.shade400,
                          Colors.blue.shade600,
                        ],
                      ),
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: Colors.blue.shade600,
                            strokeWidth: 2,
                            strokeColor: Colors.white,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            Colors.blue.shade100.withValues(alpha: 0.3),
                            Colors.blue.shade50.withValues(alpha: 0.1),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    enabled: true,
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipColor: (touchedSpot) => Colors.blueAccent,
                      getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                        return touchedBarSpots.map((barSpot) {
                          final flSpot = barSpot;
                          return LineTooltipItem(
                            'Quiz ${flSpot.x.toInt() + 1}\n${flSpot.y.toStringAsFixed(1)}%',
                            const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        }).toList();
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPassFailChart(ProgressDashboardData progressData) {
    final filteredData = _getFilteredData(progressData);
    
    if (filteredData.totalQuizzes == 0) {
      return _buildEmptyChart('No quiz data available for pass/fail analysis');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pass/Fail Ratio',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 200,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                        sections: [
                          PieChartSectionData(
                            color: Colors.green,
                            value: filteredData.passCount.toDouble(),
                            title: '${filteredData.passCount}',
                            radius: 60,
                            titleStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          PieChartSectionData(
                            color: Colors.red,
                            value: filteredData.failCount.toDouble(),
                            title: '${filteredData.failCount}',
                            radius: 60,
                            titleStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLegendItem(
                        'Passed',
                        filteredData.passCount,
                        Colors.green,
                        filteredData.totalQuizzes,
                      ),
                      const SizedBox(height: 12),
                      _buildLegendItem(
                        'Failed',
                        filteredData.failCount,
                        Colors.red,
                        filteredData.totalQuizzes,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Pass Rate: ${filteredData.totalQuizzes > 0 ? ((filteredData.passCount / filteredData.totalQuizzes) * 100).toStringAsFixed(1) : 0}%',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, int count, Color color, int total) {
    final percentage = total > 0 ? (count / total) * 100 : 0.0;
    
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '$count (${percentage.toStringAsFixed(1)}%)',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuizHistory(ProgressDashboardData progressData) {
    final filteredAttempts = _getFilteredAttempts(progressData.recentAttempts);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quiz History',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        if (filteredAttempts.isEmpty)
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
                      'No quiz history for selected period',
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
          ...filteredAttempts.map((attempt) => _buildQuizHistoryItem(attempt)),
      ],
    );
  }

  Widget _buildQuizHistoryItem(QuizAttempt attempt) {
    final isPassed = attempt.scorePercentage >= 60.0;
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
        title: Text('Quiz ${attempt.quizId}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Completed on ${_formatDate(completedAt)}',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            if (attempt.duration != null)
              Text(
                'Duration: ${_formatDuration(attempt.duration!)}',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
            if (attempt.isFlagged)
              Text(
                'Flagged for security violations',
                style: TextStyle(
                  color: Colors.orange.shade700,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${attempt.scorePercentage.toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isPassed ? Colors.green : Colors.red,
              ),
            ),
            Text(
              '${attempt.score.toInt()}/${attempt.totalQuestions}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
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

  Widget _buildEmptyChart(String message) {
    return Card(
      elevation: 2,
      child: Container(
        height: 200,
        padding: const EdgeInsets.all(24.0),
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
      ),
    );
  }

  /// Get filtered data based on selected filter
  ProgressDashboardData _getFilteredData(ProgressDashboardData originalData) {
    final filteredAttempts = _getFilteredAttempts(originalData.recentAttempts);
    
    if (filteredAttempts.isEmpty) {
      return ProgressDashboardData(
        student: originalData.student,
        recentAttempts: [],
        earnedBadges: originalData.earnedBadges,
        totalQuizzes: 0,
        averageScore: 0.0,
        currentLevel: originalData.currentLevel,
        passCount: 0,
        failCount: 0,
        improvementTrend: 0.0,
      );
    }

    final passCount = filteredAttempts.where((a) => a.scorePercentage >= 60.0).length;
    final failCount = filteredAttempts.length - passCount;
    final averageScore = filteredAttempts.isEmpty
        ? 0.0
        : filteredAttempts.map((a) => a.scorePercentage).reduce((a, b) => a + b) / filteredAttempts.length;

    // Calculate improvement trend for filtered data
    double improvementTrend = 0.0;
    if (filteredAttempts.length >= 2) {
      final halfPoint = filteredAttempts.length ~/ 2;
      final firstHalf = filteredAttempts.sublist(halfPoint);
      final secondHalf = filteredAttempts.sublist(0, halfPoint);

      if (firstHalf.isNotEmpty && secondHalf.isNotEmpty) {
        final firstHalfAvg = firstHalf.map((a) => a.scorePercentage).reduce((a, b) => a + b) / firstHalf.length;
        final secondHalfAvg = secondHalf.map((a) => a.scorePercentage).reduce((a, b) => a + b) / secondHalf.length;

        if (firstHalfAvg > 0) {
          improvementTrend = ((secondHalfAvg - firstHalfAvg) / firstHalfAvg) * 100;
        }
      }
    }

    return ProgressDashboardData(
      student: originalData.student,
      recentAttempts: filteredAttempts,
      earnedBadges: originalData.earnedBadges,
      totalQuizzes: filteredAttempts.length,
      averageScore: averageScore,
      currentLevel: originalData.currentLevel,
      passCount: passCount,
      failCount: failCount,
      improvementTrend: improvementTrend,
    );
  }

  /// Get filtered attempts based on selected filter
  List<QuizAttempt> _getFilteredAttempts(List<QuizAttempt> attempts) {
    final completedAttempts = attempts.where((a) => a.isCompleted).toList();
    
    switch (_selectedFilter) {
      case ProgressFilter.last10:
        return completedAttempts.take(10).toList();
      case ProgressFilter.last30Days:
        final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
        return completedAttempts
            .where((a) => a.completedAt!.isAfter(thirtyDaysAgo))
            .toList();
      case ProgressFilter.allTime:
        return completedAttempts;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes}m ${seconds}s';
  }
}