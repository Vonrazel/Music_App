import 'package:flutter/material.dart';
import '../services/hive_service.dart';

class ThemeProvider with ChangeNotifier {
  static final ThemeProvider _instance = ThemeProvider._internal();
  factory ThemeProvider() => _instance;
  ThemeProvider._internal();

  final HiveService _hiveService = HiveService();
  ThemeMode _themeMode = ThemeMode.dark;

  // Getters
  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  // Initialize theme provider
  Future<void> initialize() async {
    try {
      await _hiveService.initialize();
      
      // Load saved theme preference
      final savedTheme = _hiveService.box.get('themeMode', defaultValue: 'dark');
      _themeMode = _getThemeModeFromString(savedTheme);
      
      print('✅ ThemeProvider initialized with theme: $savedTheme');
    } catch (e) {
      print('❌ Error initializing ThemeProvider: $e');
      _themeMode = ThemeMode.dark;
    }
  }

  // Toggle between dark and light mode
  Future<void> toggleTheme() async {
    try {
      _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
      
      // Save theme preference
      final themeString = _getStringFromThemeMode(_themeMode);
      await _hiveService.box.put('themeMode', themeString);
      
      notifyListeners();
      print('✅ Theme changed to: $themeString');
    } catch (e) {
      print('❌ Error toggling theme: $e');
    }
  }

  // Set specific theme mode
  Future<void> setThemeMode(ThemeMode themeMode) async {
    try {
      _themeMode = themeMode;
      
      // Save theme preference
      final themeString = _getStringFromThemeMode(_themeMode);
      await _hiveService.box.put('themeMode', themeString);
      
      notifyListeners();
      print('✅ Theme set to: $themeString');
    } catch (e) {
      print('❌ Error setting theme: $e');
    }
  }

  // Helper methods
  ThemeMode _getThemeModeFromString(String themeString) {
    switch (themeString.toLowerCase()) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  String _getStringFromThemeMode(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
      default:
        return 'system';
    }
  }

  // Get theme data based on current mode
  ThemeData getLightTheme() {
    return ThemeData.light().copyWith(
      useMaterial3: true,
      primaryColor: const Color(0xFF1DB954),
      scaffoldBackgroundColor: const Color(0xFFF8F9FA),
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF1DB954),
        secondary: Color(0xFF1ed760),
        surface: Color(0xFFFFFFFF),
        background: Color(0xFFF8F9FA),
        surfaceVariant: Color(0xFFF1F3F4),
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Color(0xFF202124),
        onBackground: Color(0xFF202124),
        onSurfaceVariant: Color(0xFF5F6368),
        outline: Color(0xFFDADCE0),
        outlineVariant: Color(0xFFE8EAED),
        shadow: Color(0xFF000000),
        scrim: Color(0xFF000000),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFF8F9FA),
        foregroundColor: Color(0xFF202124),
        elevation: 0,
        shadowColor: Color(0xFFDADCE0),
        titleTextStyle: TextStyle(
          color: Color(0xFF202124),
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFFFFFFFF),
        selectedItemColor: Color(0xFF1DB954),
        unselectedItemColor: Color(0xFF5F6368),
        elevation: 8,
        type: BottomNavigationBarType.fixed,
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFFFFFFFF),
        elevation: 1,
        shadowColor: const Color(0xFF000000),
        surfaceTintColor: const Color(0xFFFFFFFF),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1DB954),
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: const Color(0xFF1DB954).withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Color(0xFF202124), fontSize: 16),
        bodyMedium: TextStyle(color: Color(0xFF202124), fontSize: 14),
        titleLarge: TextStyle(color: Color(0xFF202124), fontSize: 22, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(color: Color(0xFF202124), fontSize: 18, fontWeight: FontWeight.w600),
        titleSmall: TextStyle(color: Color(0xFF202124), fontSize: 16, fontWeight: FontWeight.w500),
        labelLarge: TextStyle(color: Color(0xFF202124), fontSize: 14, fontWeight: FontWeight.w500),
        labelMedium: TextStyle(color: Color(0xFF5F6368), fontSize: 12),
        labelSmall: TextStyle(color: Color(0xFF5F6368), fontSize: 10),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF1F3F4),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFDADCE0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFDADCE0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1DB954), width: 2),
        ),
        hintStyle: const TextStyle(color: Color(0xFF5F6368)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFFE8EAED),
        thickness: 1,
      ),
      iconTheme: const IconThemeData(
        color: Color(0xFF5F6368),
        size: 24,
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        titleTextStyle: TextStyle(
          color: Color(0xFF202124),
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        subtitleTextStyle: TextStyle(
          color: Color(0xFF5F6368),
          fontSize: 14,
        ),
      ),
    );
  }

  ThemeData getDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: const Color(0xFF1DB954),
      scaffoldBackgroundColor: const Color(0xFF121212),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF1DB954),
        secondary: Color(0xFF1ed760),
        surface: Color(0xFF282828),
        background: Color(0xFF121212),
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.white,
        onBackground: Colors.white,
        onSurfaceVariant: Colors.white70,
        outline: Colors.white24,
        outlineVariant: Colors.white12,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF121212),
        foregroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF282828),
        selectedItemColor: Color(0xFF1DB954),
        unselectedItemColor: Colors.white70,
      ),
      cardTheme: const CardThemeData(
        color: Color(0xFF282828),
        surfaceTintColor: Color(0xFF282828),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1DB954),
          foregroundColor: Colors.white,
        ),
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Colors.white),
        bodyMedium: TextStyle(color: Colors.white),
        titleLarge: TextStyle(color: Colors.white),
        titleMedium: TextStyle(color: Colors.white),
        labelLarge: TextStyle(color: Colors.white),
        labelMedium: TextStyle(color: Colors.white70),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF282828),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white24),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white24),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1DB954), width: 2),
        ),
        hintStyle: const TextStyle(color: Colors.white70),
      ),
      dividerTheme: const DividerThemeData(
        color: Colors.white12,
      ),
      iconTheme: const IconThemeData(
        color: Colors.white70,
      ),
    );
  }
} 