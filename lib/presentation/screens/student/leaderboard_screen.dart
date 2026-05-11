import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/skeleton_loader.dart';
import '../../../domain/usecases/progress/get_leaderboard_use_case.dart';
import '../../providers/auth_providers.dart';
import '../../providers/student_providers.dart';

/// Global leaderboard screen for students
/// 
/// Displays:
/// - Global leaderboard list with rankings
/// - Student names, levels, and total scores
/// - Highlighted current user position
/// - Pull-to-refresh functionality
/// - Pagination for large leaderboards
/// 
/// Requirements: 9.1, 9.2, 9.3, 9.4, 9.5
class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen> {
  static const int _pageSize = 50;
  int _currentPage = 1;
  List<LeaderboardEntry> _allEntries = [];
  bool _isLoadingMore = false;
  bool _hasMoreData = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreData();
    }
  }

  Future<void> _loadMoreData() async {
    if (_isLoadingMore || !_hasMoreData) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final nextPageEntries = await ref.read(
        leaderboardProvider(_pageSize * (_currentPage + 1)).future,
      );

      if (nextPageEntries.length <= _allEntries.length) {
        setState(() {
          _hasMoreData = false;
        });
      } else {
        setState(() {
          _allEntries = nextPageEntries;
          _currentPage++;
        });
      }
    } catch (e) {
      // Handle error silently for pagination
    } finally {
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserAsync = ref.watch(currentUserProvider);
    final leaderboardAsync = ref.watch(leaderboardProvider(_pageSize));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 0,
      ),
      body: currentUserAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorWidget(error),
        data: (currentUser) {
          if (currentUser == null) {
            return const Center(child: Text('Please log in to view leaderboard'));
          }

          return leaderboardAsync.when(
            loading: () => const LeaderboardSkeleton(),
            error: (error, stack) => _buildErrorWidget(error),
            data: (entries) {
              _allEntries = entries;
              return _buildLeaderboard(context, entries, currentUser.id);
            },
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
            'Error loading leaderboard',
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
            onPressed: () => ref.invalidate(leaderboardProvider),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboard(
    BuildContext context,
    List<LeaderboardEntry> entries,
    String currentUserId,
  ) {
    if (entries.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async {
        setState(() {
          _currentPage = 1;
          _hasMoreData = true;
        });
        ref.invalidate(leaderboardProvider);
      },
      child: Column(
        children: [
          // Header with total students
          _buildHeader(entries.length),
          
          // Leaderboard list
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: entries.length + (_hasMoreData ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= entries.length) {
                  return _buildLoadingIndicator();
                }

                final entry = entries[index];
                final isCurrentUser = entry.student.id == currentUserId;
                
                return _buildLeaderboardItem(
                  context,
                  entry,
                  isCurrentUser,
                  index,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.leaderboard_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No students on leaderboard yet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Complete quizzes to appear on the leaderboard!',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(int totalStudents) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
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
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            Icons.emoji_events,
            size: 32,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
          const SizedBox(height: 8),
          Text(
            'Global Leaderboard',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$totalStudents students competing',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardItem(
    BuildContext context,
    LeaderboardEntry entry,
    bool isCurrentUser,
    int index,
  ) {
    final rank = entry.rank;
    final student = entry.student;
    
    // Determine rank icon and color
    Widget rankWidget;
    Color? cardColor;
    
    if (rank == 1) {
      rankWidget = const Icon(Icons.emoji_events, color: Colors.amber, size: 32);
      cardColor = Colors.amber.withValues(alpha: 0.1);
    } else if (rank == 2) {
      rankWidget = const Icon(Icons.emoji_events, color: Colors.grey, size: 28);
      cardColor = Colors.grey.withValues(alpha: 0.1);
    } else if (rank == 3) {
      rankWidget = const Icon(Icons.emoji_events, color: Colors.brown, size: 24);
      cardColor = Colors.brown.withValues(alpha: 0.1);
    } else {
      rankWidget = CircleAvatar(
        radius: 16,
        backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        child: Text(
          rank.toString(),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      );
    }

    // Highlight current user
    if (isCurrentUser) {
      cardColor = Theme.of(context).colorScheme.primary.withValues(alpha: 0.1);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: Card(
        color: cardColor,
        elevation: isCurrentUser ? 4 : 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: isCurrentUser
              ? BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                )
              : BorderSide.none,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Rank
              SizedBox(
                width: 50,
                child: Center(child: rankWidget),
              ),
              
              const SizedBox(width: 16),
              
              // Student avatar
              CircleAvatar(
                radius: 24,
                backgroundColor: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.2),
                child: Text(
                  student.name.isNotEmpty ? student.name[0].toUpperCase() : 'S',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ),
              
              const SizedBox(width: 16),
              
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
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(12),
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
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.trending_up,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Level ${student.level}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          Icons.quiz,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${student.totalQuizzesTaken} quizzes',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Score info
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${entry.totalScore.toStringAsFixed(0)} pts',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${student.averageScore.toStringAsFixed(1)}% avg',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
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

  Widget _buildLoadingIndicator() {
    if (!_isLoadingMore) return const SizedBox.shrink();
    
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}