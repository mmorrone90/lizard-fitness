import 'package:flutter/material.dart';

const kYellow = Color(0xFFFFD600);
const kYellowDark = Color(0xFFCCAB00);
const kBlack = Color(0xFF0A0A0A);
const kSurface = Color(0xFF141414);
const kCard = Color(0xFF1E1E1E);
const kCardLight = Color(0xFF2A2A2A);
const kTextPrimary = Color(0xFFFFFFFF);
const kTextSecondary = Color(0xFF9E9E9E);
const kTextMuted = Color(0xFF5E5E5E);
const kSuccess = Color(0xFF4CAF50);
const kError = Color(0xFFE53935);
const kWarning = Color(0xFFFF9800);

final ThemeData appTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  scaffoldBackgroundColor: kBlack,
  primaryColor: kYellow,
  colorScheme: const ColorScheme.dark(
    primary: kYellow,
    onPrimary: kBlack,
    secondary: kYellowDark,
    onSecondary: kBlack,
    surface: kSurface,
    onSurface: kTextPrimary,
    error: kError,
    onError: kTextPrimary,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: kBlack,
    foregroundColor: kTextPrimary,
    elevation: 0,
    centerTitle: false,
    titleTextStyle: TextStyle(
      color: kTextPrimary,
      fontSize: 22,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.5,
    ),
  ),
  cardTheme: const CardThemeData(
    color: kCard,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(16)),
    ),
    margin: EdgeInsets.zero,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: kYellow,
      foregroundColor: kBlack,
      elevation: 0,
      minimumSize: const Size(double.infinity, 56),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.5,
      ),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: kYellow,
      side: const BorderSide(color: kYellow, width: 1.5),
      minimumSize: const Size(double.infinity, 56),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: kYellow,
      textStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: kCard,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: kCardLight, width: 1),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: kYellow, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: kError, width: 1),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: kError, width: 1.5),
    ),
    labelStyle: const TextStyle(color: kTextSecondary),
    hintStyle: const TextStyle(color: kTextMuted),
    prefixIconColor: kTextSecondary,
    suffixIconColor: kTextSecondary,
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: kSurface,
    selectedItemColor: kYellow,
    unselectedItemColor: kTextMuted,
    type: BottomNavigationBarType.fixed,
    elevation: 0,
    selectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
    unselectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
  ),
  dividerTheme: const DividerThemeData(
    color: kCardLight,
    thickness: 1,
  ),
  chipTheme: ChipThemeData(
    backgroundColor: kCard,
    selectedColor: kYellow,
    labelStyle: const TextStyle(color: kTextPrimary, fontSize: 13),
    side: const BorderSide(color: kCardLight),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  ),
  textTheme: const TextTheme(
    displayLarge: TextStyle(color: kTextPrimary, fontWeight: FontWeight.w900, fontSize: 48, letterSpacing: -1),
    displayMedium: TextStyle(color: kTextPrimary, fontWeight: FontWeight.w800, fontSize: 36, letterSpacing: -0.5),
    displaySmall: TextStyle(color: kTextPrimary, fontWeight: FontWeight.w800, fontSize: 28),
    headlineLarge: TextStyle(color: kTextPrimary, fontWeight: FontWeight.w800, fontSize: 24),
    headlineMedium: TextStyle(color: kTextPrimary, fontWeight: FontWeight.w700, fontSize: 20),
    headlineSmall: TextStyle(color: kTextPrimary, fontWeight: FontWeight.w700, fontSize: 18),
    titleLarge: TextStyle(color: kTextPrimary, fontWeight: FontWeight.w700, fontSize: 16),
    titleMedium: TextStyle(color: kTextPrimary, fontWeight: FontWeight.w600, fontSize: 14),
    titleSmall: TextStyle(color: kTextSecondary, fontWeight: FontWeight.w600, fontSize: 12),
    bodyLarge: TextStyle(color: kTextPrimary, fontSize: 16),
    bodyMedium: TextStyle(color: kTextSecondary, fontSize: 14),
    bodySmall: TextStyle(color: kTextMuted, fontSize: 12),
    labelLarge: TextStyle(color: kTextPrimary, fontWeight: FontWeight.w700, fontSize: 14),
  ),
);
