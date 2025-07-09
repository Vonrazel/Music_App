import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'music_service.dart';
import 'hive_service.dart';
import 'user_profile_service.dart';
import 'upload_web.dart'
    if (dart.library.html) 'upload_web.dart'
    if (dart.library.io) 'upload_stub.dart';

class UploadService {
  static final UploadService _instance = UploadService._internal();
  factory UploadService() => _instance;
  UploadService._internal();

  final HiveService _hiveService = HiveService();
  final MusicService _musicService = MusicService();
  final UserProfileService _userProfileService = UserProfileService();

  // Supported audio formats
  static const List<String> _supportedFormats = ['mp3', 'wav', 'aac', 'm4a'];

  // Check if file format is supported
  bool isSupportedFormat(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    return _supportedFormats.contains(extension);
  }

  // Pick and upload audio file
  Future<Song?> uploadAudioFile() async {
    try {
      // Pick file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: false,
        withData: true,
      );

      if (result == null || result.files.isEmpty) {
        return null;
      }

      final file = result.files.first;
      
      // Validate file format
      if (!isSupportedFormat(file.name)) {
        throw Exception('Unsupported file format. Please select an MP3, WAV, or AAC file.');
      }

      // Create song from file
      final song = await _createSongFromFile(file);
      
      // Add to music service
      await _addSongToMusicService(song);
      
      // Increment user's songs count
      await _userProfileService.incrementSongsCount();
      
      return song;
    } catch (e) {
      print('Error uploading audio file: $e');
      rethrow;
    }
  }

  // Create song from uploaded file
  Future<Song> _createSongFromFile(PlatformFile file) async {
    try {
      // Generate unique ID
      final songId = _generateUniqueId();
      
      // Extract title from filename (remove extension)
      final title = file.name.replaceAll(RegExp(r'\.[^.]*$'), '');
      
      // Default artist name
      const artist = 'Unknown Artist';
      
      // Default album art
      const albumArt = 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=150';
      
      // Handle file storage based on platform
      String audioUrl;
      if (kIsWeb) {
        // For web, create a blob URL from the file data
        audioUrl = _createWebBlobUrl(file.bytes!);
      } else {
        // For mobile, save to local storage
        final appDir = await getApplicationDocumentsDirectory();
        final uploadsDir = Directory('${appDir.path}/uploads');
        if (!await uploadsDir.exists()) {
          await uploadsDir.create(recursive: true);
        }
        
        final filePath = '${uploadsDir.path}/${file.name}';
        final localFile = File(filePath);
        await localFile.writeAsBytes(file.bytes!);
        audioUrl = filePath;
      }
      
      // Create song object
      final song = Song(
        id: songId,
        title: title,
        artist: artist,
        albumArt: albumArt,
        audioUrl: audioUrl,
        duration: Duration.zero, // Will be updated when loaded
        isLiked: false,
      );
      
      return song;
    } catch (e) {
      print('Error creating song from file: $e');
      rethrow;
    }
  }

  // Helper for web blob URL creation
  String _createWebBlobUrl(List<int> bytes) {
    // Use the conditional import function
    return createWebBlobUrl(bytes);
  }

  // Add song to music service
  Future<void> _addSongToMusicService(Song song) async {
    try {
      // Add to music service's song list
      _musicService.addUploadedSong(song);
      
      // Save to Hive for persistence
      await _saveUploadedSongToHive(song);
      
      // Notify music service to refresh streams
      _musicService.refreshSongsList();
      
      print('Successfully added uploaded song: ${song.title}');
    } catch (e) {
      print('Error adding song to music service: $e');
      rethrow;
    }
  }

  // Save uploaded song to Hive
  Future<void> _saveUploadedSongToHive(Song song) async {
    try {
      final uploadedSongs = _getUploadedSongsFromHive();
      uploadedSongs.add({
        'id': song.id,
        'title': song.title,
        'artist': song.artist,
        'albumArt': song.albumArt,
        'audioUrl': song.audioUrl,
        'duration': song.duration.inSeconds,
        'isLiked': song.isLiked,
        'uploadedAt': DateTime.now().toIso8601String(),
      });
      
      await _hiveService.box.put('uploadedSongs', uploadedSongs);
      print('Saved uploaded song to Hive: ${song.title}');
    } catch (e) {
      print('Error saving uploaded song to Hive: $e');
      rethrow;
    }
  }

  // Get uploaded songs from Hive
  List<Map<String, dynamic>> _getUploadedSongsFromHive() {
    try {
      final data = _hiveService.box.get('uploadedSongs', defaultValue: []);
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      print('Error getting uploaded songs from Hive: $e');
      return [];
    }
  }

  // Load uploaded songs from Hive
  List<Song> loadUploadedSongs() {
    try {
      final uploadedSongsData = _getUploadedSongsFromHive();
      return uploadedSongsData.map((data) => Song(
        id: data['id'],
        title: data['title'],
        artist: data['artist'],
        albumArt: data['albumArt'],
        audioUrl: data['audioUrl'],
        duration: Duration(seconds: data['duration'] ?? 0),
        isLiked: data['isLiked'] ?? false,
      )).toList();
    } catch (e) {
      print('Error loading uploaded songs: $e');
      return [];
    }
  }

  // Generate unique ID for uploaded songs
  String _generateUniqueId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (timestamp % 10000).toString().padLeft(4, '0');
    return 'uploaded_$timestamp$random';
  }

  // Get supported formats string for UI
  String getSupportedFormatsString() {
    return _supportedFormats.map((f) => f.toUpperCase()).join(', ');
  }

  void saveAudio(List<int> bytes) {
    saveToWebBlob(bytes);
  }
} 