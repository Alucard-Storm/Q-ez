import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../../core/constants/firestore_constants.dart';
import '../../core/errors/exceptions.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/user_repository.dart';

/// Firebase implementation of AuthRepository
/// Handles authentication using Firebase Auth and manages user profiles in Firestore
class FirebaseAuthRepository implements AuthRepository {
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  FirebaseAuthRepository({
    firebase_auth.FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
    UserRepository? userRepository,
  })  : _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<AppUser> signIn(String email, String password, UserRole role) async {
    try {
      // Authenticate with Firebase Auth
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw AuthException('Sign in failed: No user returned');
      }

      // Get user profile from Firestore
      final userDoc = await _firestore
          .collection(FirestoreConstants.usersCollection)
          .doc(credential.user!.uid)
          .get();

      if (!userDoc.exists) {
        throw AuthException('User profile not found');
      }

      final userData = userDoc.data()!;
      final userRole = _parseUserRole(userData[FirestoreConstants.userRole]);

      // Verify role matches
      if (userRole != role) {
        await _firebaseAuth.signOut();
        throw AuthException(
          'Invalid role: Expected ${_roleToString(role)}, got ${_roleToString(userRole)}',
        );
      }

      // Update last login time
      await _firestore
          .collection(FirestoreConstants.usersCollection)
          .doc(credential.user!.uid)
          .update({
        FirestoreConstants.userLastLoginAt: FieldValue.serverTimestamp(),
      });

      // Return appropriate user type based on role
      return _buildUserFromData(credential.user!.uid, userData);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw AuthException(_getAuthErrorMessage(e.code), e.code);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Sign in failed: ${e.toString()}');
    }
  }

  @override
  Future<AppUser> signUp(
    String email,
    String password,
    String name,
    UserRole role,
  ) async {
    try {
      // Create Firebase Auth user
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw AuthException('Sign up failed: No user returned');
      }

      final userId = credential.user!.uid;
      final now = DateTime.now();

      // Create user profile based on role
      AppUser user;
      Map<String, dynamic> userData;

      switch (role) {
        case UserRole.student:
          user = Student(
            id: userId,
            email: email,
            name: name,
            role: role,
            createdAt: now,
            lastLoginAt: now,
            level: 1,
            badgeIds: [],
            totalQuizzesTaken: 0,
            averageScore: 0.0,
          );
          userData = {
            FirestoreConstants.userId: userId,
            FirestoreConstants.userEmail: email,
            FirestoreConstants.userName: name,
            FirestoreConstants.userRole: _roleToString(role),
            FirestoreConstants.userCreatedAt: Timestamp.fromDate(now),
            FirestoreConstants.userLastLoginAt: Timestamp.fromDate(now),
            FirestoreConstants.studentLevel: 1,
            FirestoreConstants.studentBadgeIds: [],
            FirestoreConstants.studentTotalQuizzesTaken: 0,
            FirestoreConstants.studentAverageScore: 0.0,
          };
          break;

        case UserRole.teacher:
          user = Teacher(
            id: userId,
            email: email,
            name: name,
            role: role,
            createdAt: now,
            lastLoginAt: now,
            createdQuizIds: [],
          );
          userData = {
            FirestoreConstants.userId: userId,
            FirestoreConstants.userEmail: email,
            FirestoreConstants.userName: name,
            FirestoreConstants.userRole: _roleToString(role),
            FirestoreConstants.userCreatedAt: Timestamp.fromDate(now),
            FirestoreConstants.userLastLoginAt: Timestamp.fromDate(now),
            FirestoreConstants.teacherCreatedQuizIds: [],
          };
          break;

        case UserRole.admin:
          user = Admin(
            id: userId,
            email: email,
            name: name,
            role: role,
            createdAt: now,
            lastLoginAt: now,
            auditLogIds: [],
          );
          userData = {
            FirestoreConstants.userId: userId,
            FirestoreConstants.userEmail: email,
            FirestoreConstants.userName: name,
            FirestoreConstants.userRole: _roleToString(role),
            FirestoreConstants.userCreatedAt: Timestamp.fromDate(now),
            FirestoreConstants.userLastLoginAt: Timestamp.fromDate(now),
            FirestoreConstants.adminAuditLogIds: [],
          };
          break;
      }

      // Create user profile in Firestore
      await _firestore
          .collection(FirestoreConstants.usersCollection)
          .doc(userId)
          .set(userData);

      return user;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw AuthException(_getAuthErrorMessage(e.code), e.code);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Sign up failed: ${e.toString()}');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw AuthException(_getAuthErrorMessage(e.code), e.code);
    } catch (e) {
      throw AuthException('Sign out failed: ${e.toString()}');
    }
  }

  @override
  Stream<AppUser?> authStateChanges() {
    return _firebaseAuth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;

      try {
        final userDoc = await _firestore
            .collection(FirestoreConstants.usersCollection)
            .doc(firebaseUser.uid)
            .get();

        if (!userDoc.exists) return null;

        final userData = userDoc.data()!;
        return _buildUserFromData(firebaseUser.uid, userData);
      } catch (e) {
        return null;
      }
    });
  }

  @override
  Future<void> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw AuthException(_getAuthErrorMessage(e.code), e.code);
    } catch (e) {
      throw AuthException('Password reset failed: ${e.toString()}');
    }
  }

  @override
  Future<AppUser?> getCurrentUser() async {
    try {
      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser == null) return null;

      final userDoc = await _firestore
          .collection(FirestoreConstants.usersCollection)
          .doc(firebaseUser.uid)
          .get();

      if (!userDoc.exists) return null;

      final userData = userDoc.data()!;
      return _buildUserFromData(firebaseUser.uid, userData);
    } catch (e) {
      return null;
    }
  }

  /// Build AppUser entity from Firestore data
  AppUser _buildUserFromData(String userId, Map<String, dynamic> data) {
    final role = _parseUserRole(data[FirestoreConstants.userRole]);
    final email = data[FirestoreConstants.userEmail] as String;
    final name = data[FirestoreConstants.userName] as String;
    final createdAt = (data[FirestoreConstants.userCreatedAt] as Timestamp).toDate();
    final lastLoginAt = (data[FirestoreConstants.userLastLoginAt] as Timestamp).toDate();

    switch (role) {
      case UserRole.student:
        return Student(
          id: userId,
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
          id: userId,
          email: email,
          name: name,
          role: role,
          createdAt: createdAt,
          lastLoginAt: lastLoginAt,
          createdQuizIds: List<String>.from(data[FirestoreConstants.teacherCreatedQuizIds] ?? []),
        );

      case UserRole.admin:
        return Admin(
          id: userId,
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
        throw AuthException('Invalid user role: $roleString');
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

  /// Get user-friendly error message from Firebase Auth error code
  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No user found with this email address';
      case 'wrong-password':
        return 'Incorrect password';
      case 'email-already-in-use':
        return 'An account already exists with this email';
      case 'invalid-email':
        return 'Invalid email address';
      case 'weak-password':
        return 'Password is too weak';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later';
      case 'operation-not-allowed':
        return 'This operation is not allowed';
      default:
        return 'Authentication failed: $code';
    }
  }
}
