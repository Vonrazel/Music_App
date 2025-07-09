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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
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
                Icon(
                  Icons.cloud_upload,
                  color: colorScheme.onSurfaceVariant,
                  size: 32,
                ),
                const SizedBox(height: 8),
                Text(
                  'No uploaded songs yet',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Upload your music in the Create tab',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
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
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    'Upload Music',
                    style: theme.textTheme.bodySmall?.copyWith(
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
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
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
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          song.artist,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
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
                              color: colorScheme.onSurface,
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
                        child: Icon(
                          Icons.add,
                          color: colorScheme.onSurface,
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
                          color: colorScheme.onSurface,
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