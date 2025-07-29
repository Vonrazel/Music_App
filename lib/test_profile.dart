import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'services/user_profile_service.dart';

class TestProfileWidget extends StatefulWidget {
  const TestProfileWidget({super.key});

  @override
  State<TestProfileWidget> createState() => _TestProfileWidgetState();
}

class _TestProfileWidgetState extends State<TestProfileWidget> {
  final UserProfileService _userProfileService = UserProfileService();

  @override
  void initState() {
    super.initState();
    _initializeProfile();
  }

  Future<void> _initializeProfile() async {
    await _userProfileService.initialize();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('Profile Test', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF121212),
      ),
      body: ValueListenableBuilder<UserProfile?>(
        valueListenable: _userProfileService.profileNotifier,
        builder: (context, profile, child) {
          if (profile == null) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF1DB954)),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Image
                Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: _getProfileImageProvider(profile.profileImageUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Profile Info
                Text('Name: ${profile.name}', style: const TextStyle(color: Colors.white)),
                Text('Email: ${profile.email}', style: const TextStyle(color: Colors.white)),
                Text('Bio: ${profile.bio}', style: const TextStyle(color: Colors.white)),
                const SizedBox(height: 16),
                
                // Stats
                Text('Songs: ${profile.songs}', style: const TextStyle(color: Colors.white)),
                Text('Followers: ${profile.followers}', style: const TextStyle(color: Colors.white)),
                Text('Following: ${profile.following}', style: const TextStyle(color: Colors.white)),
                Text('Playlists: ${profile.playlists}', style: const TextStyle(color: Colors.white)),
                const SizedBox(height: 24),
                
                // Test Buttons
                ElevatedButton(
                  onPressed: () async {
                    await _userProfileService.incrementSongsCount();
                  },
                  child: const Text('Increment Songs'),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () async {
                    await _userProfileService.pickAndSaveProfileImage();
                  },
                  child: const Text('Change Profile Image'),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () async {
                    await _userProfileService.updateProfile(
                      name: 'Updated Name ${DateTime.now().millisecondsSinceEpoch}',
                      bio: 'Updated bio ${DateTime.now().millisecondsSinceEpoch}',
                    );
                  },
                  child: const Text('Update Profile'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  ImageProvider _getProfileImageProvider(String imageUrl) {
    if (imageUrl.startsWith('data:image/')) {
      // Base64 image for web
      return MemoryImage(base64Decode(imageUrl.split(',')[1]));
    } else if (imageUrl.startsWith('http')) {
      // Network image
      return NetworkImage(imageUrl);
    } else {
      // Local file
      return FileImage(File(imageUrl));
    }
  }
} 