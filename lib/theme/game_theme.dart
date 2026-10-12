import 'package:flutter/material.dart';

abstract final class GameColors {
  // Original arena styling inspired by the selected Clash Royale concept.
  static const ink = Color(0xFF1C315D);
  static const panel = Color(0xFF2F4D82);
  static const raised = Color(0xFF4265A1);
  static const line = Color(0xFF7899CB);
  static const cream = Color(0xFFFFF9E7);
  static const muted = Color(0xFFD6E3F4);
  static const mint = Color(0xFFF7D16A);
  static const coral = Color(0xFFEA8175);
  static const gold = Color(0xFFFFD976);
  static const button = Color(0xFFF0BA4B);
  static const road = Color(0xFF142542);
  static const curbRed = Color(0xFFE98375);
  static const rod = Color(0xFFB7C9E2);
  static const northPole = Color(0xFFE47B70);
  static const southPole = Color(0xFF76A9DF);
  static const fieldArrow = Color(0xFFFFDE7E);
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
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: GameColors.line, width: 2),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: GameColors.button,
        foregroundColor: GameColors.ink,
        minimumSize: const Size(0, 54),
        elevation: 5,
        shadowColor: const Color(0xFF8E5C28),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: GameColors.gold, width: 2),
        ),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: GameColors.cream,
        side: const BorderSide(color: GameColors.line, width: 2),
        minimumSize: const Size(0, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: GameColors.raised,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: GameColors.line),
      ),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 48,
        height: 0.95,
        fontWeight: FontWeight.w900,
        letterSpacing: -1.4,
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
