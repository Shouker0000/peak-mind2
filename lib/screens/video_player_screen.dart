import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../models/course_model.dart';
import '../utils/theme.dart';

class VideoPlayerScreen extends StatefulWidget {
  final CourseModel course;

  const VideoPlayerScreen({
    Key? key,
    required this.course,
  }) : super(key: key);

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late YoutubePlayerController _controller;
  late PlayerState _playerState;
  late YoutubeMetaData _videoMetaData;

  @override
  void initState() {
    super.initState();
    // Extract video ID from URL
    String videoId = _extractVideoId(widget.course.videoUrl);

    _controller = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        enableCaption: true,
      ),
    );
    _playerState = PlayerState.unknown;
    _videoMetaData = const YoutubeMetaData();
  }

  String _extractVideoId(String url) {
    // If it's already a video ID, return it
    if (!url.contains('http') && url.length == 11) {
      return url;
    }
    // Extract from full YouTube URL
    if (url.contains('youtube.com')) {
      return url.split('v=')[1].split('&')[0];
    }
    if (url.contains('youtu.be')) {
      return url.split('youtu.be/')[1].split('?')[0];
    }
    return url;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.course.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // YouTube Player
            YoutubePlayer(
              controller: _controller,
              showVideoProgressIndicator: true,
              progressIndicatorColor: AppTheme.primaryColor,
              onReady: () {
                // Player is ready
              },
              onEnded: (metaData) {
                // Video ended
              },
            ),
            // Course Info
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.course.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'by ${widget.course.instructor}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.lightTextColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.backgroundColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  size: 16,
                                  color: Colors.amber,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  widget.course.rating.toStringAsFixed(1),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                const Icon(
                                  Icons.people,
                                  size: 16,
                                  color: AppTheme.lightTextColor,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${widget.course.totalStudents} students',
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                const Icon(
                                  Icons.schedule,
                                  size: 16,
                                  color: AppTheme.lightTextColor,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${widget.course.duration} min',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Description',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.course.description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.lightTextColor,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
