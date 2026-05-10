import 'package:get/get.dart';

import '../../video_player/controllers/video_player_controller.dart';

class VideoManager extends GetxService {
  static VideoManager get to => Get.find();

  final Set<String> _activeTags = {};

  void register(String tag) => _activeTags.add(tag);

  void unregister(String tag) => _activeTags.remove(tag);

  void pauseAll() {
    for (final tag in _activeTags) {
      try {
        Get.find<AppVideoPlayerController>(tag: tag).pause();
      } catch (_) {}
    }
  }
}