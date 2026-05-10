  import 'dart:async';
  import 'package:flutter/material.dart';
  import 'package:get/get.dart';
  import '../../../core/services/api_services.dart';
  import '../../../core/util/storage_service.dart';
  import '../../../core/widgets/snakbar/custom_snackbar.dart';
  import '../../../base_page.dart';
  import '../models/game_models.dart';

  enum GameState { loading, playing, submitting, finished }

  class GamePlayController extends GetxController {
    final ApiServices _api = Get.find<ApiServices>();

    // ─── Game data ────────────────────────────────────────────────────────────
    final RxList<GameQuestion> questions = <GameQuestion>[].obs;
    final RxBool               isLoading = true.obs;
    final Rx<GameState>        gameState = GameState.loading.obs;

    // ─── Progress ─────────────────────────────────────────────────────────────
    final RxInt currentIndex = 0.obs;

    // ─── Collected answers — submitted all at once at the end ─────────────────
    // questionId → selected option index (1-based)
    final Map<int, int> _collectedAnswers = {};

    // ─── Server result ────────────────────────────────────────────────────────
    final Rx<GameResultModel?> gameResult = Rx<GameResultModel?>(null);

    // ─── Current question state ───────────────────────────────────────────────
    final RxInt  selectedOption = (-1).obs; // 0-3 (0-based), -1 = none
    final RxBool hasAnswered    = false.obs;
    final RxInt  timeRemaining  = 30.obs;
    Timer? _timer;

    // ─── Computed ─────────────────────────────────────────────────────────────
    GameQuestion? get currentQuestion {
      if (questions.isEmpty || currentIndex.value >= questions.length) return null;
      return questions[currentIndex.value];
    }

    bool get isLastQuestion => currentIndex.value >= questions.length - 1;

    double get timerProgress {
      final total = currentQuestion?.time ?? 30;
      return total == 0 ? 0 : timeRemaining.value / total;
    }

    String get timerText {
      final m = (timeRemaining.value ~/ 60).toString().padLeft(2, '0');
      final s = (timeRemaining.value % 60).toString().padLeft(2, '0');
      return '$m:$s';
    }

    String get questionProgress =>
        'Question ${currentIndex.value + 1} of ${questions.length}';

    @override
    void onInit() {
      super.onInit();
      _fetchGame();
    }

    // ─── Fetch game ───────────────────────────────────────────────────────────
    Future<void> _fetchGame() async {
      final token = StorageService.accessToken;
      if (token == null || token.isEmpty) {
        CustomSnackBar.error('Session expired. Please sign in again.');
        return;
      }

      isLoading.value = true;
      try {
        final raw = await _api.get(
          '/game',
          headers: {'Authorization': 'Bearer $token'},
        );

        final schedule = GameScheduleModel.fromJson(
          raw['data'] as Map<String, dynamic>,
        );

        if (schedule.questions.isEmpty) {
          CustomSnackBar.info('No questions available for today.');
          return;
        }

        questions.assignAll(schedule.questions);
        _startQuestion();
      } on HttpException catch (e) {
        CustomSnackBar.error(e.message);
      } catch (e) {
        CustomSnackBar.error('Failed to load game. Please try again.');
      } finally {
        isLoading.value = false;
      }
    }

    // ─── Question lifecycle ───────────────────────────────────────────────────
    void _startQuestion() {
      final q = currentQuestion;
      if (q == null) return;

      timeRemaining.value  = q.time;
      selectedOption.value = -1;
      hasAnswered.value    = false;
      gameState.value      = GameState.playing;

      _startTimer();
    }

    void _startTimer() {
      _timer?.cancel();
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (timeRemaining.value > 0) {
          timeRemaining.value--;
        } else {
          _onTimeUp();
        }
      });
    }

    // Time up — record no answer (0 = unanswered, server will mark wrong)
    void _onTimeUp() {
      _timer?.cancel();
      if (!hasAnswered.value) {
        hasAnswered.value = true;
        // Don't add to _collectedAnswers — server will treat as wrong
      }
    }

    // ─── User selects an option ───────────────────────────────────────────────
    void selectOption(int index) {
      if (hasAnswered.value || gameState.value != GameState.playing) return;
      _timer?.cancel();

      selectedOption.value = index;
      hasAnswered.value    = true;

      // Collect answer — convert 0-based index → 1-based for API
      final q = currentQuestion;
      if (q != null) {
        _collectedAnswers[q.id] = index + 1;
      }
    }

    // ─── Next button ──────────────────────────────────────────────────────────
    void onNext() {
      if (isLastQuestion) {
        _submitAnswers();
      } else {
        currentIndex.value++;
        _startQuestion();
      }
    }

    // ─── Submit all answers to server ────────────────────────────────────────
    Future<void> _submitAnswers() async {
      final token = StorageService.accessToken;
      if (token == null || token.isEmpty) {
        CustomSnackBar.error('Session expired. Please sign in again.');
        return;
      }

      gameState.value = GameState.submitting;

      try {
        // Build answer list — only questions the user actually answered
        final answerItems = _collectedAnswers.entries
            .map((e) => GameAnswerItem(
          questionId: e.key,
          correctAnswer: e.value,
        ))
            .toList();

        final body = GameAnswerRequest(answers: answerItems).toJson();

        final raw = await _api.post(
          '/game/question-submit',
          headers: {'Authorization': 'Bearer $token'},
          body: body,
        );

        gameResult.value = GameResultModel.fromJson(
          raw['data'] as Map<String, dynamic>,
        );

        gameState.value = GameState.finished;
      } on HttpException catch (e) {
        gameState.value = GameState.playing; // revert so user isn't stuck
        CustomSnackBar.error(e.message);
      } catch (e) {
        gameState.value = GameState.playing;
        CustomSnackBar.error('Failed to submit answers. Please try again.');
      }
    }

    // ─── Exit ─────────────────────────────────────────────────────────────────
    void exitGame(BuildContext context) {
      // Use the nested navigator (gameNavKey) to pop — avoids black screen
      Navigator.of(context).pop();
      Get.delete<GamePlayController>();
      context.findAncestorStateOfType<BasePageState>()?.onTabSelected(2);
    }

    @override
    void onClose() {
      _timer?.cancel();
      super.onClose();
    }
  }