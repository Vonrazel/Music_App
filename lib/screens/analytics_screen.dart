import 'package:flutter/material.dart';
import '../services/music_service.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({Key? key}) : super(key: key);

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final MusicService _musicService = MusicService();

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60);
    return '${twoDigits(hours)}:${twoDigits(minutes)}:${twoDigits(seconds)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        title: const Text('Your Music Analytics', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ValueListenableBuilder(
        valueListenable: _musicService.hiveService.box.listenable(),
        builder: (context, Box box, _) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stat Cards Row
                  SizedBox(
                    height: 110,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _StatCard(
                          title: 'Total Tracks Played',
                          value: '${_musicService.totalTracksPlayed}',
                          icon: Icons.music_note,
                          color: const Color(0xFF1DB954),
                        ),
                        const SizedBox(width: 12),
                        _StatCard(
                          title: 'Listening Time',
                          value: _formatDuration(_musicService.totalListeningTime),
                          icon: Icons.timer,
                          color: const Color(0xFF1ed760),
                        ),
                        const SizedBox(width: 12),
                        _StatCard(
                          title: 'Avg/Day',
                          value: _formatDuration(_musicService.getAvgListeningTimePerDay()),
                          icon: Icons.calendar_today,
                          color: const Color(0xFF1DB954),
                        ),
                        const SizedBox(width: 12),
                        _StatCard(
                          title: 'Streak',
                          value: '${_musicService.getStreak()} days',
                          icon: Icons.local_fire_department,
                          color: Colors.orange,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  // Mood/Genre Placeholder (now full width)
                  Container(
                    width: double.infinity,
                    height: 120,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF282828),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(
                      child: Text(
                        'Mood/Genre Stats\n(Coming Soon)',
                        style: TextStyle(color: Colors.white54, fontSize: 15),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Most Played Song
                  _buildMostPlayedCard(),
                  const SizedBox(height: 24),
                  // Recently Played
                  _buildRecentlyPlayedSection(),
                  const SizedBox(height: 24),
                  // Total Listening Time
                  Card(
                    color: const Color(0xFF282828),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      leading: const Icon(Icons.timer, color: Color(0xFF1DB954), size: 40),
                      title: const Text('Total Listening Time', style: TextStyle(color: Colors.white)),
                      subtitle: Text(_formatDuration(_musicService.totalListeningTime), style: const TextStyle(color: Colors.white70, fontSize: 18)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Number of Liked Songs
                  Card(
                    color: const Color(0xFF282828),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      leading: const Icon(Icons.favorite, color: Color(0xFF1DB954), size: 40),
                      title: const Text('Liked Songs', style: TextStyle(color: Colors.white)),
                      subtitle: Text('${_musicService.likedSongsCount}', style: const TextStyle(color: Colors.white70, fontSize: 18)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Favorite Genre (Optional)
                  if (_musicService.favoriteGenre != null)
                    Card(
                      color: const Color(0xFF282828),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: const Icon(Icons.category, color: Color(0xFF1DB954), size: 40),
                        title: const Text('Favorite Genre', style: TextStyle(color: Colors.white)),
                        subtitle: Text(_musicService.favoriteGenre!, style: const TextStyle(color: Colors.white70, fontSize: 18)),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMostPlayedCard() {
    final mostPlayed = _musicService.mostPlayedSong;
    
    return Card(
      color: const Color(0xFF1DB954),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: mostPlayed != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(mostPlayed.albumArt, width: 50, height: 50, fit: BoxFit.cover),
              )
            : const Icon(Icons.music_note, color: Colors.white, size: 40),
        title: Text(
          mostPlayed?.title ?? 'No data',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          mostPlayed != null ? mostPlayed.artist : '',
          style: const TextStyle(color: Colors.white70),
        ),
        trailing: const Text('Most Played', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildRecentlyPlayedSection() {
    final recentlyPlayed = _musicService.recentlyPlayedSongs;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Recently Played', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        if (recentlyPlayed.isEmpty)
          const Text('No recently played songs.', style: TextStyle(color: Colors.white70)),
        ...recentlyPlayed.take(10).map((song) => ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.network(song.albumArt, width: 40, height: 40, fit: BoxFit.cover),
              ),
              title: Text(song.title, style: const TextStyle(color: Colors.white)),
              subtitle: Text(song.artist, style: const TextStyle(color: Colors.white70)),
            )),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF282828),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
} 