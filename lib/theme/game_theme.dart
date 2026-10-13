import 'package:flutter/material.dart';

abstract final class GameColors {
  // Dark instrument-panel palette inspired by the investigation display.
  static const ink = Color(0xFF0B0B25);
  static const panel = Color(0xFF1A1D4A);
  static const raised = Color(0xFF25295E);
  static const line = Color(0xFF555DA0);
  static const cream = Color(0xFFF7F5FF);
  static const muted = Color(0xFFC8CCE6);
  static const mint = Color(0xFF69D6BC);
  static const coral = Color(0xFFED80B8);
  static const gold = Color(0xFFF1A7D4);
  static const button = Color(0xFFA16BE5);
  static const road = Color(0xFF10132E);
  static const curbRed = Color(0xFFDA6CB1);
  static const rod = Color(0xFF9199CE);
  static const northPole = Color(0xFFE9789C);
  static const southPole = Color(0xFF6DADE2);
  static const fieldArrow = Color(0xFF79E4CF);
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
        borderRadius: BorderRadius.circular(5),
        side: const BorderSide(color: GameColors.line),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: GameColors.button,
        foregroundColor: GameColors.ink,
        minimumSize: const Size(0, 54),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: GameColors.cream,
        side: const BorderSide(color: GameColors.line),
        minimumSize: const Size(0, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: GameColors.raised,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5),
        borderSide: const BorderSide(color: GameColors.line),
      ),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 48,
        height: 0.95,
        fontWeight: FontWeight.w900,
        letterSpacing: -1.5,
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
