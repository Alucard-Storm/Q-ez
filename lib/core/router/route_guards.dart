import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user.dart';
import '../../presentation/providers/auth_providers.dart';

/// Route guard to check if user is authenticated
class AuthGuard {
  final WidgetRef ref;

  AuthGuard(this.ref);

  /// Check if user is authenticated
  bool isAuthenticated() {
    final authState = ref.read(authStateProvider);
    return authState.value != null;
  }

  /// Get current user
  User? getCurrentUser() {
    final authState = ref.read(authStateProvider);
    return authState.value;
  }
}

/// Route guard to check if user has required role
class RoleGuard {
  final WidgetRef ref;

  RoleGuard(this.ref);

  /// Check if user has the required role
  bool hasRole(UserRole requiredRole) {
    final authState = ref.read(authStateProvider);
    final user = authState.value;
    
    if (user == null) return false;
    
    return user.role == requiredRole;
  }

  /// Check if user has any of the required roles
  bool hasAnyRole(List<UserRole> requiredRoles) {
    final authState = ref.read(authStateProvider);
    final user = authState.value;
    
    if (user == null) return false;
    
    return requiredRoles.contains(user.role);
  }

  /// Get user role
  UserRole? getUserRole() {
    final authState = ref.read(authStateProvider);
    final user = authState.value;
    
    return user?.role;
  }
}

/// Route guard for student-only routes
class StudentGuard {
  final WidgetRef ref;

  StudentGuard(this.ref);

  /// Check if current user is a student
  bool isStudent() {
    final authState = ref.read(authStateProvider);
    final user = authState.value;
    
    return user?.role == UserRole.student;
  }
}

/// Route guard for teacher-only routes
class TeacherGuard {
  final WidgetRef ref;

  TeacherGuard(this.ref);

  /// Check if current user is a teacher
  bool isTeacher() {
    final authState = ref.read(authStateProvider);
    final user = authState.value;
    
    return user?.role == UserRole.teacher;
  }
}

/// Route guard for admin-only routes
class AdminGuard {
  final WidgetRef ref;

  AdminGuard(this.ref);

  /// Check if current user is an admin
  bool isAdmin() {
    final authState = ref.read(authStateProvider);
    final user = authState.value;
    
    return user?.role == UserRole.admin;
  }
}

/// Combined guard for teacher and admin routes
class TeacherOrAdminGuard {
  final WidgetRef ref;

  TeacherOrAdminGuard(this.ref);

  /// Check if current user is a teacher or admin
  bool isTeacherOrAdmin() {
    final authState = ref.read(authStateProvider);
    final user = authState.value;
    
    return user?.role == UserRole.teacher || user?.role == UserRole.admin;
  }
}
