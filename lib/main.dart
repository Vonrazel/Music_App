import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:html' as html;
import 'screens/main_navigation.dart';
import 'services/hive_service.dart';

void main() async {
  print('🚀 Starting Music App...');
  WidgetsFlutterBinding.ensureInitialized();
  print('✅ WidgetsFlutterBinding initialized');
  
  // Global error handler for Flutter errors
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    print('Flutter Error: ${details.exception}');
    print('Stack trace: ${details.stack}');
  };
  
  try {
    print('🔄 Initializing HiveService...');
    // Initialize HiveService (runs Hive.initFlutter and opens box)
    final hiveService = HiveService();
    await hiveService.initialize();
    print('✅ HiveService initialized successfully');
    
    print('🎵 Starting MusicApp...');
    runApp(const MusicApp());
    print('✅ MusicApp started successfully');
  } catch (e, stack) {
    print("❌ App failed to start: $e");
    print("Stack trace: $stack");
    // Run app with error fallback
    print('🔄 Starting ErrorApp as fallback...');
    runApp(const ErrorApp());
  }
}

// Fallback app for when initialization fails
class ErrorApp extends StatelessWidget {
  const ErrorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Music App - Error',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF1DB954),
        scaffoldBackgroundColor: const Color(0xFF121212),
      ),
      home: Scaffold(
        backgroundColor: const Color(0xFF121212),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Color(0xFF1DB954),
                  size: 64,
                ),
                const SizedBox(height: 24),
                const Text(
                  'App Failed to Start',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'There was an error initializing the app. Please check the console for details and try refreshing the page.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    // Reload the page
                    if (kIsWeb) {
                      // For web, reload the page
                      html.window.location.reload();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1DB954),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  ),
                  child: const Text('Reload App'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MusicApp extends StatelessWidget {
  const MusicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Music App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF1DB954),
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF121212),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF282828),
          selectedItemColor: Color(0xFF1DB954),
          unselectedItemColor: Colors.white70,
        ),
        cardTheme: const CardThemeData(
          color: Color(0xFF282828),
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
        ),
      ),
      home: Builder(
        builder: (context) {
          try {
            return const MainNavigation();
          } catch (e) {
            print('Failed to load MainNavigation: $e');
            return Scaffold(
              backgroundColor: const Color(0xFF121212),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Color(0xFF1DB954),
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Failed to load UI',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Error: $e',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
