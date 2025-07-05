import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'search_screen.dart';
import 'library_screen.dart';
import 'create_screen.dart';
import 'analytics_screen.dart';
import '../services/music_service.dart';
import '../widgets/mini_player.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  final MusicService _musicService = MusicService();
  
  final List<Widget> _screens = [
    const HomeScreen(),
    const SearchScreen(),
    const LibraryScreen(),
    const CreateScreen(),
    const AnalyticsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _initializeMusicService();
  }

  Future<void> _initializeMusicService() async {
    try {
      print('🔄 Initializing MusicService in MainNavigation...');
      await _musicService.initialize();
      print('✅ MusicService initialized successfully in MainNavigation');
    } catch (e) {
      print('❌ Failed to initialize MusicService in MainNavigation: $e');
      // Don't rethrow - let the app continue without music functionality
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            constraints: const BoxConstraints(maxHeight: 70),
            child: const MiniPlayer(),
          ),
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFF282828),
              border: Border(
                top: BorderSide(color: Colors.white12, width: 0.5),
              ),
            ),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              type: BottomNavigationBarType.fixed,
              backgroundColor: const Color(0xFF282828),
              selectedItemColor: const Color(0xFF1DB954),
              unselectedItemColor: Colors.white70,
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400),
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.search),
                  label: 'Search',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.library_music),
                  label: 'Library',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.add_circle_outline, size: 36),
                  label: 'Create',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.bar_chart),
                  label: 'Analytics',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 