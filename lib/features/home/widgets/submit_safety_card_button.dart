// features/home/widgets/submit_safety_card_button.dart
import 'package:flutter/material.dart';

import '../../../core/util/screen_size.dart';
import '../../../core/widgets/text/app_text.dart';

class SubmitSafetyCardButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;

  const SubmitSafetyCardButton({
    super.key,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Button
        GestureDetector(
          onTap: isLoading ? null : onPressed,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              vertical: context.responsiveSize(14),
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF0047AB),
              borderRadius: BorderRadius.circular(context.responsiveSize(12)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0047AB).withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: isLoading
                ? Center(
              child: SizedBox(
                width: context.responsiveSize(24),
                height: context.responsiveSize(24),
                child: const CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              ),
            )
                : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(context.responsiveSize(2)),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.add,
                    color: Colors.white,
                    size: context.responsiveSize(20),
                  ),
                ),
                SizedBox(width: context.responsiveSize(12)),
                AppText(
                  data: ' Submit Safety Card',
                  fontSize: 16  ,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  useResponsiveFontSize: true,
                ),
              ],
            ),
          ),
        ),

        SizedBox(height: context.responsiveSize(8)),

        // Subtitle
        AppText(
          data: 'Takes less than 30 seconds',
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: const Color(0xFF9E9E9E),
          useResponsiveFontSize: true,
        ),
      ],
    );
  }
}