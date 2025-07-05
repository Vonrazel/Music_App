import 'package:flutter/material.dart';
import '../services/music_service.dart';
import 'fullscreen_player.dart';

class MiniPlayer extends StatefulWidget {
  const MiniPlayer({super.key});

  @override
  State<MiniPlayer> createState() => _MiniPlayerState();
}

class _MiniPlayerState extends State<MiniPlayer> {
  final MusicService _musicService = MusicService();
  bool _isPlaying = false;
  Song? _currentSong;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _setupListeners();
  }

  void _setupListeners() {
    // Listen to playing state changes
    _musicService.isPlayingStream.listen((isPlaying) {
      if (mounted) {
        setState(() {
          _isPlaying = isPlaying;
        });
      }
    });

    // Listen to current song changes
    _musicService.currentSongStream.listen((song) {
      if (mounted) {
        setState(() {
          _currentSong = song;
        });
      }
    });

    // Listen to position changes
    _musicService.positionStream.listen((pos) {
      if (mounted) {
        setState(() {
          _position = pos;
        });
      }
    });

    // Listen to duration changes
    _musicService.durationStream.listen((dur) {
      if (mounted) {
        setState(() {
          _duration = dur;
        });
      }
    });
  }

  void _openFullscreenPlayer() {
    if (_currentSong != null) {
      print('🎵 Opening fullscreen player for: ${_currentSong!.title}');
      Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => FullscreenPlayer(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
        ),
      );
    } else {
      print('⚠️ No current song to open in fullscreen player');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Don't show mini player if no song is playing
    if (_currentSong == null) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: _openFullscreenPlayer,
      child: Container(
        height: 70,
        decoration: const BoxDecoration(
          color: Color(0xFF282828),
          border: Border(
            top: BorderSide(color: Colors.white12, width: 0.5),
          ),
        ),
        child: Column(
          children: [
            // Progress bar
            LinearProgressIndicator(
              value: _duration.inMilliseconds > 0 
                  ? _position.inMilliseconds / _duration.inMilliseconds 
                  : 0.0,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF1DB954)),
              minHeight: 2,
            ),
            
            // Player content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    // Album art
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.network(
                          _currentSong!.albumArt,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color: const Color(0xFF282828),
                              child: const Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
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
                                size: 24,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    
                    // Song info
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _currentSong!.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _currentSong!.artist,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          // Show position and duration
                          Text(
                            '${_musicService.getFormattedPosition()} / ${_musicService.getFormattedDuration()}',
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Controls
                    Row(
                      children: [
                        // Previous button
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () {
                              _musicService.previousSong();
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              child: const Icon(Icons.skip_previous, color: Colors.white, size: 28),
                            ),
                          ),
                        ),
                        
                        // Play/Pause button
                        Material(
                          color: const Color(0xFF1DB954),
                          shape: const CircleBorder(),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () {
                              _musicService.togglePlayPause();
                            },
                            child: Container(
                              width: 40,
                              height: 40,
                              child: Icon(
                                _isPlaying ? Icons.pause : Icons.play_arrow,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                        
                        // Next button
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () {
                              _musicService.nextSong();
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              child: const Icon(Icons.skip_next, color: Colors.white, size: 28),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 