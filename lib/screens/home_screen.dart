import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'profile_screen.dart';
import 'main_navigation.dart';
import '../services/music_service.dart';
import '../services/user_profile_service.dart';
import '../widgets/playlist_selection_dialog.dart';
import '../widgets/new_music_tab.dart';
import '../providers/theme_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 0;
  final MusicService _musicService = MusicService();
  final UserProfileService _userProfileService = UserProfileService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    await _initializeMusicService();
    await _userProfileService.initialize();
  }

  Future<void> _initializeMusicService() async {
    try {
      print('🔄 Initializing MusicService in HomeScreen...');
      await _musicService.initialize();
      print('✅ MusicService initialized successfully in HomeScreen');
    } catch (e) {
      print('❌ Failed to initialize MusicService in HomeScreen: $e');
      // Don't rethrow - let the app continue without music functionality
    }
  }

  ImageProvider _getProfileImageProvider(String imageUrl) {
    if (imageUrl.startsWith('data:image/')) {
      // Base64 image for web
      return MemoryImage(base64Decode(imageUrl.split(',')[1]));
    } else if (imageUrl.startsWith('http')) {
      // Network image
      return NetworkImage(imageUrl);
    } else {
      // Local file
      return FileImage(File(imageUrl));
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

    @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      backgroundColor: colorScheme.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App Bar with Profile
            SliverAppBar(
              backgroundColor: colorScheme.background,
              expandedHeight: 80,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: ValueListenableBuilder<UserProfile?>(
                  valueListenable: _userProfileService.profileNotifier,
                  builder: (context, profile, child) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          // Profile Picture - Now Clickable
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ProfileScreen(),
                                ),
                              );
                            },
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                  image: _getProfileImageProvider(profile?.profileImageUrl ?? ''),
                                  fit: BoxFit.cover,
                                ),
                                border: Border.all(color: colorScheme.outline, width: 1),
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: colorScheme.onSurface.withValues(alpha: 0.1),
                                ),
                                child: Icon(
                                  Icons.person,
                                  color: colorScheme.onSurfaceVariant,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Profile Info - Also Clickable
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const ProfileScreen(),
                                  ),
                                );
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Good Evening',
                                    style: TextStyle(
                                      color: colorScheme.onSurfaceVariant,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  Text(
                                    profile?.name ?? 'John Doe',
                                    style: TextStyle(
                                      color: colorScheme.onSurface,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.settings, color: colorScheme.onSurface),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ProfileScreen(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            
            // Toggle Tabs
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverAppBarDelegate(
                TabBar(
                  controller: _tabController,
                  indicatorColor: colorScheme.primary,
                  indicatorWeight: 3,
                  labelColor: colorScheme.onSurface,
                  unselectedLabelColor: colorScheme.onSurfaceVariant,
                  labelStyle: const TextStyle(fontWeight: FontWeight.w600),
                  tabs: const [
                    Tab(text: 'All'),
                    Tab(text: 'Music'),
                    Tab(text: 'New Music'),
                  ],
                ),
              ),
            ),
            
            // Tab Content
            SliverToBoxAdapter(
              child: SizedBox(
                height: MediaQuery.of(context).size.height - 200, // Adjusted height to account for bottom navigation
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Home Tab (All)
                    SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Featured Section
                            _buildFeaturedSection(),
                            const SizedBox(height: 32),
                            // Your Music Section
                            _buildYourMusicSection(),
                          ],
                        ),
                      ),
                    ),
                    // Music Tab (existing content, can be customized)
                    SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // You can add more music-related content here
                            _buildFeaturedSection(),
                          ],
                        ),
                      ),
                    ),
                    // New Music Tab (Uploaded Songs)
                    NewMusicTab(musicService: _musicService),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserMusicPlayButton() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return StreamBuilder<Song?>(
      stream: _musicService.currentSongStream,
      builder: (context, snapshot) {
        final currentSong = snapshot.data;
        final isCurrentSong = currentSong?.id == 'waiaan_12am'; // WAIIAN song is now the featured track
        
        return StreamBuilder<bool>(
          stream: _musicService.isPlayingStream,
          builder: (context, playingSnapshot) {
            final isPlaying = playingSnapshot.data ?? false;
            
            return GestureDetector(
              onTap: () {
                if (isCurrentSong) {
                  _musicService.togglePlayPause();
                } else {
                  final song = _musicService.getSongById('waiaan_12am');
                  if (song != null) {
                    _musicService.playSong(song);
                  }
                }
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [colorScheme.primary, colorScheme.primary.withValues(alpha: 0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    // Album Art
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=150&v=waiaan',
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color: colorScheme.surface,
                              child: Center(
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                                  ),
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: colorScheme.surface,
                              child: Icon(
                                Icons.music_note,
                                color: colorScheme.onSurfaceVariant,
                                size: 30,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    
                    // Song Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '12 AM',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'WAIIAN',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Like Button
                    StreamBuilder<List<Song>>(
                      stream: _musicService.likedSongsStream,
                      builder: (context, likedSnapshot) {
                        final likedSongs = likedSnapshot.data ?? [];
                        final isLiked = likedSongs.any((likedSong) => likedSong.id == 'waiaan_12am');
                        
                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () {
                              _musicService.toggleLikeSong('waiaan_12am');
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              child: Icon(
                                isLiked ? Icons.favorite : Icons.favorite_border,
                                color: colorScheme.onSurface,
                                size: 24,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    
                    // Add to Playlist Button
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () {
                          final song = _musicService.getSongById('waiaan_12am');
                          if (song != null) {
                            showDialog(
                              context: context,
                              builder: (context) => PlaylistSelectionDialog(song: song),
                            );
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                                                  child: Icon(
                          Icons.add,
                          color: colorScheme.onSurface,
                          size: 24,
                        ),
                        ),
                      ),
                    ),
                    
                    // Play/Pause Button
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () {
                          if (isCurrentSong) {
                            _musicService.togglePlayPause();
                          } else {
                            final song = _musicService.getSongById('waiaan_12am');
                            if (song != null) {
                              _musicService.playSong(song);
                            }
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                                                  child: Icon(
                          (isCurrentSong && isPlaying) ? Icons.pause : Icons.play_arrow,
                          color: colorScheme.onSurface,
                          size: 32,
                        ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFeaturedSection() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final topSongs = _musicService.getTopSongs();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Top 10 Global',
          style: theme.textTheme.titleLarge?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: topSongs.length,
          itemBuilder: (context, index) {
            final song = topSongs[index];
            return _buildSongTile(
              song: song,
              rank: index + 1,
            );
          },
        ),
      ],
    );
  }

  Widget _buildYourMusicSection() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return StreamBuilder<List<Song>>(
      stream: _musicService.uploadedSongsStream,
      builder: (context, snapshot) {
        final uploadedSongs = snapshot.data ?? [];
        
        if (uploadedSongs.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Music',
            style: theme.textTheme.titleLarge?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Icon(
                    Icons.music_note,
                    color: colorScheme.primary,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'No uploaded music yet',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Upload your music in the Create tab to see it here',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    // Navigate to Create tab (index 3)
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      '/',
                      (route) => false,
                    );
                    // Set the tab to Create (index 3)
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (context.mounted) {
                        final mainNavigation = context.findAncestorStateOfType<MainNavigationState>();
                        mainNavigation?.setSelectedIndex(3);
                      }
                    });
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Upload Music'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Your Music',
              style: theme.textTheme.titleLarge?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Text(
              '${uploadedSongs.length} song${uploadedSongs.length == 1 ? '' : 's'}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: uploadedSongs.length,
          itemBuilder: (context, index) {
            final song = uploadedSongs[index];
            return _buildUploadedSongTile(song);
          },
        ),
      ],
    );
        },
      );
  }

  Widget _buildUploadedSongTile(Song song) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return StreamBuilder<Song?>(
      stream: _musicService.currentSongStream,
      builder: (context, snapshot) {
        final currentSong = snapshot.data;
        final isCurrentSong = currentSong?.id == song.id;
        
        return StreamBuilder<bool>(
          stream: _musicService.isPlayingStream,
          builder: (context, playingSnapshot) {
            final isPlaying = playingSnapshot.data ?? false;
            
            return GestureDetector(
              onTap: () {
                if (isCurrentSong) {
                  _musicService.togglePlayPause();
                } else {
                  _musicService.playSong(song);
                }
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isCurrentSong ? colorScheme.primary.withOpacity(0.1) : colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: isCurrentSong ? Border.all(color: colorScheme.primary, width: 1) : null,
                ),
                child: Row(
                  children: [
                    // Upload Icon
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Icon(
                        Icons.cloud_upload,
                        color: colorScheme.onPrimary,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 12),
                    
                    // Album Art
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.network(
                          song.albumArt,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color: colorScheme.surface,
                              child: Center(
                                child: SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                                  ),
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: colorScheme.surface,
                              child: Icon(
                                Icons.music_note,
                                color: colorScheme.onSurface.withOpacity(0.54),
                                size: 20,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    
                    // Song Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            song.title,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.w500,
                            ) ?? TextStyle(color: colorScheme.onSurface, fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            song.artist,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurface.withOpacity(0.7),
                            ) ?? TextStyle(color: colorScheme.onSurface.withOpacity(0.7), fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    
                    // Like Button
                    StreamBuilder<List<Song>>(
                      stream: _musicService.likedSongsStream,
                      builder: (context, likedSnapshot) {
                        final likedSongs = likedSnapshot.data ?? [];
                        final isLiked = likedSongs.any((likedSong) => likedSong.id == song.id);
                        
                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () {
                              _musicService.toggleLikeSong(song.id);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              child: Icon(
                                isLiked ? Icons.favorite : Icons.favorite_border,
                                color: isLiked ? colorScheme.primary : colorScheme.onSurface.withOpacity(0.7),
                                size: 24,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    
                    // Add to Playlist Button
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => PlaylistSelectionDialog(song: song),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          child: Icon(
                            Icons.add,
                            color: colorScheme.onSurface.withOpacity(0.7),
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                    
                    // Play/Pause Button
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () {
                          if (isCurrentSong) {
                            _musicService.togglePlayPause();
                          } else {
                            _musicService.playSong(song);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          child: Icon(
                            (isCurrentSong && isPlaying) ? Icons.pause : Icons.play_arrow,
                            color: colorScheme.onSurface,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSongTile({
    required Song song,
    required int rank,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return StreamBuilder<Song?>(
      stream: _musicService.currentSongStream,
      builder: (context, snapshot) {
        final currentSong = snapshot.data;
        final isCurrentSong = currentSong?.id == song.id;
        
        return StreamBuilder<bool>(
          stream: _musicService.isPlayingStream,
          builder: (context, playingSnapshot) {
            final isPlaying = playingSnapshot.data ?? false;
            
            return GestureDetector(
              onTap: () {
                if (isCurrentSong) {
                  _musicService.togglePlayPause();
                } else {
                  _musicService.playSong(song);
                }
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isCurrentSong ? colorScheme.primary.withOpacity(0.1) : colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: isCurrentSong ? Border.all(color: colorScheme.primary, width: 1) : null,
                ),
                child: Row(
                  children: [
                    // Rank
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: rank <= 3 ? colorScheme.primary : Colors.transparent,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Center(
                        child: Text(
                          '$rank',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: rank <= 3 ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    
                    // Album Art
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.network(
                          song.albumArt,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color: colorScheme.surface,
                              child: Center(
                                child: SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                                  ),
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: colorScheme.surface,
                              child: Icon(
                                Icons.music_note,
                                color: colorScheme.onSurface.withOpacity(0.54),
                                size: 20,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    
                    // Song Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            song.title,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.w500,
                            ) ?? TextStyle(color: colorScheme.onSurface, fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            song.artist,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurface.withOpacity(0.7),
                            ) ?? TextStyle(color: colorScheme.onSurface.withOpacity(0.7), fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    
                    // Like Button
                    StreamBuilder<List<Song>>(
                      stream: _musicService.likedSongsStream,
                      builder: (context, likedSnapshot) {
                        final likedSongs = likedSnapshot.data ?? [];
                        final isLiked = likedSongs.any((likedSong) => likedSong.id == song.id);
                        
                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () {
                              _musicService.toggleLikeSong(song.id);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              child: Icon(
                                isLiked ? Icons.favorite : Icons.favorite_border,
                                color: isLiked ? colorScheme.primary : colorScheme.onSurface.withOpacity(0.7),
                                size: 24,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    
                    // Add to Playlist Button
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => PlaylistSelectionDialog(song: song),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          child: Icon(
                            Icons.add,
                            color: colorScheme.onSurface.withOpacity(0.7),
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                    
                    // Play Button
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () {
                          if (isCurrentSong) {
                            _musicService.togglePlayPause();
                          } else {
                            _musicService.playSong(song);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          child: Icon(
                            (isCurrentSong && isPlaying) ? Icons.pause : Icons.play_arrow,
                            color: isCurrentSong ? colorScheme.primary : colorScheme.onSurface,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      color: colorScheme.surface,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
} 