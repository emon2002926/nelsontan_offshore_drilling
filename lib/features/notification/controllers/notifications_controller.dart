// features/notifications/presentation/controllers/notifications_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nelsontan_offshore_drilling/core/util/app_navigation.dart';
import '../../../core/util/screen_size.dart';
import '../../../core/widgets/buttons/app_button.dart';
import '../../../core/widgets/snakbar/custom_snackbar.dart';
import '../../../core/widgets/text/app_text.dart';
import '../models/notification_model.dart';
import '../views/notification_details_screen.dart';

class NotificationsController extends GetxController {
  final RxList<NotificationModel> notifications = <NotificationModel>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    isLoading.value = true;

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // TODO: Replace with actual API call
      notifications.value = NotificationModel.dummies();

    } catch (e) {
      CustomSnackBar.error('Failed to load notifications');
      print('Error fetching notifications: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void onNotificationTap(BuildContext context, NotificationModel notification) {
    if (notification.fullMessage != null) {
      // Show full message in bottom sheet
      // showModalBottomSheet(
      //   context: context,
      //   isScrollControlled: true,
      //   shape: RoundedRectangleBorder(
      //     borderRadius: BorderRadius.vertical(
      //       top: Radius.circular(context.responsiveSize(20)),
      //     ),
      //   ),
      //   builder: (context) => _buildNotificationDetails(context, notification),
      // );

      AppNavigation.push(context, NotificationDetailsScreen(notification: notification));
    }
  }

  Widget _buildNotificationDetails(BuildContext context, NotificationModel notification) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(context.responsiveSize(24)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Row(
              children: [
                _getNotificationIcon(notification.type, context),
                SizedBox(width: context.responsiveSize(12)),
                Expanded(
                  child: AppText(
                    data: notification.title,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _getNotificationColor(notification.type),
                    useResponsiveFontSize: true,
                  ),
                ),
              ],
            ),

            SizedBox(height: context.responsiveSize(16)),

            // Full message
            AppText(
              data: notification.fullMessage ?? notification.message,
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF6B6B6B),
              useResponsiveFontSize: true,
              height: 1.5,
              maxLines: null,
            ),

            SizedBox(height: context.responsiveSize(16)),

            // Time
            AppText(
              data: _formatTimestamp(notification.timestamp),
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF9E9E9E),
              useResponsiveFontSize: true,
            ),

            SizedBox(height: context.responsiveSize(24)),

            // Close button
            AppButton(
              buttonText: 'Close',
              onPressed: () => Navigator.pop(context),
              fillColor: const Color(0xFF0047AB),
              textColor: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              buttonHeight: 48,
            ),
          ],
        ),
      ),
    );
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

  Widget _getNotificationIcon(String type, BuildContext context) {
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
        size: context.responsiveSize(28),
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

  Future<void> refreshNotifications() async {
    await fetchNotifications();
  }
}