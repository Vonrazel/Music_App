import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'hive_service.dart';

class Song {
  final String id;
  final String title;
  final String artist;
  final String albumArt;
  final String audioUrl;
  final Duration duration;
  bool isLiked;

  Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.albumArt,
    required this.audioUrl,
    required this.duration,
    this.isLiked = false,
  });

  // Create a copy of the song with updated like status
  Song copyWith({bool? isLiked}) {
    return Song(
      id: id,
      title: title,
      artist: artist,
      albumArt: albumArt,
      audioUrl: audioUrl,
      duration: duration,
      isLiked: isLiked ?? this.isLiked,
    );
  }
}

class MusicService {
  static final MusicService _instance = MusicService._internal();
  factory MusicService() => _instance;
  MusicService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  final StreamController<bool> _isPlayingController = StreamController<bool>.broadcast();
  final StreamController<Song?> _currentSongController = StreamController<Song?>.broadcast();
  final StreamController<Duration> _positionController = StreamController<Duration>.broadcast();
  final StreamController<Duration> _durationController = StreamController<Duration>.broadcast();
  final StreamController<List<Song>> _likedSongsController = StreamController<List<Song>>.broadcast();
  
  Song? _currentSong;
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  List<Song> _likedSongs = [];

  // Hive Service for persistent data
  final HiveService _hiveService = HiveService();

  // Demo/royalty-free remote songs only
  List<Song> _songs = [
    Song(
      id: 'waiaan_12am',
      title: '12 AM',
      artist: 'WAIIAN',
      albumArt: 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=150&v=waiaan',
      audioUrl: 'assets/audio/WAIIAN - 12 AM Prod by Jwudz Official Music Video.mp3',
      duration: const Duration(minutes: 3, seconds: 50),
    ),
    Song(
      id: '1',
      title: 'Kodak Blu Lyrics Habang habol ko yung money Habol mo ay clout',
      artist: 'Gaspari',
      albumArt: 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=150',
      audioUrl: 'assets/audio/Gaspari - Kodak Blu Lyrics Habang habol ko yung money Habol mo ay clout.mp3',
      duration: const Duration(minutes: 3, seconds: 45),
    ),
    Song(
      id: '2',
      title: 'Blinding Lights',
      artist: 'The Weeknd',
      albumArt: 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=150&v=1',
      audioUrl: 'https://www.soundjay.com/misc/sounds/bell-ringing-05.wav',
      duration: const Duration(minutes: 3, seconds: 53),
    ),
    Song(
      id: '3',
      title: 'Dance Monkey',
      artist: 'Tones and I',
      albumArt: 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=150&v=2',
      audioUrl: 'https://www.soundjay.com/misc/sounds/fail-buzzer-02.wav',
      duration: const Duration(minutes: 3, seconds: 29),
    ),
    Song(
      id: '4',
      title: 'Shape of You',
      artist: 'Ed Sheeran',
      albumArt: 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=150&v=3',
      audioUrl: 'https://www.soundjay.com/misc/sounds/bell-ringing-05.wav',
      duration: const Duration(minutes: 4, seconds: 12),
    ),
    Song(
      id: '5',
      title: 'Uptown Funk',
      artist: 'Mark Ronson ft. Bruno Mars',
      albumArt: 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=150&v=4',
      audioUrl: 'https://www.soundjay.com/misc/sounds/fail-buzzer-02.wav',
      duration: const Duration(minutes: 3, seconds: 14),
    ),
    Song(
      id: '6',
      title: 'Despacito',
      artist: 'Luis Fonsi ft. Daddy Yankee',
      albumArt: 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=150&v=5',
      audioUrl: 'https://www.soundjay.com/misc/sounds/bell-ringing-05.wav',
      duration: const Duration(minutes: 3, seconds: 23),
    ),
    Song(
      id: '7',
      title: 'See You Again',
      artist: 'Wiz Khalifa ft. Charlie Puth',
      albumArt: 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=150&v=6',
      audioUrl: 'https://www.soundjay.com/misc/sounds/bell-ringing-05.wav',
      duration: const Duration(minutes: 2, seconds: 54),
    ),
    Song(
      id: '8',
      title: 'Closer',
      artist: 'The Chainsmokers ft. Halsey',
      albumArt: 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=150&v=7',
      audioUrl: 'https://www.soundjay.com/misc/sounds/fail-buzzer-02.wav',
      duration: const Duration(minutes: 2, seconds: 21),
    ),
    Song(
      id: '9',
      title: 'Cheap Thrills',
      artist: 'Sia ft. Sean Paul',
      albumArt: 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=150&v=8',
      audioUrl: 'https://www.soundjay.com/misc/sounds/bell-ringing-05.wav',
      duration: const Duration(minutes: 2, seconds: 21),
    ),
    Song(
      id: '10',
      title: 'Faded',
      artist: 'Alan Walker',
      albumArt: 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=150&v=9',
      audioUrl: 'https://www.soundjay.com/misc/sounds/fail-buzzer-02.wav',
      duration: const Duration(minutes: 2, seconds: 47),
    ),
  ];

