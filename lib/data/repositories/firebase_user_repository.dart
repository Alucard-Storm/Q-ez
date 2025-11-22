import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/firestore_constants.dart';
import '../../core/errors/exceptions.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';

/// Firebase implementation of UserRepository
/// Handles user profile management and leaderboard operations
class FirebaseUserRepository implements UserRepository {
  final FirebaseFirestore _firestore;

  FirebaseUserRepository({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<Student> getStudent(String id) async {
    try {
      final user = await getUser(id);
      if (user is! Student) {
        throw UserException('User $id is not a student');
      }
      return user;
    } catch (e) {
      if (e is UserException || e is UserNotFoundException) rethrow;
      throw UserException('Failed to get student: ${e.toString()}');
    }
  }

  @override
  Future<Teacher> getTeacher(String id) async {
    try {
      final user = await getUser(id);
      if (user is! Teacher) {
        throw UserException('User $id is not a teacher');
      }
      return user;
    } catch (e) {
      if (e is UserException || e is UserNotFoundException) rethrow;
      throw UserException('Failed to get teacher: ${e.toString()}');
    }
  }

  @override
  Future<Admin> getAdmin(String id) async {
    try {
      final user = await getUser(id);
      if (user is! Admin) {
        throw UserException('User $id is not an admin');
      }
      return user;
    } catch (e) {
      if (e is UserException || e is UserNotFoundException) rethrow;
      throw UserException('Failed to get admin: ${e.toString()}');
    }
  }

  @override
  Future<User> getUser(String id) async {
    try {
      final docSnapshot = await _firestore
          .collection(FirestoreConstants.usersCollection)
          .doc(id)
          .get();

      if (!docSnapshot.exists) {
        throw UserNotFoundException(id);
      }

      return _userFromSnapshot(docSnapshot);
    } catch (e) {
      if (e is UserNotFoundException) rethrow;
      throw UserException('Failed to get user: ${e.toString()}');
    }
  }

  @override
  Future<void> updateStudentLevel(String id, int newLevel) async {
    try {
      final docRef = _firestore.collection(FirestoreConstants.usersCollection).doc(id);

      final docSnapshot = await docRef.get();
      if (!docSnapshot.exists) {
        throw UserNotFoundException(id);
      }

      await docRef.update({
        FirestoreConstants.studentLevel: newLevel,
      });
    } catch (e) {
      if (e is UserNotFoundException) rethrow;
      throw UserException('Failed to update student level: ${e.toString()}');
    }
  }

  @override
  Future<void> updateStudentStats(
    String id,
    int totalQuizzes,
    double averageScore,
  ) async {
    try {
      final docRef = _firestore.collection(FirestoreConstants.usersCollection).doc(id);

      final docSnapshot = await docRef.get();
      if (!docSnapshot.exists) {
        throw UserNotFoundException(id);
      }

      await docRef.update({
        FirestoreConstants.studentTotalQuizzesTaken: totalQuizzes,
        FirestoreConstants.studentAverageScore: averageScore,
      });
    } catch (e) {
      if (e is UserNotFoundException) rethrow;
      throw UserException('Failed to update student stats: ${e.toString()}');
    }
  }

  @override
  Future<void> awardBadge(String studentId, String badgeId) async {
    try {
      final docRef = _firestore.collection(FirestoreConstants.usersCollection).doc(studentId);

      final docSnapshot = await docRef.get();
      if (!docSnapshot.exists) {
        throw UserNotFoundException(studentId);
      }

      await docRef.update({
        FirestoreConstants.studentBadgeIds: FieldValue.arrayUnion([badgeId]),
      });
    } catch (e) {
      if (e is UserNotFoundException) rethrow;
      throw UserException('Failed to award badge: ${e.toString()}');
    }
  }

  @override
  Future<List<Student>> getLeaderboard(int limit) async {
    try {
      // Get all students ordered by level (desc) and average score (desc)
      final querySnapshot = await _firestore
          .collection(FirestoreConstants.usersCollection)
          .where(FirestoreConstants.userRole, isEqualTo: FirestoreConstants.roleStudent)
          .orderBy(FirestoreConstants.studentLevel, descending: true)
          .orderBy(FirestoreConstants.studentAverageScore, descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs.map((doc) {
        final user = _userFromSnapshot(doc);
        return user as Student;
      }).toList();
    } catch (e) {
      throw UserException('Failed to get leaderboard: ${e.toString()}');
    }
  }

  @override
  Future<List<Student>> getTopStudentsForQuiz(String quizId, int limit) async {
    try {
      // Get all attempts for this quiz, ordered by score (desc) and completion time (asc)
      final attemptsSnapshot = await _firestore
          .collection(FirestoreConstants.quizAttemptsCollection)
          .where(FirestoreConstants.attemptQuizId, isEqualTo: quizId)
          .where(FirestoreConstants.attemptCompletedAt, isNull: false)
          .orderBy(FirestoreConstants.attemptScore, descending: true)
          .orderBy(FirestoreConstants.attemptCompletedAt, descending: false)
          .limit(limit)
          .get();

      // Get unique student IDs (in case a student has multiple attempts)
      final seenStudentIds = <String>{};
      final topStudentIds = <String>[];

      for (final doc in attemptsSnapshot.docs) {
        final studentId = doc.data()[FirestoreConstants.attemptStudentId] as String;
        if (!seenStudentIds.contains(studentId)) {
          seenStudentIds.add(studentId);
          topStudentIds.add(studentId);
        }
      }

      // Fetch student profiles
      final students = <Student>[];
      for (final studentId in topStudentIds) {
        try {
          final student = await getStudent(studentId);
          students.add(student);
        } catch (e) {
          // Skip if student not found
          continue;
        }
      }

      return students;
    } catch (e) {
      throw UserException('Failed to get top students for quiz: ${e.toString()}');
    }
  }

  @override
  Future<List<User>> getAllUsers() async {
    try {
      final querySnapshot = await _firestore
          .collection(FirestoreConstants.usersCollection)
          .orderBy(FirestoreConstants.userCreatedAt, descending: true)
          .get();

      return querySnapshot.docs.map(_userFromSnapshot).toList();
    } catch (e) {
      throw UserException('Failed to get all users: ${e.toString()}');
    }
  }

  @override
  Future<List<Student>> getAllStudents() async {
    try {
      final querySnapshot = await _firestore
          .collection(FirestoreConstants.usersCollection)
          .where(FirestoreConstants.userRole, isEqualTo: FirestoreConstants.roleStudent)
          .orderBy(FirestoreConstants.userCreatedAt, descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        final user = _userFromSnapshot(doc);
        return user as Student;
      }).toList();
    } catch (e) {
      throw UserException('Failed to get all students: ${e.toString()}');
    }
  }

  @override
  Future<List<Teacher>> getAllTeachers() async {
    try {
      final querySnapshot = await _firestore
          .collection(FirestoreConstants.usersCollection)
          .where(FirestoreConstants.userRole, isEqualTo: FirestoreConstants.roleTeacher)
          .orderBy(FirestoreConstants.userCreatedAt, descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        final user = _userFromSnapshot(doc);
        return user as Teacher;
      }).toList();
    } catch (e) {
      throw UserException('Failed to get all teachers: ${e.toString()}');
    }
  }

  @override
  Future<void> updateUser(User user) async {
    try {
      final docRef = _firestore.collection(FirestoreConstants.usersCollection).doc(user.id);

      final docSnapshot = await docRef.get();
      if (!docSnapshot.exists) {
        throw UserNotFoundException(user.id);
      }

      final userData = _userToMap(user);
      await docRef.update(userData);
    } catch (e) {
      if (e is UserNotFoundException) rethrow;
      throw UserException('Failed to update user: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteUser(String id) async {
    try {
      final docRef = _firestore.collection(FirestoreConstants.usersCollection).doc(id);

      final docSnapshot = await docRef.get();
      if (!docSnapshot.exists) {
        throw UserNotFoundException(id);
      }

      final userData = docSnapshot.data()!;
      final role = _parseUserRole(userData[FirestoreConstants.userRole]);

      // Use batch to delete user and associated data
      final batch = _firestore.batch();

      // Delete user document
      batch.delete(docRef);

      // If student, delete all quiz attempts
      if (role == UserRole.student) {
        final attemptsSnapshot = await _firestore
            .collection(FirestoreConstants.quizAttemptsCollection)
            .where(FirestoreConstants.attemptStudentId, isEqualTo: id)
            .get();

        for (final doc in attemptsSnapshot.docs) {
          batch.delete(doc.reference);
        }
      }

      // If teacher, delete all created quizzes and their attempts
      if (role == UserRole.teacher) {
        final quizzesSnapshot = await _firestore
            .collection(FirestoreConstants.quizzesCollection)
            .where(FirestoreConstants.quizTeacherId, isEqualTo: id)
            .get();

        for (final quizDoc in quizzesSnapshot.docs) {
          // Delete quiz attempts for this quiz
          final attemptsSnapshot = await _firestore
              .collection(FirestoreConstants.quizAttemptsCollection)
              .where(FirestoreConstants.attemptQuizId, isEqualTo: quizDoc.id)
              .get();

          for (final attemptDoc in attemptsSnapshot.docs) {
            batch.delete(attemptDoc.reference);
          }

          // Delete quiz
          batch.delete(quizDoc.reference);
        }
      }

      await batch.commit();
    } catch (e) {
      if (e is UserNotFoundException) rethrow;
      throw UserException('Failed to delete user: ${e.toString()}');
    }
  }

  @override
  Future<void> createUserProfile(User user) async {
    try {
      final userData = _userToMap(user);
      await _firestore
          .collection(FirestoreConstants.usersCollection)
          .doc(user.id)
          .set(userData);
    } catch (e) {
      throw UserException('Failed to create user profile: ${e.toString()}');
    }
  }

  /// Convert User entity to Firestore map
  Map<String, dynamic> _userToMap(User user) {
    final baseData = {
      FirestoreConstants.userId: user.id,
      FirestoreConstants.userEmail: user.email,
      FirestoreConstants.userName: user.name,
      FirestoreConstants.userRole: _roleToString(user.role),
      FirestoreConstants.userCreatedAt: Timestamp.fromDate(user.createdAt),
      FirestoreConstants.userLastLoginAt: Timestamp.fromDate(user.lastLoginAt),
    };

    if (user is Student) {
      return {
        ...baseData,
        FirestoreConstants.studentLevel: user.level,
        FirestoreConstants.studentBadgeIds: user.badgeIds,
        FirestoreConstants.studentTotalQuizzesTaken: user.totalQuizzesTaken,
        FirestoreConstants.studentAverageScore: user.averageScore,
      };
    } else if (user is Teacher) {
      return {
        ...baseData,
        FirestoreConstants.teacherCreatedQuizIds: user.createdQuizIds,
      };
    } else if (user is Admin) {
      return {
        ...baseData,
        FirestoreConstants.adminAuditLogIds: user.auditLogIds,
      };
    }

    return baseData;
  }

  /// Convert Firestore document to User entity
  User _userFromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    final role = _parseUserRole(data[FirestoreConstants.userRole]);

    final id = snapshot.id;
    final email = data[FirestoreConstants.userEmail] as String;
    final name = data[FirestoreConstants.userName] as String;
    final createdAt = (data[FirestoreConstants.userCreatedAt] as Timestamp).toDate();
    final lastLoginAt = (data[FirestoreConstants.userLastLoginAt] as Timestamp).toDate();

    switch (role) {
      case UserRole.student:
        return Student(
          id: id,
          email: email,
          name: name,
          role: role,
          createdAt: createdAt,
          lastLoginAt: lastLoginAt,
          level: data[FirestoreConstants.studentLevel] as int,
          badgeIds: List<String>.from(data[FirestoreConstants.studentBadgeIds] ?? []),
          totalQuizzesTaken: data[FirestoreConstants.studentTotalQuizzesTaken] as int,
          averageScore: (data[FirestoreConstants.studentAverageScore] as num).toDouble(),
        );

      case UserRole.teacher:
        return Teacher(
          id: id,
          email: email,
          name: name,
          role: role,
          createdAt: createdAt,
          lastLoginAt: lastLoginAt,
          createdQuizIds:
              List<String>.from(data[FirestoreConstants.teacherCreatedQuizIds] ?? []),
        );

      case UserRole.admin:
        return Admin(
          id: id,
          email: email,
          name: name,
          role: role,
          createdAt: createdAt,
          lastLoginAt: lastLoginAt,
          auditLogIds: List<String>.from(data[FirestoreConstants.adminAuditLogIds] ?? []),
        );
    }
  }

  /// Parse UserRole from string
  UserRole _parseUserRole(dynamic roleValue) {
    final roleString = roleValue as String;
    switch (roleString) {
      case FirestoreConstants.roleStudent:
        return UserRole.student;
      case FirestoreConstants.roleTeacher:
        return UserRole.teacher;
      case FirestoreConstants.roleAdmin:
        return UserRole.admin;
      default:
        throw UserException('Invalid user role: $roleString');
    }
  }

  /// Convert UserRole to string
  String _roleToString(UserRole role) {
    switch (role) {
      case UserRole.student:
        return FirestoreConstants.roleStudent;
      case UserRole.teacher:
        return FirestoreConstants.roleTeacher;
      case UserRole.admin:
        return FirestoreConstants.roleAdmin;
    }
  }
}
