import 'package:flutter/material.dart';
class AppTheme {
  static const green = Color(0xFF075B49);
  static const deep = Color(0xFF092F3D);
  static const gold = Color(0xFFE3C56F);
  static const cream = Color(0xFFFFF9E9);
  static ThemeData dark() => ThemeData(
    brightness: Brightness.dark, useMaterial3: true,
    scaffoldBackgroundColor: deep,
    colorScheme: ColorScheme.fromSeed(seedColor: green, brightness: Brightness.dark, primary: gold, secondary: green),
    appBarTheme: const AppBarTheme(backgroundColor: green, foregroundColor: Colors.white, centerTitle: true),
    cardTheme: CardThemeData(color: Colors.white.withValues(alpha: .10), elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22), side: BorderSide(color: Colors.white.withValues(alpha: .18)))),
    inputDecorationTheme: InputDecorationTheme(
      filled: true, fillColor: Colors.white.withValues(alpha: .08),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      labelStyle: const TextStyle(color: Colors.white70),
    ),
  );
}
