import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/lesson_model.dart';

class LessonPlayerScreen extends StatefulWidget {
  final LessonModel lesson;

  const LessonPlayerScreen({
    Key? key,
    required this.lesson,
  }) : super(key: key);

  @override
  State<LessonPlayerScreen> createState() => _LessonPlayerScreenState();
}

class _LessonPlayerScreenState extends State<LessonPlayerScreen> {
  late YoutubePlayerController _youtubeController;
  bool _showPdf = false;

  @override
  void initState() {
    super.initState();
    // Extract YouTube Video ID from URL
    final videoId = YoutubePlayer.convertUrlToId(widget.lesson.videoUrl) ??
        widget.lesson.videoUrl;

    _youtubeController = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
        disableDragSeek: true,
        enableCaption: true,
      ),
    );
  }

  @override
  void dispose() {
    _youtubeController.dispose();
    super.dispose();
  }

  Future<void> _launchPdf(String url) async {
    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(
          Uri.parse(url),
          mode: LaunchMode.externalApplication,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open PDF'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          widget.lesson.title,
          style: const TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // YouTube Player
            YoutubePlayer(
              controller: _youtubeController,
              showVideoProgressIndicator: true,
              progressIndicatorColor: const Color(0xFF25A0DC),
              onReady: () {
                print('Player is ready');
              },
            ),
            // Lesson Details
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    widget.lesson.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF142132),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Duration
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 16,
                        color: Color(0xFF25A0DC),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${widget.lesson.durationMinutes} minutes',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Description
                  Text(
                    'Lesson Description',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF142132),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.lesson.description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // PDF Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _launchPdf(widget.lesson.pdfUrl);
                      },
                      icon: const Icon(Icons.picture_as_pdf),
                      label: const Text('Open Lesson Materials (PDF)'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF25A0DC),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Download PDF Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        _launchPdf(widget.lesson.pdfUrl);
                      },
                      icon: const Icon(Icons.download),
                      label: const Text('Download Materials'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF25A0DC),
                        side: const BorderSide(
                          color: Color(0xFF25A0DC),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
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
