// features/notifications/presentation/notification_details_screen.dart
import 'package:flutter/material.dart';

import '../../../core/constants/app_assert_image.dart';
import '../../../core/util/screen_size.dart';
import '../../../core/widgets/app_bar/build_app_bar.dart';
import '../../../core/widgets/text/app_text.dart';
import '../models/notification_model.dart';

class NotificationDetailsScreen extends StatelessWidget {
  final NotificationModel notification;

  const NotificationDetailsScreen({
    super.key,
    required this.notification,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: BuildAppBar(
        showBackButton: true,
        title: "Notification",
        titleColor: Colors.black,
        fontWeight: FontWeight.bold,
        titleSize: 20,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: context.responsiveSize(12)),

            // Alert Header
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: context.responsiveSize(16),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning,
                    color: Colors.red,
                    size: context.responsiveSize(28),
                  ),
                  SizedBox(width: context.responsiveSize(12)),
                  AppText(
                    data: notification.title,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                    useResponsiveFontSize: true,
                  ),
                ],
              ),
            ),

            SizedBox(height: context.responsiveSize(20)),

            // Title
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: context.responsiveSize(16),
              ),
              child: AppText(
                data: 'Fire in Rig Floor',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.red,
                useResponsiveFontSize: true,
              ),
            ),

            SizedBox(height: context.responsiveSize(20)),

            // Image
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: context.responsiveSize(16),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(context.responsiveSize(16)),
                child: Image.asset(
                  AppAssertImage.instance.rigAnimationImage,
                  width: double.infinity,
                  height: context.responsiveSize(250),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            SizedBox(height: context.responsiveSize(24)),

            // Details Section
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: context.responsiveSize(16),
              ),
              child: AppText(
                data: 'Details',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF4A4A4A),
                useResponsiveFontSize: true,
              ),
            ),

            SizedBox(height: context.responsiveSize(12)),

            // Details Content
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: context.responsiveSize(16),
              ),
              child: AppText(
                data: notification.fullMessage ??
                    '''A fire has been detected on the rig floor area. This is a critical safety alert that requires immediate attention. All personnel should remain alert and follow emergency procedures. Access to the rig floor may be restricted until the situation is under control. Emergency response teams may be deployed to manage the incident. Please prioritize safety and avoid the affected zone. Further updates will be provided as more information becomes available.''',
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF6B6B6B),
                useResponsiveFontSize: true,
                height: 1.6,
                maxLines: null,
              ),
            ),

            SizedBox(height: context.responsiveSize(40)),
          ],
        ),
      ),
    );
  }
}