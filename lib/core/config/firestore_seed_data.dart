import 'package:cloud_firestore/cloud_firestore.dart';

/// Seed data for initializing Firestore collections
class FirestoreSeedData {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Initialize badges collection with predefined badges
  static Future<void> seedBadges() async {
    final badgesRef = _firestore.collection('badges');

    // Check if badges already exist
    final snapshot = await badgesRef.limit(1).get();
    if (snapshot.docs.isNotEmpty) {
      print('Badges already seeded, skipping...');
      return;
    }

    final badges = [
      // Quizzes Completed Badges
      {
        'name': 'Quiz Novice',
        'description': 'Complete your first quiz',
        'iconAsset': 'assets/badges/novice.png',
        'type': 'quizzesCompleted',
        'requirement': 1,
      },
      {
        'name': 'Quiz Enthusiast',
        'description': 'Complete 5 quizzes',
        'iconAsset': 'assets/badges/enthusiast.png',
        'type': 'quizzesCompleted',
        'requirement': 5,
      },
      {
        'name': 'Quiz Expert',
        'description': 'Complete 10 quizzes',
        'iconAsset': 'assets/badges/expert.png',
        'type': 'quizzesCompleted',
        'requirement': 10,
      },
      {
        'name': 'Quiz Master',
        'description': 'Complete 25 quizzes',
        'iconAsset': 'assets/badges/master.png',
        'type': 'quizzesCompleted',
        'requirement': 25,
      },
      {
        'name': 'Quiz Legend',
        'description': 'Complete 50 quizzes',
        'iconAsset': 'assets/badges/legend.png',
        'type': 'quizzesCompleted',
        'requirement': 50,
      },

      // Perfect Score Badges
      {
        'name': 'Perfect Score',
        'description': 'Achieve 100% on any quiz',
        'iconAsset': 'assets/badges/perfect.png',
        'type': 'perfectScore',
        'requirement': 1,
      },

      // Level Reached Badges
      {
        'name': 'Rising Star',
        'description': 'Reach level 5',
        'iconAsset': 'assets/badges/level5.png',
        'type': 'levelReached',
        'requirement': 5,
      },
      {
        'name': 'Knowledge Seeker',
        'description': 'Reach level 10',
        'iconAsset': 'assets/badges/level10.png',
        'type': 'levelReached',
        'requirement': 10,
      },
      {
        'name': 'Scholar',
        'description': 'Reach level 25',
        'iconAsset': 'assets/badges/level25.png',
        'type': 'levelReached',
        'requirement': 25,
      },
      {
        'name': 'Grandmaster',
        'description': 'Reach level 50',
        'iconAsset': 'assets/badges/level50.png',
        'type': 'levelReached',
        'requirement': 50,
      },
    ];

    // Batch write badges
    final batch = _firestore.batch();
    for (final badge in badges) {
      final docRef = badgesRef.doc();
      batch.set(docRef, {
        ...badge,
        'id': docRef.id,
      });
    }

    await batch.commit();
    print('Successfully seeded ${badges.length} badges');
  }

  /// Initialize global leaderboard document
  static Future<void> initializeGlobalLeaderboard() async {
    final leaderboardRef = _firestore.collection('leaderboard').doc('global');

    // Check if leaderboard already exists
    final doc = await leaderboardRef.get();
    if (doc.exists) {
      print('Global leaderboard already initialized, skipping...');
      return;
    }

    await leaderboardRef.set({
      'rankings': [],
      'lastUpdated': FieldValue.serverTimestamp(),
    });

    print('Successfully initialized global leaderboard');
  }

  /// Run all seed operations
  static Future<void> seedAll() async {
    try {
      print('Starting Firestore seed operations...');
      await seedBadges();
      await initializeGlobalLeaderboard();
      print('All seed operations completed successfully');
    } catch (e, stackTrace) {
      print('Error seeding Firestore: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }
}
