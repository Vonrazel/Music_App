import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'hive_service.dart';
import 'auth_service.dart';

class UserProfile {
  final String id;
  final String name;
  final String email;
  final String bio;
  final String profileImageUrl;
  final int followers;
  final int following;
  final int playlists;
  final int songs;
  final DateTime createdAt;
  final DateTime lastUpdated;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.bio,
    required this.profileImageUrl,
    required this.followers,
    required this.following,
    required this.playlists,
    required this.songs,
    required this.createdAt,
    required this.lastUpdated,
  });

  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? bio,
    String? profileImageUrl,
    int? followers,
    int? following,
    int? playlists,
    int? songs,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      bio: bio ?? this.bio,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      followers: followers ?? this.followers,
      following: following ?? this.following,
      playlists: playlists ?? this.playlists,
      songs: songs ?? this.songs,
      createdAt: createdAt,
      lastUpdated: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'bio': bio,
      'profileImageUrl': profileImageUrl,
      'followers': followers,
      'following': following,
      'playlists': playlists,
      'songs': songs,
      'createdAt': createdAt.toIso8601String(),
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      bio: json['bio'],
      profileImageUrl: json['profileImageUrl'],
      followers: json['followers'],
      following: json['following'],
      playlists: json['playlists'],
      songs: json['songs'],
      createdAt: DateTime.parse(json['createdAt']),
      lastUpdated: DateTime.parse(json['lastUpdated']),
    );
  }
}

class UserProfileService {
  static final UserProfileService _instance = UserProfileService._internal();
  factory UserProfileService() => _instance;
  UserProfileService._internal();

  final HiveService _hiveService = HiveService();
  AuthService? _authService;
  
  AuthService get _authServiceInstance {
    _authService ??= AuthService();
    return _authService!;
  }
  final ValueNotifier<UserProfile?> _profileNotifier = ValueNotifier<UserProfile?>(null);
  final ValueNotifier<String> _profileImageNotifier = ValueNotifier<String>('');

  // Default profile data
  static const String _defaultProfileId = 'user_001';
  static const String _defaultName = 'John Doe';
  static const String _defaultEmail = 'john.doe@example.com';
  static const String _defaultBio = 'Music lover and creator';
  static const String _defaultProfileImage = 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150';

  // Getters
  ValueNotifier<UserProfile?> get profileNotifier => _profileNotifier;
  ValueNotifier<String> get profileImageNotifier => _profileImageNotifier;
  UserProfile? get currentProfile => _profileNotifier.value;

  // Initialize the service
  Future<void> initialize() async {
    await _loadProfile();
  }

  // Refresh profile when user logs in (for new users)
  Future<void> refreshProfileForNewUser() async {
    final currentUser = _authServiceInstance.currentUser;
    if (currentUser != null) {
      // Check if current profile is the default one
      final currentProfile = _profileNotifier.value;
      if (currentProfile != null && currentProfile.name == _defaultName) {
        // Update profile with actual user data
        final updatedProfile = currentProfile.copyWith(
          id: currentUser.username,
          name: currentUser.username,
          email: '${currentUser.username}@example.com',
        );
        await _saveProfile(updatedProfile);
        _profileNotifier.value = updatedProfile;
      }
    }
  }

  // Load profile from Hive
  Future<void> _loadProfile() async {
    try {
      final profileData = _hiveService.box.get('userProfile');
      if (profileData != null) {
        final profile = UserProfile.fromJson(Map<String, dynamic>.from(profileData));
        _profileNotifier.value = profile;
        _profileImageNotifier.value = profile.profileImageUrl;
      } else {
        // Create profile based on authenticated user or default
        final currentUser = _authServiceInstance.currentUser;
        final profileName = currentUser?.username ?? _defaultName;
        final profileEmail = currentUser != null ? '${currentUser.username}@example.com' : _defaultEmail;
        
        final newProfile = UserProfile(
          id: currentUser?.username ?? _defaultProfileId,
          name: profileName,
          email: profileEmail,
          bio: _defaultBio,
          profileImageUrl: _defaultProfileImage,
          followers: 1200,
          following: 856,
          playlists: 12,
          songs: 0, // Will be updated dynamically
          createdAt: DateTime.now(),
          lastUpdated: DateTime.now(),
        );
        await _saveProfile(newProfile);
        _profileNotifier.value = newProfile;
        _profileImageNotifier.value = newProfile.profileImageUrl;
      }
    } catch (e) {
      print('Error loading profile: $e');
      // Create profile based on authenticated user or default on error
      final currentUser = _authServiceInstance.currentUser;
      final profileName = currentUser?.username ?? _defaultName;
      final profileEmail = currentUser != null ? '${currentUser.username}@example.com' : _defaultEmail;
      
      final newProfile = UserProfile(
        id: currentUser?.username ?? _defaultProfileId,
        name: profileName,
        email: profileEmail,
        bio: _defaultBio,
        profileImageUrl: _defaultProfileImage,
        followers: 1200,
        following: 856,
        playlists: 12,
        songs: 0,
        createdAt: DateTime.now(),
        lastUpdated: DateTime.now(),
      );
      await _saveProfile(newProfile);
      _profileNotifier.value = newProfile;
      _profileImageNotifier.value = newProfile.profileImageUrl;
    }
  }

