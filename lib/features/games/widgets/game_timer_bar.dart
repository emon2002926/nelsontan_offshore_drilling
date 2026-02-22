// features/game/views/game_timer_bar.dart
import 'package:flutter/material.dart';

import '../../../core/util/screen_size.dart';
import '../../../core/widgets/text/app_text.dart';

// features/game/widgets/game_timer_bar.dart


class GameTimerBar extends StatelessWidget {
  final String timerText;
  final double progress; // 0.0 to 1.0
  final VoidCallback? onClose;

  const GameTimerBar({
    super.key,
    required this.timerText,
    required this.progress,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    Color timerColor;
    if (progress > 0.5) {
      timerColor = const Color(0xFF0047AB);
    } else if (progress > 0.2) {
      timerColor = const Color(0xFFFFAA00);
    } else {
      timerColor = Colors.red;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.responsiveSize(16),
        vertical: context.responsiveSize(10),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.responsiveSize(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (onClose != null)
            GestureDetector(
              onTap: onClose,
              child: Icon(
                Icons.close,
                color: const Color(0xFF6B6B6B),
                size: context.responsiveSize(20),
              ),
            ),
          SizedBox(width: context.responsiveSize(8)),
          Icon(
            Icons.timer_outlined,
            color: timerColor,
            size: context.responsiveSize(18),
          ),
          SizedBox(width: context.responsiveSize(8)),
          AppText(
            data: timerText,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A1A1A),
            useResponsiveFontSize: true,
          ),
          SizedBox(width: context.responsiveSize(12)),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(context.responsiveSize(10)),
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                minHeight: context.responsiveSize(8),
                backgroundColor: const Color(0xFFE0E0E0),
                valueColor: AlwaysStoppedAnimation<Color>(timerColor),
              ),
            ),
          ),
        ],
      ),
    );
  }
}