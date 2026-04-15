import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/cached_image.dart';
import '../../../core/widgets/skeleton_loader.dart';
import '../../../domain/entities/badge.dart' as domain_badge;
import '../../providers/auth_providers.dart';
import '../../providers/student_providers.dart';

/// Badges screen for students
/// 
/// Displays:
/// - Grid of all available badges
/// - Earned badges in color, locked badges in grayscale
/// - Badge details dialog with description and unlock criteria
/// - Progress towards next badge
/// 
/// Requirements: 13.5, 13.6, 13.7
class BadgesScreen extends ConsumerStatefulWidget {
  const BadgesScreen({super.key});

  @override
  ConsumerState<BadgesScreen> createState() => _BadgesScreenState();
}

class _BadgesScreenState extends ConsumerState<BadgesScreen> {
  @override
  Widget build(BuildContext context) {
    final currentUserAsync = ref.watch(currentUserProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Achievement Badges'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 0,
      ),
      body: currentUserAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorWidget(error),
        data: (currentUser) {
          if (currentUser == null) {
            return const Center(child: Text('Please log in to view badges'));
          }

          return _buildBadgesContent(currentUser.id);
        },
      ),
    );
  }

  Widget _buildBadgesLoadingSkeleton() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SkeletonLoader(height: 140, borderRadius: 16),
          const SizedBox(height: 24),
          const SkeletonLoader(width: 100, height: 20),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.8,
            ),
            itemCount: 9,
            itemBuilder: (_, __) => const SkeletonLoader(borderRadius: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeIcon(domain_badge.Badge badge, bool isEarned, {double size = 48}) {
    final iconAsset = badge.iconAsset;
    final isUrl = iconAsset.startsWith('http://') || iconAsset.startsWith('https://');

    if (isUrl) {
      return CachedImage(
        imageUrl: iconAsset,
        width: size,
        height: size,
        borderRadius: size / 2,
        errorWidget: _buildFallbackBadgeIcon(badge, isEarned, size),
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isEarned
            ? Theme.of(context).colorScheme.primary
            : Colors.grey.shade400,
        shape: BoxShape.circle,
      ),
      child: Icon(
        _getBadgeIcon(badge.type),
        color: Colors.white,
        size: size * 0.5,
      ),
    );
  }

  Widget _buildFallbackBadgeIcon(domain_badge.Badge badge, bool isEarned, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isEarned
            ? Theme.of(context).colorScheme.primary
            : Colors.grey.shade400,
        shape: BoxShape.circle,
      ),
      child: Icon(
        _getBadgeIcon(badge.type),
        color: Colors.white,
        size: size * 0.5,
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
            'Error loading badges',
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
            onPressed: () {
              ref.invalidate(badgesProvider);
              ref.invalidate(studentBadgesProvider);
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgesContent(String studentId) {
    final allBadgesAsync = ref.watch(badgesProvider);
    final studentBadgesAsync = ref.watch(studentBadgesProvider(studentId));
    final progressAsync = ref.watch(progressDashboardProvider(studentId));

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(badgesProvider);
        ref.invalidate(studentBadgesProvider(studentId));
        ref.invalidate(progressDashboardProvider(studentId));
      },
      child: allBadgesAsync.when(
        loading: () => _buildBadgesLoadingSkeleton(),
        error: (error, stack) => _buildErrorWidget(error),
        data: (allBadges) {
          return studentBadgesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => _buildErrorWidget(error),
            data: (earnedBadges) {
              return progressAsync.when(
                loading: () => _buildBadgesGrid(allBadges, earnedBadges, null),
                error: (error, stack) => _buildBadgesGrid(allBadges, earnedBadges, null),
                data: (progressData) => _buildBadgesGrid(allBadges, earnedBadges, progressData),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildBadgesGrid(
    List<domain_badge.Badge> allBadges,
    List<domain_badge.Badge> earnedBadges,
    dynamic progressData,
  ) {
    if (allBadges.isEmpty) {
      return _buildEmptyState();
    }

    final earnedBadgeIds = earnedBadges.map((b) => b.id).toSet();

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with progress summary
          _buildProgressSummary(earnedBadges.length, allBadges.length),
          
          const SizedBox(height: 24),
          
          // Badges grid
          _buildBadgesSectionHeader('All Badges'),
          const SizedBox(height: 16),
          
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.8,
            ),
            itemCount: allBadges.length,
            itemBuilder: (context, index) {
              final badge = allBadges[index];
              final isEarned = earnedBadgeIds.contains(badge.id);
              
              return _buildBadgeCard(
                badge,
                isEarned,
                progressData,
                () => _showBadgeDetails(badge, isEarned, progressData),
              );
            },
          ),
          
          const SizedBox(height: 24),
          
          // Next badge progress
          if (progressData != null)
            _buildNextBadgeProgress(allBadges, earnedBadgeIds, progressData),
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
            Icons.emoji_events_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No badges available yet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Complete quizzes to start earning badges!',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSummary(int earnedCount, int totalCount) {
    final percentage = totalCount > 0 ? (earnedCount / totalCount) : 0.0;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
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
      ),
      child: Column(
        children: [
          Icon(
            Icons.emoji_events,
            size: 40,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
          const SizedBox(height: 12),
          Text(
            'Badge Collection',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$earnedCount of $totalCount badges earned',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 16),
          
          // Progress bar
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: percentage,
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onPrimary,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${(percentage * 100).toStringAsFixed(1)}% Complete',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.9),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgesSectionHeader(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildBadgeCard(
    domain_badge.Badge badge,
    bool isEarned,
    dynamic progressData,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isEarned 
              ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3)
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isEarned 
                ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)
                : Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Badge icon
              _buildBadgeIcon(badge, isEarned),
              
              const SizedBox(height: 8),
              
              // Badge name
              Text(
                badge.name,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isEarned ? null : Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 4),
              
              // Progress indicator for unearned badges
              if (!isEarned && progressData != null)
                _buildBadgeProgress(badge, progressData),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadgeProgress(domain_badge.Badge badge, dynamic progressData) {
    final progress = _calculateBadgeProgress(badge, progressData);
    
    if (progress <= 0) {
      return Text(
        'Not started',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Colors.grey.shade500,
          fontSize: 10,
        ),
      );
    }
    
    return Column(
      children: [
        Container(
          height: 4,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(2),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '${(progress * 100).toInt()}%',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey.shade600,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildNextBadgeProgress(
    List<domain_badge.Badge> allBadges,
    Set<String> earnedBadgeIds,
    dynamic progressData,
  ) {
    // Find the next badge to earn (closest to completion)
    domain_badge.Badge? nextBadge;
    double bestProgress = 0.0;
    
    for (final badge in allBadges) {
      if (!earnedBadgeIds.contains(badge.id)) {
        final progress = _calculateBadgeProgress(badge, progressData);
        if (progress > bestProgress) {
          bestProgress = progress;
          nextBadge = badge;
        }
      }
    }
    
    if (nextBadge == null) {
      return const SizedBox.shrink();
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildBadgesSectionHeader('Next Badge'),
        const SizedBox(height: 16),
        
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: [
              // Badge icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getBadgeIcon(nextBadge.type),
                  color: Colors.white,
                  size: 20,
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Badge info and progress
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nextBadge.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      nextBadge.unlockCriteria,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // Progress bar
                    Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: bestProgress.clamp(0.0, 1.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${(bestProgress * 100).toInt()}% complete',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  double _calculateBadgeProgress(domain_badge.Badge badge, dynamic progressData) {
    if (progressData == null) return 0.0;
    
    switch (badge.type) {
      case domain_badge.BadgeType.quizzesCompleted:
        final completed = progressData.totalQuizzes as int;
        return (completed / badge.requirement).clamp(0.0, 1.0);
        
      case domain_badge.BadgeType.levelReached:
        final currentLevel = progressData.currentLevel as int;
        return (currentLevel / badge.requirement).clamp(0.0, 1.0);
        
      case domain_badge.BadgeType.perfectScore:
        // This would need perfect score count from progressData
        // For now, return 0 as we don't have this data readily available
        return 0.0;
    }
  }

  IconData _getBadgeIcon(domain_badge.BadgeType type) {
    switch (type) {
      case domain_badge.BadgeType.quizzesCompleted:
        return Icons.quiz;
      case domain_badge.BadgeType.perfectScore:
        return Icons.star;
      case domain_badge.BadgeType.levelReached:
        return Icons.trending_up;
    }
  }

  void _showBadgeDetails(domain_badge.Badge badge, bool isEarned, dynamic progressData) {
    showDialog(
      context: context,
      builder: (context) => _BadgeDetailsDialog(
        badge: badge,
        isEarned: isEarned,
        progress: isEarned ? 1.0 : _calculateBadgeProgress(badge, progressData),
      ),
    );
  }
}

/// Dialog widget for displaying badge details
class _BadgeDetailsDialog extends StatelessWidget {
  final domain_badge.Badge badge;
  final bool isEarned;
  final double progress;

  const _BadgeDetailsDialog({
    required this.badge,
    required this.isEarned,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Badge icon - uses CachedImage for network URLs
            _buildBadgeIcon(context),
            
            const SizedBox(height: 16),
            
            // Badge name
            Text(
              badge.name,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 8),
            
            // Badge description
            Text(
              badge.description,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 16),
            
            // Unlock criteria
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Unlock Criteria',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    badge.unlockCriteria,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Progress indicator
            if (!isEarned) ...[
              Text(
                'Progress',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: progress.clamp(0.0, 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${(progress * 100).toInt()}% complete',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 16),
            ] else ...[
              // Earned badge indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Theme.of(context).colorScheme.onPrimary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Earned!',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            // Close button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadgeIcon(BuildContext context) {
    final iconAsset = badge.iconAsset;
    final isUrl = iconAsset.startsWith('http://') || iconAsset.startsWith('https://');

    if (isUrl) {
      return CachedImage(
        imageUrl: iconAsset,
        width: 80,
        height: 80,
        borderRadius: 40,
        errorWidget: _buildFallbackIcon(context),
      );
    }

    return _buildFallbackIcon(context);
  }

  Widget _buildFallbackIcon(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: isEarned
            ? Theme.of(context).colorScheme.primary
            : Colors.grey.shade400,
        shape: BoxShape.circle,
      ),
      child: Icon(
        _getBadgeIconData(badge.type),
        color: Colors.white,
        size: 40,
      ),
    );
  }

  IconData _getBadgeIconData(domain_badge.BadgeType type) {
    switch (type) {
      case domain_badge.BadgeType.quizzesCompleted:
        return Icons.quiz;
      case domain_badge.BadgeType.perfectScore:
        return Icons.star;
      case domain_badge.BadgeType.levelReached:
        return Icons.trending_up;
    }
  }
}
