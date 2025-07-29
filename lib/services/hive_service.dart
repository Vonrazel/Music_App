import 'package:hive_flutter/hive_flutter.dart';
import 'dart:convert';
import 'music_service.dart';

class HiveService {
  static final HiveService _instance = HiveService._internal();
  factory HiveService() => _instance;
  HiveService._internal();

  static const String _boxName = 'musicData';
  
  // Keys for different data types
  static const String _totalPlaysKey = 'totalPlays';
  static const String _totalListeningTimeKey = 'totalListeningTime';
  static const String _playPerDayKey = 'playPerDay';
  static const String _streakKey = 'streak';
  static const String _recentlyPlayedKey = 'recentlyPlayed';
  static const String _mostPlayedKey = 'mostPlayed';
  static const String _likedSongsKey = 'likedSongs';
  static const String _lastPlayedDayKey = 'lastPlayedDay';

  Box? _box;
  Box? _playlistsBox;
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    await Hive.initFlutter();
    _box = await Hive.openBox(_boxName);
    _playlistsBox = await Hive.openBox('playlistsBox');
    _initialized = true;
    
    // Initialize default playlists if they don't exist
    await _initializeDefaultPlaylists();
  }

  Box get box {
    if (_box == null) {
      throw Exception('HiveService not initialized. Call initialize() first.');
    }
    return _box!;
  }

  Box get playlistsBox {
    if (_playlistsBox == null) {
      throw Exception('HiveService not initialized. Call initialize() first.');
    }
    return _playlistsBox!;
  }

  // Initialize default playlists
  Future<void> _initializeDefaultPlaylists() async {
    final existingPlaylists = getAllPlaylists();
    
    // Add default playlists if they don't exist
    if (!existingPlaylists.any((p) => p['id'] == 'liked')) {
      await createPlaylist('Liked Songs', []);
    }
    if (!existingPlaylists.any((p) => p['name'] == 'Workout Mix')) {
      await createPlaylist('Workout Mix', []);
    }
    if (!existingPlaylists.any((p) => p['name'] == 'Chill Vibes')) {
      await createPlaylist('Chill Vibes', []);
    }
    if (!existingPlaylists.any((p) => p['name'] == 'My Playlist #1')) {
      await createPlaylist('My Playlist #1', []);
    }
  }

  // ===== ANALYTICS METHODS =====

  // Total Plays
  int getTotalPlays() {
    return box.get(_totalPlaysKey, defaultValue: 0);
  }

  Future<void> incrementTotalPlays() async {
    final current = getTotalPlays();
    await box.put(_totalPlaysKey, current + 1);
  }

  // Total Listening Time
  Duration getTotalListeningTime() {
    final seconds = box.get(_totalListeningTimeKey, defaultValue: 0);
    return Duration(seconds: seconds);
  }

  Future<void> addListeningTime(Duration duration) async {
    final current = getTotalListeningTime();
    final newTotal = current + duration;
    await box.put(_totalListeningTimeKey, newTotal.inSeconds);
  }

  // Play Per Day
  Map<String, int> getPlayPerDay() {
    final data = box.get(_playPerDayKey, defaultValue: '{}');
    return Map<String, int>.from(jsonDecode(data));
  }

  Future<void> incrementPlayPerDay(String date) async {
    final data = getPlayPerDay();
    data[date] = (data[date] ?? 0) + 1;
    await box.put(_playPerDayKey, jsonEncode(data));
  }

  // Streak
  int getStreak() {
    return box.get(_streakKey, defaultValue: 0);
  }

  Future<void> updateStreak() async {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final lastPlayedDay = box.get(_lastPlayedDayKey, defaultValue: '');
    
    if (lastPlayedDay.isEmpty) {
      // First time playing
      await box.put(_streakKey, 1);
      await box.put(_lastPlayedDayKey, today);
    } else if (lastPlayedDay != today) {
      // Check if it's consecutive days
      final lastDate = DateTime.parse(lastPlayedDay);
      final todayDate = DateTime.parse(today);
      final diff = todayDate.difference(lastDate).inDays;
      
      if (diff == 1) {
        // Consecutive day
        final currentStreak = getStreak();
        await box.put(_streakKey, currentStreak + 1);
      } else if (diff > 1) {
        // Break in streak
        await box.put(_streakKey, 1);
      }
      // If diff == 0, same day, streak unchanged
      
      await box.put(_lastPlayedDayKey, today);
    }
  }

  // Recently Played
  List<Map<String, dynamic>> getRecentlyPlayed() {
    final data = box.get(_recentlyPlayedKey, defaultValue: '[]');
    return List<Map<String, dynamic>>.from(jsonDecode(data));
  }

  Future<void> addRecentlyPlayed(String songId, String title, String artist, String albumArt) async {
    final recentlyPlayed = getRecentlyPlayed();
    
    // Remove if already exists
    recentlyPlayed.removeWhere((item) => item['songId'] == songId);
    
    // Add to beginning
    recentlyPlayed.insert(0, {
      'songId': songId,
      'title': title,
      'artist': artist,
      'albumArt': albumArt,
      'timestamp': DateTime.now().toIso8601String(),
    });
    
    // Keep only last 10
    if (recentlyPlayed.length > 10) {
      recentlyPlayed.removeRange(10, recentlyPlayed.length);
    }
    
    await box.put(_recentlyPlayedKey, jsonEncode(recentlyPlayed));
  }

  // Most Played
  Map<String, int> getMostPlayed() {
    final data = box.get(_mostPlayedKey, defaultValue: '{}');
    return Map<String, int>.from(jsonDecode(data));
  }

  Future<void> incrementMostPlayed(String songId) async {
    final mostPlayed = getMostPlayed();
    mostPlayed[songId] = (mostPlayed[songId] ?? 0) + 1;
    await box.put(_mostPlayedKey, jsonEncode(mostPlayed));
  }

  String? getTopPlayedSongId() {
    final mostPlayed = getMostPlayed();
    if (mostPlayed.isEmpty) return null;
    
    final maxEntry = mostPlayed.entries.reduce((a, b) => a.value >= b.value ? a : b);
    return maxEntry.key;
  }

  // Liked Songs
  List<String> getLikedSongs() {
    return List<String>.from(box.get(_likedSongsKey, defaultValue: []));
  }

  Future<void> setLikedSongs(List<String> songIds) async {
    await box.put(_likedSongsKey, songIds);
  }

  Future<void> addLikedSong(String songId) async {
    final likedSongs = getLikedSongs();
    if (!likedSongs.contains(songId)) {
      likedSongs.add(songId);
      await setLikedSongs(likedSongs);
    }
  }

  Future<void> removeLikedSong(String songId) async {
    final likedSongs = getLikedSongs();
    likedSongs.remove(songId);
    await setLikedSongs(likedSongs);
  }

  // ===== HELPER METHODS =====

  Future<void> recordPlay(String songId, String title, String artist, String albumArt) async {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    
    // Increment total plays
    await incrementTotalPlays();
    
    // Increment play per day
    await incrementPlayPerDay(today);
    
    // Update streak
    await updateStreak();
    
    // Add to recently played
    await addRecentlyPlayed(songId, title, artist, albumArt);
    
    // Increment most played
    await incrementMostPlayed(songId);
  }

  // Get analytics summary
  Map<String, dynamic> getAnalyticsSummary() {
    return {
      'totalPlays': getTotalPlays(),
      'totalListeningTime': getTotalListeningTime().inSeconds,
      'streak': getStreak(),
      'recentlyPlayed': getRecentlyPlayed(),
      'mostPlayed': getMostPlayed(),
      'topPlayedSongId': getTopPlayedSongId(),
      'likedSongs': getLikedSongs(),
    };
  }

  // Clear all data (for testing/reset)
  Future<void> clearAllData() async {
    await box.clear();
  }

  // Dispose
  Future<void> dispose() async {
    await _box?.close();
  }

  // ===== PLAYLIST METHODS =====

  // Create a new playlist
  Future<void> createPlaylist(String name, [List<String> songIds = const []]) async {
    final id = _generateUniqueId();
    final playlist = {
      'id': id,
      'name': name,
      'songIds': songIds,
      'createdAt': DateTime.now().toIso8601String(),
    };
    await playlistsBox.put(id, playlist);
  }

  // Generate unique playlist ID
  String _generateUniqueId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (timestamp % 10000).toString().padLeft(4, '0');
    return 'playlist_$timestamp$random';
  }

  // Get favorite artists based on liked songs
  List<Map<String, dynamic>> getFavoriteArtists(List<Song> allSongs) {
    final likedSongIds = getLikedSongs();
    final artistCounts = <String, int>{};
    
    // Count songs per artist from liked songs
    for (final songId in likedSongIds) {
      final song = allSongs.firstWhere(
        (song) => song.id == songId,
        orElse: () => Song(
          id: songId,
          title: 'Unknown',
          artist: 'Unknown Artist',
          albumArt: 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=150',
          audioUrl: '',
          duration: Duration.zero,
        ),
      );
      
      if (song.artist != 'Unknown Artist') {
        artistCounts[song.artist] = (artistCounts[song.artist] ?? 0) + 1;
      }
    }
    
    // Convert to list and sort by count
    final artists = artistCounts.entries.map((entry) => {
      'name': entry.key,
      'count': entry.value,
      'imageUrl': _getArtistImageUrl(entry.key),
    }).toList();
    
    artists.sort((a, b) => (b['count'] as int).compareTo(a['count'] as int));
    return artists.take(5).toList(); // Return top 5
  }

  // Helper method to get artist image URL (placeholder)
  String _getArtistImageUrl(String artistName) {
    // This would need to be implemented with actual artist data
    // For now, return a placeholder image
    return 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=150';
  }

  // Get all playlists
  List<Map<String, dynamic>> getAllPlaylists() {
    final playlists = <Map<String, dynamic>>[];
    for (final key in playlistsBox.keys) {
      final playlist = playlistsBox.get(key);
      if (playlist != null) {
        playlists.add(Map<String, dynamic>.from(playlist));
      }
    }
    return playlists;
  }

  // Get a specific playlist
  Map<String, dynamic>? getPlaylist(String id) {
    final playlist = playlistsBox.get(id);
    return playlist != null ? Map<String, dynamic>.from(playlist) : null;
  }

  // Update a playlist
  Future<void> updatePlaylist(String id, String name, List<String> songIds) async {
    final playlist = {
      'id': id,
      'name': name,
      'songIds': songIds,
      'updatedAt': DateTime.now().toIso8601String(),
    };
    await playlistsBox.put(id, playlist);
  }

  // Delete a playlist
  Future<void> deletePlaylist(String id) async {
    await playlistsBox.delete(id);
  }

  // Add a song to a playlist
  Future<void> addSongToPlaylist(String playlistId, String songId) async {
    final playlist = getPlaylist(playlistId);
    if (playlist != null) {
      final songIds = List<String>.from(playlist['songIds'] ?? []);
      if (!songIds.contains(songId)) {
        songIds.add(songId);
        await updatePlaylist(playlistId, playlist['name'], songIds);
      }
    }
  }

  // Remove a song from a playlist
  Future<void> removeSongFromPlaylist(String playlistId, String songId) async {
    final playlist = getPlaylist(playlistId);
    if (playlist != null) {
      final songIds = List<String>.from(playlist['songIds'] ?? []);
      songIds.remove(songId);
      await updatePlaylist(playlistId, playlist['name'], songIds);
    }
  }

  // Get playlist cover image (first song's album art or default)
  String getPlaylistCoverImage(String playlistId, List<Song> allSongs) {
    final playlist = getPlaylist(playlistId);
    if (playlist != null) {
      final songIds = List<String>.from(playlist['songIds'] ?? []);
      if (songIds.isNotEmpty) {
        final firstSong = allSongs.firstWhere(
          (song) => song.id == songIds.first,
          orElse: () => Song(
            id: '',
            title: '',
            artist: '',
            albumArt: 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=150',
            audioUrl: '',
            duration: Duration.zero,
          ),
        );
        return firstSong.albumArt;
      }
    }
    // Default cover image
    return 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=150';
  }

  // Get playlist song count
  int getPlaylistSongCount(String playlistId) {
    final playlist = getPlaylist(playlistId);
    if (playlist != null) {
      final songIds = List<String>.from(playlist['songIds'] ?? []);
      return songIds.length;
    }
    return 0;
  }

  // Update liked songs playlist when a song is liked/unliked
  Future<void> updateLikedSongsPlaylist(List<String> likedSongIds) async {
    // Find the liked songs playlist
    final playlists = getAllPlaylists();
    final likedPlaylist = playlists.firstWhere(
      (p) => p['name'] == 'Liked Songs',
      orElse: () => {'id': 'liked', 'name': 'Liked Songs', 'songIds': []},
    );
    
    await updatePlaylist(likedPlaylist['id'], 'Liked Songs', likedSongIds);
  }
} 