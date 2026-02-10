import 'package:flutter/material.dart';
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
    final items = [
      {'icon': Icons.home_outlined, 'activeIcon': Icons.home, 'label': 'Home'},
      {'icon': Icons.add_circle_outline, 'activeIcon': Icons.add_circle, 'label': 'Cards'},
      {'icon': Icons.sports_esports_outlined, 'activeIcon': Icons.sports_esports, 'label': 'Game'},
      {'icon': Icons.play_circle_outline, 'activeIcon': Icons.play_circle, 'label': 'Videos'},
      {'icon': Icons.person_outline, 'activeIcon': Icons.person, 'label': 'Profile'},
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
                        Icon(
                          isSelected
                              ? item['activeIcon'] as IconData
                              : item['icon'] as IconData,
                          size: context.responsiveSize(28),
                          color: isSelected
                              ? const Color(0xFF0047AB) // SafeRig360 blue
                              : const Color(0xFF4A4A4A), // Dark gray for unselected
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