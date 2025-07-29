import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'home_screen.dart';
import 'search_screen.dart';
import 'library_screen.dart';
import 'create_screen.dart';
import 'analytics_screen.dart';
import '../services/music_service.dart';
import '../services/user_profile_service.dart';
import '../widgets/mini_player.dart';
import '../providers/theme_provider.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => MainNavigationState();
}

class MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  final MusicService _musicService = MusicService();
  final UserProfileService _userProfileService = UserProfileService();
  
  void setSelectedIndex(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
  
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
    _initializeProfileService();
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

  Future<void> _initializeProfileService() async {
    try {
      print('🔄 Initializing UserProfileService in MainNavigation...');
      await _userProfileService.initialize();
      await _userProfileService.refreshProfileForNewUser();
      print('✅ UserProfileService initialized successfully in MainNavigation');
    } catch (e) {
      print('❌ Failed to initialize UserProfileService in MainNavigation: $e');
      // Don't rethrow - let the app continue without profile functionality
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      backgroundColor: colorScheme.background,
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              constraints: const BoxConstraints(maxHeight: 70),
              child: const MiniPlayer(),
            ),
            Container(
              decoration: BoxDecoration(
                color: colorScheme.surface,
                border: Border(
                  top: BorderSide(color: colorScheme.outline, width: 0.5),
                ),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.shadow.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: BottomNavigationBar(
                currentIndex: _currentIndex,
                onTap: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                type: BottomNavigationBarType.fixed,
                backgroundColor: colorScheme.surface,
                selectedItemColor: colorScheme.primary,
                unselectedItemColor: colorScheme.onSurfaceVariant,
                selectedLabelStyle: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w400,
                ),
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
      ),
    );
  }
} 