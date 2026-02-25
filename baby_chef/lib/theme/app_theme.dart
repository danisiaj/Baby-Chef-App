import 'package:flutter/material.dart';

class AppTheme {
  // LIGHT THEME
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    useMaterial3: true,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      actionsIconTheme: IconThemeData(size: 30),
      backgroundColor: Color.fromRGBO(96, 141, 209, 1),
      scrolledUnderElevation: 4,
      elevation: 4,
      iconTheme: IconThemeData(color: Colors.white, size: 25),
    ),
    colorScheme: const ColorScheme.light(
      primary: Color.fromRGBO(96, 141, 209, 1),
      onPrimary: Colors.white,
      surface: Colors.white,
      onSurface: Color.fromARGB(221, 30, 29, 29),
      secondary: Color.fromRGBO(96, 141, 209, 1),
      tertiary: Color.fromRGBO(96, 141, 209, 1),
    ),
    cardTheme: CardThemeData(
      color: const Color.fromARGB(255, 238, 236, 236),
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: Colors.black87.withValues(alpha: 0.35)),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Color.fromRGBO(96, 141, 209, 1),
        foregroundColor: Colors.white,
        elevation: 3,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: BorderSide(
          color: const Color.fromARGB(255, 216, 215, 215),
          width: 0.5,
        ),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color.fromRGBO(96, 141, 209, 1),
      foregroundColor: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color.fromRGBO(96, 141, 209, 1),
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white70,
      type: BottomNavigationBarType.fixed,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Color.fromARGB(221, 30, 29, 29)),
      bodyMedium: TextStyle(color: Color.fromARGB(221, 30, 29, 29)),
      titleLarge: TextStyle(color: Color.fromARGB(221, 30, 29, 29)),
    ),
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: Color.fromRGBO(96, 141, 209, 1),
      selectionColor: Color(0xFFB0C4DE),
      selectionHandleColor: Color.fromRGBO(96, 141, 209, 1),
    ),
  );

  // DARK THEME
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    scaffoldBackgroundColor: const Color(0xFF121212),
    appBarTheme: const AppBarTheme(
      actionsIconTheme: IconThemeData(size: 30),
      backgroundColor: Color(0xFF1A1A1A),
      foregroundColor: Colors.white,
      scrolledUnderElevation: 4,
      iconTheme: IconThemeData(color: Colors.white, size: 25),
    ),
    colorScheme: const ColorScheme.dark(
      primary: Color.fromARGB(221, 30, 29, 29),
      onPrimary: Colors.white,
      surface: Color(0xFF1A1A1A),
      onSurface: Colors.white,
      secondary: Colors.white,
      tertiary: Color.fromRGBO(96, 141, 209, 1),
    ),
    cardTheme: CardThemeData(
      color: Color(0xFF1A1A1A),
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.35)),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Color.fromRGBO(96, 141, 209, 1),
        foregroundColor: Colors.white,
        elevation: 3,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: BorderSide(
          color: Colors.white10, // subtle border color
          width: 2.2, // ⬅️ slightly thicker border
        ),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color.fromRGBO(96, 141, 209, 1),
      foregroundColor: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: Color.fromRGBO(96, 141, 209, 1),
      unselectedItemColor: Color.fromARGB(221, 30, 29, 29),
      type: BottomNavigationBarType.fixed,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white),
      titleLarge: TextStyle(color: Colors.white),
    ),
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: Color.fromRGBO(96, 141, 209, 1),
      selectionColor: Color.fromARGB(221, 30, 29, 29),
      selectionHandleColor: Color.fromRGBO(96, 141, 209, 1),
    ),
  );
}
