import 'package:get/get.dart';

import '../controllers/daily_debrief_controller.dart';
import '../controllers/safety_card_controller.dart';
class CardBinding {
  static void cardDependencies() {
    Get.lazyPut<DailyDebriefController>(
          () => DailyDebriefController(),
      fenix: true,
    );
    Get.lazyPut<SafetyCardController>(
          () => SafetyCardController(),
      fenix: true,
    );

  }
}