import 'package:flutter/material.dart';

abstract final class GameColors {
  // Lofi Cafe inspired twilight tones, applied to the existing layout.
  static const ink = Color(0xFF262643);
  static const panel = Color(0xFF393450);
  static const raised = Color(0xFF4B4260);
  static const line = Color(0xFF746582);
  static const cream = Color(0xFFF9E6D0);
  static const muted = Color(0xFFC4AFC7);
  static const mint = Color(0xFFB88BB8);
  static const coral = Color(0xFFBC7E7D);
  static const gold = Color(0xFFD4B16F);
  static const button = Color(0xFFB88BB8);
  static const road = Color(0xFF17192E);
  static const curbRed = Color(0xFFAA7476);
  static const rod = Color(0xFF9788A4);
  static const northPole = Color(0xFFBC7E7D);
  static const southPole = Color(0xFF6D8CAD);
  static const fieldArrow = Color(0xFFD4B16F);
}

ThemeData gameTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: GameColors.mint,
    brightness: Brightness.dark,
  ).copyWith(
    primary: GameColors.mint,
    onPrimary: GameColors.ink,
    secondary: GameColors.coral,
    onSecondary: GameColors.ink,
    surface: GameColors.ink,
    onSurface: GameColors.cream,
    outline: GameColors.line,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: GameColors.ink,
    appBarTheme: const AppBarTheme(
      backgroundColor: GameColors.ink,
      foregroundColor: GameColors.cream,
      surfaceTintColor: Colors.transparent,
    ),
    cardTheme: CardThemeData(
      color: GameColors.panel,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
        side: const BorderSide(color: GameColors.line),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: GameColors.button,
        foregroundColor: GameColors.ink,
        minimumSize: const Size(0, 54),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: GameColors.cream,
        side: const BorderSide(color: GameColors.line),
        minimumSize: const Size(0, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: GameColors.raised,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: GameColors.line),
      ),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 54,
        height: 0.95,
        fontWeight: FontWeight.w900,
        letterSpacing: -2,
        color: GameColors.cream,
      ),
      headlineMedium: TextStyle(
        fontSize: 29,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.6,
        color: GameColors.cream,
      ),
      titleLarge: TextStyle(
        fontSize: 19,
        fontWeight: FontWeight.w800,
        color: GameColors.cream,
      ),
      bodyLarge: TextStyle(fontSize: 16, height: 1.45, color: GameColors.muted),
      bodyMedium: TextStyle(fontSize: 14, height: 1.4, color: GameColors.muted),
      labelLarge: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.6,
        color: GameColors.mint,
      ),
    ),
  );
}
