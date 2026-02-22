// features/home/widgets/training_game_card.dart
import 'package:flutter/material.dart';
import 'package:nelsontan_offshore_drilling/core/constants/app_assert_image.dart';
import 'package:nelsontan_offshore_drilling/core/constants/app_colors.dart';

import '../../../core/util/screen_size.dart';
import '../../../core/widgets/text/app_text.dart';
import '../models/training_game_model.dart';

class TrainingGameCard extends StatelessWidget {
  final TrainingGameModel? data;
  final bool isLoading;
  final VoidCallback? onPlay;
  final VoidCallback? onSettings;

   TrainingGameCard({
    super.key,
    this.data,
    this.isLoading = false,
    this.onPlay,
    this.onSettings,
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
                AppAssertImage.instance.trainingGameBg,
                fit: BoxFit.fill,
              ),
            ),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: context.responsiveSize(16)),
              child: isLoading
                  ? _buildLoadingState(context)
                  : _buildContent(context),
            ),

            // Settings Button
            if (!isLoading && data != null)
              Positioned(
                bottom: context.responsiveSize(20),
                right: context.responsiveSize(20),
                child: GestureDetector(
                  onTap: onSettings,
                  child: Container(
                    padding: EdgeInsets.all(context.responsiveSize(12)),
                    decoration: const BoxDecoration(
                      color: Color(0xFF0047AB),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.settings,
                      size: context.responsiveSize(24),
                      color: Colors.white,
                    ),
                  ),
                ),
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
                data: 'Training & Game',
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
            data: data?.title ?? 'Spot the hazard',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color:appColor.headLineTextColor,
            useResponsiveFontSize: true,
          ),


          // Description
          AppText(
            data: data?.description ?? 'Sharpen your safety eyes! Find 5 \n hazards in 30 seconds.',
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: appColor.titleTextColor,
            useResponsiveFontSize: true,
            maxLines: 2,
          ),

          SizedBox(height: context.responsiveSize(8)),


          // Last Score
            Row(
              children: [
                Container(
                  child: Image.asset(
                   appAssets.winnerIcon,
                    width: context.responsiveSize(20),
                    height: context.responsiveSize(20),
                    colorBlendMode: BlendMode.srcIn,
                  ),
                ),
                SizedBox(width: context.responsiveSize(8)),
                AppText(
                  data: 'Last Score: ',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF6B6B6B),
                  useResponsiveFontSize: true,
                ),
                AppText(
                  data: '10 pts',
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1A1A1A),
                  useResponsiveFontSize: true,
                ),
              ],
            ),

          SizedBox(height: context.responsiveSize(10)),

          // Play Button
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: GestureDetector(
                onTap: onPlay,
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
                    data: 'Play',
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

  Widget _buildLoadingState(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: context.responsiveSize(48),
              height: context.responsiveSize(48),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            SizedBox(width: context.responsiveSize(12)),
            Container(
              width: context.responsiveSize(150),
              height: context.responsiveSize(22),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
        SizedBox(height: context.responsiveSize(16)),
        Container(
          width: double.infinity,
          height: context.responsiveSize(24),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.3),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        SizedBox(height: context.responsiveSize(8)),
        Container(
          width: context.responsiveSize(220),
          height: context.responsiveSize(16),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.3),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        SizedBox(height: context.responsiveSize(12)),
        Container(
          width: context.responsiveSize(140),
          height: context.responsiveSize(18),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.3),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        SizedBox(height: context.responsiveSize(16)),
        Container(
          width: context.responsiveSize(100),
          height: context.responsiveSize(40),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ],
    );
  }
}