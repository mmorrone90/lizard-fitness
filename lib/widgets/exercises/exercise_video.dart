import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:lizard_fitness/theme/app_theme.dart';

/// Looping, muted exercise demo video. Tap to play/pause. Shows a placeholder
/// when no [url] is set.
class ExerciseVideo extends StatefulWidget {
  final String? url;
  const ExerciseVideo({super.key, required this.url});

  @override
  State<ExerciseVideo> createState() => _ExerciseVideoState();
}

class _ExerciseVideoState extends State<ExerciseVideo> {
  VideoPlayerController? _controller;
  bool _ready = false;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    final url = widget.url;
    if (url != null && url.isNotEmpty) {
      final c = VideoPlayerController.networkUrl(Uri.parse(url));
      _controller = c;
      c.initialize().then((_) {
        c.setLooping(true);
        c.setVolume(0); // muted by default — silent loop like gym apps
        c.play();
        if (mounted) setState(() => _ready = true);
      }).catchError((e, st) {
        debugPrint('[ExerciseVideo] init failed for $url: $e');
        if (mounted) setState(() => _error = true);
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasUrl = widget.url != null && widget.url!.isNotEmpty;

    Widget child;
    if (!hasUrl || _error) {
      child = _Placeholder(failed: _error);
    } else if (!_ready) {
      child = const Center(child: CircularProgressIndicator(color: kYellow));
    } else {
      final c = _controller!;
      child = GestureDetector(
        onTap: () => setState(() => c.value.isPlaying ? c.pause() : c.play()),
        child: Stack(
          alignment: Alignment.center,
          fit: StackFit.expand,
          children: [
            FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: c.value.size.width,
                height: c.value.size.height,
                child: VideoPlayer(c),
              ),
            ),
            if (!c.value.isPlaying)
              Container(
                decoration: const BoxDecoration(color: Colors.black38),
                child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 56),
              ),
            // mute toggle
            Positioned(
              right: 10,
              bottom: 10,
              child: GestureDetector(
                onTap: () => setState(() => c.setVolume(c.value.volume == 0 ? 1 : 0)),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                  child: Icon(c.value.volume == 0 ? Icons.volume_off : Icons.volume_up,
                      color: Colors.white, size: 18),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(color: kCard, child: child),
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  final bool failed;
  const _Placeholder({required this.failed});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(failed ? Icons.error_outline : Icons.videocam_off_outlined, color: kTextMuted, size: 40),
          const SizedBox(height: 8),
          Text(failed ? 'Video unavailable' : 'Demo video coming soon',
              style: const TextStyle(color: kTextMuted)),
        ],
      ),
    );
  }
}
