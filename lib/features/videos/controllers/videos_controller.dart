import 'package:flutter/cupertino.dart';

import '../../../core/services/api_services.dart';
import 'package:get/get.dart';

import '../../../core/util/app_navigation.dart';
import '../../../core/util/storage_service.dart';
import '../../../core/widgets/snakbar/custom_snackbar.dart';
import '../../auth/views/signin_screen.dart';
import '../../video_player/models/video_source.dart';
import '../models/video_model.dart';
import '../views/video_player_screen.dart';
class VideosController extends GetxController {
  final ApiServices _api = Get.find<ApiServices>();

  final RxList<VideoModel> videos = <VideoModel>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchVideos();
  }

  Future<void> fetchVideos() async {
    final token = StorageService.accessToken;
    if (token == null || token.isEmpty) {
      CustomSnackBar.error('Session expired. Please sign in again.');
      AppNavigation.pushAndClear(const SignInScreen());
      return;
    }

    isLoading.value = true;
    try {
      final raw = await _api.get(
        '/video',
        headers: {'Authorization': 'Bearer $token'},
      );

      final list = (raw['data'] as List<dynamic>? ?? [])
          .map((e) => VideoModel.fromJson(e))
          .toList();

      videos.assignAll(list);
    } on HttpException catch (e) {
      CustomSnackBar.error(e.message);
    } catch (e) {
      CustomSnackBar.error('Failed to load videos. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  void onVideoTap(BuildContext context, VideoModel video) {
    if (video.videoUrl == null) {
      CustomSnackBar.warning('Video is not available.');
      return;
    }
    AppNavigation.push(
      VideoPlayerScreen(
        videoSource: VideoSource.network(
          video.videoUrl!,
          // thumbnailNetworkPath: video.thumbnail,
        ),
        title: video.title,
        description: video.description,
      ),
      context: context,
    );
  }
}