  // Getters
  AudioPlayer get audioPlayer => _audioPlayer;
  Song? get currentSong => _currentSong;
  bool get isPlaying => _isPlaying;
  Duration get position => _position;
  Duration get duration => _duration;
  List<Song> get songs => _songs;
  List<Song> get likedSongs => _likedSongs;
  HiveService get hiveService => _hiveService;
  
  // Streams for UI updates
  Stream<bool> get isPlayingStream => _isPlayingController.stream;
  Stream<Song?> get currentSongStream => _currentSongController.stream;
  Stream<Duration> get positionStream => _positionController.stream;
  Stream<Duration> get durationStream => _durationController.stream;
  Stream<List<Song>> get likedSongsStream => _likedSongsController.stream;

  // --- Analytics Streams ---
  final StreamController<void> _analyticsController = StreamController<void>.broadcast();
  Stream<void> get analyticsStream => _analyticsController.stream;

  // --- Analytics Getters (now using Hive) ---
  Map<String, int> get playCounts => _hiveService.getMostPlayed();
  List<Song> get recentlyPlayedSongs {
    final recentlyPlayed = _hiveService.getRecentlyPlayed();
    return recentlyPlayed.map((item) {
      final songId = item['songId'] as String;
      return getSongById(songId);
    }).whereType<Song>().toList();
  }
  Duration get totalListeningTime => _hiveService.getTotalListeningTime();
  int get likedSongsCount => _likedSongs.length;
  String? get favoriteGenre => null; // Not implemented, placeholder
  int get totalTracksPlayed => _hiveService.getTotalPlays();

  Song? get mostPlayedSong {
    final topSongId = _hiveService.getTopPlayedSongId();
    return topSongId != null ? getSongById(topSongId) : null;
  }

  // --- Analytics Update Helpers (now using Hive) ---
  void _recordPlay(Song song) async {
    // Record play in Hive
    await _hiveService.recordPlay(song.id, song.title, song.artist, song.albumArt);
    
    // Notify analytics listeners
    _analyticsController.add(null);
  }

  void _addListeningTime(Duration duration) async {
    // Add listening time to Hive
    await _hiveService.addListeningTime(duration);
    
    // Notify analytics listeners
    _analyticsController.add(null);
  }





  // Initialize the audio session
  Future<void> initialize() async {
    try {
      print('🎵 Initializing MusicService...');
      
      // Configure audio session for better compatibility (including web)
      try {
        final session = await AudioSession.instance;
        await session.configure(const AudioSessionConfiguration.music());
        print('✅ Audio session configured');
      } catch (e) {
        print('⚠️ Audio session configuration failed: $e');
        print('🔄 Continuing without audio session configuration...');
      }
      
      // Load uploaded songs from Hive
      await _loadUploadedSongs();
      
      // Load liked songs from Hive
      await _loadLikedSongs();
      print('✅ Liked songs loaded');
      
      // Listen to player state changes
      _audioPlayer.playerStateStream.listen((state) {
        print('🎵 Player state changed: ${state.playing} - ${state.processingState}');
        _isPlaying = state.playing;
        _isPlayingController.add(_isPlaying);
      });

      // Listen to position changes
      _audioPlayer.positionStream.listen((pos) {
        _position = pos;
        _positionController.add(_position);
      });

      // Listen to duration changes
      _audioPlayer.durationStream.listen((dur) {
        print('⏱️ Duration updated: ${dur?.inSeconds} seconds');
        _duration = dur ?? Duration.zero;
        _durationController.add(_duration);
      });

      // Listen to processing state changes
      _audioPlayer.processingStateStream.listen((state) {
        print('🔄 Processing state: $state');
        if (state == ProcessingState.completed) {
          // Auto-play next song when current song finishes
          nextSong();
        }
      });

      // Set initial volume to ensure audio is not muted
      await _audioPlayer.setVolume(1.0);
      print('✅ Audio volume set to 1.0');
      
      print('✅ MusicService initialized successfully');

    } catch (e) {
      print('❌ Error initializing audio session: $e');
      // Don't rethrow - let the app continue without audio functionality
    }
  }

