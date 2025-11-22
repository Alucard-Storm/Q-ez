import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/firebase_auth_repository.dart';
import '../../data/repositories/firebase_user_repository.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/user_repository.dart';

/// Provider for UserRepository dependency injection
/// Used by AuthRepository for user profile operations
final userRepositoryProvider = Provider<UserRepository>((ref) {
  return FirebaseUserRepository(
    firestore: FirebaseFirestore.instance,
  );
});

/// Provider for AuthRepository dependency injection
/// Provides access to authentication operations throughout the app
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return FirebaseAuthRepository(
    firebaseAuth: firebase_auth.FirebaseAuth.instance,
    firestore: FirebaseFirestore.instance,
    userRepository: ref.watch(userRepositoryProvider),
  );
});

/// StreamProvider for reactive authentication state
/// Emits the current user when authenticated, null when not authenticated
/// Automatically updates UI when auth state changes
final authStateProvider = StreamProvider<User?>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return authRepository.authStateChanges();
});

/// Provider for accessing the currently logged-in user data
/// Returns null if no user is authenticated
/// Throws an error if fetching user data fails
final currentUserProvider = FutureProvider<User?>((ref) async {
  final authRepository = ref.watch(authRepositoryProvider);
  return authRepository.getCurrentUser();
});
