import 'package:flutter/material.dart';
import 'package:mobile_hexy/app/theme/app_colors.dart';

abstract final class AppTheme {
  static ThemeData get light => _build(
    ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      secondary: AppColors.accent,
      surface: AppColors.surface,
      brightness: Brightness.light,
    ),
  );

  static ThemeData get dark => _build(
    ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: const Color(0xFFB9B6FF),
      secondary: const Color(0xFFF472B6),
      surface: const Color(0xFF171729),
      brightness: Brightness.dark,
    ),
  );

  static ThemeData _build(ColorScheme colors) {
    final dark = colors.brightness == Brightness.dark;
    final background = dark ? const Color(0xFF0F0F1A) : Colors.white;
    final border = dark ? const Color(0xFF343447) : const Color(0xFFE5E7EB);
    return ThemeData(
      useMaterial3: true,
      brightness: colors.brightness,
      colorScheme: colors,
      scaffoldBackgroundColor: background,
      dividerColor: border,
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: colors.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: colors.surface,
        surfaceTintColor: Colors.transparent,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surface,
        hintStyle: TextStyle(color: colors.onSurfaceVariant),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: border),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colors.surface,
        selectedItemColor: dark ? colors.primary : AppColors.primary,
        unselectedItemColor: colors.onSurfaceVariant,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colors.surface,
        indicatorColor: colors.primaryContainer,
      ),
      dialogTheme: DialogThemeData(backgroundColor: colors.surface),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colors.surface,
        modalBackgroundColor: colors.surface,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? colors.onPrimary
              : colors.outline,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? colors.primary
              : colors.surfaceContainerHighest,
        ),
      ),
    );
  }
}
