import 'package:flutter/material.dart';

import '../../../core/constants/app_assert_image.dart';
import '../../../core/util/app_navigation.dart';
import '../../../core/util/screen_size.dart';
import '../../../core/widgets/text/app_text.dart';
import '../../notification/views/notifications_screen.dart';
import '../../video_player/models/video_source.dart';
import '../../video_player/video_player_screen/video_player_screen.dart';
class VideosPage extends StatelessWidget {
   VideosPage({super.key});

  final appAssets = AppAssertImage.instance;


  @override
  Widget build(BuildContext context) {
    // Sample video data - replace with your actual data
    final videos = [
      VideoSource.asset('assets/videos/demo.mp4', thumbnailAssetPath: appAssets.thumbnailImage),
      VideoSource.asset('assets/videos/demo.mp4', thumbnailAssetPath: appAssets.thumbnailImage),
      VideoSource.asset('assets/videos/demo.mp4', thumbnailAssetPath: appAssets.thumbnailImage),
      VideoSource.asset('assets/videos/demo.mp4', thumbnailAssetPath: appAssets.thumbnailImage),
    ];

    final videoTitles = [
      'Avoiding Hazards on WIP Oil Machine',
      'Avoiding Hazards on WIP Oil Machine',
      'Avoiding Hazards on WIP Oil Machine',
      'Avoiding Hazards on WIP Oil Machine',
    ];

    return Scaffold(
      backgroundColor:  Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header

            SizedBox(height: context.heightPercentage(1),),
            _buildHeader(context),

            // Video Grid
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(context.responsiveSize(16)),
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: context.responsiveSize(24),
                    mainAxisSpacing: context.responsiveSize(8),
                    childAspectRatio: 0.85,
                  ),
                  itemCount: videos.length,
                  itemBuilder: (context, index) {
                    return _buildVideoCard(
                      context,
                      videoSource: videos[index],
                      title: videoTitles[index],
                      duration: '04:30',
                      index: index,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.responsiveSize(16)),
      color: Colors.white,
      child: Row(
        children: [
          // Icon
          Container(
            child: Image.asset(
              appAssets.bxsVideos,
              width: context.responsiveSize(40),
              height: context.responsiveSize(40),
              colorBlendMode: BlendMode.srcIn,
            ),
          ),
          SizedBox(width: context.responsiveSize(12)),

          // Title and subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  data: 'Safety Training Library',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1A1A1A),
                  useResponsiveFontSize: true,
                ),
                SizedBox(height: context.responsiveSize(4)),
                AppText(
                  data: 'Complete required training modules',
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF6B6B6B),
                  useResponsiveFontSize: true,
                ),
              ],
            ),
          ),

          // Notification icon
          IconButton(
            onPressed: () {
              // Handle notification tap
              AppNavigation.push(context, const NotificationsScreen());

            },
            icon: const Icon(
              Icons.notifications_outlined,
              color: Color(0xFF1A1A1A),
            ),
            iconSize: context.responsiveSize(28),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoCard(
      BuildContext context, {
        required VideoSource videoSource,
        required String title,
        required String duration,
        required int index,
      }) {
    return GestureDetector(
      onTap: () {
        AppNavigation.push(context, VideoPlayerScreen(
          videoSource: videoSource,
          title: title,
        ));

      },
      child: Container(

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Video thumbnail with play button and duration
            Expanded(
              child: Stack(
                children: [
                  // Thumbnail
                  ClipRRect(

                    child: videoSource.thumbnailPath != null
                        ? Image.asset(
                      videoSource.thumbnailPath!,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    )
                        : Container(
                      color: Colors.black,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),

                  // Play button
                  Center(
                    child: Container(
                      padding: EdgeInsets.all(context.responsiveSize(16)),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.play_arrow_outlined,
                        color: const Color(0xFF0047AB),
                        size: context.responsiveSize(32),
                      ),
                    ),
                  ),

                  // Duration badge
                  Positioned(
                    bottom: context.responsiveSize(8),
                    right: context.responsiveSize(8),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: context.responsiveSize(8),
                        vertical: context.responsiveSize(4),
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(context.responsiveSize(4)),
                      ),
                      child: AppText(
                        data: duration,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        useResponsiveFontSize: false,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Title
            Padding(
              padding: EdgeInsets.all(context.responsiveSize(12)),
              child: AppText(
                data: title,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF1A1A1A),
                useResponsiveFontSize: true,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Video Player Screen (Full screen video player)
