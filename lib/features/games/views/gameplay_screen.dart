// features/game/views/gameplay_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/util/screen_size.dart';
import '../../../core/widgets/text/app_text.dart';
import '../controllers/game_play_controller.dart';
import '../models/game_play_model.dart';
import '../widgets/game_score_card.dart';
import '../widgets/game_timer_bar.dart';

class GameplayScreen extends StatelessWidget {
  const GameplayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(GamePlayController(timePerRound: 20));

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Obx(() {
          final state = controller.gameState.value;

          if (state == GameState.finished) {
            return _buildFinalResults(context, controller);
          }

          if (state == GameState.roundComplete) {
            return _buildRoundComplete(context, controller);
          }

          // Playing state
          return Column(
            children: [
              SizedBox(height: context.responsiveSize(12)),

              // Round label
              AppText(
                data: controller.roundProgress,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF9E9E9E),
                useResponsiveFontSize: true,
              ),

              SizedBox(height: context.responsiveSize(8)),

              // Timer
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: context.responsiveSize(24)),
                child: GameTimerBar(
                  timerText: controller.timerText,
                  progress: controller.timerProgress,
                  onClose: () => _showExitDialog(context, controller),
                ),
              ),

              SizedBox(height: context.responsiveSize(12)),

              // Round content
              Expanded(
                child: controller.isHazardRound
                    ? _buildHazardRound(context, controller)
                    : _buildQuizRound(context, controller),
              ),
            ],
          );
        }),
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // HAZARD ROUND
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildHazardRound(
      BuildContext context, GamePlayController controller) {
    final round = controller.currentRound?.hazardRound;
    if (round == null) return const SizedBox.shrink();

    return Column(
      children: [
        // Rig image with spots
        Expanded(
          flex: 3,
          child: Padding(
            padding:
            EdgeInsets.symmetric(horizontal: context.responsiveSize(16)),
            child: ClipRRect(
              borderRadius:
              BorderRadius.circular(context.responsiveSize(16)),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        round.imagePath,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: const Color(0xFFE8F4FC),
                          child: Center(
                            child: Icon(Icons.image,
                                size: context.responsiveSize(80),
                                color: Colors.grey),
                          ),
                        ),
                      ),
                      ...round.spots.map((spot) => Positioned(
                        left: spot.xPercent * constraints.maxWidth - 20,
                        top: spot.yPercent * constraints.maxHeight - 20,
                        child: _buildSpotMarker(
                            context, controller, spot),
                      )),
                    ],
                  );
                },
              ),
            ),
          ),
        ),

        SizedBox(height: context.responsiveSize(16)),

        // Progress text
        Obx(() => Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.warning_amber_rounded,
                color: const Color(0xFFFFAA00),
                size: context.responsiveSize(20)),
            SizedBox(width: context.responsiveSize(8)),
            AppText(
              data:
              'Tap On Unsafe Condition Found (${controller.hazardsFound.value}/${round.totalHazards})',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1A1A),
              useResponsiveFontSize: true,
            ),
          ],
        )),

        SizedBox(height: context.responsiveSize(16)),

        // Live score
        Padding(
          padding:
          EdgeInsets.symmetric(horizontal: context.responsiveSize(40)),
          child: Obx(() => GameScoreCard(
            score: controller.hazardsFound.value,
            total: round.totalHazards,
          )),
        ),

        SizedBox(height: context.responsiveSize(20)),
      ],
    );
  }

  Widget _buildSpotMarker(
      BuildContext context,
      GamePlayController controller,
      HazardSpot spot,
      ) {
    return Obx(() {
      final isTapped = controller.tappedSpots.containsKey(spot.id);
      final isCorrect = controller.tappedSpots[spot.id];

      if (isTapped) {
        return Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: (isCorrect == true)
                ? Colors.green.withOpacity(0.9)
                : Colors.red.withOpacity(0.9),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 2)),
            ],
          ),
          child: Icon(
            (isCorrect == true) ? Icons.check : Icons.close,
            color: Colors.white,
            size: 22,
          ),
        );
      }

      return GestureDetector(
        onTap: () => controller.onSpotTapped(spot),
        child: Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            color: Colors.transparent,
            shape: BoxShape.circle,
          ),
        ),
      );
    });
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // QUIZ ROUND
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildQuizRound(
      BuildContext context, GamePlayController controller) {
    final question = controller.currentRound?.quizQuestion;
    if (question == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      padding:
      EdgeInsets.symmetric(horizontal: context.responsiveSize(16)),
      child: Column(
        children: [
          // Question image
          ClipRRect(
            borderRadius:
            BorderRadius.circular(context.responsiveSize(16)),
            child: Image.asset(
              question.imagePath,
              width: double.infinity,
              height: context.responsiveSize(200),
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: double.infinity,
                height: context.responsiveSize(200),
                color: const Color(0xFFE8F4FC),
                child: Center(
                    child: Icon(Icons.image,
                        size: context.responsiveSize(60),
                        color: Colors.grey)),
              ),
            ),
          ),

          SizedBox(height: context.responsiveSize(24)),

          // Question text
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: context.responsiveSize(8)),
            child: AppText(
              data: question.question,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1A1A),
              useResponsiveFontSize: true,
              textAlign: TextAlign.center,
              maxLines: 3,
            ),
          ),

          SizedBox(height: context.responsiveSize(24)),

          // Options 2×2
          Obx(() => _buildOptionsGrid(context, controller, question)),

          SizedBox(height: context.responsiveSize(24)),

          // Score card
          Obx(() => GameScoreCard(
            score: controller.answeredCorrectly.value ? 1 : 0,
            total: 1,
          )),

          SizedBox(height: context.responsiveSize(24)),
        ],
      ),
    );
  }

  Widget _buildOptionsGrid(BuildContext context,
      GamePlayController controller, QuizQuestion question) {
    return Wrap(
      spacing: context.responsiveSize(12),
      runSpacing: context.responsiveSize(12),
      alignment: WrapAlignment.center,
      children: question.options
          .map((o) => _buildOptionButton(context, controller, o))
          .toList(),
    );
  }

  Widget _buildOptionButton(BuildContext context,
      GamePlayController controller, QuizOption option) {
    final isSelected = controller.isOptionSelected(option.id);
    final hasAnswered = controller.hasAnswered.value;
    final isCorrect = controller.isOptionCorrect(option.id);

    Color bgColor = Colors.white;
    Color borderColor = const Color(0xFFE0E0E0);
    Color textColor = const Color(0xFF1A1A1A);

    if (hasAnswered) {
      if (isCorrect) {
        bgColor = const Color(0xFFE8F5E9);
        borderColor = Colors.green;
        textColor = Colors.green.shade800;
      } else if (isSelected && !isCorrect) {
        bgColor = const Color(0xFFFFEBEE);
        borderColor = Colors.red;
        textColor = Colors.red.shade800;
      }
    } else if (isSelected) {
      bgColor = const Color(0xFFE3F2FD);
      borderColor = const Color(0xFF0047AB);
      textColor = const Color(0xFF0047AB);
    }

    final buttonWidth =
        (context.screenWidth - context.responsiveSize(24 + 16 + 12)) / 2;

    return GestureDetector(
      onTap: () => controller.selectOption(option.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: buttonWidth,
        padding: EdgeInsets.symmetric(
          horizontal: context.responsiveSize(16),
          vertical: context.responsiveSize(14),
        ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius:
          BorderRadius.circular(context.responsiveSize(12)),
          border: Border.all(color: borderColor, width: 1.5),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(option.emoji,
                style: TextStyle(
                    fontSize: context.responsiveFontSize(18))),
            SizedBox(width: context.responsiveSize(8)),
            Flexible(
              child: AppText(
                data: option.label,
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: textColor,
                useResponsiveFontSize: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // ROUND COMPLETE — transition screen
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildRoundComplete(
      BuildContext context, GamePlayController controller) {
    final roundIdx = controller.currentRoundIndex.value;
    final roundScore = controller.roundScores.isNotEmpty
        ? controller.roundScores[roundIdx]
        : 0;
    final roundTotal = controller.roundTotals.isNotEmpty
        ? controller.roundTotals[roundIdx]
        : 0;
    final wasHazard =
        controller.rounds[roundIdx].type == RoundType.hazard;

    return Padding(
      padding:
      EdgeInsets.symmetric(horizontal: context.responsiveSize(24)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Round type icon
          Container(
            width: context.responsiveSize(80),
            height: context.responsiveSize(80),
            decoration: BoxDecoration(
              color: const Color(0xFFE6F0FF),
              shape: BoxShape.circle,
            ),
            child: Icon(
              wasHazard ? Icons.touch_app_outlined : Icons.quiz_outlined,
              color: const Color(0xFF0047AB),
              size: context.responsiveSize(40),
            ),
          ),

          SizedBox(height: context.responsiveSize(20)),

          AppText(
            data: wasHazard
                ? 'Hazard Round Complete!'
                : 'Quiz Round Complete!',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF003E9A),
            useResponsiveFontSize: true,
            textAlign: TextAlign.center,
          ),

          SizedBox(height: context.responsiveSize(24)),

          GameScoreCard(score: roundScore, total: roundTotal),

          SizedBox(height: context.responsiveSize(16)),

          AppText(
            data: 'Next: ${controller.rounds[roundIdx + 1].type == RoundType.hazard ? 'Spot the Hazard' : 'Quiz Question'}',
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF6B6B6B),
            useResponsiveFontSize: true,
          ),

          SizedBox(height: context.responsiveSize(40)),

          // Continue button
          GestureDetector(
            onTap: () => controller.nextRound(),
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
                child: AppText(
                  data: 'Continue',
                  fontSize: 18,
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

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // FINAL RESULTS
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildFinalResults(
      BuildContext context, GamePlayController controller) {
    return Padding(
      padding:
      EdgeInsets.symmetric(horizontal: context.responsiveSize(24)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.emoji_events,
            color: const Color(0xFFFFAA00),
            size: context.responsiveSize(80),
          ),

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

          // Total score
          GameScoreCard(
            score: controller.totalScore.value,
            total: controller.totalPossible.value,
          ),

          SizedBox(height: context.responsiveSize(16)),

          // Per-round breakdown
          ...List.generate(controller.rounds.length, (i) {
            final round = controller.rounds[i];
            final rScore =
            i < controller.roundScores.length ? controller.roundScores[i] : 0;
            final rTotal =
            i < controller.roundTotals.length ? controller.roundTotals[i] : 0;
            final icon = round.type == RoundType.hazard
                ? Icons.touch_app_outlined
                : Icons.quiz_outlined;
            final label = round.type == RoundType.hazard
                ? 'Spot the Hazard'
                : 'Quiz';

            return Padding(
              padding: EdgeInsets.only(bottom: context.responsiveSize(8)),
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
                    Icon(icon,
                        color: const Color(0xFF0047AB),
                        size: context.responsiveSize(22)),
                    SizedBox(width: context.responsiveSize(12)),
                    Expanded(
                      child: AppText(
                        data: label,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1A1A1A),
                        useResponsiveFontSize: true,
                      ),
                    ),
                    AppText(
                      data: '$rScore/$rTotal',
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0047AB),
                      useResponsiveFontSize: true,
                    ),
                  ],
                ),
              ),
            );
          }),

          SizedBox(height: context.responsiveSize(32)),

          // Play Again
          // GestureDetector(
          //   onTap: () => controller.playAgain(),
          //   child: Container(
          //     width: double.infinity,
          //     padding: EdgeInsets.symmetric(
          //         vertical: context.responsiveSize(14)),
          //     decoration: BoxDecoration(
          //       color: const Color(0xFF0047AB),
          //       borderRadius:
          //       BorderRadius.circular(context.responsiveSize(12)),
          //     ),
          //     child: Center(
          //       child: AppText(
          //         data: 'Play Again',
          //         fontSize: 18,
          //         fontWeight: FontWeight.w600,
          //         color: Colors.white,
          //         useResponsiveFontSize: true,
          //       ),
          //     ),
          //   ),
          // ),

          SizedBox(height: context.responsiveSize(16)),

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

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // EXIT DIALOG
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  void _showExitDialog(
      BuildContext context, GamePlayController controller) {
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