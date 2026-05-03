import 'package:get/get.dart';
import 'package:nelsontan_offshore_drilling/features/notification/controllers/notifications_controller.dart';
class NotificationBinding {
  static void notificationDependencies() {
    Get.lazyPut<NotificationsController>(
          () => NotificationsController(),
      fenix: true,
    );
  }
}