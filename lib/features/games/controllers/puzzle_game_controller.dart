import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
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


  // ─── Audio ────────────────────────────────────────────────────────────────
  final AudioPlayer _audioPlayer = AudioPlayer();

  Future<void> _playCorrectSound() async {
    await _audioPlayer.stop();
    await _audioPlayer.play(AssetSource('audio/correct.mp3'));
  }

  Future<void> _playWrongSound() async {
    await _audioPlayer.stop();
    await _audioPlayer.play(AssetSource('audio/wrong.mp3'));
  }


  // ─── Progress ─────────────────────────────────────────────────────────────
  final RxInt currentIndex  = 0.obs;
  final RxInt timeRemaining = 60.obs;
  Timer? _timer;

  // ─── User taps for current puzzle ─────────────────────────────────────────
  final RxList<UserTap> currentTaps = <UserTap>[].obs;

  // ─── Indices of marks already correctly found — prevents re-tapping ───────
  final RxSet<int> foundMarkIndices = <int>{}.obs;

  // ─── Per-puzzle score tracking ────────────────────────────────────────────
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

  // Remaining taps user can make (= marksLength - total taps so far)
  int get remainingTaps {
    final limit = currentPuzzle?.marksLength ?? 0;
    return (limit - currentTaps.length).clamp(0, limit);
  }

  // True when user has used all allowed taps
  bool get tapsExhausted => remainingTaps == 0;

  // True when all marks have been correctly found
  bool get allMarksFound {
    final puzzle = currentPuzzle;
    if (puzzle == null) return false;
    return foundMarkIndices.length >= puzzle.marks.length;
  }

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
    foundMarkIndices.clear();
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
  }

  void _saveScoreForCurrentPuzzle() {
    final p = currentPuzzle;
    if (p == null) return;
    _puzzleScores[p.id] = (
    correct: currentCorrectCount,
    wrong: currentWrongCount,
    );
  }

  // Fixed exclusion radius for wrong taps (in percentage units)
  static const double _wrongTapRadius = 5.0;

  // ─── User taps on image ───────────────────────────────────────────────────
  void onImageTapped(Offset localPosition, Size imageSize) {
    if (gameState.value != PuzzleGameState.playing) return;
    if (timeRemaining.value == 0) return;
    if (tapsExhausted) return;

    final tapX = (localPosition.dx / imageSize.width) * 100;
    final tapY = (localPosition.dy / imageSize.height) * 100;

    final puzzle = currentPuzzle;
    if (puzzle == null) return;

    final alreadyClaimed = currentTaps.any((t) {
      const rx = _wrongTapRadius;
      const ry = _wrongTapRadius;
      final dx = (tapX - t.x) / rx;
      final dy = (tapY - t.y) / ry;
      return (dx * dx + dy * dy) <= 1.0;
    });

    if (alreadyClaimed) return;

    int? hitMarkIndex;
    for (int i = 0; i < puzzle.marks.length; i++) {
      if (foundMarkIndices.contains(i)) continue;
      if (puzzle.marks[i].containsTap(tapX, tapY)) {
        hitMarkIndex = i;
        break;
      }
    }

    final isCorrect = hitMarkIndex != null;
    if (isCorrect) {
      foundMarkIndices.add(hitMarkIndex);
      _playCorrectSound(); // ✅ correct sound
    } else {
      _playWrongSound();   // ❌ wrong sound
    }

    currentTaps.add(UserTap(
      x: tapX,
      y: tapY,
      result: isCorrect ? TapResult.correct : TapResult.wrong,
    ));
  }
  // Only wrong taps can be removed — and only when taps not exhausted
  void removeTap(int index) {
    if (index >= currentTaps.length) return;
    if (tapsExhausted) return;
    final tap = currentTaps[index];
    if (tap.result == TapResult.wrong) {
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
    _audioPlayer.dispose(); // ← add this
    super.onClose();
  }
}