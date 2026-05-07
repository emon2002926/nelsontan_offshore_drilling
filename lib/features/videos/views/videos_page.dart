import 'package:flutter/material.dart';

import '../../../core/constants/app_assert_image.dart';
import '../../../core/util/app_navigation.dart';
import '../../../core/util/screen_size.dart';
import '../../../core/widgets/text/app_text.dart';
import '../../notification/views/notifications_screen.dart';
import '../controllers/videos_controller.dart';
import '../models/video_model.dart';
import 'package:get/get.dart';
class VideosPage extends StatelessWidget {
  VideosPage({super.key});

  final appAssets = AppAssertImage.instance;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(VideosController());

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: context.heightPercentage(1)),
            _buildHeader(context),

            Expanded(
              child: Obx(() {
                // ── Loading ──────────────────────────────────────────────
                if (controller.isLoading.value) {
                  return GridView.builder(
                    padding: EdgeInsets.all(context.responsiveSize(16)),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: context.responsiveSize(24),
                      mainAxisSpacing: context.responsiveSize(8),
                      childAspectRatio: 0.85,
                    ),
                    itemCount: 4,
                    itemBuilder: (_, _) => _buildSkeletonCard(context),
                  );
                }

                // ── Empty ────────────────────────────────────────────────
                if (controller.videos.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.video_library_outlined,
                            size: context.responsiveSize(64),
                            color: Colors.grey.shade300),
                        SizedBox(height: context.responsiveSize(12)),
                        AppText(
                          data: 'No videos available',
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF6B6B6B),
                          useResponsiveFontSize: true,
                        ),
                      ],
                    ),
                  );
                }

                // ── Grid ─────────────────────────────────────────────────
                return GridView.builder(
                  padding: EdgeInsets.all(context.responsiveSize(16)),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: context.responsiveSize(24),
                    mainAxisSpacing: context.responsiveSize(8),
                    childAspectRatio: 0.85,
                  ),
                  itemCount: controller.videos.length,
                  itemBuilder: (context, index) {
                    final video = controller.videos[index];
                    return _buildVideoCard(context, video: video);
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.responsiveSize(16)),
      color: Colors.white,
      child: Row(
        children: [
          Image.asset(
            appAssets.bxsVideos,
            width: context.responsiveSize(40),
            height: context.responsiveSize(40),
            colorBlendMode: BlendMode.srcIn,
          ),
          SizedBox(width: context.responsiveSize(12)),
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
          IconButton(
            onPressed: () =>
                AppNavigation.push(const NotificationsScreen(), context: context),
            icon: const Icon(Icons.notifications_outlined,
                color: Color(0xFF1A1A1A)),
            iconSize: context.responsiveSize(28),
          ),
        ],
      ),
    );
  }

  // ── Video card — thumbnail only, no video loaded ───────────────────────────

  Widget _buildVideoCard(BuildContext context, {required VideoModel video}) {
    return GestureDetector(
      onTap: () => Get.find<VideosController>().onVideoTap(context, video),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(context.responsiveSize(8)),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Thumbnail image
                  video.thumbnail != null
                      ? Image.network(
                    video.thumbnail!,
                    fit: BoxFit.cover,
                    loadingBuilder: (_, child, progress) {
                      if (progress == null) return child;
                      return Container(
                        color: Colors.grey.shade200,
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF0047AB),
                            strokeWidth: 2,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (_, _, _) =>
                        _buildThumbnailFallback(context),
                  )
                      : _buildThumbnailFallback(context),

                  // Play button overlay
                  Center(
                    child: Container(
                      padding: EdgeInsets.all(context.responsiveSize(12)),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.play_arrow_outlined,
                        color: const Color(0xFF0047AB),
                        size: context.responsiveSize(28),
                      ),
                    ),
                  ),

                  // Unavailable badge when videoUrl is null
                  if (video.videoUrl == null)
                    Positioned(
                      top: context.responsiveSize(8),
                      left: context.responsiveSize(8),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: context.responsiveSize(6),
                          vertical: context.responsiveSize(3),
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius:
                          BorderRadius.circular(context.responsiveSize(4)),
                        ),
                        child: AppText(
                          data: 'Unavailable',
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          useResponsiveFontSize: false,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Title
          Padding(
            padding: EdgeInsets.symmetric(
              vertical: context.responsiveSize(8),
              horizontal: context.responsiveSize(4),
            ),
            child: AppText(
              data: video.title,
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
    );
  }

  // ── Fallback when thumbnail is null or fails to load ──────────────────────

  Widget _buildThumbnailFallback(BuildContext context) {
    return Container(
      color: Colors.grey.shade200,
      child: Center(
        child: Icon(
          Icons.video_library_outlined,
          color: Colors.grey.shade400,
          size: context.responsiveSize(40),
        ),
      ),
    );
  }

  // ── Skeleton card shown while loading ─────────────────────────────────────

  Widget _buildSkeletonCard(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(context.responsiveSize(8)),
            child: Container(color: Colors.grey.shade200),
          ),
        ),
        SizedBox(height: context.responsiveSize(8)),
        Container(
          height: context.responsiveSize(14),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        SizedBox(height: context.responsiveSize(4)),
        Container(
          height: context.responsiveSize(14),
          width: context.responsiveSize(80),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }
}
// Video Player Screen (Full screen video player)
