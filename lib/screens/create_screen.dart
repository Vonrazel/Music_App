import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/upload_service.dart';
import '../services/music_service.dart';
import '../providers/theme_provider.dart';

class CreateScreen extends StatefulWidget {
  const CreateScreen({super.key});

  @override
  State<CreateScreen> createState() => _CreateScreenState();
}

class _CreateScreenState extends State<CreateScreen> {
  bool _isRecording = false;
  double _recordingProgress = 0.0;
  bool _isUploading = false;
  final UploadService _uploadService = UploadService();
  final MusicService _musicService = MusicService();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      backgroundColor: colorScheme.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              backgroundColor: colorScheme.background,
              pinned: true,
              title: Text(
                'Create',
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.help_outline, color: colorScheme.onSurface),
                  onPressed: () {},
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
                    // Upload Section
                    _buildUploadSection(),
                    const SizedBox(height: 32),
                    
                    // Record Section
                    _buildRecordSection(),
                    const SizedBox(height: 32),
                    
                    // Recent Creations
                    _buildRecentCreationsSection(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadSection() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Upload Music',
          style: theme.textTheme.titleMedium?.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [colorScheme.primary, colorScheme.primary.withValues(alpha: 0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.cloud_upload,
                  color: colorScheme.onPrimary,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  'Upload Your Music',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Share your tracks with the world',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onPrimary.withValues(alpha: 0.8),
                  ),
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 20),
                              if (_isUploading) ...[
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(colorScheme.onPrimary),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Uploading...',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ] else ...[
                  ElevatedButton(
                    onPressed: _handleFileUpload,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.surface,
                      foregroundColor: theme.brightness == Brightness.dark
                          ? Colors.black
                          : Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: Text(
                      'Choose Files',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Supported formats: ${_uploadService.getSupportedFormatsString()}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onPrimary.withValues(alpha: 0.8),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecordSection() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Record Music',
          style: theme.textTheme.titleMedium?.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colorScheme.outline),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Recording Visualizer
              Container(
                height: 80,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceVariant.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: _isRecording
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(20, (index) {
                            return Container(
                              width: 3,
                              height: 20 + (index % 3) * 10.0,
                              margin: const EdgeInsets.symmetric(horizontal: 1),
                              decoration: BoxDecoration(
                                color: colorScheme.primary,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            );
                          }),
                        )
                                              : Icon(
                            Icons.mic,
                            color: colorScheme.onSurfaceVariant,
                            size: 32,
                          ),
                ),
              ),
              const SizedBox(height: 20),
              
              // Recording Progress
              if (_isRecording) ...[
                LinearProgressIndicator(
                  value: _recordingProgress,
                  backgroundColor: colorScheme.surfaceVariant.withValues(alpha: 0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                ),
                const SizedBox(height: 8),
                Text(
                  'Recording... ${(_recordingProgress * 100).toInt()}%',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
              ],
              
              // Record Button
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isRecording = !_isRecording;
                    if (_isRecording) {
                      _startRecording();
                    } else {
                      _stopRecording();
                    }
                  });
                },
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isRecording ? Colors.red : colorScheme.primary,
                    boxShadow: [
                      BoxShadow(
                        color: (_isRecording ? Colors.red : colorScheme.primary).withValues(alpha: 0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Icon(
                    _isRecording ? Icons.stop : Icons.mic,
                    color: colorScheme.onPrimary,
                    size: 32,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _isRecording ? 'Tap to Stop' : 'Tap to Record',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecentCreationsSection() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Creations',
          style: theme.textTheme.titleLarge?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 3,
          itemBuilder: (context, index) {
            return _buildCreationTile(index);
          },
        ),
      ],
    );
  }

  Widget _buildCreationTile(int index) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final titles = ['My Song #1', 'Recorded Track', 'Uploaded Music'];
    final types = ['Uploaded', 'Recorded', 'Uploaded'];
    final dates = ['2 hours ago', 'Yesterday', '3 days ago'];
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
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
          // Icon
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: types[index] == 'Recorded' ? Colors.red.withValues(alpha: 0.2) : colorScheme.primary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              types[index] == 'Recorded' ? Icons.mic : Icons.music_note,
              color: types[index] == 'Recorded' ? Colors.red : colorScheme.primary,
            ),
          ),
          const SizedBox(width: 16),
          
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titles[index],
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  types[index],
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  dates[index],
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          
          // Actions
          IconButton(
            icon: Icon(Icons.play_arrow, color: colorScheme.onSurface),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.more_vert, color: colorScheme.onSurfaceVariant),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  void _startRecording() {
    // Simulate recording progress
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_isRecording && mounted) {
        setState(() {
          _recordingProgress += 0.01;
          if (_recordingProgress < 1.0) {
            _startRecording();
          }
        });
      }
    });
  }

  void _stopRecording() {
    setState(() {
      _recordingProgress = 0.0;
    });
  }

  // Handle file upload
  Future<void> _handleFileUpload() async {
    setState(() {
      _isUploading = true;
    });

    try {
      final song = await _uploadService.uploadAudioFile();
      
      if (song != null) {
        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Successfully uploaded: ${song.title}'),
              backgroundColor: const Color(0xFF1DB954),
              duration: const Duration(seconds: 3),
            ),
          );
        }
        
        // Add to music service
        _musicService.addUploadedSong(song);
        
        print('Successfully uploaded song: ${song.title}');
      }
    } catch (e) {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Upload failed: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
      print('Upload error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }
} 