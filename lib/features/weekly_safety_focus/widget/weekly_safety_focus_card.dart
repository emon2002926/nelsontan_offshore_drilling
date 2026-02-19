import 'package:flutter/material.dart';
import 'package:nelsontan_offshore_drilling/core/constants/app_assert_image.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/util/screen_size.dart';
import '../../../core/widgets/text/app_text.dart';
import '../models/weekly_safety_focus_model.dart';

class WeeklySafetyFocusCard extends StatelessWidget {
  final WeeklySafetyFocusModel? data;
  final bool isLoading;
  final VoidCallback? onReadMore;

   WeeklySafetyFocusCard({
    super.key,
    this.data,
    this.isLoading = false,
    this.onReadMore,
  });

  final appColors = AppColors.instance;

  @override
  Widget build(BuildContext context) {

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(context.responsiveSize(16)),
          border: Border.all(
            color: appColors.strokeColor,
            width: 1.5,
          )
      ),

      child: ClipRRect(
        borderRadius: BorderRadius.circular(context.responsiveSize(16)),
        child: Stack(
          children: [
            // Background Image
            Positioned.fill(
              child: Image.asset(
                AppAssertImage.instance.weeklySafetyBannerBg,
                fit: BoxFit.cover,
              ),
            ),


            // Content
            Padding(
              padding: EdgeInsets.symmetric(vertical: context.responsiveSize(20),horizontal: 16),
              child: isLoading
                  ? _buildLoadingState(context)
                  : _buildContent(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with Icon
        Row(
          children: [
            Image.asset(
              AppAssertImage.instance.calendarIcon,
              width: context.responsiveSize(24),
              height: context.responsiveSize(24),
              // color: const Color(0xFF0047AB), // only works if PNG is monochrome/masked
              colorBlendMode: BlendMode.srcIn,
            ),
            SizedBox(width: context.responsiveSize(12)),
            Expanded(
              child: AppText(
                data: 'Weekly Safety Focus',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: appColors.headLineTextColor,
                useResponsiveFontSize: true,
              ),
            ),
          ],
        ),

        SizedBox(height: context.responsiveSize(8)),

        // Title
        AppText(
          data: data?.title ?? 'No data available',
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: appColors.headLineTextColor,
          useResponsiveFontSize: true,
        ),

        SizedBox(height: context.responsiveSize(4)),

        // Description
        AppText(
          data: data?.description ?? 'Please check back later.',
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: appColors.titleTextColor,
          useResponsiveFontSize: true,
          maxLines: 2,
        ),

        SizedBox(height: context.responsiveSize(10)),

        // Read More Button
        if (data != null)
          GestureDetector(
            onTap: onReadMore,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: context.responsiveSize(18),
                vertical: context.responsiveSize(6),
              ),
              decoration: BoxDecoration(
                color: appColors.profileBackground,
                borderRadius: BorderRadius.circular(
                  context.responsiveSize(6),
                ),
                border: Border.all(
                  color: const Color(0x4D2C2B2B),
                  width: 1,
                ),
              ),
              child: AppText(
                data: 'Read more',
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2C2B2B),
                useResponsiveFontSize: true,
              ),
            ),
          ),
        SizedBox(height: context.responsiveSize(4))
      ],
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header skeleton
        Row(
          children: [
            Container(
              width: context.responsiveSize(40),
              height: context.responsiveSize(40),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            SizedBox(width: context.responsiveSize(12)),
            Container(
              width: context.responsiveSize(150),
              height: context.responsiveSize(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),

        SizedBox(height: context.responsiveSize(16)),

        // Title skeleton
        Container(
          width: double.infinity,
          height: context.responsiveSize(22),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.5),
            borderRadius: BorderRadius.circular(4),
          ),
        ),

        SizedBox(height: context.responsiveSize(8)),

        // Description skeleton
        Container(
          width: context.responsiveSize(200),
          height: context.responsiveSize(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.5),
            borderRadius: BorderRadius.circular(4),
          ),
        ),

        SizedBox(height: context.responsiveSize(16)),

        // Button skeleton
        Container(
          width: context.responsiveSize(100),
          height: context.responsiveSize(36),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.5),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ],
    );
  }
}