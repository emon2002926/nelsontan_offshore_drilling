import 'package:flutter/material.dart';
import '../../constants/app_assert_image.dart';
import '../../util/screen_size.dart';
import '../text/app_text.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTabSelected;

  const CustomBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    final appAssets = AppAssertImage.instance;

    final items = [
      {
        'assetIcon': appAssets.home,
        'label': 'Home'
      },
      {
        'assetIcon': appAssets.card,
        'label': 'Cards'
      },
      {
        'assetIcon': appAssets.game,
        'label': 'Game'
      },
      {
        'assetIcon': appAssets.video,
        'label': 'Videos'
      },
      {
        'assetIcon': appAssets.profileIcon,
        'label': 'Profile'
      },
    ];

    return Padding(
      padding: EdgeInsets.only(
        left: context.responsiveSize(16),
        right: context.responsiveSize(16),
        bottom: context.responsiveSize(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFE8EDF5), // Light blue-gray background
          borderRadius: BorderRadius.circular(context.responsiveSize(28)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: context.responsiveSize(12),
              horizontal: context.responsiveSize(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(items.length, (index) {
                final item = items[index];
                final isSelected = currentIndex == index;

                return Expanded(
                  child: GestureDetector(
                    onTap: () => onTabSelected(index),
                    behavior: HitTestBehavior.opaque,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Asset Icon with color change
                        Image.asset(
                          item['assetIcon'] as String,
                          width: context.responsiveSize(28),
                          height: context.responsiveSize(28),
                          color: isSelected
                              ? const Color(0xFF0047AB) // SafeRig360 blue when selected
                              : const Color(0xFF4A4A4A), // Dark gray when unselected
                          errorBuilder: (context, error, stackTrace) {
                            // Fallback to material icon if asset not found
                            return Icon(
                              Icons.error_outline,
                              size: context.responsiveSize(28),
                              color: Colors.red,
                            );
                          },
                        ),
                        SizedBox(height: context.responsiveSize(4)),
                        AppText(
                          data: item['label'] as String,
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelected
                              ? const Color(0xFF0047AB) // SafeRig360 blue
                              : const Color(0xFF4A4A4A), // Dark gray for unselected
                          useResponsiveFontSize: true,
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
