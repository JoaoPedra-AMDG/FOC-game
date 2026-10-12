import 'package:flutter/material.dart';

abstract final class GameColors {
  // Warm board and tile tones from the original 2048 visual language.
  static const ink = Color(0xFFFAF8EF);
  static const panel = Color(0xFFEEE4DA);
  static const raised = Color(0xFFDDD0C2);
  static const line = Color(0xFFBBADA0);
  static const cream = Color(0xFF776E65);
  static const muted = Color(0xFF8F7A66);
  static const mint = Color(0xFFAD5732);
  static const coral = Color(0xFFC94F38);
  static const gold = Color(0xFF936B0A);
  static const button = Color(0xFF8F7A66);
  static const road = Color(0xFF42403E);
  static const curbRed = Color(0xFFD65045);
  static const rod = Color.fromARGB(255, 205, 206, 206);
}

ThemeData gameTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: GameColors.mint,
    brightness: Brightness.light,
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
