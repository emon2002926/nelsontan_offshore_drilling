import 'package:nelsontan_offshore_drilling/features/home/controllers/home_controller.dart';
import 'package:get/get.dart';
class HomeBinding {
  static void homeDependencies() {
    Get.lazyPut<HomeController>(
          () => HomeController(),
      fenix: true,
    );
  }
}