import '../../entities/user.dart';
import '../../repositories/user_repository.dart';

/// Data class for leaderboard entry with ranking information
class LeaderboardEntry {
  final Student student;
  final int rank;
  final int level;
  final double totalScore;

  LeaderboardEntry({
    required this.student,
    required this.rank,
    required this.level,
    required this.totalScore,
  });
}

/// Use case for getting the global leaderboard with ranking logic
class GetLeaderboardUseCase {
  final UserRepository _userRepository;

  GetLeaderboardUseCase(this._userRepository);

  /// Get the global leaderboard
  /// Students are ranked by:
  /// 1. Level (descending) - higher level ranks higher
  /// 2. Total score (descending) - higher total score ranks higher when levels are equal
  /// Returns a list of [LeaderboardEntry] with rank, student, level, and total score
  /// The limit parameter controls how many entries to return (default: 100)
  Future<List<LeaderboardEntry>> call({int limit = 100}) async {
    // Get leaderboard from repository (already sorted by level and total score)
    final students = await _userRepository.getLeaderboard(limit);

    // Calculate total scores and create leaderboard entries with ranks
    final entries = <LeaderboardEntry>[];
    
    for (int i = 0; i < students.length; i++) {
      final student = students[i];
      
      // Calculate total score (average score * total quizzes taken)
      final totalScore = student.averageScore * student.totalQuizzesTaken;
      
      entries.add(LeaderboardEntry(
        student: student,
        rank: i + 1,
        level: student.level,
        totalScore: totalScore,
      ));
    }

    return entries;
  }
}
