import 'package:flutter/foundation.dart';
/// Example usage of the HiveCacheRepository
/// 
/// This file demonstrates how to use the cache repository for:
/// - User session caching
/// - Quiz offline caching
/// - Security settings management
/// - Cache invalidation and sync logic

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/quiz.dart';
import '../providers/cache_provider.dart';

/// Example: Cache user session after login
Future<void> exampleCacheUserSession(WidgetRef ref, dynamic user, String token) async {
  final cacheRepo = ref.read(cacheRepositoryProvider);
  
  // Cache the user with authentication token (can be Student, Teacher, or Admin)
  await cacheRepo.cacheUser(user, token: token);
  
  debugPrint('User cached successfully');
}

/// Example: Retrieve cached user on app startup
Future<void> exampleGetCachedUser(WidgetRef ref) async {
  final cacheRepo = ref.read(cacheRepositoryProvider);
  
  // Get cached user
  final cachedUser = await cacheRepo.getCachedUser();
  
  if (cachedUser != null) {
    debugPrint('Found cached user: ${cachedUser.name}');
    
    // Get cached token for auto-login
    final token = await cacheRepo.getCachedToken();
    if (token != null) {
      debugPrint('Token available for auto-login');
    }
  } else {
    debugPrint('No cached user found, show login screen');
  }
}

/// Example: Cache quiz for offline access
Future<void> exampleCacheQuiz(WidgetRef ref, Quiz quiz) async {
  final cacheRepo = ref.read(cacheRepositoryProvider);
  
  // Cache the quiz
  await cacheRepo.cacheQuiz(quiz);
  
  debugPrint('Quiz "${quiz.title}" cached for offline access');
}

/// Example: Get cached quiz when offline
Future<void> exampleGetCachedQuiz(WidgetRef ref, String quizId) async {
  final cacheRepo = ref.read(cacheRepositoryProvider);
  
  // Try to get quiz from cache
  final cachedQuiz = await cacheRepo.getCachedQuiz(quizId);
  
  if (cachedQuiz != null) {
    debugPrint('Quiz loaded from cache: ${cachedQuiz.title}');
  } else {
    debugPrint('Quiz not in cache, need network connection');
  }
}

/// Example: Get all cached quizzes
Future<void> exampleGetAllCachedQuizzes(WidgetRef ref) async {
  final cacheRepo = ref.read(cacheRepositoryProvider);
  
  final cachedQuizzes = await cacheRepo.getAllCachedQuizzes();
  
  debugPrint('Found ${cachedQuizzes.length} cached quizzes');
  for (final quiz in cachedQuizzes) {
    debugPrint('- ${quiz.title}');
  }
}

/// Example: Manage security settings
Future<void> exampleManageSecuritySettings(WidgetRef ref) async {
  final cacheRepo = ref.read(cacheRepositoryProvider);
  
  // Enable biometric authentication
  await cacheRepo.saveBiometricEnabled(true);
  
  // Set max violations before auto-submit
  await cacheRepo.saveMaxViolations(3);
  
  // Enable strict mode
  await cacheRepo.saveStrictMode(true);
  
  // Read settings
  final biometricEnabled = await cacheRepo.isBiometricEnabled();
  final maxViolations = await cacheRepo.getMaxViolations();
  final strictMode = await cacheRepo.isStrictModeEnabled();
  
  debugPrint('Security Settings:');
  debugPrint('- Biometric: $biometricEnabled');
  debugPrint('- Max Violations: $maxViolations');
  debugPrint('- Strict Mode: $strictMode');
}

/// Example: Clear cache on logout
Future<void> exampleLogout(WidgetRef ref) async {
  final cacheRepo = ref.read(cacheRepositoryProvider);
  
  // Clear user session data
  await cacheRepo.clearUserCache();
  
  debugPrint('User logged out, cache cleared');
}

/// Example: Clear all cache
Future<void> exampleClearAllCache(WidgetRef ref) async {
  final cacheRepo = ref.read(cacheRepositoryProvider);
  
  // Clear everything
  await cacheRepo.clearAllCache();
  
  debugPrint('All cache cleared');
}

/// Example: Cache invalidation strategy
Future<void> exampleCacheInvalidation(WidgetRef ref) async {
  final cacheRepo = ref.read(cacheRepositoryProvider);
  
  // Check if cache is valid
  final isValid = await cacheRepo.isCacheValid();
  
  if (!isValid) {
    debugPrint('Cache is invalid, need to sync with server');
    
    // Invalidate and clear cache
    await cacheRepo.invalidateCache();
    
    // Re-fetch data from server
    // ... fetch logic here ...
  } else {
    debugPrint('Cache is valid, using cached data');
  }
}

/// Example: Sync strategy - cache quiz after fetching from server
Future<void> exampleSyncQuiz(WidgetRef ref, String quizId) async {
  final cacheRepo = ref.read(cacheRepositoryProvider);
  
  // Try cache first
  var quiz = await cacheRepo.getCachedQuiz(quizId);
  
  if (quiz == null) {
    debugPrint('Quiz not in cache, fetching from server...');
    
    // Fetch from server (pseudo-code)
    // quiz = await quizRepository.getQuizById(quizId);
    
    // Cache for offline access
    // await cacheRepo.cacheQuiz(quiz);
    
    debugPrint('Quiz fetched and cached');
  } else {
    debugPrint('Quiz loaded from cache');
  }
}

/// Example: Remove specific cached quiz
Future<void> exampleRemoveCachedQuiz(WidgetRef ref, String quizId) async {
  final cacheRepo = ref.read(cacheRepositoryProvider);
  
  // Remove specific quiz from cache
  await cacheRepo.removeCachedQuiz(quizId);
  
  debugPrint('Quiz removed from cache');
}
