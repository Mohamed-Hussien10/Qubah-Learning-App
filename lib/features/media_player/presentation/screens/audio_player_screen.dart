import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/helpers.dart';

class AudioPlayerScreen extends StatefulWidget {
  final String audioUrl;
  final String title;
  final String? coverImageUrl;

  const AudioPlayerScreen({
    super.key,
    required this.audioUrl,
    required this.title,
    this.coverImageUrl,
  });

  @override
  State<AudioPlayerScreen> createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends State<AudioPlayerScreen> {
  late AudioPlayer _player;
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _init();
  }

  Future<void> _init() async {
    try {
      await _player.setUrl(widget.audioUrl);
      _player.durationStream.listen(
        (d) => setState(() => _duration = d ?? Duration.zero),
      );
      _player.positionStream.listen((p) => setState(() => _position = p));
      _player.playerStateStream.listen((state) {
        setState(() => _isPlaying = state.playing);
      });
      _player.play();
    } catch (e) {
      // Handle error
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'درس صوتي',
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Album art
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.music_note_rounded,
                size: 80,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              widget.title,
              style: GoogleFonts.cairo(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            // Progress bar
            Slider(
              min: 0,
              max: _duration.inSeconds.toDouble(),
              value: _position.inSeconds.toDouble().clamp(
                0,
                _duration.inSeconds.toDouble(),
              ),
              onChanged: (value) {
                _player.seek(Duration(seconds: value.toInt()));
              },
              activeColor: AppColors.primary,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(AppHelpers.formatDuration(_position)),
                  Text(AppHelpers.formatDuration(_duration)),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.replay_10_rounded, size: 36),
                  onPressed: () =>
                      _player.seek(_position - const Duration(seconds: 10)),
                ),
                const SizedBox(width: 16),
                CircleAvatar(
                  radius: 36,
                  backgroundColor: AppColors.primary,
                  child: IconButton(
                    icon: Icon(
                      _isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      size: 36,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      if (_isPlaying) {
                        _player.pause();
                      } else {
                        _player.play();
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.forward_10_rounded, size: 36),
                  onPressed: () =>
                      _player.seek(_position + const Duration(seconds: 10)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
