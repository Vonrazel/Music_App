import 'package:flutter/material.dart';
import '../services/music_service.dart';

class FullscreenPlayer extends StatefulWidget {
  const FullscreenPlayer({super.key});

  @override
  State<FullscreenPlayer> createState() => _FullscreenPlayerState();
}

class _FullscreenPlayerState extends State<FullscreenPlayer> {
  final MusicService _musicService = MusicService();
  bool _isDragging = false;
  double _sliderValue = 0.0;

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    // Get the current song value immediately
    final currentSong = _musicService.currentSong;
    debugPrint('[FullscreenPlayer] build() - currentSong: ${currentSong?.title ?? 'null'}');
    
    // If no current song, show placeholder
    if (currentSong == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF121212),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: const Color(0xFF282828),
                  borderRadius: BorderRadius.circular(60),
                ),
                child: const Icon(
                  Icons.music_note,
                  size: 60,
                  color: Colors.white54,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'No song playing',
                style: TextStyle(color: Colors.white70, fontSize: 18),
              ),
              const SizedBox(height: 8),
              const Text(
                'Select a song to start listening',
                style: TextStyle(color: Colors.white54, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    // Use StreamBuilder for real-time updates, but start with current value
    return StreamBuilder<Song?>(
      stream: _musicService.currentSongStream,
      initialData: currentSong, // Provide initial data
      builder: (context, songSnapshot) {
        final song = songSnapshot.data;
        debugPrint('[FullscreenPlayer] StreamBuilder - currentSong: ${song?.title ?? 'null'}');
        
        if (song == null) {
          return Scaffold(
            backgroundColor: const Color(0xFF121212),
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: const Color(0xFF282828),
                      borderRadius: BorderRadius.circular(60),
                    ),
                    child: const Icon(
                      Icons.music_note,
                      size: 60,
                      color: Colors.white54,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'No song playing',
                    style: TextStyle(color: Colors.white70, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Select a song to start listening',
                    style: TextStyle(color: Colors.white54, fontSize: 14),
                  ),
                ],
              ),
            ),
          );
        }

        return StreamBuilder<bool>(
          stream: _musicService.isPlayingStream,
          initialData: _musicService.isPlaying, // Provide initial data
          builder: (context, playingSnapshot) {
            final isPlaying = playingSnapshot.data ?? false;
            return StreamBuilder<Duration>(
              stream: _musicService.positionStream,
              initialData: _musicService.position, // Provide initial data
              builder: (context, positionSnapshot) {
                final position = positionSnapshot.data ?? Duration.zero;
                return StreamBuilder<Duration>(
                  stream: _musicService.durationStream,
                  initialData: _musicService.duration, // Provide initial data
                  builder: (context, durationSnapshot) {
                    final duration = durationSnapshot.data ?? Duration.zero;
                    return Scaffold(
                      backgroundColor: const Color(0xFF121212),
                      appBar: AppBar(
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        leading: IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        actions: [
                          IconButton(
                            icon: const Icon(Icons.more_vert, color: Colors.white),
                            onPressed: () {},
                          ),
                        ],
                      ),
                      body: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          children: [
                            // Add spacing below the app bar
                            const SizedBox(height: 32),
                            // Album art
                            Expanded(
                              flex: 3,
                              child: Center(
                                child: Container(
                                  width: double.infinity,
                                  height: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.3),
                                        blurRadius: 20,
                                        offset: const Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: Image.asset(
                                      'assets/images/kodak_cover.png.png',
                                      width: 300,
                                      height: 300,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 40),
                            // Song info
                            Expanded(
                              flex: 2,
                              child: Column(
                                children: [
                                  Text(
                                    song.title,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    song.artist,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 18,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            // Progress bar
                            duration.inSeconds > 0 ? Column(
                              children: [
                                SliderTheme(
                                  data: SliderTheme.of(context).copyWith(
                                    activeTrackColor: const Color(0xFF1DB954),
                                    inactiveTrackColor: Colors.white24,
                                    thumbColor: const Color(0xFF1DB954),
                                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                                  ),
                                  child: Slider(
                                    min: 0.0,
                                    max: duration.inSeconds.toDouble(),
                                    value: _isDragging 
                                        ? _sliderValue 
                                        : position.inSeconds.clamp(0, duration.inSeconds).toDouble(),
                                    onChanged: (value) {
                                      setState(() {
                                        _isDragging = true;
                                        _sliderValue = value;
                                      });
                                    },
                                    onChangeEnd: (value) {
                                      setState(() {
                                        _isDragging = false;
                                      });
                                      final newPosition = Duration(seconds: value.toInt());
                                      _musicService.seekTo(newPosition);
                                    },
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        _formatDuration(position),
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 14,
                                        ),
                                      ),
                                      Text(
                                        _formatDuration(duration),
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ) : Container(), // Show empty container if duration is 0
                            const SizedBox(height: 30),
                            // Controls
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                // Shuffle button
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(20),
                                    onTap: () {},
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      child: const Icon(Icons.shuffle, color: Colors.white70, size: 28),
                                    ),
                                  ),
                                ),
                                // Previous button
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(20),
                                    onTap: () {
                                      _musicService.previousSong();
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      child: const Icon(Icons.skip_previous, color: Colors.white, size: 36),
                                    ),
                                  ),
                                ),
                                // Play/Pause button
                                Material(
                                  color: const Color(0xFF1DB954),
                                  shape: const CircleBorder(),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(30),
                                    onTap: () {
                                      _musicService.togglePlayPause();
                                    },
                                    child: Container(
                                      width: 60,
                                      height: 60,
                                      child: Icon(
                                        isPlaying ? Icons.pause : Icons.play_arrow,
                                        color: Colors.white,
                                        size: 32,
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
                                      padding: const EdgeInsets.all(12),
                                      child: const Icon(Icons.skip_next, color: Colors.white, size: 36),
                                    ),
                                  ),
                                ),
                                // Repeat button
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(20),
                                    onTap: () {},
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      child: const Icon(Icons.repeat, color: Colors.white70, size: 28),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
} 