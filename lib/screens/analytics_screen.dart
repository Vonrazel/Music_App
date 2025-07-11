import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/music_service.dart';
import '../providers/theme_provider.dart';
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        backgroundColor: colorScheme.background,
        elevation: 0,
        title: Text('Your Music Analytics', style: TextStyle(color: colorScheme.onSurface)),
        centerTitle: true,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
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
                  // Stat Cards Row - Now Responsive
                  LayoutBuilder(
                    builder: (context, constraints) {
                      // Determine if we should use single row or wrap based on screen width
                      final isTablet = constraints.maxWidth > 600;
                      final cardWidth = isTablet ? (constraints.maxWidth - 60) / 4 : 150.0;
                      
                      return Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        alignment: WrapAlignment.start,
                        children: [
                          SizedBox(
                            width: cardWidth,
                            child: _StatCard(
                              title: 'Total Tracks Played',
                              value: '${_musicService.totalTracksPlayed}',
                              icon: Icons.music_note,
                              color: const Color(0xFF1DB954),
                            ),
                          ),
                          // Real-time Listening Time Card
                          SizedBox(
                            width: cardWidth,
                            child: StreamBuilder<Duration>(
                              stream: _musicService.listeningTimeStream,
                              builder: (context, snapshot) {
                                final currentListeningTime = _musicService.getCurrentListeningTime();
                                return _StatCard(
                                  title: 'Listening Time',
                                  value: _formatDuration(currentListeningTime),
                                  icon: Icons.timer,
                                  color: const Color(0xFF1ed760),
                                );
                              },
                            ),
                          ),
                          SizedBox(
                            width: cardWidth,
                            child: _StatCard(
                              title: 'Avg/Day',
                              value: _formatDuration(_musicService.getAvgListeningTimePerDay()),
                              icon: Icons.calendar_today,
                              color: const Color(0xFF1DB954),
                            ),
                          ),
                          SizedBox(
                            width: cardWidth,
                            child: _StatCard(
                              title: 'Streak',
                              value: '${_musicService.getStreak()} days',
                              icon: Icons.local_fire_department,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 28),
                  // Mood/Genre Placeholder (now full width)
                  Container(
                    width: double.infinity,
                    height: 120,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.shadow.withValues(alpha: 0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        'Mood/Genre Stats\n(Coming Soon)',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
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
                  // Real-time Total Listening Time Card
                  StreamBuilder<Duration>(
                    stream: _musicService.listeningTimeStream,
                    builder: (context, snapshot) {
                      final currentListeningTime = _musicService.getCurrentListeningTime();
                      return Card(
                        color: colorScheme.surface,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          leading: Icon(Icons.timer, color: colorScheme.primary, size: 40),
                          title: Text('Total Listening Time', style: theme.textTheme.titleMedium?.copyWith(color: colorScheme.onSurface)),
                          subtitle: Text(
                            _formatDuration(currentListeningTime), 
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          trailing: _musicService.isPlaying 
                            ? Icon(Icons.play_circle_filled, color: Colors.green, size: 24)
                            : null,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  // Number of Liked Songs
                  Card(
                    color: colorScheme.surface,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      leading: Icon(Icons.favorite, color: colorScheme.primary, size: 40),
                      title: Text('Liked Songs', style: theme.textTheme.titleMedium?.copyWith(color: colorScheme.onSurface)),
                      subtitle: Text('${_musicService.likedSongsCount}', style: theme.textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Favorite Genre (Optional)
                  if (_musicService.favoriteGenre != null)
                    Card(
                      color: colorScheme.surface,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: Icon(Icons.category, color: colorScheme.primary, size: 40),
                        title: Text('Favorite Genre', style: theme.textTheme.titleMedium?.copyWith(color: colorScheme.onSurface)),
                        subtitle: Text(_musicService.favoriteGenre!, style: theme.textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant)),
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
    
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Card(
      color: colorScheme.primary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: mostPlayed != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(mostPlayed.albumArt, width: 50, height: 50, fit: BoxFit.cover),
              )
            : Icon(Icons.music_note, color: colorScheme.onPrimary, size: 40),
        title: Text(
          mostPlayed?.title ?? 'No data',
          style: theme.textTheme.titleMedium?.copyWith(
            color: colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          mostPlayed != null ? mostPlayed.artist : '',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onPrimary.withValues(alpha: 0.8),
          ),
        ),
        trailing: Text('Most Played', style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onPrimary)),
      ),
    );
  }

  Widget _buildRecentlyPlayedSection() {
    final recentlyPlayed = _musicService.recentlyPlayedSongs;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Recently Played', style: theme.textTheme.titleMedium?.copyWith(color: colorScheme.onSurface, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        if (recentlyPlayed.isEmpty)
          Text('No recently played songs.', style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
        ...recentlyPlayed.take(10).map((song) => ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.network(song.albumArt, width: 40, height: 40, fit: BoxFit.cover),
              ),
              title: Text(song.title, style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface)),
              subtitle: Text(song.artist, style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.08),
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
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: theme.textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
} 