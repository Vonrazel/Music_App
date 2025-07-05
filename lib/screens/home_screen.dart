import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'profile_screen.dart';
import '../services/music_service.dart';
import '../services/user_profile_service.dart';
import '../widgets/playlist_selection_dialog.dart';
import '../widgets/uploaded_songs_section.dart';
import '../widgets/new_music_tab.dart';

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
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App Bar with Profile
            SliverAppBar(
              backgroundColor: const Color(0xFF121212),
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
                                border: Border.all(color: Colors.white24, width: 1),
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.black.withValues(alpha: 0.2),
                                ),
                                child: const Icon(
                                  Icons.person,
                                  color: Colors.white70,
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
                                  const Text(
                                    'Good Evening',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  Text(
                                    profile?.name ?? 'John Doe',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.settings, color: Colors.white),
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
                  indicatorColor: const Color(0xFF1DB954),
                  indicatorWeight: 3,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white70,
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
                height: MediaQuery.of(context).size.height * 1.2, // ensure enough space for tab content
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Home Tab (All)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Featured Section
                          _buildFeaturedSection(),
                        ],
                      ),
                    ),
                    // Music Tab (existing content, can be customized)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // You can add more music-related content here
                          _buildFeaturedSection(),
                        ],
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
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1DB954), Color(0xFF1ed760)],
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
                              color: const Color(0xFF282828),
                              child: const Center(
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1DB954)),
                                  ),
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: const Color(0xFF282828),
                              child: const Icon(
                                Icons.music_note,
                                color: Colors.white54,
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
                          const Text(
                            '12 AM',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'WAIIAN',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
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
                                color: Colors.white,
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
                          child: const Icon(
                            Icons.add,
                            color: Colors.white,
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
                            color: Colors.white,
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
    final topSongs = _musicService.getTopSongs();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Top 10 Global',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
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

  Widget _buildSongTile({
    required Song song,
    required int rank,
  }) {
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
                  color: isCurrentSong ? const Color(0xFF1DB954).withValues(alpha: 0.2) : const Color(0xFF282828),
                  borderRadius: BorderRadius.circular(8),
                  border: isCurrentSong ? Border.all(color: const Color(0xFF1DB954), width: 1) : null,
                ),
                child: Row(
                  children: [
                    // Rank
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: rank <= 3 ? const Color(0xFF1DB954) : Colors.transparent,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Center(
                        child: Text(
                          '$rank',
                          style: TextStyle(
                            color: rank <= 3 ? Colors.white : Colors.white70,
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
                              color: const Color(0xFF282828),
                              child: const Center(
                                child: SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1DB954)),
                                  ),
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: const Color(0xFF282828),
                              child: const Icon(
                                Icons.music_note,
                                color: Colors.white54,
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
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            song.artist,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
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
                                color: isLiked ? const Color(0xFF1DB954) : Colors.white70,
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
                          child: const Icon(
                            Icons.add,
                            color: Colors.white70,
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
                            color: isCurrentSong ? const Color(0xFF1DB954) : Colors.white,
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
    return Container(
      color: const Color(0xFF121212),
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
} 