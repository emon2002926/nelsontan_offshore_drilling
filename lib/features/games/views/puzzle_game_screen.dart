import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../core/util/screen_size.dart';
import '../../../core/widgets/text/app_text.dart';
import '../controllers/puzzle_game_controller.dart';
import 'package:get/get.dart';

import '../models/puzzle_model.dart';
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
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF0047AB)),
            );
          }

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

          if (controller.gameState.value == PuzzleGameState.finished) {
            return _buildResults(context, controller);
          }

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

        Obx(() => AppText(
          data: controller.puzzleProgress,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF9E9E9E),
          useResponsiveFontSize: true,
        )),

        SizedBox(height: context.responsiveSize(8)),

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

        // Instruction + remaining taps pill
        Padding(
          padding:
          EdgeInsets.symmetric(horizontal: context.responsiveSize(16)),
          child: Obx(() {
            final remaining = controller.remainingTaps;
            final exhausted = controller.tapsExhausted;
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppText(
                  data: exhausted
                      ? 'No taps remaining'
                      : 'Tap on all unsafe conditions you find',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: exhausted
                      ? Colors.red.shade600
                      : const Color(0xFF1A1A1A),
                  useResponsiveFontSize: true,
                  textAlign: TextAlign.center,
                ),
                SizedBox(width: context.responsiveSize(8)),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.responsiveSize(10),
                    vertical: context.responsiveSize(3),
                  ),
                  decoration: BoxDecoration(
                    color: exhausted
                        ? Colors.red.shade50
                        : const Color(0xFFE6ECF5),
                    borderRadius:
                    BorderRadius.circular(context.responsiveSize(20)),
                    border: Border.all(
                      color: exhausted
                          ? Colors.red.shade200
                          : const Color(0xFF0047AB),
                      width: 1,
                    ),
                  ),
                  child: AppText(
                    data: '$remaining left',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: exhausted
                        ? Colors.red.shade600
                        : const Color(0xFF0047AB),
                    useResponsiveFontSize: false,
                  ),
                ),
              ],
            );
          }),
        ),

        SizedBox(height: context.responsiveSize(12)),

        // ── Tappable 16:9 image ────────────────────────────────────────
        Padding(
          padding:
          EdgeInsets.symmetric(horizontal: context.responsiveSize(16)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(context.responsiveSize(12)),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final imageSize =
                  Size(constraints.maxWidth, constraints.maxHeight);

                  return Obx(() {
                    // When taps exhausted — disable GestureDetector
                    final canTap = !controller.tapsExhausted &&
                        controller.timeRemaining.value > 0;

                    return GestureDetector(
                      onTapDown: canTap
                          ? (details) => controller.onImageTapped(
                        details.localPosition,
                        imageSize,
                      )
                          : null,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Image — slight dim when exhausted
                          Opacity(
                            opacity: controller.tapsExhausted ? 0.75 : 1.0,
                            child: Image.network(
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
                          ),

                          // Tap markers
                          Obx(() => Stack(
                            children: controller.currentTaps
                                .asMap()
                                .entries
                                .map((entry) {
                              final i   = entry.key;
                              final tap = entry.value;
                              final isCorrect =
                                  tap.result == TapResult.correct;
                              final left = (tap.x / 100) *
                                  constraints.maxWidth -
                                  16;
                              final top = (tap.y / 100) *
                                  constraints.maxHeight -
                                  16;

                              return Positioned(
                                left: left,
                                top: top,
                                child: GestureDetector(
                                  // Only wrong taps can be removed
                                  onLongPress: isCorrect
                                      ? null
                                      : () => controller.removeTap(i),
                                  child: Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: isCorrect
                                          ? Colors.green.withOpacity(0.9)
                                          : Colors.red.withOpacity(0.9),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: Colors.white, width: 2),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black
                                              .withOpacity(0.3),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      isCorrect
                                          ? Icons.check
                                          : Icons.close,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          )),
                        ],
                      ),
                    );
                  });
                },
              ),
            ),
          ),
        ),

        SizedBox(height: context.responsiveSize(16)),

        // Live score row
        Obx(() => Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline,
                color: Colors.green, size: context.responsiveSize(18)),
            SizedBox(width: context.responsiveSize(4)),
            AppText(
              data: '${controller.currentCorrectCount} correct',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.green.shade700,
              useResponsiveFontSize: true,
            ),
            SizedBox(width: context.responsiveSize(16)),
            Icon(Icons.cancel_outlined,
                color: Colors.red, size: context.responsiveSize(18)),
            SizedBox(width: context.responsiveSize(4)),
            AppText(
              data: '${controller.currentWrongCount} wrong',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.red.shade700,
              useResponsiveFontSize: true,
            ),
            SizedBox(width: context.responsiveSize(16)),
            // Icon(Icons.info_outline,
            //     color: const Color(0xFF9E9E9E),
            //     size: context.responsiveSize(16)),
            // SizedBox(width: context.responsiveSize(4)),
            // AppText(
            //   data: 'Long-press ❌ to remove',
            //   fontSize: 11,
            //   fontWeight: FontWeight.w400,
            //   color: const Color(0xFF9E9E9E),
            //   useResponsiveFontSize: true,
            // ),
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

  Widget _buildResults(BuildContext context, PuzzleGameController controller) {
    final result = controller.gameResult.value;
    if (result == null) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.responsiveSize(24)),
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

          GameScoreCard(
            score: result.score,
            total: result.totalPossibleScore,
          ),

          SizedBox(height: context.responsiveSize(16)),

          Container(
            padding: EdgeInsets.all(context.responsiveSize(16)),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FB),
              borderRadius:
              BorderRadius.circular(context.responsiveSize(12)),
              border: Border.all(
                  color: const Color(0xFFF0F0F0), width: 1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _statItem(context, '✅', 'Correct',
                    '${result.totalCorrect}', Colors.green.shade700),
                _statItem(context, '❌', 'Wrong',
                    '${result.totalWrong}', Colors.red.shade700),
                _statItem(context, '🎯', 'Missed',
                    '${result.totalMissed}', Colors.orange.shade700),
                _statItem(context, '📊', 'Score',
                    '${result.percentage.toStringAsFixed(0)}%',
                    const Color(0xFF0047AB)),
              ],
            ),
          ),

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

  Widget _statItem(BuildContext context, String emoji, String label,
      String value, Color color) {
    return Column(
      children: [
        Text(emoji,
            style:
            TextStyle(fontSize: context.responsiveFontSize(20))),
        SizedBox(height: context.responsiveSize(4)),
        AppText(
          data: value,
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: color,
          useResponsiveFontSize: true,
        ),
        AppText(
          data: label,
          fontSize: 11,
          fontWeight: FontWeight.w400,
          color: const Color(0xFF9E9E9E),
          useResponsiveFontSize: true,
        ),
      ],
    );
  }

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