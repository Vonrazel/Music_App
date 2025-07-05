import 'package:flutter/material.dart';
import '../services/music_service.dart';
import '../widgets/playlist_selection_dialog.dart';
import '../screens/main_navigation.dart';

class UploadedSongsSection extends StatelessWidget {
  final MusicService musicService;
  final String? sortBy;

  const UploadedSongsSection({
    super.key,
    required this.musicService,
    this.sortBy,
  });

  @override
  Widget build(BuildContext context) {
    // Get uploaded songs (songs with IDs starting with 'uploaded_')
    var uploadedSongs = musicService.songs.where((song) => song.id.startsWith('uploaded_')).toList();
    
    // Sort songs based on sortBy parameter
    if (sortBy != null) {
      uploadedSongs.sort((a, b) {
        if (sortBy == 'uploadDate') {
          // Sort by upload date (extract timestamp from ID)
          final aTimestamp = _extractTimestampFromId(a.id);
          final bTimestamp = _extractTimestampFromId(b.id);
          return bTimestamp.compareTo(aTimestamp); // Newest first
        } else if (sortBy == 'fileName') {
          // Sort by file name (title)
          return a.title.toLowerCase().compareTo(b.title.toLowerCase());
        }
        return 0;
      });
    }
    
    if (uploadedSongs.isEmpty) {
      return SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF282828),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.cloud_upload,
                  color: Colors.white54,
                  size: 32,
                ),
                const SizedBox(height: 8),
                const Text(
                  'No uploaded songs yet',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Upload your music in the Create tab',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1DB954),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Upload Music',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Uploaded Songs (${uploadedSongs.length})',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: uploadedSongs.length,
              itemBuilder: (context, index) {
                final song = uploadedSongs[index];
                return _buildUploadedSongTile(context, song);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadedSongTile(BuildContext context, Song song) {
    return StreamBuilder<Song?>(
      stream: musicService.currentSongStream,
      builder: (context, snapshot) {
        final currentSong = snapshot.data;
        final isCurrentSong = currentSong?.id == song.id;
        
        return StreamBuilder<bool>(
          stream: musicService.isPlayingStream,
          builder: (context, playingSnapshot) {
            final isPlaying = playingSnapshot.data ?? false;
            
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isCurrentSong ? const Color(0xFF1DB954).withValues(alpha: 0.2) : const Color(0xFF282828),
                borderRadius: BorderRadius.circular(8),
                border: isCurrentSong ? Border.all(color: const Color(0xFF1DB954), width: 1) : null,
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
                            fontSize: 14,
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
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Like Button
                  StreamBuilder<List<Song>>(
                    stream: musicService.likedSongsStream,
                    builder: (context, likedSnapshot) {
                      final likedSongs = likedSnapshot.data ?? [];
                      final isLiked = likedSongs.any((likedSong) => likedSong.id == song.id);
                      
                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () {
                            musicService.toggleLikeSong(song.id);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            child: Icon(
                              isLiked ? Icons.favorite : Icons.favorite_border,
                              color: Colors.white,
                              size: 20,
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
                          color: Colors.white,
                          size: 20,
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
                          musicService.togglePlayPause();
                        } else {
                          musicService.playSong(song);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        child: Icon(
                          (isCurrentSong && isPlaying) ? Icons.pause : Icons.play_arrow,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  int _extractTimestampFromId(String id) {
    try {
      // Extract timestamp from uploaded song ID format: uploaded_timestamp_filename
      final parts = id.split('_');
      if (parts.length >= 2) {
        return int.tryParse(parts[1]) ?? 0;
      }
    } catch (e) {
      // If parsing fails, return 0
    }
    return 0;
  }
} 