  // Save profile to Hive
  Future<void> _saveProfile(UserProfile profile) async {
    try {
      await _hiveService.box.put('userProfile', profile.toJson());
    } catch (e) {
      print('Error saving profile: $e');
    }
  }

  // Update profile
  Future<void> updateProfile({
    String? name,
    String? email,
    String? bio,
    String? profileImageUrl,
  }) async {
    if (_profileNotifier.value == null) return;

    final updatedProfile = _profileNotifier.value!.copyWith(
      name: name,
      email: email,
      bio: bio,
      profileImageUrl: profileImageUrl,
    );

    await _saveProfile(updatedProfile);
    _profileNotifier.value = updatedProfile;
    if (profileImageUrl != null) {
      _profileImageNotifier.value = profileImageUrl;
    }
  }

  // Update songs count (called when user uploads music)
  Future<void> incrementSongsCount() async {
    if (_profileNotifier.value == null) return;

    final updatedProfile = _profileNotifier.value!.copyWith(
      songs: _profileNotifier.value!.songs + 1,
    );

    await _saveProfile(updatedProfile);
    _profileNotifier.value = updatedProfile;
  }

  // Update playlists count
  Future<void> updatePlaylistsCount(int count) async {
    if (_profileNotifier.value == null) return;

    final updatedProfile = _profileNotifier.value!.copyWith(
      playlists: count,
    );

    await _saveProfile(updatedProfile);
    _profileNotifier.value = updatedProfile;
  }

  // Follow/Unfollow functionality (mock for now)
  Future<void> toggleFollow(String userId) async {
    if (_profileNotifier.value == null) return;

    // Mock follow/unfollow logic
    final updatedProfile = _profileNotifier.value!.copyWith(
      following: _profileNotifier.value!.following + 1,
    );

    await _saveProfile(updatedProfile);
    _profileNotifier.value = updatedProfile;
  }

  // Pick and save profile image
  Future<String?> pickAndSaveProfileImage() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: true,
      );

      if (result == null || result.files.isEmpty) {
        return null;
      }

      final file = result.files.first;
      String imageUrl;

      if (kIsWeb) {
        // For web, convert to base64
        final base64 = base64Encode(file.bytes!);
        imageUrl = 'data:image/${file.extension};base64,$base64';
      } else {
        // For mobile, save to local storage
        final appDir = await getApplicationDocumentsDirectory();
        final profileDir = Directory('${appDir.path}/profile');
        if (!await profileDir.exists()) {
          await profileDir.create(recursive: true);
        }

        final fileName = 'profile_image_${DateTime.now().millisecondsSinceEpoch}.${file.extension}';
        final filePath = '${profileDir.path}/$fileName';
        final localFile = File(filePath);
        await localFile.writeAsBytes(file.bytes!);
        imageUrl = filePath;
      }

      // Update profile with new image
      await updateProfile(profileImageUrl: imageUrl);
      return imageUrl;
    } catch (e) {
      print('Error picking profile image: $e');
      return null;
    }
  }

  // Get profile image for display
  String getProfileImageUrl() {
    return _profileImageNotifier.value;
  }

  // Get current songs count
  int getCurrentSongsCount() {
    return _profileNotifier.value?.songs ?? 0;
  }

  // Get current playlists count
  int getCurrentPlaylistsCount() {
    return _profileNotifier.value?.playlists ?? 0;
  }

  // Get current followers count
  int getCurrentFollowersCount() {
    return _profileNotifier.value?.followers ?? 0;
  }

  // Get current following count
  int getCurrentFollowingCount() {
    return _profileNotifier.value?.following ?? 0;
  }

  // Dispose
  void dispose() {
    _profileNotifier.dispose();
    _profileImageNotifier.dispose();
  }
} 