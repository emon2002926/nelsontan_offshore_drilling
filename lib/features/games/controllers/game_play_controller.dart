// features/game/controllers/game_play_controller.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/util/app_navigation.dart';
import '../models/game_play_model.dart';

enum GameState { playing, roundComplete, finished }

class GamePlayController extends GetxController {
  // ─── Config ───
  final int timePerRound;

  GamePlayController({this.timePerRound = 20});

  // ─── Game state ───
  final Rx<GameState> gameState = GameState.playing.obs;
  final RxList<GameRound> rounds = <GameRound>[].obs;
  final RxInt currentRoundIndex = 0.obs;
  final RxInt timeRemaining = 0.obs;
  final RxInt totalScore = 0.obs;
  final RxInt totalPossible = 0.obs;
  Timer? _timer;

  // ─── Per-round scores (for final summary) ───
  final RxList<int> roundScores = <int>[].obs;
  final RxList<int> roundTotals = <int>[].obs;

  // ─── Hazard round state ───
  final RxMap<String, bool> tappedSpots = <String, bool>{}.obs;
  final RxInt hazardsFound = 0.obs;

  // ─── Quiz round state ───
  final Rx<String?> selectedOptionId = Rx<String?>(null);
  final RxBool hasAnswered = false.obs;
  final RxBool answeredCorrectly = false.obs;

  // ─── Computed ───
  GameRound? get currentRound {
    if (rounds.isEmpty || currentRoundIndex.value >= rounds.length) return null;
    return rounds[currentRoundIndex.value];
  }

  bool get isHazardRound => currentRound?.type == RoundType.hazard;
  bool get isQuizRound => currentRound?.type == RoundType.quiz;
  bool get isLastRound => currentRoundIndex.value >= rounds.length - 1;

  double get timerProgress {
    if (timePerRound == 0) return 0;
    return timeRemaining.value / timePerRound;
  }

  String get timerText {
    final m = (timeRemaining.value ~/ 60).toString().padLeft(2, '0');
    final s = (timeRemaining.value % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  String get roundLabel {
    final round = currentRound;
    if (round == null) return '';
    return round.type == RoundType.hazard ? 'Spot the Hazard' : 'Quiz';
  }

  String get roundProgress =>
      'Round ${currentRoundIndex.value + 1} of ${rounds.length}';

  @override
  void onInit() {
    super.onInit();
    _loadGame();
  }

  // ─── Load game data ───
  void _loadGame() {
    // TODO: Replace with API call later
    rounds.value = GameRound.dummyRounds();

    // Calculate total possible score
    for (final round in rounds) {
      if (round.type == RoundType.hazard) {
        totalPossible.value += round.hazardRound?.totalHazards ?? 0;
      } else {
        totalPossible.value += 1; // 1 point per quiz question
      }
    }

    _startRound();
  }

  // ─── Round lifecycle ───
  void _startRound() {
    timeRemaining.value = timePerRound;
    gameState.value = GameState.playing;

    // Reset hazard state
    tappedSpots.clear();
    hazardsFound.value = 0;

    // Reset quiz state
    selectedOptionId.value = null;
    hasAnswered.value = false;
    answeredCorrectly.value = false;

    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (timeRemaining.value > 0) {
        timeRemaining.value--;
      } else {
        _onRoundTimeUp();
      }
    });
  }

  void _onRoundTimeUp() {
    _timer?.cancel();

    // Record score for this round
    if (isHazardRound) {
      roundScores.add(hazardsFound.value);
      roundTotals.add(currentRound?.hazardRound?.totalHazards ?? 0);
      totalScore.value += hazardsFound.value;
    } else {
      final earned = answeredCorrectly.value ? 1 : 0;
      roundScores.add(earned);
      roundTotals.add(1);
      totalScore.value += earned;
    }

    if (isLastRound) {
      gameState.value = GameState.finished;
    } else {
      gameState.value = GameState.roundComplete;
    }
  }

  void _finishRoundEarly() {
    _timer?.cancel();

    if (isHazardRound) {
      roundScores.add(hazardsFound.value);
      roundTotals.add(currentRound?.hazardRound?.totalHazards ?? 0);
      totalScore.value += hazardsFound.value;
    } else {
      final earned = answeredCorrectly.value ? 1 : 0;
      roundScores.add(earned);
      roundTotals.add(1);
      totalScore.value += earned;
    }

    if (isLastRound) {
      gameState.value = GameState.finished;
    } else {
      gameState.value = GameState.roundComplete;
    }
  }

  // ─── Move to next round ───
  void nextRound() {
    currentRoundIndex.value++;
    _startRound();
  }

  // ─── Hazard actions ───
  void onSpotTapped(HazardSpot spot) {
    if (gameState.value != GameState.playing) return;
    if (tappedSpots.containsKey(spot.id)) return;

    tappedSpots[spot.id] = spot.isHazard;

    if (spot.isHazard) {
      hazardsFound.value++;
      // All hazards found — end round early
      if (hazardsFound.value >= (currentRound?.hazardRound?.totalHazards ?? 0)) {
        _finishRoundEarly();
      }
    }
  }

  // ─── Quiz actions ───
  void selectOption(String optionId) {
    if (hasAnswered.value || gameState.value != GameState.playing) return;

    selectedOptionId.value = optionId;
    hasAnswered.value = true;

    final question = currentRound?.quizQuestion;
    if (question != null && optionId == question.correctOptionId) {
      answeredCorrectly.value = true;
    }

    // Auto-finish round after short feedback delay
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (gameState.value == GameState.playing) {
        _finishRoundEarly();
      }
    });
  }

  bool isOptionCorrect(String optionId) {
    return currentRound?.quizQuestion?.correctOptionId == optionId;
  }

  bool isOptionSelected(String optionId) {
    return selectedOptionId.value == optionId;
  }

  // ─── Play again ───
  void playAgain() {
    totalScore.value = 0;
    totalPossible.value = 0;
    currentRoundIndex.value = 0;
    roundScores.clear();
    roundTotals.clear();
    _loadGame();
  }

  // ─── Exit ───
  void exitGame(BuildContext context) {
    AppNavigation.pop(context);
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}