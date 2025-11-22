import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/firestore_constants.dart';
import '../../core/errors/exceptions.dart';
import '../../domain/entities/badge.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/badge_repository.dart';
import '../../domain/repositories/user_repository.dart';

/// Firebase implementation of BadgeRepository
/// Handles badge retrieval and awarding logic
class FirebaseBadgeRepository implements BadgeRepository {
  final FirebaseFirestore _firestore;
  final UserRepository _userRepository;

  FirebaseBadgeRepository({
    FirebaseFirestore? firestore,
    required UserRepository userRepository,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _userRepository = userRepository;

  @override
  Future<List<Badge>> getAllBadges() async {
    try {
      final querySnapshot = await _firestore
          .collection(FirestoreConstants.badgesCollection)
          .orderBy(FirestoreConstants.badgeRequirement)
          .get();

      return querySnapshot.docs.map(_badgeFromSnapshot).toList();
    } catch (e) {
      throw BadgeException('Failed to get all badges: ${e.toString()}');
    }
  }

  @override
  Future<Badge> getBadgeById(String id) async {
    try {
      final docSnapshot = await _firestore
          .collection(FirestoreConstants.badgesCollection)
          .doc(id)
          .get();

      if (!docSnapshot.exists) {
        throw BadgeNotFoundException(id);
      }

      return _badgeFromSnapshot(docSnapshot);
    } catch (e) {
      if (e is BadgeNotFoundException) rethrow;
      throw BadgeException('Failed to get badge: ${e.toString()}');
    }
  }

  @override
  Future<List<Badge>> getStudentBadges(String studentId) async {
    try {
      final student = await _userRepository.getStudent(studentId);
      final badgeIds = student.badgeIds;

      if (badgeIds.isEmpty) {
        return [];
      }

      // Fetch all badges that the student has earned
      final badges = <Badge>[];
      for (final badgeId in badgeIds) {
        try {
          final badge = await getBadgeById(badgeId);
          badges.add(badge);
        } catch (e) {
          // Skip if badge not found
          continue;
        }
      }

      return badges;
    } catch (e) {
      if (e is UserNotFoundException) rethrow;
      throw BadgeException('Failed to get student badges: ${e.toString()}');
    }
  }

  @override
  Future<bool> hasStudentEarnedBadge(String studentId, String badgeId) async {
    try {
      final student = await _userRepository.getStudent(studentId);
      return student.badgeIds.contains(badgeId);
    } catch (e) {
      if (e is UserNotFoundException) rethrow;
      throw BadgeException('Failed to check badge status: ${e.toString()}');
    }
  }

  @override
  Future<List<String>> checkAndAwardBadges(String studentId) async {
    try {
      // Get student profile
      final student = await _userRepository.getStudent(studentId);

      // Get all available badges
      final allBadges = await getAllBadges();

      // Get student's quiz attempts to calculate perfect scores
      final attemptsSnapshot = await _firestore
          .collection(FirestoreConstants.quizAttemptsCollection)
          .where(FirestoreConstants.attemptStudentId, isEqualTo: studentId)
          .where(FirestoreConstants.attemptCompletedAt, isNull: false)
          .get();

      final completedAttempts = attemptsSnapshot.docs;
      final totalQuizzes = student.totalQuizzesTaken;

      // Count perfect scores (100%)
      int perfectScoreCount = 0;
      for (final doc in completedAttempts) {
        final data = doc.data();
        final score = (data[FirestoreConstants.attemptScore] as num).toDouble();
        final totalQuestions = data[FirestoreConstants.attemptTotalQuestions] as int;

        if (totalQuestions > 0 && score == totalQuestions.toDouble()) {
          perfectScoreCount++;
        }
      }

      // Check each badge and award if criteria met
      final newlyAwardedBadges = <String>[];

      for (final badge in allBadges) {
        // Skip if already earned
        if (student.badgeIds.contains(badge.id)) {
          continue;
        }

        bool shouldAward = false;

        switch (badge.type) {
          case BadgeType.quizzesCompleted:
            shouldAward = totalQuizzes >= badge.requirement;
            break;

          case BadgeType.perfectScore:
            shouldAward = perfectScoreCount >= badge.requirement;
            break;

          case BadgeType.levelReached:
            shouldAward = student.level >= badge.requirement;
            break;
        }

        if (shouldAward) {
          await _userRepository.awardBadge(studentId, badge.id);
          newlyAwardedBadges.add(badge.id);
        }
      }

      return newlyAwardedBadges;
    } catch (e) {
      if (e is UserNotFoundException) rethrow;
      throw BadgeException('Failed to check and award badges: ${e.toString()}');
    }
  }

  @override
  Future<List<Badge>> getAvailableBadges(String studentId) async {
    try {
      final student = await _userRepository.getStudent(studentId);
      final allBadges = await getAllBadges();

      // Filter out badges the student has already earned
      return allBadges.where((badge) => !student.badgeIds.contains(badge.id)).toList();
    } catch (e) {
      if (e is UserNotFoundException) rethrow;
      throw BadgeException('Failed to get available badges: ${e.toString()}');
    }
  }

  @override
  Future<void> initializeDefaultBadges() async {
    try {
      // Check if badges already exist
      final existingBadges = await getAllBadges();
      if (existingBadges.isNotEmpty) {
        return; // Badges already initialized
      }

      // Define default badges
      final defaultBadges = [
        // Quizzes Completed badges
        Badge(
          id: 'quiz_1',
          name: 'First Steps',
          description: 'Complete your first quiz',
          iconAsset: 'assets/badges/first_quiz.png',
          type: BadgeType.quizzesCompleted,
          requirement: 1,
        ),
        Badge(
          id: 'quiz_5',
          name: 'Quiz Enthusiast',
          description: 'Complete 5 quizzes',
          iconAsset: 'assets/badges/quiz_5.png',
          type: BadgeType.quizzesCompleted,
          requirement: 5,
        ),
        Badge(
          id: 'quiz_10',
          name: 'Quiz Master',
          description: 'Complete 10 quizzes',
          iconAsset: 'assets/badges/quiz_10.png',
          type: BadgeType.quizzesCompleted,
          requirement: 10,
        ),
        Badge(
          id: 'quiz_25',
          name: 'Quiz Champion',
          description: 'Complete 25 quizzes',
          iconAsset: 'assets/badges/quiz_25.png',
          type: BadgeType.quizzesCompleted,
          requirement: 25,
        ),
        Badge(
          id: 'quiz_50',
          name: 'Quiz Legend',
          description: 'Complete 50 quizzes',
          iconAsset: 'assets/badges/quiz_50.png',
          type: BadgeType.quizzesCompleted,
          requirement: 50,
        ),

        // Perfect Score badges
        Badge(
          id: 'perfect_1',
          name: 'Perfect Start',
          description: 'Achieve your first perfect score',
          iconAsset: 'assets/badges/perfect_1.png',
          type: BadgeType.perfectScore,
          requirement: 1,
        ),
        Badge(
          id: 'perfect_5',
          name: 'Perfectionist',
          description: 'Achieve 5 perfect scores',
          iconAsset: 'assets/badges/perfect_5.png',
          type: BadgeType.perfectScore,
          requirement: 5,
        ),
        Badge(
          id: 'perfect_10',
          name: 'Flawless',
          description: 'Achieve 10 perfect scores',
          iconAsset: 'assets/badges/perfect_10.png',
          type: BadgeType.perfectScore,
          requirement: 10,
        ),

        // Level Reached badges
        Badge(
          id: 'level_5',
          name: 'Rising Star',
          description: 'Reach level 5',
          iconAsset: 'assets/badges/level_5.png',
          type: BadgeType.levelReached,
          requirement: 5,
        ),
        Badge(
          id: 'level_10',
          name: 'Expert',
          description: 'Reach level 10',
          iconAsset: 'assets/badges/level_10.png',
          type: BadgeType.levelReached,
          requirement: 10,
        ),
        Badge(
          id: 'level_25',
          name: 'Elite',
          description: 'Reach level 25',
          iconAsset: 'assets/badges/level_25.png',
          type: BadgeType.levelReached,
          requirement: 25,
        ),
        Badge(
          id: 'level_50',
          name: 'Grandmaster',
          description: 'Reach level 50',
          iconAsset: 'assets/badges/level_50.png',
          type: BadgeType.levelReached,
          requirement: 50,
        ),
      ];

      // Create badges in Firestore
      final batch = _firestore.batch();

      for (final badge in defaultBadges) {
        final docRef = _firestore
            .collection(FirestoreConstants.badgesCollection)
            .doc(badge.id);

        batch.set(docRef, _badgeToMap(badge));
      }

      await batch.commit();
    } catch (e) {
      throw BadgeException('Failed to initialize default badges: ${e.toString()}');
    }
  }

  /// Convert Badge entity to Firestore map
  Map<String, dynamic> _badgeToMap(Badge badge) {
    return {
      FirestoreConstants.badgeId: badge.id,
      FirestoreConstants.badgeName: badge.name,
      FirestoreConstants.badgeDescription: badge.description,
      FirestoreConstants.badgeIconAsset: badge.iconAsset,
      FirestoreConstants.badgeType: _badgeTypeToString(badge.type),
      FirestoreConstants.badgeRequirement: badge.requirement,
    };
  }

  /// Convert Firestore document to Badge entity
  Badge _badgeFromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;

    return Badge(
      id: snapshot.id,
      name: data[FirestoreConstants.badgeName] as String,
      description: data[FirestoreConstants.badgeDescription] as String,
      iconAsset: data[FirestoreConstants.badgeIconAsset] as String,
      type: _parseBadgeType(data[FirestoreConstants.badgeType] as String),
      requirement: data[FirestoreConstants.badgeRequirement] as int,
    );
  }

  /// Convert BadgeType to string
  String _badgeTypeToString(BadgeType type) {
    switch (type) {
      case BadgeType.quizzesCompleted:
        return FirestoreConstants.badgeTypeQuizzesCompleted;
      case BadgeType.perfectScore:
        return FirestoreConstants.badgeTypePerfectScore;
      case BadgeType.levelReached:
        return FirestoreConstants.badgeTypeLevelReached;
    }
  }

  /// Parse BadgeType from string
  BadgeType _parseBadgeType(String typeString) {
    switch (typeString) {
      case FirestoreConstants.badgeTypeQuizzesCompleted:
        return BadgeType.quizzesCompleted;
      case FirestoreConstants.badgeTypePerfectScore:
        return BadgeType.perfectScore;
      case FirestoreConstants.badgeTypeLevelReached:
        return BadgeType.levelReached;
      default:
        throw BadgeException('Invalid badge type: $typeString');
    }
  }
}
