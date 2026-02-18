// features/home/presentation/safety_focus_details_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nelsontan_offshore_drilling/core/constants/app_assert_image.dart';

import '../../../core/util/app_navigation.dart';
import '../../../core/util/screen_size.dart';
import '../../../core/widgets/text/app_text.dart';
import '../models/weekly_safety_focus_model.dart';

class SafetyFocusDetailsScreen extends StatelessWidget {
  final WeeklySafetyFocusModel data;

  const SafetyFocusDetailsScreen({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding:  EdgeInsets.symmetric(horizontal: context.widthPercentage(5)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: context.widthPercentage(10)),

                // Header
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      color: const Color(0xFF0047AB),
                      size: context.responsiveSize(28),
                    ),
                    SizedBox(width: context.responsiveSize(12)),
                    Expanded(
                      child: AppText(
                        data: 'Weekly Safety Focus',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0047AB),
                        useResponsiveFontSize: true,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: context.responsiveSize(8)),

                // Title
                AppText(
                  data: data.title,
                  fontSize: 18  ,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF4A4A4A),
                  useResponsiveFontSize: true,
                ),

                SizedBox(height: context.responsiveSize(20)),


                ClipRRect(
                    borderRadius: BorderRadius.circular(context.responsiveSize(16)),
                    child: data.imageUrl != null
                        ? Image.network(
                      data.imageUrl!,
                      width: double.infinity,
                      height: context.responsiveSize(250),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildPlaceholderImage(context);
                      },
                    )
                        : _buildPlaceholderImage(context),
                  ),


                SizedBox(height: context.responsiveSize(24)),

                // Details Section
                AppText(
                  data: 'Details',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF4A4A4A),
                  useResponsiveFontSize: true,
                ),

                SizedBox(height: context.responsiveSize(12)),

                // Details Content
                AppText(
                    data: data.fullDetails ?? data.description,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF6B6B6B),
                    useResponsiveFontSize: true,
                    height: 1.6,
                    maxLines: null,
                  ),


                SizedBox(height: context.responsiveSize(40)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage(BuildContext context) {
    return Container(
      width: double.infinity,
      height: context.responsiveSize(250),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F4FC),
      ),
      child: Center(
        child: Image.asset(AppAssertImage.instance.thumbnailImage),

    ));
  }
}