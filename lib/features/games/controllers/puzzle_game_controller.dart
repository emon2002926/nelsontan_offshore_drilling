import 'dart:async';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../core/services/api_services.dart';
import '../../../core/util/storage_service.dart';
import '../../../core/widgets/snakbar/custom_snackbar.dart';
import '../../../home_page.dart';
import '../models/puzzle_model.dart';

enum PuzzleGameState { loading, playing, submitting, finished }

class PuzzleGameController extends GetxController {
  final ApiServices _api = Get.find<ApiServices>();

  // ─── Game data ────────────────────────────────────────────────────────────
  final RxList<PuzzleModel> puzzles   = <PuzzleModel>[].obs;
  final RxBool              isLoading = true.obs;
  final Rx<PuzzleGameState> gameState = PuzzleGameState.loading.obs;

  // ─── Progress ─────────────────────────────────────────────────────────────
  final RxInt currentIndex  = 0.obs;
  final RxInt timeRemaining = 60.obs;
  Timer? _timer;

  // ─── User taps for current puzzle ─────────────────────────────────────────
  // Stores each tap with its hit result (correct/wrong)
  final RxList<UserTap> currentTaps = <UserTap>[].obs;

  // ─── Per-puzzle score tracking ────────────────────────────────────────────
  // puzzleId → { correct, wrong }
  final Map<int, ({int correct, int wrong})> _puzzleScores = {};

  Map<int, ({int correct, int wrong})> get puzzleScores => _puzzleScores;

  // ─── Result from server ───────────────────────────────────────────────────
  final Rx<PuzzleResultModel?> gameResult = Rx<PuzzleResultModel?>(null);

  // ─── Computed ─────────────────────────────────────────────────────────────
  PuzzleModel? get currentPuzzle {
    if (puzzles.isEmpty || currentIndex.value >= puzzles.length) return null;
    return puzzles[currentIndex.value];
  }

  bool get isLastPuzzle => currentIndex.value >= puzzles.length - 1;

  double get timerProgress {
    final total = currentPuzzle?.time ?? 60;
    return total == 0 ? 0 : timeRemaining.value / total;
  }

  String get timerText {
    final m = (timeRemaining.value ~/ 60).toString().padLeft(2, '0');
    final s = (timeRemaining.value % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  String get puzzleProgress =>
      'Puzzle ${currentIndex.value + 1} of ${puzzles.length}';

  int get currentCorrectCount =>
      currentTaps.where((t) => t.result == TapResult.correct).length;

  int get currentWrongCount =>
      currentTaps.where((t) => t.result == TapResult.wrong).length;

  @override
  void onInit() {
    super.onInit();
    _fetchGame();
  }

  // ─── Fetch ────────────────────────────────────────────────────────────────
  Future<void> _fetchGame() async {
    final token = StorageService.accessToken;
    if (token == null || token.isEmpty) {
      CustomSnackBar.error('Session expired. Please sign in again.');
      return;
    }

    isLoading.value = true;
    try {
      final raw  = await _api.get(
        '/game',
        headers: {'Authorization': 'Bearer $token'},
      );

      final data    = raw['data'] as Map<String, dynamic>;
      final rawList = data['puzzles'] as List<dynamic>? ?? [];
      final loaded  = rawList
          .map((e) => PuzzleModel.fromJson(e as Map<String, dynamic>))
          .toList();

      if (loaded.isEmpty) {
        CustomSnackBar.info('No puzzles available for today.');
        return;
      }

      puzzles.assignAll(loaded);
      _startPuzzle();
    } on HttpException catch (e) {
      CustomSnackBar.error(e.message);
    } catch (e) {
      CustomSnackBar.error('Failed to load puzzle. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  // ─── Puzzle lifecycle ─────────────────────────────────────────────────────
  void _startPuzzle() {
    final p = currentPuzzle;
    if (p == null) return;

    timeRemaining.value = p.time;
    currentTaps.clear();
    gameState.value = PuzzleGameState.playing;

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

  void _onTimeUp() {
    _timer?.cancel();
    _saveScoreForCurrentPuzzle();
    // Don't auto-advance — user taps Next/Done
  }

  void _saveScoreForCurrentPuzzle() {
    final p = currentPuzzle;
    if (p == null) return;
    _puzzleScores[p.id] = (
    correct: currentCorrectCount,
    wrong: currentWrongCount,
    );
  }

  // ─── User taps on image ───────────────────────────────────────────────────
  void onImageTapped(Offset localPosition, Size imageSize) {
    if (gameState.value != PuzzleGameState.playing) return;
    if (timeRemaining.value == 0) return;

    final tapX = (localPosition.dx / imageSize.width) * 100;
    final tapY = (localPosition.dy / imageSize.height) * 100;

    // Check if tap hits any hazard mark using ellipse formula
    final puzzle = currentPuzzle;
    if (puzzle == null) return;

    final hitMark = puzzle.marks.any((mark) => mark.containsTap(tapX, tapY));

    currentTaps.add(UserTap(
      x: tapX,
      y: tapY,
      result: hitMark ? TapResult.correct : TapResult.wrong,
    ));
  }

  // Remove a tap (long-press)
  void removeTap(int index) {
    if (index < currentTaps.length) {
      currentTaps.removeAt(index);
    }
  }

  // ─── Next / Done ──────────────────────────────────────────────────────────
  void onNext() {
    _saveScoreForCurrentPuzzle();

    if (isLastPuzzle) {
      _submitAnswers();
    } else {
      _timer?.cancel();
      currentIndex.value++;
      _startPuzzle();
    }
  }

  // ─── Submit ───────────────────────────────────────────────────────────────
  Future<void> _submitAnswers() async {
    final token = StorageService.accessToken;
    if (token == null || token.isEmpty) {
      CustomSnackBar.error('Session expired. Please sign in again.');
      return;
    }

    gameState.value = PuzzleGameState.submitting;

    try {
      final items = _puzzleScores.entries
          .map((e) => PuzzleSubmitItem(
        puzzleId: e.key,
        correct: e.value.correct,
        wrong: e.value.wrong,
      ))
          .toList();

      final body = PuzzleSubmitRequest(puzzles: items).toJson();

      final raw = await _api.post(
        '/game/puzzle-submit',
        headers: {'Authorization': 'Bearer $token'},
        body: body,
      );

      gameResult.value = PuzzleResultModel.fromJson(
        raw['data'] as Map<String, dynamic>,
      );

      gameState.value = PuzzleGameState.finished;
    } on HttpException catch (e) {
      gameState.value = PuzzleGameState.playing;
      CustomSnackBar.error(e.message);
    } catch (e) {
      gameState.value = PuzzleGameState.playing;
      CustomSnackBar.error('Failed to submit. Please try again.');
    }
  }

  // ─── Exit ─────────────────────────────────────────────────────────────────
  void exitGame(BuildContext context) {
    Navigator.of(context).pop();
    Get.delete<PuzzleGameController>();
    context.findAncestorStateOfType<BasePageState>()?.onTabSelected(2);
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}