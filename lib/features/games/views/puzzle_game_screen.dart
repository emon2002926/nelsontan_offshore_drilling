import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../core/util/screen_size.dart';
import '../../../core/widgets/text/app_text.dart';
import '../controllers/puzzle_game_controller.dart';
import 'package:get/get.dart';

import '../widgets/game_score_card.dart';
import '../widgets/game_timer_bar.dart';

class PuzzleGameScreen extends StatelessWidget {
  const PuzzleGameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PuzzleGameController());

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Obx(() {
          // ── Loading ────────────────────────────────────────────────────
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF0047AB)),
            );
          }

          // ── Submitting ─────────────────────────────────────────────────
          if (controller.gameState.value == PuzzleGameState.submitting) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(color: Color(0xFF0047AB)),
                  const SizedBox(height: 16),
                  AppText(
                    data: 'Submitting your answers...',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF6B6B6B),
                    useResponsiveFontSize: true,
                  ),
                ],
              ),
            );
          }

          // ── Results ────────────────────────────────────────────────────
          if (controller.gameState.value == PuzzleGameState.finished) {
            return _buildResults(context, controller);
          }

          // ── Playing ────────────────────────────────────────────────────
          return _buildPuzzle(context, controller);
        }),
      ),
    );
  }

  // ── Puzzle screen ─────────────────────────────────────────────────────────

  Widget _buildPuzzle(BuildContext context, PuzzleGameController controller) {
    final puzzle = controller.currentPuzzle;
    if (puzzle == null) return const SizedBox.shrink();

    return Column(
      children: [
        SizedBox(height: context.responsiveSize(12)),

        // Progress label
        Obx(() => AppText(
          data: controller.puzzleProgress,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF9E9E9E),
          useResponsiveFontSize: true,
        )),

        SizedBox(height: context.responsiveSize(8)),

        // Timer bar
        Padding(
          padding:
          EdgeInsets.symmetric(horizontal: context.responsiveSize(24)),
          child: Obx(() => GameTimerBar(
            timerText: controller.timerText,
            progress: controller.timerProgress,
            onClose: () => _showExitDialog(context, controller),
          )),
        ),

        SizedBox(height: context.responsiveSize(12)),

        // Puzzle title
        Padding(
          padding:
          EdgeInsets.symmetric(horizontal: context.responsiveSize(16)),
          child: AppText(
            data: 'Tap on all unsafe conditions you find',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A1A1A),
            useResponsiveFontSize: true,
            textAlign: TextAlign.center,
          ),
        ),

        SizedBox(height: context.responsiveSize(12)),

        // ── Tappable image ─────────────────────────────────────────────
        Padding(
          padding:
          EdgeInsets.symmetric(horizontal: context.responsiveSize(16)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(context.responsiveSize(12)),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final imageSize = Size(
                      constraints.maxWidth, constraints.maxHeight);

                  return GestureDetector(
                    onTapDown: (details) => controller.onImageTapped(
                      details.localPosition,
                      imageSize,
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Puzzle image
                        Image.network(
                          puzzle.image,
                          fit: BoxFit.cover,
                          loadingBuilder: (_, child, progress) {
                            if (progress == null) return child;
                            return Container(
                              color: const Color(0xFFE8F4FC),
                              child: const Center(
                                child: CircularProgressIndicator(
                                    color: Color(0xFF0047AB)),
                              ),
                            );
                          },
                          errorBuilder: (_, __, ___) => Container(
                            color: const Color(0xFFE8F4FC),
                            child: Center(
                              child: Icon(Icons.image,
                                  size: context.responsiveSize(48),
                                  color: Colors.grey),
                            ),
                          ),
                        ),

                        // User tap markers
                        Obx(() => Stack(
                          children: controller.currentTaps
                              .asMap()
                              .entries
                              .map((entry) {
                            final i    = entry.key;
                            final mark = entry.value;
                            final left = (mark.x / 100) *
                                constraints.maxWidth -
                                16;
                            final top  = (mark.y / 100) *
                                constraints.maxHeight -
                                16;

                            return Positioned(
                              left: left,
                              top: top,
                              child: GestureDetector(
                                onLongPress: () =>
                                    controller.removeTap(i),
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0047AB)
                                        .withOpacity(0.85),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: Colors.white,
                                        width: 2),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black
                                            .withOpacity(0.3),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: AppText(
                                      data: '${i + 1}',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      useResponsiveFontSize: false,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        )),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),

        SizedBox(height: context.responsiveSize(16)),

        // Tap count hint
        Obx(() => Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.warning_amber_rounded,
                color: const Color(0xFFFFAA00),
                size: context.responsiveSize(20)),
            SizedBox(width: context.responsiveSize(8)),
            AppText(
              data:
              'Hazards marked: ${controller.currentTaps.length}  •  Long-press a marker to remove it',
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF1A1A1A),
              useResponsiveFontSize: true,
            ),
          ],
        )),

        SizedBox(height: context.responsiveSize(16)),

        // Next / Done button
        Padding(
          padding:
          EdgeInsets.symmetric(horizontal: context.responsiveSize(24)),
          child: GestureDetector(
            onTap: controller.onNext,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                  vertical: context.responsiveSize(14)),
              decoration: BoxDecoration(
                color: const Color(0xFF0047AB),
                borderRadius:
                BorderRadius.circular(context.responsiveSize(12)),
              ),
              child: Center(
                child: Obx(() => AppText(
                  data: controller.isLastPuzzle ? 'Done' : 'Next',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  useResponsiveFontSize: true,
                )),
              ),
            ),
          ),
        ),

        SizedBox(height: context.responsiveSize(24)),
      ],
    );
  }

  // ── Results screen ────────────────────────────────────────────────────────

  Widget _buildResults(
      BuildContext context, PuzzleGameController controller) {
    final result = controller.gameResult.value;

    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: context.responsiveSize(24)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.emoji_events,
              color: const Color(0xFFFFAA00),
              size: context.responsiveSize(80)),

          SizedBox(height: context.responsiveSize(20)),

          AppText(
            data: 'Game Over!',
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF003E9A),
            useResponsiveFontSize: true,
          ),

          SizedBox(height: context.responsiveSize(8)),

          AppText(
            data: 'Here\'s how you did',
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF6B6B6B),
            useResponsiveFontSize: true,
          ),

          SizedBox(height: context.responsiveSize(24)),

          // Score card
          GameScoreCard(
            score: result?.score ?? 0,
            total: controller.puzzles.length,
          ),

          SizedBox(height: context.responsiveSize(16)),

          // Per-puzzle breakdown
          ...controller.puzzles.asMap().entries.map((entry) {
            final puzzle = entry.value;
            final taps   = controller.collectedTaps[puzzle.id] ?? [];

            return Padding(
              padding:
              EdgeInsets.only(bottom: context.responsiveSize(8)),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: context.responsiveSize(16),
                  vertical: context.responsiveSize(12),
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FB),
                  borderRadius:
                  BorderRadius.circular(context.responsiveSize(12)),
                  border: Border.all(
                      color: const Color(0xFFF0F0F0), width: 1),
                ),
                child: Row(
                  children: [
                    Icon(Icons.image_search_outlined,
                        color: const Color(0xFF0047AB),
                        size: context.responsiveSize(22)),
                    SizedBox(width: context.responsiveSize(12)),
                    Expanded(
                      child: AppText(
                        data: puzzle.title,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1A1A1A),
                        useResponsiveFontSize: true,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: context.responsiveSize(8)),
                    AppText(
                      data: '${taps.length} taps',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0047AB),
                      useResponsiveFontSize: true,
                    ),
                  ],
                ),
              ),
            );
          }),

          SizedBox(height: context.responsiveSize(32)),

          GestureDetector(
            onTap: () => controller.exitGame(context),
            child: AppText(
              data: 'Back to Games',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF0047AB),
              useResponsiveFontSize: true,
            ),
          ),

          SizedBox(height: context.responsiveSize(24)),
        ],
      ),
    );
  }

  // ── Exit dialog ───────────────────────────────────────────────────────────

  void _showExitDialog(
      BuildContext context, PuzzleGameController controller) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text('Exit Game?'),
        content:
        const Text('Your progress will be lost. Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: Color(0xFF6B6B6B))),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              controller.exitGame(context);
            },
            child: const Text('Exit',
                style: TextStyle(color: Color(0xFF0047AB))),
          ),
        ],
      ),
    );
  }
}