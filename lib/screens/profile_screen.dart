import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import '../services/user_profile_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isEditing = false;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final UserProfileService _userProfileService = UserProfileService();

  @override
  void initState() {
    super.initState();
    _initializeProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _initializeProfile() async {
    await _userProfileService.initialize();
    final profile = _userProfileService.currentProfile;
    if (profile != null) {
      _nameController.text = profile.name;
      _bioController.text = profile.bio;
      _emailController.text = profile.email;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: ValueListenableBuilder<UserProfile?>(
        valueListenable: _userProfileService.profileNotifier,
        builder: (context, profile, child) {
          return CustomScrollView(
            slivers: [
              // App Bar
              SliverAppBar(
                backgroundColor: const Color(0xFF121212),
                expandedHeight: 200,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF1DB954), Color(0xFF1ed760)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: SafeArea(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Profile Picture
                          GestureDetector(
                            onTap: () {
                              // Handle profile picture change
                              _showImagePickerDialog();
                            },
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                  image: _getProfileImageProvider(profile?.profileImageUrl ?? ''),
                                  fit: BoxFit.cover,
                                ),
                                border: Border.all(color: Colors.white, width: 3),
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.black.withValues(alpha: 0.3),
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 30,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            profile?.name ?? 'John Doe',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                actions: [
                  IconButton(
                    icon: Icon(
                      _isEditing ? Icons.check : Icons.edit,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      if (_isEditing) {
                        // Save changes
                        _saveProfileChanges();
                      }
                      setState(() {
                        _isEditing = !_isEditing;
                      });
                    },
                  ),
                ],
              ),
          
          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats Section
                  _buildStatsSection(profile),
                  const SizedBox(height: 24),
                  
                  // Profile Info Section
                  _buildProfileInfoSection(),
                  const SizedBox(height: 24),
                  
                  // Settings Section
                  _buildSettingsSection(),
                  const SizedBox(height: 24),
                  
                  // Account Actions
                  _buildAccountActions(),
                ],
              ),
            ),
          ),
        ],
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

  Future<void> _saveProfileChanges() async {
    await _userProfileService.updateProfile(
      name: _nameController.text,
      email: _emailController.text,
      bio: _bioController.text,
    );
  }

  Widget _buildStatsSection(UserProfile? profile) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF282828),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Playlists', '${profile?.playlists ?? 0}'),
          _buildStatItem('Followers', '${profile?.followers ?? 0}'),
          _buildStatItem('Following', '${profile?.following ?? 0}'),
          _buildStatItem('Songs', '${profile?.songs ?? 0}'),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Profile Information',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF282828),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              _buildInfoField(
                'Name',
                _nameController,
                Icons.person,
              ),
              const SizedBox(height: 16),
              _buildInfoField(
                'Bio',
                _bioController,
                Icons.info,
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              _buildInfoField(
                'Email',
                _emailController,
                Icons.email,
                enabled: _isEditing,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoField(
    String label,
    TextEditingController controller,
    IconData icon, {
    int maxLines = 1,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          enabled: enabled && _isEditing,
          maxLines: maxLines,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.white70),
            filled: true,
            fillColor: enabled ? const Color(0xFF404040) : const Color(0xFF202020),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Settings',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF282828),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              _buildSettingTile(
                'Notifications',
                Icons.notifications,
                onTap: () {},
              ),
              _buildDivider(),
              _buildSettingTile(
                'Privacy',
                Icons.privacy_tip,
                onTap: () {},
              ),
              _buildDivider(),
              _buildSettingTile(
                'Theme',
                Icons.palette,
                onTap: () {},
              ),
              _buildDivider(),
              _buildSettingTile(
                'Language',
                Icons.language,
                onTap: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingTile(String title, IconData icon, {required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 16),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return const Divider(
      color: Colors.white12,
      height: 1,
      indent: 56,
    );
  }

  Widget _buildAccountActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Account',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF282828),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              _buildSettingTile(
                'Help & Support',
                Icons.help,
                onTap: () {},
              ),
              _buildDivider(),
              _buildSettingTile(
                'About',
                Icons.info,
                onTap: () {},
              ),
              _buildDivider(),
              _buildSettingTile(
                'Logout',
                Icons.logout,
                onTap: () {
                  _showLogoutDialog();
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showImagePickerDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF282828),
        title: const Text(
          'Change Profile Picture',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Choose how you want to update your profile picture',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _pickProfileImage();
            },
            child: const Text('Gallery', style: TextStyle(color: Color(0xFF1DB954))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
        ],
      ),
    );
  }

  Future<void> _pickProfileImage() async {
    final imageUrl = await _userProfileService.pickAndSaveProfileImage();
    if (imageUrl != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile picture updated successfully!'),
          backgroundColor: Color(0xFF1DB954),
        ),
      );
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF282828),
        title: const Text(
          'Logout',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Handle logout
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
} 