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
  final RxList<PuzzleModel>   puzzles   = <PuzzleModel>[].obs;
  final RxBool                isLoading = true.obs;
  final Rx<PuzzleGameState>   gameState = PuzzleGameState.loading.obs;

  // ─── Progress ─────────────────────────────────────────────────────────────
  final RxInt currentIndex  = 0.obs;
  final RxInt timeRemaining = 60.obs;
  Timer? _timer;

  // ─── User taps for current puzzle — {x%, y%} ─────────────────────────────
  final RxList<PuzzleMark> currentTaps = <PuzzleMark>[].obs;

  // ─── Collected taps per puzzle — submitted all at once at the end ─────────
  // puzzleId → list of user taps
  final Map<int, List<PuzzleMark>> _collectedTaps = {};

  // Public getter so the results screen can read collected taps
  Map<int, List<PuzzleMark>> get collectedTaps => _collectedTaps;

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
      final raw = await _api.get(
        '/game',
        headers: {'Authorization': 'Bearer $token'},
      );

      final data     = raw['data'] as Map<String, dynamic>;
      final rawList  = data['puzzles'] as List<dynamic>? ?? [];
      final loaded   = rawList
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
    // Save whatever taps the user made before time ran out
    _saveTapsForCurrentPuzzle();
    // Don't auto advance — show Done button so user sees time is up
    // Force hasAnswered state by stopping timer (UI checks timer == 0)
  }

  void _saveTapsForCurrentPuzzle() {
    final p = currentPuzzle;
    if (p == null) return;
    _collectedTaps[p.id] = List.from(currentTaps);
  }

  // ─── User taps on image ───────────────────────────────────────────────────
  void onImageTapped(Offset localPosition, Size imageSize) {
    if (gameState.value != PuzzleGameState.playing) return;
    if (timeRemaining.value == 0) return;

    // Convert tap to percentage
    final xPercent = (localPosition.dx / imageSize.width) * 100;
    final yPercent = (localPosition.dy / imageSize.height) * 100;

    currentTaps.add(PuzzleMark(x: xPercent, y: yPercent));
  }

  // Remove a tap if user long-presses a marker
  void removeTap(int index) {
    if (index < currentTaps.length) {
      currentTaps.removeAt(index);
    }
  }

  // ─── Next / Done button ───────────────────────────────────────────────────
  void onNext() {
    _saveTapsForCurrentPuzzle();

    if (isLastPuzzle) {
      _submitAnswers();
    } else {
      _timer?.cancel();
      currentIndex.value++;
      _startPuzzle();
    }
  }

  // ─── Submit all taps to server ────────────────────────────────────────────
  Future<void> _submitAnswers() async {
    final token = StorageService.accessToken;
    if (token == null || token.isEmpty) {
      CustomSnackBar.error('Session expired. Please sign in again.');
      return;
    }

    gameState.value = PuzzleGameState.submitting;

    try {
      final items = _collectedTaps.entries
          .map((e) => PuzzleSubmitItem(
        puzzleId: e.key,
        marks: e.value,
      ))
          .toList();

      final body = PuzzleSubmitRequest(puzzles: items).toJson();

      final raw = await _api.post(
        '/game/puzzle-submit',
        headers: {'Authorization': 'Bearer $token'},
        body: body,
      );

      // TODO: update PuzzleResultModel.fromJson when real response is known
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