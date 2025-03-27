
import 'package:flutter/material.dart';

ThemeData appTheme() {
  return ThemeData(
    fontFamily: 'Inter',
    scaffoldBackgroundColor: const Color(0xFF1E1E1E),
    appBarTheme: AppBarTheme(
      color: const Color(0xFF27272A),
      iconTheme: const IconThemeData(color: Colors.white),
      centerTitle: true,
    ),
    colorScheme: const ColorScheme(
      brightness: Brightness.dark,
      secondary: Colors.white10,
      secondaryContainer: Color(0xFF250000),
      surface: Color(0xFF18181B),
      onSurface: Color(0xFFFFFFFF),
      primary: Color(0xFFFFFFFF),
      onPrimary: Colors.white10,
      primaryContainer: Color(0xFF250000),
      onSecondary: Color(0xFF250000),
      tertiary: Color(0xFFFFFFFF),
      tertiaryContainer: Color(0xFF27272A),
      error: Color(0xFFBA1A1A),
      onError: Color(0xFFFFFFFF),
    ),
  );
}