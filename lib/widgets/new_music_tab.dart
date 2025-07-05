import 'package:flutter/material.dart';
import '../services/music_service.dart';
import '../screens/create_screen.dart';
import 'uploaded_songs_section.dart';

class NewMusicTab extends StatefulWidget {
  final MusicService musicService;

  const NewMusicTab({
    super.key,
    required this.musicService,
  });

  @override
  State<NewMusicTab> createState() => _NewMusicTabState();
}

class _NewMusicTabState extends State<NewMusicTab> {
  String _sortBy = 'uploadDate'; // 'uploadDate' or 'fileName'

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header with Upload Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'New Music',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  // Navigate to Create tab
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const CreateScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('Upload'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1DB954),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Filter/Sort Options
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF282828),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.sort,
                  color: Colors.white70,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Sort by:',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 12),
                _buildSortChip('Upload Date', 'uploadDate'),
                const SizedBox(width: 8),
                _buildSortChip('File Name', 'fileName'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Uploaded Songs Section
          UploadedSongsSection(
            musicService: widget.musicService,
            sortBy: _sortBy,
          ),
        ],
      ),
    );
  }

  Widget _buildSortChip(String label, String value) {
    final isSelected = _sortBy == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _sortBy = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1DB954) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF1DB954) : Colors.white30,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
} 