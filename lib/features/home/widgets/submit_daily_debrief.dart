import 'package:flutter/material.dart';
import 'package:nelsontan_offshore_drilling/core/constants/app_assert_image.dart';
import 'package:nelsontan_offshore_drilling/core/constants/app_colors.dart';

import '../../../core/util/screen_size.dart';
import '../../../core/widgets/text/app_text.dart';

class SubmitDailyDebrief extends StatelessWidget {

  final VoidCallback? onStart;

   SubmitDailyDebrief({
    super.key,
    this.onStart,
  });

   final appColor = AppColors.instance;
   final appAssets = AppAssertImage.instance;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(context.responsiveSize(12)),
        border: Border.all(
          color: appColor.strokeColor,
          width: 1.5,
        )
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(context.responsiveSize(12)),
        child: Stack(
          children: [
            // Background Image
            Positioned.fill(
              child: Image.asset(
                AppAssertImage.instance.submitDailyDebrief,
                fit: BoxFit.cover,
              ),
            ),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: context.responsiveSize(16)),
              child:  _buildContent(context),
            ),

          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Padding(
      padding:  EdgeInsets.only(top: context.responsiveSize(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                child: Image.asset(
                 appAssets.gameCardIcon,
                  width: context.responsiveSize(28),
                  height: context.responsiveSize(28),
                  // color: const Color(0xFF0047AB), // only works if PNG is monochrome/masked
                  colorBlendMode: BlendMode.srcIn,
                ),
              ),
              SizedBox(width: context.responsiveSize(12)),
              AppText(
                data: 'Submit Daily Debrief ',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: appColor.headLineTextColor,
                useResponsiveFontSize: true,
              ),
            ],
          ),


          SizedBox(height: context.responsiveSize(4)),
          // Title
          AppText(
            data:  'Capture Today’s Insights',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color:appColor.headLineTextColor,
            useResponsiveFontSize: true,
          ),


          // Description
          AppText(
            data: 'Capture safety insights & improvements \n from today\'s shift.',
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: appColor.titleTextColor,
            useResponsiveFontSize: true,
            maxLines: 2,
          ),

          SizedBox(height: context.responsiveSize(8)),


          // Last Score

          SizedBox(height: context.responsiveSize(10)),

          // Play Button
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: GestureDetector(
                onTap: onStart,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.responsiveSize(24 ),
                    vertical: context.responsiveSize(4),
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0047AB),
                    borderRadius: BorderRadius.circular(context.responsiveSize(8)),
                  ),
                  child: AppText(
                    data: 'Start Now',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    useResponsiveFontSize: true,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }


}