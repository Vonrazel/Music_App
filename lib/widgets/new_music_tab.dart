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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header with Upload Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'New Music',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: colorScheme.onSurface,
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
                icon: Icon(Icons.add, color: colorScheme.onPrimary),
                label: Text('Upload', style: TextStyle(color: colorScheme.onPrimary)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
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
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  Icons.sort,
                  color: colorScheme.onSurfaceVariant,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Sort by:',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
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
          color: isSelected ? colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? colorScheme.primary : colorScheme.outline.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: isSelected ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
} 