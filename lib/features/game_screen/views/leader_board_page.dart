import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:nelsontan_offshore_drilling/core/constants/app_assert_image.dart';
import '../../../core/util/screen_size.dart';
import '../controllers/leader_bord_controller.dart';

// ─── Colors ───
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:nelsontan_offshore_drilling/core/constants/app_assert_image.dart';
import '../../../core/util/screen_size.dart';
import '../controllers/leader_bord_controller.dart';

// ─── Colors ───
const _kBackground = Color(0xFFF5F6FA);
const _kTextPrimary = Color(0xFF6E6C6C);
const _kTextSecondary = Color(0xFF90A4AE);
const _kGoldScore = Color(0xFFFFAA00);
const _kGoldBorder = Color(0xFFFFAA00);
const _kGoldLight = Color(0xFFFFFDE7);
const _kSilverBorder = Color(0xFFBDBDBD);
const _kBronzeBorder = Color(0xFF9E512E);

Color _rankColor(int r) => [
  const Color(0xFFFFA726),
  const Color(0xFF29B6F6),
  const Color(0xFF66BB6A),
  const Color(0xFF5C6BC0),
  const Color(0xFF26C6DA)
][r.clamp(1, 5) - 1];

Color _scoreColor(int r) => r == 1 ? _kGoldScore : _rankColor(r);

class LeaderboardView extends StatelessWidget {
  const LeaderboardView({super.key});

  // ─── Medal asset helper ───
  String _medalAsset(int pos) {
    switch (pos) {
      case 1:
        return AppAssertImage.instance.medalGold;   // e.g. assets/images/image_253.png
      case 2:
        return AppAssertImage.instance.medalSilver; // e.g. assets/images/image_252.png
      default:
        return AppAssertImage.instance.medalBronze; // e.g. assets/images/Layer_1.png
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = Get.put(LeaderboardController());

    return Scaffold(
      backgroundColor: _kBackground,
      body: SafeArea(
        child: Obx(() {
          if (c.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: _kGoldBorder),
            );
          }

          return RefreshIndicator(
            onRefresh: c.refreshLeaderboard,
            color: _kGoldBorder,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics()),
              padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                children: [
                  SizedBox(height: context.heightPercentage(3)),
                  _buildPodium(c),
                  const SizedBox(height: 16),
                  _buildWeeklyChampions(c),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  // ─── Podium ───
  Widget _buildPodium(LeaderboardController c) {
    final podium = c.podiumPlayers;
    if (podium.length < 3) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Silver (left) — rank 2
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 32),
              child: _podiumPlayer(
                podium[0],
                pos: 2,
                size: 80,
                border: _kSilverBorder,
                scoreCol: _kTextPrimary,
              ),
            ),
          ),
          // Gold (center) — rank 1
          Expanded(
            child: _podiumPlayer(
              podium[1],
              pos: 1,
              size: 90,
              border: _kGoldBorder,
              scoreCol: _kGoldScore,
              showCrown: true,
            ),
          ),
          // Bronze (right) — rank 3
          Expanded(
            child: _podiumPlayer(
              podium[2],
              pos: 3,
              size: 65,
              border: _kBronzeBorder,
              scoreCol: _kBronzeBorder,
            ),
          ),
        ],
      ),
    );
  }

  Widget _podiumPlayer(
      Map<String, dynamic> p, {
        required int pos,
        required double size,
        required Color border,
        required Color scoreCol,
        bool showCrown = false,
      }) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        // ── Card with drop shadow (name + score) ──
        Container(
          width: double.infinity,
          margin: EdgeInsets.only(top: (showCrown ? 24 + 4 : 0) + size * 0.5),
          padding: EdgeInsets.only(top: size * 0.55 + 8, bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(size * 0.15),
              topRight: Radius.circular(size * 0.15),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 16,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                p['name'],
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: pos == 1 ? 15 : 12,
                  fontWeight: FontWeight.w700,
                  color: _kTextPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${p['totalScore']}',
                style: TextStyle(
                  fontSize: pos == 1 ? 22 : 16,
                  fontWeight: FontWeight.w800,
                  color: scoreCol,
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),

        // ── Crown (gold only) ──
        if (showCrown)
          Positioned(
            top: 6,
            child: Image.asset(
              AppAssertImage.instance.winnerIcon,
              height: 20,
              width: 30,
            ),
          ),

        // ── Avatar + Medal (overlapping the card) ──
        Positioned(
          top: showCrown ? 28.0 : 0,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Avatar circle
              Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: border, width: 3),
                  color: const Color(0xFFFFF3E0),
                  boxShadow: [
                    BoxShadow(
                      color: border.withOpacity(0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    AppAssertImage.instance.profile,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              // ── Medal image (replaces CustomPainter) ──
              Positioned(
                bottom: -10,
                right: -6,  // always on the right
                child: Image.asset(
                  _medalAsset(pos),
                  width: 36,
                  height: 36,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── Weekly Champions ───
  Widget _buildWeeklyChampions(LeaderboardController c) {
    final ranked = c.weeklyRankedPlayers;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            children: [
              Image.asset(
                AppAssertImage.instance.trophyIcon,
                width: 22,
                height: 22,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Weekly Champions',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: _kTextPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              Obx(() => Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: _kBackground,
                  borderRadius: BorderRadius.circular(20),
                  border:
                  Border.all(color: const Color(0xFFE0E0E0)),
                ),
                child: Text(
                  'Week ${c.currentWeek.value}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _kTextSecondary,
                  ),
                ),
              )),
            ],
          ),
          const SizedBox(height: 14),

          // Rows
          ...List.generate(
            ranked.length,
                (i) => _rankRow(ranked[i], i + 1),
          ),
        ],
      ),
    );
  }

  Widget _rankRow(Map<String, dynamic> p, int rank) {
    final isFirst = rank == 1;
    final rc = _rankColor(rank);
    final sc = _scoreColor(rank);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isFirst ? _kGoldLight : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isFirst ? _kGoldBorder : const Color(0xFFF0F0F0),
          width: isFirst ? 1.8 : 1.2,
        ),
      ),
      child: Row(
        children: [
          // Rank circle
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: rc,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: rc.withOpacity(0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                '$rank',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Name + hazards
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p['name'],
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _kTextPrimary,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  '${p['hazards']} hazards found',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: _kTextSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Score
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${p['weeklyScore']}',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: sc,
                ),
              ),
              const Text(
                'pts',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: _kTextSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}