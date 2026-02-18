import 'package:flutter/material.dart';

import '../../../core/util/screen_size.dart';
import '../../../core/widgets/text/app_text.dart';
import '../models/video_source.dart';
import '../widgets/app_video_player.dart';

class VideoPlayerScreen extends StatelessWidget {
  final VideoSource videoSource;
  final String title;

  const VideoPlayerScreen({
    super.key,
    required this.videoSource,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: AppText(
          data: title,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          useResponsiveFontSize: true,
        ),
      ),
      body: Center(
        child: AppVideoPlayer(
          videoSource: videoSource,
          width: double.infinity,
          height: context.heightPercentage(40),
          showThumbnail: true,
          autoPlay: false,
          tag: 'fullscreen_${videoSource.path}',
        ),
      ),
    );
  }
}