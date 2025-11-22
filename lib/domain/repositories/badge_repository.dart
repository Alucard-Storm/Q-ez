import '../entities/badge.dart';

/// Repository interface for badge operations
abstract class BadgeRepository {
  /// Get all available badges in the system
  /// Returns a list of all badges
  Future<List<Badge>> getAllBadges();

  /// Get a specific badge by ID
  /// Returns the Badge if found
  /// Throws [BadgeNotFoundException] if badge doesn't exist
  Future<Badge> getBadgeById(String id);

  /// Get all badges earned by a student
  /// Returns a list of badges the student has earned
  Future<List<Badge>> getStudentBadges(String studentId);

  /// Check if a student has earned a specific badge
  /// Returns true if the student has the badge, false otherwise
  Future<bool> hasStudentEarnedBadge(String studentId, String badgeId);

  /// Check and award badges to a student based on their current progress
  /// Evaluates all badge criteria and awards any newly earned badges
  /// Returns a list of newly awarded badge IDs
  Future<List<String>> checkAndAwardBadges(String studentId);

  /// Get badges that a student is eligible for but hasn't earned yet
  /// Returns a list of badges the student can still earn
  Future<List<Badge>> getAvailableBadges(String studentId);

  /// Initialize default badges in the system
  /// Creates the standard set of achievement badges
  /// Should be called during app initialization if badges don't exist
  Future<void> initializeDefaultBadges();
}
