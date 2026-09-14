import 'package:qubah_learning_app/core/widgets/hover_scale.dart';
import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../core/security/protected_lesson_scaffold.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;
  final String title;

  const VideoPlayerScreen({
    super.key,
    required this.videoUrl,
    required this.title,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      final resolvedUrl = AppHelpers.resolveMediaUrl(widget.videoUrl);
      _videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(Uri.encodeFull(Uri.decodeFull(resolvedUrl))),
      );
      await _videoPlayerController.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController,
        autoPlay: true,
        looping: false,
        materialProgressColors: ChewieProgressColors(
          playedColor: AppColors.primary,
          handleColor: AppColors.primary,
          backgroundColor: Colors.grey.withValues(alpha: 0.5),
          bufferedColor: Colors.white.withValues(alpha: 0.3),
        ),
        placeholder: Container(color: Colors.black),
        autoInitialize: true,
      );
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      debugPrint('Video Error: $e');
      if (mounted) {
        setState(() => _hasError = true);
      }
    }
  }

  void _onCaptureStateChanged(bool isCaptured) {
    if (isCaptured) {
      _chewieController?.pause();
      _videoPlayerController.pause();
    }
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ProtectedLessonScaffold(
      backgroundColor: Colors.black,
      onCaptureStateChanged: _onCaptureStateChanged,
      appBar: AppBar(
        leading: HoverScale(
          child: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              } else {
                Navigator.of(context).pushReplacementNamed('/home');
              }
            },
          ),
        ),
        backgroundColor: Colors.black,
        title: Text(
          widget.title,
          style: GoogleFonts.inter(color: Colors.white, fontSize: 16),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      child: Center(
        child: _hasError
            ? const Text(
                'Error loading video',
                style: TextStyle(color: Colors.white),
              )
            : _chewieController != null &&
                    _chewieController!.videoPlayerController.value.isInitialized
                ? Chewie(controller: _chewieController!)
                : const CircularProgressIndicator(color: AppColors.primary),
      ),
    );
  }
}
