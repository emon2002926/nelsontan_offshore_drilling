import 'package:get/get.dart';

import '../controllers/profile_controller.dart';
class ProfileBinding {
  static void profileDependencies() {
    Get.lazyPut<ProfileController>(
          () => ProfileController(),
      fenix: true,
    );
  }
}


