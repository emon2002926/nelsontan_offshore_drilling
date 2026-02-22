import 'package:flutter/material.dart';
import '../../../core/util/screen_size.dart';
import '../../../core/widgets/text/app_text.dart';

class GameScoreCard extends StatelessWidget {
  final int score;
  final int total;

  const GameScoreCard({
    super.key,
    required this.score,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: context.responsiveSize(20),
        horizontal: context.responsiveSize(24),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.responsiveSize(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFF0F0F0), width: 1),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.star_outline,
                color: const Color(0xFFFFAA00),
                size: context.responsiveSize(22),
              ),
              SizedBox(width: context.responsiveSize(6)),
              AppText(
                data: 'Score',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0047AB),
                useResponsiveFontSize: true,
              ),
            ],
          ),
          SizedBox(height: context.responsiveSize(8)),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$score',
                  style: TextStyle(
                    fontSize: context.responsiveFontSize(48),
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
                TextSpan(
                  text: '/$total',
                  style: TextStyle(
                    fontSize: context.responsiveFontSize(28),
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF9E9E9E),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: context.responsiveSize(4)),
          AppText(
            data: 'Points Scored',
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF9E9E9E),
            useResponsiveFontSize: true,
          ),
        ],
      ),
    );
  }
}