  // Load uploaded songs from Hive
  Future<void> _loadUploadedSongs() async {
    try {
      final uploadedSongsData = _hiveService.box.get('uploadedSongs', defaultValue: []);
      final uploadedSongs = List<Map<String, dynamic>>.from(uploadedSongsData);
      
      for (final songData in uploadedSongs) {
        final song = Song(
          id: songData['id'],
          title: songData['title'],
          artist: songData['artist'],
          albumArt: songData['albumArt'],
          audioUrl: songData['audioUrl'],
          duration: Duration(seconds: songData['duration'] ?? 0),
          isLiked: songData['isLiked'] ?? false,
        );
        
        // Add to songs list if not already present
        if (!_songs.any((s) => s.id == song.id)) {
          _songs.add(song);
        }
      }
      
      print('Loaded ${uploadedSongs.length} uploaded songs from Hive');
    } catch (e) {
      print('Error loading uploaded songs from Hive: $e');
    }
  }

  // Load liked songs from Hive
  Future<void> _loadLikedSongs() async {
    try {
      final likedSongIds = _hiveService.getLikedSongs();
      
      // Update songs with their liked status
      for (int i = 0; i < _songs.length; i++) {
        _songs[i].isLiked = likedSongIds.contains(_songs[i].id);
      }
      
      // Update liked songs list
      _likedSongs = _songs.where((song) => song.isLiked).toList();
      _likedSongsController.add(_likedSongs);
      
      print('Loaded ${_likedSongs.length} liked songs from Hive');
    } catch (e) {
      print('Error loading liked songs from Hive: $e');
    }
  }

  // Save liked songs to Hive
  Future<void> _saveLikedSongs() async {
    try {
      final likedSongIds = _likedSongs.map((song) => song.id).toList();
      await _hiveService.setLikedSongs(likedSongIds);
      print('Saved ${likedSongIds.length} liked songs to Hive');
    } catch (e) {
      print('Error saving liked songs to Hive: $e');
    }
  }

  // Toggle like status for a song
  Future<void> toggleLikeSong(String songId) async {
    try {
      final songIndex = _songs.indexWhere((song) => song.id == songId);
      if (songIndex == -1) return;

      final song = _songs[songIndex];
      final newLikedStatus = !song.isLiked;
      
      // Update the song's liked status
      _songs[songIndex] = song.copyWith(isLiked: newLikedStatus);
      
      // Update liked songs list
      if (newLikedStatus) {
        _likedSongs.add(_songs[songIndex]);
        await _hiveService.addLikedSong(songId);
      } else {
        _likedSongs.removeWhere((song) => song.id == songId);
        await _hiveService.removeLikedSong(songId);
      }
      
      // Update liked songs playlist in Hive
      final likedSongIds = _likedSongs.map((song) => song.id).toList();
      await _hiveService.updateLikedSongsPlaylist(likedSongIds);
      
      // Update current song if it's the same song
      if (_currentSong?.id == songId) {
        _currentSong = _songs[songIndex];
        _currentSongController.add(_currentSong);
      }
      
      // Notify listeners
      _likedSongsController.add(_likedSongs);
      
      print('${newLikedStatus ? 'Liked' : 'Unliked'}: ${song.title}');
    } catch (e) {
      print('Error toggling like status: $e');
    }
  }

  // Check if a song is liked
  bool isSongLiked(String songId) {
    return _songs.any((song) => song.id == songId && song.isLiked);
  }

  // Add uploaded song to the music service
  void addUploadedSong(Song song) {
    // Check if song already exists
    if (!_songs.any((s) => s.id == song.id)) {
      _songs.add(song);
      print('Added uploaded song: ${song.title}');
    }
  }

