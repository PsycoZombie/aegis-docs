import 'package:flutter/material.dart';

// ai generated themes

final ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,

  colorScheme: const ColorScheme.light(
    primary: Color(0xFF0065FF),
    onPrimary: Color(0xFFFFFFFF),
    secondary: Color(0xFF00A8E8),
    onSecondary: Color(0xFF000000),
    surface: Color(0xFFFFFFFF),
    onSurface: Color(0xFF1B1B1B),
    error: Color(0xFFB00020),
    onError: Color(0xFFFFFFFF),
  ),

  scaffoldBackgroundColor: const Color(0xFFF7F7F7),
  cardColor: const Color(0xFFFFFFFF),
  dividerColor: const Color(0xFFDDDDDD),
  hintColor: const Color(0xFF757575),

  fontFamily: 'Inter',
  textTheme: const TextTheme(
    displayLarge: TextStyle(
      color: Color(0xFF212121),
      fontWeight: FontWeight.bold,
    ),
    displayMedium: TextStyle(
      color: Color(0xFF212121),
      fontWeight: FontWeight.bold,
    ),
    headlineMedium: TextStyle(
      color: Color(0xFF212121),
      fontWeight: FontWeight.w600,
    ),
    titleLarge: TextStyle(
      color: Color.fromRGBO(33, 33, 33, 0.85),
      fontWeight: FontWeight.w500,
    ),
    bodyMedium: TextStyle(color: Color.fromRGBO(33, 33, 33, 0.8), height: 1.5),
    labelLarge: TextStyle(
      color: Color(0xFFFFFFFF),
      fontWeight: FontWeight.bold,
    ),
  ),

  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFFFFFFFF),
    elevation: 1,
    shadowColor: Color(0xFFE0E0E0),
    centerTitle: true,
    iconTheme: IconThemeData(color: Color(0xFF000000)),
    titleTextStyle: TextStyle(
      color: Color(0xFF000000),
      fontSize: 20,
      fontFamily: 'Inter',
      fontWeight: FontWeight.w600,
    ),
  ),

  cardTheme: CardThemeData(
    elevation: 1,
    shadowColor: const Color(0xFFF5F5F5),
    color: const Color(0xFFFFFFFF),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
  ),

  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFFF5F5F5),
    contentPadding: const EdgeInsets.symmetric(
      horizontal: 16.0,
      vertical: 12.0,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: const BorderSide(color: Color(0xFF0065FF), width: 2.0),
    ),
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF0065FF),
      foregroundColor: const Color(0xFFFFFFFF),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      textStyle: const TextStyle(fontWeight: FontWeight.bold),
    ),
  ),

  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: Color(0xFF0065FF),
    foregroundColor: Color(0xFFFFFFFF),
    elevation: 4,
  ),

  visualDensity: VisualDensity.adaptivePlatformDensity,
);

final ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,

  colorScheme: const ColorScheme.dark(
    primary: Color(0xFF3A86FF),
    onPrimary: Color(0xFFFFFFFF),
    secondary: Color(0xFF00A8E8),
    onSecondary: Color(0xFFFFFFFF),
    surface: Color(0xFF1E1E1E),
    onSurface: Color(0xFFF5F5F5),
    error: Color(0xFFD32F2F),
    onError: Color(0xFFFFFFFF),
  ),

  scaffoldBackgroundColor: const Color(0xFF121212),
  cardColor: const Color(0xFF1E1E1E),
  dividerColor: const Color(0xFF424242),
  hintColor: const Color(0xFF9E9E9E),

  fontFamily: 'Inter',
  textTheme: const TextTheme(
    displayLarge: TextStyle(
      color: Color.fromRGBO(255, 255, 255, 0.9),
      fontWeight: FontWeight.bold,
    ),
    displayMedium: TextStyle(
      color: Color.fromRGBO(255, 255, 255, 0.9),
      fontWeight: FontWeight.bold,
    ),
    displaySmall: TextStyle(
      color: Color.fromRGBO(255, 255, 255, 0.9),
      fontWeight: FontWeight.bold,
    ),
    headlineLarge: TextStyle(
      color: Color.fromRGBO(255, 255, 255, 0.9),
      fontWeight: FontWeight.w600,
    ),
    headlineMedium: TextStyle(
      color: Color.fromRGBO(255, 255, 255, 0.9),
      fontWeight: FontWeight.w600,
    ),
    headlineSmall: TextStyle(
      color: Color.fromRGBO(255, 255, 255, 0.9),
      fontWeight: FontWeight.w600,
    ),
    titleLarge: TextStyle(
      color: Color.fromRGBO(255, 255, 255, 0.85),
      fontWeight: FontWeight.w500,
    ),
    titleMedium: TextStyle(color: Color.fromRGBO(255, 255, 255, 0.85)),
    titleSmall: TextStyle(color: Color.fromRGBO(255, 255, 255, 0.85)),
    bodyLarge: TextStyle(
      color: Color.fromRGBO(255, 255, 255, 0.8),
      height: 1.5,
    ),
    bodyMedium: TextStyle(
      color: Color.fromRGBO(255, 255, 255, 0.8),
      height: 1.5,
    ),
    bodySmall: TextStyle(color: Color.fromRGBO(255, 255, 255, 0.7)),
    labelLarge: TextStyle(
      color: Color(0xFFFFFFFF),
      fontWeight: FontWeight.bold,
    ),
    labelMedium: TextStyle(color: Color(0xFFBDBDBD)),
    labelSmall: TextStyle(color: Color(0xFFBDBDBD)),
  ),

  appBarTheme: AppBarTheme(
    backgroundColor: const Color(0xFF181818),
    elevation: 0,
    centerTitle: true,
    iconTheme: const IconThemeData(color: Color(0xFFFFFFFF)),
    titleTextStyle: const TextStyle(
      color: Color.fromRGBO(255, 255, 255, 0.9),
      fontSize: 20,
      fontFamily: 'Inter',
      fontWeight: FontWeight.w600,
    ),
  ),

  cardTheme: CardThemeData(
    elevation: 2,
    color: const Color(0xFF1E1E1E),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
  ),

  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFF2A2A2A),
    contentPadding: const EdgeInsets.symmetric(
      horizontal: 16.0,
      vertical: 12.0,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: const BorderSide(color: Colors.transparent),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: const BorderSide(color: Color(0xFF3A86FF), width: 2.0),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: const BorderSide(color: Color(0xFFD32F2F)),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: const BorderSide(color: Color(0xFFD32F2F), width: 2.0),
    ),
    labelStyle: const TextStyle(color: Color(0xFFBDBDBD)),
    hintStyle: const TextStyle(color: Color(0xFF757575)),
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF3A86FF),
      foregroundColor: const Color(0xFFFFFFFF),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      textStyle: const TextStyle(fontWeight: FontWeight.bold),
    ),
  ),

  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: const Color(0xFF3A86FF),
      side: const BorderSide(color: Color(0xFF3A86FF), width: 1.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      textStyle: const TextStyle(fontWeight: FontWeight.bold),
    ),
  ),

  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: const Color(0xFF3A86FF),
      textStyle: const TextStyle(fontWeight: FontWeight.bold),
    ),
  ),

  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: Color(0xFF3A86FF),
    foregroundColor: Color(0xFFFFFFFF),
    elevation: 4,
  ),

  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: const Color(0xFF1E1E1E),
    selectedItemColor: const Color(0xFF3A86FF),
    unselectedItemColor: const Color(0xFF9E9E9E),
    selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
    unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
    type: BottomNavigationBarType.fixed,
    elevation: 0,
  ),

  visualDensity: VisualDensity.adaptivePlatformDensity,
);
