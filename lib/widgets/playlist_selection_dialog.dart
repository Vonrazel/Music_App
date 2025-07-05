import 'package:flutter/material.dart';
import '../services/music_service.dart';

class PlaylistSelectionDialog extends StatefulWidget {
  final Song song;

  const PlaylistSelectionDialog({
    super.key,
    required this.song,
  });

  @override
  State<PlaylistSelectionDialog> createState() => _PlaylistSelectionDialogState();
}

class _PlaylistSelectionDialogState extends State<PlaylistSelectionDialog> {
  final MusicService _musicService = MusicService();
  final TextEditingController _playlistNameController = TextEditingController();
  List<Map<String, dynamic>> _playlists = [];

  @override
  void initState() {
    super.initState();
    _loadPlaylists();
  }

  @override
  void dispose() {
    _playlistNameController.dispose();
    super.dispose();
  }

  void _loadPlaylists() {
    _playlists = _musicService.hiveService.getAllPlaylists();
    setState(() {});
  }

  Future<void> _createNewPlaylist() async {
    final name = _playlistNameController.text.trim();
    if (name.isEmpty) return;

    await _musicService.hiveService.createPlaylist(name, [widget.song.id]);
    _playlistNameController.clear();
    _loadPlaylists();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added to "$name"'),
          backgroundColor: const Color(0xFF1DB954),
        ),
      );
    }
  }

  Future<void> _addToPlaylist(String playlistId) async {
    await _musicService.hiveService.addSongToPlaylist(playlistId, widget.song.id);
    
    if (mounted) {
      final playlist = _playlists.firstWhere((p) => p['id'] == playlistId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added to "${playlist['name']}"'),
          backgroundColor: const Color(0xFF1DB954),
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF282828),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFF1DB954),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: NetworkImage(widget.song.albumArt),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Add to Playlist',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.song.title,
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
                ],
              ),
            ),
            
            // Content
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Create new playlist section
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Create New Playlist',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _playlistNameController,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                    hintText: 'Playlist name',
                                    hintStyle: const TextStyle(color: Colors.white54),
                                    filled: true,
                                    fillColor: Colors.white.withValues(alpha: 0.1),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide.none,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton(
                                onPressed: _createNewPlaylist,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1DB954),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text('Create'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    const Divider(color: Colors.white24, height: 1),
                    
                    // Existing playlists section
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Add to Existing Playlist',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          
                          if (_playlists.isEmpty)
                            const Padding(
                              padding: EdgeInsets.all(16),
                              child: Text(
                                'No playlists found. Create one above!',
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            )
                          else
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _playlists.length,
                              itemBuilder: (context, index) {
                                final playlist = _playlists[index];
                                final songCount = _musicService.hiveService
                                    .getPlaylistSongCount(playlist['id']);
                                final coverImage = _musicService.hiveService
                                    .getPlaylistCoverImage(playlist['id'], _musicService.songs);
                                
                                return ListTile(
                                  leading: Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      image: DecorationImage(
                                        image: NetworkImage(coverImage),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    playlist['name'],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  subtitle: Text(
                                    '$songCount songs',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(
                                      Icons.add_circle_outline,
                                      color: Color(0xFF1DB954),
                                      size: 28,
                                    ),
                                    onPressed: () => _addToPlaylist(playlist['id']),
                                  ),
                                  onTap: () => _addToPlaylist(playlist['id']),
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Close button
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 