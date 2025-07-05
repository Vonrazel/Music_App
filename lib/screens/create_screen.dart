import 'package:flutter/material.dart';
import '../services/upload_service.dart';
import '../services/music_service.dart';

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
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              backgroundColor: const Color(0xFF121212),
              pinned: true,
              title: const Text(
                'Create',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.help_outline, color: Colors.white),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Upload Music',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1DB954), Color(0xFF1ed760)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              const Icon(
                Icons.cloud_upload,
                color: Colors.white,
                size: 48,
              ),
              const SizedBox(height: 16),
              const Text(
                'Upload Your Music',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Share your tracks with the world',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              if (_isUploading) ...[
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Uploading...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ] else ...[
                ElevatedButton(
                  onPressed: _handleFileUpload,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF1DB954),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    'Choose Files',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Supported formats: ${_uploadService.getSupportedFormatsString()}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Record Music',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF282828),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white24),
          ),
          child: Column(
            children: [
              // Recording Visualizer
              Container(
                height: 80,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.black26,
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
                                color: const Color(0xFF1DB954),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            );
                          }),
                        )
                      : const Icon(
                          Icons.mic,
                          color: Colors.white70,
                          size: 32,
                        ),
                ),
              ),
              const SizedBox(height: 20),
              
              // Recording Progress
              if (_isRecording) ...[
                LinearProgressIndicator(
                  value: _recordingProgress,
                  backgroundColor: Colors.white24,
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF1DB954)),
                ),
                const SizedBox(height: 8),
                Text(
                  'Recording... ${(_recordingProgress * 100).toInt()}%',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
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
                    color: _isRecording ? Colors.red : const Color(0xFF1DB954),
                    boxShadow: [
                      BoxShadow(
                        color: (_isRecording ? Colors.red : const Color(0xFF1DB954)).withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Icon(
                    _isRecording ? Icons.stop : Icons.mic,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _isRecording ? 'Tap to Stop' : 'Tap to Record',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecentCreationsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Creations',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
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
    final titles = ['My Song #1', 'Recorded Track', 'Uploaded Music'];
    final types = ['Uploaded', 'Recorded', 'Uploaded'];
    final dates = ['2 hours ago', 'Yesterday', '3 days ago'];
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF282828),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: types[index] == 'Recorded' ? Colors.red.withOpacity(0.2) : const Color(0xFF1DB954).withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              types[index] == 'Recorded' ? Icons.mic : Icons.music_note,
              color: types[index] == 'Recorded' ? Colors.red : const Color(0xFF1DB954),
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
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  types[index],
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  dates[index],
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          
          // Actions
          IconButton(
            icon: const Icon(Icons.play_arrow, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white70),
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