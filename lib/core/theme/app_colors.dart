import 'package:flutter/material.dart';

/// Brand color seed used for Material Design 3 color scheme generation.
const Color kBrandSeedColor = Color(0xFF1565C0); // Deep Blue

/// Custom color extensions for brand-specific colors.
///
/// Accessed via `Theme.of(context).extension<AppColors>()`.
///
/// Requirements: 17.7
class AppColors extends ThemeExtension<AppColors> {
  final Color brandPrimary;
  final Color brandSecondary;
  final Color success;
  final Color warning;
  final Color error;
  final Color quizBackground;
  final Color correctAnswer;
  final Color incorrectAnswer;
  final Color timerNormal;
  final Color timerWarning;
  final Color timerCritical;

  const AppColors({
    required this.brandPrimary,
    required this.brandSecondary,
    required this.success,
    required this.warning,
    required this.error,
    required this.quizBackground,
    required this.correctAnswer,
    required this.incorrectAnswer,
    required this.timerNormal,
    required this.timerWarning,
    required this.timerCritical,
  });

  /// Light theme brand colors.
  static const AppColors light = AppColors(
    brandPrimary: Color(0xFF1565C0),
    brandSecondary: Color(0xFF0288D1),
    success: Color(0xFF2E7D32),
    warning: Color(0xFFF57F17),
    error: Color(0xFFC62828),
    quizBackground: Color(0xFFF5F5F5),
    correctAnswer: Color(0xFF2E7D32),
    incorrectAnswer: Color(0xFFC62828),
    timerNormal: Color(0xFF1565C0),
    timerWarning: Color(0xFFF57F17),
    timerCritical: Color(0xFFC62828),
  );

  /// Dark theme brand colors.
  static const AppColors dark = AppColors(
    brandPrimary: Color(0xFF90CAF9),
    brandSecondary: Color(0xFF4FC3F7),
    success: Color(0xFF66BB6A),
    warning: Color(0xFFFFCA28),
    error: Color(0xFFEF5350),
    quizBackground: Color(0xFF1A1A2E),
    correctAnswer: Color(0xFF66BB6A),
    incorrectAnswer: Color(0xFFEF5350),
    timerNormal: Color(0xFF90CAF9),
    timerWarning: Color(0xFFFFCA28),
    timerCritical: Color(0xFFEF5350),
  );

  @override
  AppColors copyWith({
    Color? brandPrimary,
    Color? brandSecondary,
    Color? success,
    Color? warning,
    Color? error,
    Color? quizBackground,
    Color? correctAnswer,
    Color? incorrectAnswer,
    Color? timerNormal,
    Color? timerWarning,
    Color? timerCritical,
  }) {
    return AppColors(
      brandPrimary: brandPrimary ?? this.brandPrimary,
      brandSecondary: brandSecondary ?? this.brandSecondary,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      error: error ?? this.error,
      quizBackground: quizBackground ?? this.quizBackground,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      incorrectAnswer: incorrectAnswer ?? this.incorrectAnswer,
      timerNormal: timerNormal ?? this.timerNormal,
      timerWarning: timerWarning ?? this.timerWarning,
      timerCritical: timerCritical ?? this.timerCritical,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      brandPrimary: Color.lerp(brandPrimary, other.brandPrimary, t)!,
      brandSecondary: Color.lerp(brandSecondary, other.brandSecondary, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      error: Color.lerp(error, other.error, t)!,
      quizBackground: Color.lerp(quizBackground, other.quizBackground, t)!,
      correctAnswer: Color.lerp(correctAnswer, other.correctAnswer, t)!,
      incorrectAnswer: Color.lerp(incorrectAnswer, other.incorrectAnswer, t)!,
      timerNormal: Color.lerp(timerNormal, other.timerNormal, t)!,
      timerWarning: Color.lerp(timerWarning, other.timerWarning, t)!,
      timerCritical: Color.lerp(timerCritical, other.timerCritical, t)!,
    );
  }
}

/// Convenience extension on [BuildContext] for quick access to brand colors.
extension AppColorsContext on BuildContext {
  AppColors get appColors =>
      Theme.of(this).extension<AppColors>() ?? AppColors.light;
}