  // Play a specific song
  Future<void> playSong(Song song) async {
    try {
      print('🎵 Attempting to play: ${song.title} by ${song.artist}');
      print('📁 Audio source: ${song.audioUrl}');
      
      // If it's the same song that's already loaded, just play it
      if (_currentSong?.id == song.id) {
        print('🔄 Resuming same song: ${song.title}');
        await _audioPlayer.play();
        _isPlaying = true;
        _isPlayingController.add(_isPlaying);
        // --- Analytics: Record play ---
        _recordPlay(song);
        return;
      }
      
      // If it's a different song, load it and play from beginning
      print('🔄 Loading new song: ${song.title}');
      _currentSong = song;
      _currentSongController.add(_currentSong);
      
      // Stop any current playback first
      await _audioPlayer.stop();
      
      // Handle local assets vs remote URLs vs uploaded files
      if (song.audioUrl.startsWith('assets/')) {
        // For local assets, use setAsset method
        print('📂 Loading local asset: ${song.audioUrl}');
        
        // For web, we need to use a different approach for assets
        if (kIsWeb) {
          // On web, assets need to be served from the web directory
          // Convert assets/audio/filename.mp3 to /assets/audio/filename.mp3
          final webPath = song.audioUrl.replaceFirst('assets/', '/assets/');
          print('🌐 Web platform - loading from: $webPath');
          await _audioPlayer.setUrl(webPath);
        } else {
          // For mobile platforms, use setAsset
          await _audioPlayer.setAsset(song.audioUrl);
        }
        print('✅ Successfully loaded audio source');
      } else if (song.audioUrl.startsWith('blob:')) {
        // For web uploaded files (blob URLs)
        print('🌐 Web uploaded file (blob): ${song.audioUrl}');
        await _audioPlayer.setUrl(song.audioUrl);
        print('✅ Successfully loaded web uploaded file');
      } else if (song.audioUrl.contains('/uploads/')) {
        // For uploaded files on mobile, use setFilePath
        print('📂 Loading uploaded file: ${song.audioUrl}');
        await _audioPlayer.setFilePath(song.audioUrl);
        print('✅ Successfully loaded uploaded file');
      } else {
        // For remote URLs, use setUrl method
        print('🌐 Loading remote URL: ${song.audioUrl}');
        await _audioPlayer.setUrl(song.audioUrl);
        print('✅ Successfully loaded remote URL: ${song.audioUrl}');
      }
      
      // Wait for the audio to load and get duration
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Ensure volume is set correctly
      await _audioPlayer.setVolume(1.0);
      
      // Start playing
      await _audioPlayer.play();
      _isPlaying = true;
      _isPlayingController.add(_isPlaying);
      
      print('🎵 Now playing: ${song.title} by ${song.artist}');
      
      // --- Analytics: Record play ---
      _recordPlay(song);
      
    } catch (e) {
      print('❌ Error playing song: $e');
      String errorMessage = 'Unable to play "${song.title}". ';
      
      if (song.audioUrl.startsWith('assets/')) {
        errorMessage += 'Please check if the file exists in the assets folder.';
        print('💡 TIP: Verify file exists at: ${song.audioUrl}');
        print('💡 TIP: Check pubspec.yaml includes: assets/audio/');
      } else {
        errorMessage += 'Please check your internet connection.';
      }
      
      _showErrorDialog(errorMessage);
    }
  }





  // Play/Pause toggle with position memory
  Future<void> togglePlayPause() async {
    if (_currentSong == null) {
      // If no song is playing, start with the first song
      if (_songs.isNotEmpty) {
        print('🎵 No song playing, starting with first song');
        await playSong(_songs.first);
      }
      return;
    }
    
    try {
      print('🔄 Toggling play/pause for: ${_currentSong!.title}');

      if (_isPlaying) {
        // Pause the audio (position is automatically saved)
        await _audioPlayer.pause();
        _isPlaying = false;
        _isPlayingController.add(_isPlaying);
        print('⏸️ Audio paused at position: ${_position.inSeconds} seconds');
      } else {
        // Resume the audio from the same position
        await _audioPlayer.play();
        _isPlaying = true;
        _isPlayingController.add(_isPlaying);
        print('▶️ Audio resumed from position: ${_position.inSeconds} seconds');
      }
    } catch (e) {
      print('❌ Error toggling play/pause: $e');
    }
  }

