import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/music_service.dart';
import '../widgets/playlist_selection_dialog.dart';
import '../providers/theme_provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final MusicService _musicService = MusicService();
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      backgroundColor: colorScheme.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              backgroundColor: colorScheme.background,
              pinned: true,
              title: Text(
                'Your Library',
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.search, color: colorScheme.onSurface),
                  onPressed: () {},
                ),
                IconButton(
                  icon: Icon(Icons.add, color: colorScheme.onSurface),
                  onPressed: () {
                    _showCreatePlaylistDialog();
                  },
                ),
              ],
            ),
            
            // Content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Liked Songs Section
                    _buildLikedSongsSection(),
                    const SizedBox(height: 32),
                    
                    // Recently Played Section
                    _buildRecentlyPlayedSection(),
                    const SizedBox(height: 32),
                    
                    // Playlists Section
                    _buildPlaylistsSection(),
                    const SizedBox(height: 32),
                    
                    // Favorite Artists Section
                    _buildFavoriteArtistsSection(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLikedSongsSection() {
    return StreamBuilder<List<Song>>(
      stream: _musicService.likedSongsStream,
      builder: (context, snapshot) {
        final likedSongs = snapshot.data ?? [];
        final likedSongCount = likedSongs.length;
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1DB954), Color(0xFF1ed760)],
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Icon(
                    Icons.favorite,
                    color: colorScheme.onPrimary,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Liked Songs',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
                Text(
                  '$likedSongCount songs',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (likedSongs.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
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
                        color: colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Icon(
                        Icons.favorite_border,
                        color: colorScheme.primary,
                        size: 30,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No liked songs yet',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Like songs to see them here',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: likedSongs.length,
                itemBuilder: (context, index) {
                  return _buildLikedSongTile(likedSongs[index]);
                },
              ),
          ],
        );
      },
    );
  }

  Widget _buildLikedSongTile(Song song) {
    return StreamBuilder<Song?>(
      stream: _musicService.currentSongStream,
      builder: (context, snapshot) {
        final currentSong = snapshot.data;
        final isCurrentSong = currentSong?.id == song.id;
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
        
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
                  color: isCurrentSong 
                      ? colorScheme.primary.withValues(alpha: 0.1) 
                      : colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: isCurrentSong 
                      ? Border.all(color: colorScheme.primary, width: 1) 
                      : null,
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.shadow.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Row(
                  children: [
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
                              color: colorScheme.surfaceVariant,
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
                              color: colorScheme.surfaceVariant,
                              child: Icon(
                                Icons.music_note,
                                color: colorScheme.onSurfaceVariant,
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
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: colorScheme.onSurface,
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
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () {
                          _musicService.toggleLikeSong(song.id);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          child: Icon(
                            Icons.favorite,
                            color: colorScheme.primary,
                            size: 24,
                          ),
                        ),
                      ),
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
                            color: colorScheme.onSurfaceVariant,
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

  Widget _buildRecentlyPlayedSection() {
    return StreamBuilder<void>(
      stream: _musicService.analyticsStream,
      builder: (context, snapshot) {
        final recentlyPlayed = _musicService.recentlyPlayedSongs;
        
        if (recentlyPlayed.isEmpty) {
          return const SizedBox.shrink();
        }
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recently Played',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: recentlyPlayed.length,
                itemBuilder: (context, index) {
                  return _buildRecentlyPlayedCard(recentlyPlayed[index]);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRecentlyPlayedCard(Song song) {
    return GestureDetector(
      onTap: () {
        _musicService.playSong(song);
      },
      child: Container(
        width: 150,
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Album Art
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: NetworkImage(song.albumArt),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                ),
                child: Center(
                  child: Icon(
                    Icons.play_arrow,
                    color: Theme.of(context).colorScheme.onSurface,
                    size: 40,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            
            // Track Info
            Text(
              song.title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              song.artist,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaylistsSection() {
    return ValueListenableBuilder(
      valueListenable: _musicService.hiveService.playlistsBox.listenable(),
      builder: (context, Box playlistsBox, _) {
        final playlists = _musicService.hiveService.getAllPlaylists();
        if (playlists.isEmpty) {
          return const SizedBox.shrink();
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Playlists',
              style: Theme.of(context).brightness == Brightness.light
                  ? Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    )
                  : Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onBackground,
                      fontWeight: FontWeight.bold,
                    ),
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: playlists.length,
              itemBuilder: (context, index) {
                final playlist = playlists[index];
                return _buildPlaylistTile(playlist);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildPlaylistTile(Map<String, dynamic> playlist) {
    final playlistId = playlist['id'] as String;
    final playlistName = playlist['name'] as String;
    final songCount = (playlist['songIds'] as List).length;
    final coverImage = _musicService.hiveService.getPlaylistCoverImage(playlistId, _musicService.songs);
    
    return GestureDetector(
      onTap: () {
        _showPlaylistContents(playlistId, playlistName);
      },
      onLongPress: () {
        _showPlaylistOptions(playlistId, playlistName);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            // Playlist Image
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: NetworkImage(coverImage),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 12),
            
            // Playlist Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    playlistName,
                    style: Theme.of(context).brightness == Brightness.light
                        ? Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.black, fontWeight: FontWeight.w500)
                        : Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onBackground, fontWeight: FontWeight.w500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'songCount songs',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).brightness == Brightness.light
                          ? Colors.black54
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            
            // Three-dot menu
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
              onSelected: (value) {
                if (value == 'rename') {
                  _showRenamePlaylistDialog(playlistId, playlistName);
                } else if (value == 'delete') {
                  _showDeletePlaylistDialog(playlistId, playlistName);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'rename',
                  child: Text('Rename'),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Text('Delete'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showRenamePlaylistDialog(String playlistId, String currentName) {
    final textController = TextEditingController(text: currentName);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text('Rename Playlist', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface)),
        content: TextField(
          controller: textController,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface),
          decoration: InputDecoration(
            labelText: 'Playlist Name',
            labelStyle: Theme.of(context).textTheme.labelMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7))),
          ),
          TextButton(
            onPressed: () async {
              final newName = textController.text.trim();
              if (newName.isNotEmpty) {
                final playlist = _musicService.hiveService.getPlaylist(playlistId);
                if (playlist != null) {
                  final songIds = List<String>.from(playlist['songIds'] ?? []);
                  await _musicService.hiveService.updatePlaylist(playlistId, newName, songIds);
                  setState(() {}); // Refresh UI
                }
              }
              Navigator.pop(context);
            },
            child: Text('Rename', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Theme.of(context).colorScheme.primary)),
          ),
        ],
      ),
    );
  }

  void _showDeletePlaylistDialog(String playlistId, String playlistName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: const Text('Delete Playlist', style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to delete "$playlistName"? This action cannot be undone.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () async {
              await _musicService.hiveService.deletePlaylist(playlistId);
              setState(() {}); // Refresh UI
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showCreatePlaylistDialog() {
    final textController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: const Text('Create Playlist', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: textController,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: 'Playlist Name',
            labelStyle: TextStyle(color: Colors.white70),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white70),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF1DB954)),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () async {
              final newName = textController.text.trim();
              if (newName.isNotEmpty) {
                await _musicService.hiveService.createPlaylist(newName);
                setState(() {}); // Refresh UI
              }
              Navigator.pop(context);
            },
            child: const Text('Create', style: TextStyle(color: Color(0xFF1DB954))),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteArtistsSection() {
    return StreamBuilder<void>(
      stream: _musicService.analyticsStream,
      builder: (context, snapshot) {
        final favoriteArtists = _musicService.hiveService.getFavoriteArtists(_musicService.songs);
        
        if (favoriteArtists.isEmpty) {
          return const SizedBox.shrink();
        }
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Favorite Artists',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: favoriteArtists.length,
                itemBuilder: (context, index) {
                  final artist = favoriteArtists[index];
                  return _buildArtistCard(artist);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildArtistCard(Map<String, dynamic> artist) {
    final name = artist['name'] as String;
    final count = artist['count'] as int;
    final imageUrl = artist['imageUrl'] as String;
    
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Artist Image
          Container(
            width: 120,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: NetworkImage(imageUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 8),
          
          // Artist Info
          Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            '$count songs',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  void _showPlaylistContents(String playlistId, String playlistName) {
    final playlist = _musicService.hiveService.getPlaylist(playlistId);
    if (playlist != null) {
      final songIds = List<String>.from(playlist['songIds'] ?? []);
      final songs = songIds.map((id) => _musicService.getSongById(id)).whereType<Song>().toList();
      
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Scaffold(
            backgroundColor: const Color(0xFF121212),
            appBar: AppBar(
              backgroundColor: const Color(0xFF121212),
              title: Text(
                playlistName,
                style: const TextStyle(color: Colors.white),
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                Text(
                  '${songs.length} songs',
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(width: 16),
              ],
            ),
            body: songs.isEmpty
                ? const Center(
                    child: Text(
                      'No songs in this playlist',
                      style: TextStyle(color: Colors.white70),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: songs.length,
                    itemBuilder: (context, index) {
                      final song = songs[index];
                      return _buildPlaylistSongTile(song, index);
                    },
                  ),
          ),
        ),
      );
    }
  }

  Widget _buildPlaylistSongTile(Song song, int index) {
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
                    // Track number
                    Container(
                      width: 30,
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: isCurrentSong ? const Color(0xFF1DB954) : Colors.white70,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    
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
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            song.artist,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
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
                            color: isLiked ? const Color(0xFF1DB954) : Colors.white70,
                          ),
                          onPressed: () {
                            _musicService.toggleLikeSong(song.id);
                          },
                        );
                      },
                    ),
                    
                    // Play Button
                    IconButton(
                      icon: Icon(
                        (isCurrentSong && isPlaying) ? Icons.pause : Icons.play_arrow,
                        color: isCurrentSong ? const Color(0xFF1DB954) : Colors.white,
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

  void _showPlaylistOptions(String playlistId, String playlistName) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF121212),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.white),
              title: const Text('Rename Playlist', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _showRenamePlaylistDialog(playlistId, playlistName);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete Playlist', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _showDeletePlaylistDialog(playlistId, playlistName);
              },
            ),
          ],
        ),
      ),
    );
  }
} 