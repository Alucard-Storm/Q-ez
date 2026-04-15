import 'package:flutter/material.dart';

/// Animated shimmer skeleton loader for better perceived performance.
/// Use while data is loading to show placeholder content.
class SkeletonLoader extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const SkeletonLoader({
    super.key,
    this.width = double.infinity,
    this.height = 16,
    this.borderRadius = 8,
  });

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey.shade700 : Colors.grey.shade300;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) => Opacity(
        opacity: _animation.value,
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: baseColor,
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
        ),
      ),
    );
  }
}

/// Skeleton for a leaderboard list item
class LeaderboardItemSkeleton extends StatelessWidget {
  const LeaderboardItemSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const SkeletonLoader(width: 40, height: 40, borderRadius: 20),
            const SizedBox(width: 16),
            const SkeletonLoader(width: 48, height: 48, borderRadius: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  SkeletonLoader(height: 16),
                  SizedBox(height: 8),
                  SkeletonLoader(width: 120, height: 12),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: const [
                SkeletonLoader(width: 60, height: 16),
                SizedBox(height: 6),
                SkeletonLoader(width: 50, height: 12),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton for a user/quiz card in admin screens
class CardSkeleton extends StatelessWidget {
  const CardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const SkeletonLoader(width: 40, height: 40, borderRadius: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      SkeletonLoader(height: 16),
                      SizedBox(height: 8),
                      SkeletonLoader(width: 160, height: 12),
                    ],
                  ),
                ),
                const SkeletonLoader(width: 60, height: 24, borderRadius: 12),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: const [
                SkeletonLoader(width: 80, height: 24, borderRadius: 12),
                SizedBox(width: 8),
                SkeletonLoader(width: 80, height: 24, borderRadius: 12),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: const [
                Expanded(child: SkeletonLoader(height: 36, borderRadius: 8)),
                SizedBox(width: 8),
                Expanded(child: SkeletonLoader(height: 36, borderRadius: 8)),
                SizedBox(width: 8),
                SkeletonLoader(width: 40, height: 36, borderRadius: 8),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton list of cards
class CardListSkeleton extends StatelessWidget {
  final int count;

  const CardListSkeleton({super.key, this.count = 5});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: count,
      itemBuilder: (_, __) => const CardSkeleton(),
    );
  }
}

/// Skeleton for leaderboard list
class LeaderboardSkeleton extends StatelessWidget {
  final int count;

  const LeaderboardSkeleton({super.key, this.count = 8});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: count,
      itemBuilder: (_, __) => const LeaderboardItemSkeleton(),
    );
  }
}
