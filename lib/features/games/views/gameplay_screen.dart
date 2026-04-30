import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/util/screen_size.dart';
import '../../../core/widgets/buttons/app_button.dart';
import '../../../core/widgets/text/app_text.dart';
import '../controllers/game_play_controller.dart';
import '../models/game_models.dart';
import '../models/game_play_model.dart';
import '../widgets/game_score_card.dart';
import '../widgets/game_timer_bar.dart';

class GameplayScreen extends StatelessWidget {
  const GameplayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<GamePlayController>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF0047AB)),
            );
          }

          if (controller.gameState.value == GameState.submitting) {
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

          if (controller.gameState.value == GameState.finished) {
            return _buildResults(context, controller);
          }

          return _buildQuestion(context, controller);
        }),
      ),
    );
  }

  // ── Question screen ───────────────────────────────────────────────────────

  Widget _buildQuestion(BuildContext context, GamePlayController controller) {
    final question = controller.currentQuestion;
    if (question == null) return const SizedBox.shrink();

    return Column(
      children: [
        SizedBox(height: context.responsiveSize(12)),

        Obx(() => AppText(
          data: controller.questionProgress,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF9E9E9E),
          useResponsiveFontSize: true,
        )),

        SizedBox(height: context.responsiveSize(8)),

        Padding(
          padding: EdgeInsets.symmetric(horizontal: context.responsiveSize(24)),
          child: Obx(() => GameTimerBar(
            timerText: controller.timerText,
            progress: controller.timerProgress,
            onClose: () => _showExitDialog(context, controller),
          )),
        ),

        SizedBox(height: context.responsiveSize(12)),

        Expanded(
          child: SingleChildScrollView(
            padding:
            EdgeInsets.symmetric(horizontal: context.responsiveSize(16)),
            child: Column(
              children: [
                if (question.image != null)
                  ClipRRect(
                    borderRadius:
                    BorderRadius.circular(context.responsiveSize(16)),
                    child: Image.network(
                      question.image!,
                      width: double.infinity,
                      height: context.responsiveSize(200),
                      fit: BoxFit.cover,
                      loadingBuilder: (_, child, progress) {
                        if (progress == null) return child;
                        return Container(
                          width: double.infinity,
                          height: context.responsiveSize(200),
                          color: const Color(0xFFE8F4FC),
                          child: const Center(
                            child: CircularProgressIndicator(
                                color: Color(0xFF0047AB)),
                          ),
                        );
                      },
                      errorBuilder: (_, __, ___) => _imageFallback(context),
                    ),
                  ),

                SizedBox(height: context.responsiveSize(24)),

                AppText(
                  data: question.question,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A1A1A),
                  useResponsiveFontSize: true,
                  textAlign: TextAlign.center,
                  maxLines: 4,
                ),

                SizedBox(height: context.responsiveSize(24)),

                Obx(() => _buildOptions(context, controller, question)),

                SizedBox(height: context.responsiveSize(24)),

                Obx(() {
                  if (!controller.hasAnswered.value) return const SizedBox.shrink();
                  return GestureDetector(
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
                        child: AppText(
                          data: controller.isLastQuestion ? 'See Result' : 'Next',
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          useResponsiveFontSize: true,
                        ),
                      ),
                    ),
                  );
                }),

                SizedBox(height: context.responsiveSize(24)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Options ───────────────────────────────────────────────────────────────

  Widget _buildOptions(BuildContext context, GamePlayController controller,
      GameQuestion question) {
    const optionEmojis = ['🔵', '⚡', '⚙️', '💨'];

    return Wrap(
      spacing: context.responsiveSize(12),
      runSpacing: context.responsiveSize(12),
      alignment: WrapAlignment.center,
      children: List.generate(question.options.length, (i) {
        final isSelected  = controller.selectedOption.value == i;
        final hasAnswered = controller.hasAnswered.value;
        final isCorrect   = (question.correctAnswer - 1) == i;

        Color bgColor     = Colors.white;
        Color borderColor = const Color(0xFFE0E0E0);
        Color textColor   = const Color(0xFF1A1A1A);

        if (hasAnswered) {
          if (isCorrect) {
            bgColor     = const Color(0xFFE8F5E9);
            borderColor = Colors.green;
            textColor   = Colors.green.shade800;
          } else if (isSelected) {
            bgColor     = const Color(0xFFFFEBEE);
            borderColor = Colors.red;
            textColor   = Colors.red.shade800;
          }
        } else if (isSelected) {
          bgColor     = const Color(0xFFE3F2FD);
          borderColor = const Color(0xFF0047AB);
          textColor   = const Color(0xFF0047AB);
        }

        final buttonWidth =
            (context.screenWidth - context.responsiveSize(24 + 16 + 12)) / 2;

        return GestureDetector(
          onTap: () => controller.selectOption(i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: buttonWidth,
            padding: EdgeInsets.symmetric(
              horizontal: context.responsiveSize(16),
              vertical: context.responsiveSize(14),
            ),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(context.responsiveSize(12)),
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
                Text(optionEmojis[i],
                    style:
                    TextStyle(fontSize: context.responsiveFontSize(18))),
                SizedBox(width: context.responsiveSize(8)),
                Flexible(
                  child: AppText(
                    data: question.options[i],
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
      }),
    );
  }

  // ── Results — old style with GameScoreCard + per-question rows ────────────

  Widget _buildResults(BuildContext context, GamePlayController controller) {
    final result = controller.gameResult.value;
    if (result == null) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.responsiveSize(24)),
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

          // Score card — uses server values
          GameScoreCard(
            score: result.correctAnswers,
            total: result.totalQuestions,
          ),

          SizedBox(height: context.responsiveSize(16)),

          // Per-question breakdown
          Expanded(
            child: ListView.separated(
              itemCount: result.results.length,
              separatorBuilder: (_, __) =>
                  SizedBox(height: context.responsiveSize(8)),
              itemBuilder: (_, i) {
                final r = result.results[i];
                return Container(
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
                      Icon(
                        Icons.quiz_outlined,
                        color: const Color(0xFF0047AB),
                        size: context.responsiveSize(22),
                      ),
                      SizedBox(width: context.responsiveSize(12)),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText(
                              data: r.question,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1A1A1A),
                              useResponsiveFontSize: true,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (!r.isCorrect) ...[
                              SizedBox(height: context.responsiveSize(4)),
                              AppText(
                                data: 'Correct: ${r.correctAnswerText}',
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: Colors.green.shade700,
                                useResponsiveFontSize: true,
                              ),
                            ],
                          ],
                        ),
                      ),
                      SizedBox(width: context.responsiveSize(8)),
                      Text(
                        r.isCorrect ? '✅' : '❌',
                        style: TextStyle(
                            fontSize: context.responsiveFontSize(18)),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          SizedBox(height: context.responsiveSize(16)),



          AppButton(
            buttonText: 'Back to Games',
            onPressed: (){controller.exitGame(context);},
            fillColor: const Color(0xFF0047AB),
            textColor: Colors.white,
            // isLoading: controller.isUpdating.value,
            // loadingText: 'Back to Games',
          ),

          // GestureDetector(
          //   onTap: () => controller.exitGame(context),
          //   child: AppText(
          //     data: 'Back to Games',
          //     fontSize: 16,
          //     fontWeight: FontWeight.w600,
          //     color: const Color(0xFF0047AB),
          //     useResponsiveFontSize: true,
          //   ),
          // ),

          SizedBox(height: context.responsiveSize(24)),
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Widget _imageFallback(BuildContext context) {
    return Container(
      width: double.infinity,
      height: context.responsiveSize(200),
      color: const Color(0xFFE8F4FC),
      child: Center(
        child: Icon(Icons.image,
            size: context.responsiveSize(60), color: Colors.grey),
      ),
    );
  }

  void _showExitDialog(BuildContext context, GamePlayController controller) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Exit Game?'),
        content: const Text('Your progress will be lost. Are you sure?'),
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