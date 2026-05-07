// features/notifications/presentation/notifications_screen.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/util/screen_size.dart';
import '../../../core/widgets/app_bar/build_app_bar.dart';
import '../../../core/widgets/text/app_text.dart';
import '../controllers/notifications_controller.dart';
import '../models/notification_model.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // final controller = Get.put(NotificationsController());
    final controller = Get.find<NotificationsController>();
    // controller.fetchNotifications();


    return Scaffold(
      backgroundColor: Colors.white,
      appBar: BuildAppBar(
        backgroundColor: Colors.transparent,
        titleSize: 20,
        fontWeight: FontWeight.w700,
        backButtonIcon: CupertinoIcons.back,
        title: "Notifications",
        titleColor: const Color(0xFF1A1A1A),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF0047AB),
            ),
          );
        }

        if (controller.notifications.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.notifications_none,
                  size: context.responsiveSize(80),
                  color: const Color(0xFFE0E0E0),
                ),
                SizedBox(height: context.responsiveSize(16)),
                AppText(
                  data: 'No notifications yet',
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF9E9E9E),
                  useResponsiveFontSize: true,
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.refreshNotifications,
          child: ListView.separated(
            padding: EdgeInsets.symmetric(
              horizontal: context.responsiveSize(16),
              vertical: context.responsiveSize(12),
            ),
            itemCount: controller.notifications.length,
            separatorBuilder: (context, index) => SizedBox(
              height: context.responsiveSize(12),
            ),
            itemBuilder: (context, index) {
              final notification = controller.notifications[index];
              return _buildNotificationCard(context, notification, controller);
            },
          ),
        );
      }),
    );
  }

  Widget _buildNotificationCard(
      BuildContext context,
      NotificationModel notification,
      NotificationsController controller,
      ) {
    return GestureDetector(
      onTap: () => controller.onNotificationTap(context, notification),
      child: Container(
        padding: EdgeInsets.all(context.responsiveSize(16)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(context.responsiveSize(12)),
          // border: Border.all(
          //   color: const Color(0xFFE0E0E0),
          //   width: 1,
          // ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            _buildNotificationIcon(context, notification.type),

            SizedBox(width: context.responsiveSize(16)),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Time
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: AppText(
                          data: notification.title,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _getNotificationColor(notification.type),
                          useResponsiveFontSize: true,
                        ),
                      ),
                      SizedBox(width: context.responsiveSize(8)),
                      AppText(
                        data: _formatTimestamp(notification.timestamp),
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF9E9E9E),
                        useResponsiveFontSize: true,
                      ),
                    ],
                  ),

                  // Subtitle (if alert type)
                  if (notification.type == 'alert') ...[
                    SizedBox(height: context.responsiveSize(4)),
                    AppText(
                      data: 'Fire in Rig Floor',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A1A1A),
                      useResponsiveFontSize: true,
                    ),
                  ],

                  SizedBox(height: context.responsiveSize(6)),

                  // Message
                  Row(
                    children: [
                      Expanded(
                        child: AppText(
                          data: notification.message,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF6B6B6B),
                          useResponsiveFontSize: true,
                          maxLines: 2,
                        ),
                      ),
                      if (notification.fullMessage != null) ...[
                        SizedBox(width: context.responsiveSize(4)),
                        AppText(
                          data: 'See More',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF0047AB),
                          useResponsiveFontSize: true,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationIcon(BuildContext context, String type) {
    IconData icon;
    Color bgColor;

    switch (type) {
      case 'reminder':
        icon = Icons.notifications_active_outlined;
        bgColor = const Color(0xFF0047AB);
        break;
      case 'alert':
        icon = Icons.warning_outlined;
        bgColor = Colors.red;
        break;
      default:
        icon = Icons.info_outline;
        bgColor = const Color(0xFF0047AB);
    }

    return Container(
      padding: EdgeInsets.all(context.responsiveSize(12)),
      decoration: BoxDecoration(
        color: bgColor.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: bgColor,
        size: context.responsiveSize(24),
      ),
    );
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'alert':
        return Colors.red;
      case 'reminder':
        return const Color(0xFF0047AB);
      default:
        return const Color(0xFF1A1A1A);
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }
}