  // Stop playback
  Future<void> stop() async {
    try {
      // --- Analytics: Add listening time ---
      if (_currentSong != null) _addListeningTime(_position);
      await _audioPlayer.stop();
      _isPlaying = false;
      _isPlayingController.add(_isPlaying);
    } catch (e) {
      print('Error stopping playback: $e');
    }
  }

  // Seek to position
  Future<void> seekTo(Duration position) async {
    try {
      await _audioPlayer.seek(position);
    } catch (e) {
      print('Error seeking: $e');
    }
  }

  // Skip to next song
  Future<void> nextSong() async {
    if (_currentSong == null) {
      if (_songs.isNotEmpty) {
        await playSong(_songs.first);
      }
      return;
    }
    
    final currentIndex = _songs.indexWhere((song) => song.id == _currentSong!.id);
    if (currentIndex < _songs.length - 1) {
      await playSong(_songs[currentIndex + 1]);
    } else {
      // Loop back to first song
      await playSong(_songs.first);
    }
  }

  // Skip to previous song
  Future<void> previousSong() async {
    if (_currentSong == null) {
      if (_songs.isNotEmpty) {
        await playSong(_songs.first);
      }
      return;
    }
    
    final currentIndex = _songs.indexWhere((song) => song.id == _currentSong!.id);
    if (currentIndex > 0) {
      await playSong(_songs[currentIndex - 1]);
    } else {
      // Loop to last song
      await playSong(_songs.last);
    }
  }

  // Get song by ID
  Song? getSongById(String id) {
    try {
      return _songs.firstWhere((song) => song.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get top 10 songs
  List<Song> getTopSongs() {
    return _songs.take(10).toList();
  }

  // Show error dialog
  void _showErrorDialog(String message) {
    print('Error: $message');
    // You can implement a proper error dialog here if needed
  }

  // Dispose resources
  void dispose() {
    try {
      _audioPlayer.dispose();
      _isPlayingController.close();
      _currentSongController.close();
      _positionController.close();
      _durationController.close();
      _likedSongsController.close();
      _analyticsController.close();
      print('MusicService disposed successfully');
    } catch (e) {
      print('Error disposing MusicService: $e');
    }
  }

  // Get formatted position string (e.g., "1:23")
  String getFormattedPosition() {
    final minutes = _position.inMinutes;
    final seconds = _position.inSeconds % 60;
    return '${minutes}:${seconds.toString().padLeft(2, '0')}';
  }

  // Get formatted duration string (e.g., "3:45")
  String getFormattedDuration() {
    final minutes = _duration.inMinutes;
    final seconds = _duration.inSeconds % 60;
    return '${minutes}:${seconds.toString().padLeft(2, '0')}';
  }

  // Get playback progress as a percentage (0.0 to 1.0)
  double getPlaybackProgress() {
    if (_duration.inMilliseconds > 0) {
      return _position.inMilliseconds / _duration.inMilliseconds;
    }
    return 0.0;
  }

  // --- Analytics Helper Methods (now using Hive) ---
  Duration getTotalListeningTime() => _hiveService.getTotalListeningTime();
  Song? getTopPlayedSong() => mostPlayedSong;
  Map<DateTime, int> getDailyPlayCounts({int days = 7}) {
    final playPerDay = _hiveService.getPlayPerDay();
    final now = DateTime.now();
    final result = <DateTime, int>{};
    for (int i = 0; i < days; i++) {
      final day = DateTime(now.year, now.month, now.day).subtract(Duration(days: i));
      final dateKey = day.toIso8601String().substring(0, 10);
      result[day] = playPerDay[dateKey] ?? 0;
    }
    return result;
  }
  Duration getAvgListeningTimePerDay() {
    // This would need to be calculated from daily listening time data
    // For now, return a simple calculation
    final totalTime = getTotalListeningTime();
    final totalPlays = _hiveService.getTotalPlays();
    if (totalPlays == 0) return Duration.zero;
    return Duration(seconds: totalTime.inSeconds ~/ totalPlays);
  }
  int getStreak() => _hiveService.getStreak();
  List<Map<String, dynamic>> getRecentlyPlayedWithTimestamps({int max = 10}) {
    return _hiveService.getRecentlyPlayed().take(max).toList();
  }
} 