import 'package:flutter/material.dart';

enum AppThemeChoice {
  lightBlue,
  darkGreen,
  custom;

  String get label => switch (this) {
        AppThemeChoice.lightBlue => 'Light (white & blue)',
        AppThemeChoice.darkGreen => 'Dark (black & green)',
        AppThemeChoice.custom => 'Custom',
      };

  static AppThemeChoice fromValue(String value) => AppThemeChoice.values
      .firstWhere((e) => e.name == value, orElse: () => AppThemeChoice.darkGreen);
}

class AppTheme {
  AppTheme._();

  static ThemeData themeFor(AppThemeChoice choice) => switch (choice) {
        AppThemeChoice.lightBlue => _build(_lightBlueScheme),
        AppThemeChoice.darkGreen => _build(_darkGreenScheme),
        AppThemeChoice.custom => _build(_lightBlueScheme),
      };

  /// Shared entry point for any [ColorScheme] (preset or custom-seeded) so
  /// every theme — built-in or user-chosen — goes through the same styling.
  static ThemeData themeForScheme(ColorScheme scheme) => _build(scheme);

  static final ColorScheme _lightBlueScheme = ColorScheme.fromSeed(
    seedColor: Colors.blue,
    brightness: Brightness.light,
  ).copyWith(
    surface: Colors.white,
    surfaceDim: const Color(0xFFF0F0F0),
    surfaceBright: Colors.white,
    surfaceContainerLowest: Colors.white,
    surfaceContainerLow: const Color(0xFFF6F6F6),
    surfaceContainer: const Color(0xFFF0F0F0),
    surfaceContainerHigh: const Color(0xFFEAEAEA),
    surfaceContainerHighest: const Color(0xFFE2E2E2),
  );

  static final ColorScheme _darkGreenScheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFF2E7D5B),
    brightness: Brightness.dark,
  ).copyWith(
    surface: Colors.black,
    surfaceDim: Colors.black,
    surfaceBright: const Color(0xFF2A2A2A),
    surfaceContainerLowest: Colors.black,
    surfaceContainerLow: const Color(0xFF0D0D0D),
    surfaceContainer: const Color(0xFF141414),
    surfaceContainerHigh: const Color(0xFF1C1C1C),
    surfaceContainerHighest: const Color(0xFF262626),
  );

  /// Overrides on-surface/on-surface-variant with the theme's primary color
  /// (full and dimmed) so every default text/icon color — and every place in
  /// the app that reads `colorScheme.onSurface`/`onSurfaceVariant` directly —
  /// matches the selected theme color, the same way Material's default
  /// button styling already colors the Customize button with `primary`.
  static ThemeData _build(ColorScheme rawScheme) {
    final colorScheme = rawScheme.copyWith(
      onSurface: rawScheme.primary,
      onSurfaceVariant: rawScheme.primary.withValues(alpha: 0.7),
    );

    // Material's default press/hover/focus state layer on tiles and controls
    // is a low-opacity wash of `onSurface`. Since onSurface is now the theme
    // color (for text/icons), pull this overlay from the original neutral
    // onSurface instead, so selecting/pressing a tile darkens it neutrally
    // rather than tinting its background with the theme color.
    final neutralOverlay = WidgetStateProperty.resolveWith<Color?>((states) {
      if (states.contains(WidgetState.pressed)) {
        return rawScheme.onSurface.withValues(alpha: 0.1);
      }
      if (states.contains(WidgetState.hovered)) {
        return rawScheme.onSurface.withValues(alpha: 0.08);
      }
      if (states.contains(WidgetState.focused)) {
        return rawScheme.onSurface.withValues(alpha: 0.1);
      }
      return null;
    });

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 22,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: colorScheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        margin: EdgeInsets.zero,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surfaceContainerHigh,
        labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        side: BorderSide.none,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHigh,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surfaceContainerLow,
        elevation: 0,
        indicatorColor: colorScheme.primaryContainer,
        labelTextStyle: WidgetStateProperty.all(
          TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      checkboxTheme: CheckboxThemeData(overlayColor: neutralOverlay),
      radioTheme: RadioThemeData(overlayColor: neutralOverlay),
      visualDensity: VisualDensity.standard,
    );

    return base.copyWith(
      textTheme: base.textTheme.apply(
          bodyColor: colorScheme.onSurface, displayColor: colorScheme.onSurface),
      iconTheme: base.iconTheme.copyWith(color: colorScheme.onSurface),
      primaryIconTheme: base.primaryIconTheme.copyWith(color: colorScheme.onSurface),
      listTileTheme: base.listTileTheme.copyWith(
        iconColor: colorScheme.onSurfaceVariant,
        textColor: colorScheme.onSurface,
      ),
    );
  }
}
