import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/music_service.dart';
import '../widgets/playlist_selection_dialog.dart';
import '../providers/theme_provider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final MusicService _musicService = MusicService();
  
  List<Song> _allSongs = [];
  List<Song> _filteredSongs = [];
  bool _isSearching = false;

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Hip-Hop', 'color': Colors.orange, 'icon': Icons.music_note},
    {'name': 'Pop', 'color': Colors.pink, 'icon': Icons.music_note},
    {'name': 'Rock', 'color': Colors.red, 'icon': Icons.music_note},
    {'name': 'Jazz', 'color': Colors.purple, 'icon': Icons.music_note},
    {'name': 'Classical', 'color': Colors.blue, 'icon': Icons.music_note},
    {'name': 'Electronic', 'color': Colors.cyan, 'icon': Icons.music_note},
    {'name': 'Country', 'color': Colors.green, 'icon': Icons.music_note},
    {'name': 'R&B', 'color': Colors.indigo, 'icon': Icons.music_note},
    {'name': 'Reggae', 'color': Colors.yellow, 'icon': Icons.music_note},
    {'name': 'Blues', 'color': Colors.teal, 'icon': Icons.music_note},
  ];

  @override
  void initState() {
    super.initState();
    _loadSongs();
    _searchController.addListener(_onSearchChanged);
  }

  void _loadSongs() {
    _allSongs = _musicService.songs;
    _filteredSongs = _allSongs;
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase().trim();
    
    setState(() {
      _isSearching = query.isNotEmpty;
      
      if (query.isEmpty) {
        _filteredSongs = _allSongs;
      } else {
        _filteredSongs = _allSongs.where((song) {
          final title = song.title.toLowerCase();
          final artist = song.artist.toLowerCase();
          return title.contains(query) || artist.contains(query);
        }).toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      backgroundColor: colorScheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // Search Header
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Search',
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Search Bar
                  Container(
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: TextStyle(color: colorScheme.onSurface),
                      decoration: InputDecoration(
                        hintText: 'What do you want to listen to?',
                        hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                        prefixIcon: Icon(Icons.search, color: colorScheme.onSurfaceVariant),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.clear, color: colorScheme.onSurfaceVariant),
                                onPressed: () {
                                  _searchController.clear();
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Content based on search state
            Expanded(
              child: _isSearching ? _buildSearchResults() : _buildCategories(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    if (_filteredSongs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              color: colorScheme.onSurfaceVariant,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'No results found',
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try searching for a different song or artist',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Found ${_filteredSongs.length} result${_filteredSongs.length == 1 ? '' : 's'}',
            style: theme.textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredSongs.length,
              itemBuilder: (context, index) {
                final song = _filteredSongs[index];
                return _buildSearchResultTile(song);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResultTile(Song song) {
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
                  color: isCurrentSong ? colorScheme.primary.withValues(alpha: 0.1) : colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: isCurrentSong ? Border.all(color: colorScheme.primary, width: 1) : null,
                ),
                child: Row(
                  children: [
                    // Album Art
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        image: DecorationImage(
                          image: NetworkImage(song.albumArt),
                          fit: BoxFit.cover,
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
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            song.artist,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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
                        
                        return IconButton(
                          icon: Icon(
                            isLiked ? Icons.favorite : Icons.favorite_border,
                            color: isLiked ? colorScheme.primary : colorScheme.onSurfaceVariant,
                          ),
                          onPressed: () {
                            _musicService.toggleLikeSong(song.id);
                          },
                        );
                      },
                    ),
                    
                    // Add to Playlist Button
                    IconButton(
                      icon: Icon(
                        Icons.add,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => PlaylistSelectionDialog(song: song),
                        );
                      },
                    ),
                    
                    // Play Button
                    IconButton(
                      icon: Icon(
                        (isCurrentSong && isPlaying) ? Icons.pause : Icons.play_arrow,
                        color: isCurrentSong ? colorScheme.primary : colorScheme.onSurface,
                      ),
                      onPressed: () {
                        if (isCurrentSong) {
                          _musicService.togglePlayPause();
                        } else {
                          _musicService.playSong(song);
                        }
                      },
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

  Widget _buildCategories() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.2,
        ),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          return _buildCategoryCard(_categories[index]);
        },
      ),
    );
  }

  Widget _buildCategoryCard(Map<String, dynamic> category) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return GestureDetector(
      onTap: () {
        // Navigate to category page
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              category['color'],
              category['color'].withOpacity(0.7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Stack(
          children: [
            // Background Pattern
            Positioned(
              right: -20,
              bottom: -20,
              child: Icon(
                category['icon'],
                size: 80,
                color: colorScheme.onPrimary.withValues(alpha: 0.2),
              ),
            ),
            // Category Name
            Positioned(
              left: 16,
              bottom: 16,
              child: Text(
                category['name'],
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 