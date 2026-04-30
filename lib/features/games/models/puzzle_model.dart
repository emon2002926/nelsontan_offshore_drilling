
import 'dart:convert';

import 'dart:convert';

class PuzzleModel {
  final int id;
  final String image;
  final String title;
  final List<PuzzleMark> marks;
  final int time;
  final int marksLength; // max taps user is allowed

  PuzzleModel({
    required this.id,
    required this.image,
    required this.title,
    required this.marks,
    required this.time,
    required this.marksLength,
  });

  factory PuzzleModel.fromJson(Map<String, dynamic> json) {
    final rawMarks = json['marks'];
    List<PuzzleMark> parsedMarks = [];
    if (rawMarks is List) {
      parsedMarks = rawMarks
          .map((e) => PuzzleMark.fromJson(e as Map<String, dynamic>))
          .toList();
    } else if (rawMarks is String) {
      final decoded = jsonDecode(rawMarks) as List<dynamic>;
      parsedMarks = decoded
          .map((e) => PuzzleMark.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return PuzzleModel(
      id: json['id'] as int,
      image: json['image'] as String,
      title: json['title'] as String,
      marks: parsedMarks,
      time: json['time'] as int? ?? 60,
      // fallback to marks.length if marksLength not present
      marksLength: json['marksLength'] as int? ?? parsedMarks.length,
    );
  }
}

class PuzzleMark {
  final double x;
  final double y;
  final double radiusX;
  final double radiusY;

  PuzzleMark({
    required this.x,
    required this.y,
    required this.radiusX,
    required this.radiusY,
  });

  factory PuzzleMark.fromJson(Map<String, dynamic> json) => PuzzleMark(
    x:       (json['x'] as num).toDouble(),
    y:       (json['y'] as num).toDouble(),
    radiusX: (json['radiusX'] as num?)?.toDouble() ?? 5.0,
    radiusY: (json['radiusY'] as num?)?.toDouble() ?? 5.0,
  );

  bool containsTap(double tapX, double tapY) {
    final dx = (tapX - x) / radiusX;
    final dy = (tapY - y) / radiusY;
    return (dx * dx + dy * dy) <= 1.0;
  }
}

enum TapResult { correct, wrong }

class UserTap {
  final double x;
  final double y;
  final TapResult result;

  UserTap({required this.x, required this.y, required this.result});
}

class PuzzleSubmitRequest {
  final List<PuzzleSubmitItem> puzzles;

  PuzzleSubmitRequest({required this.puzzles});

  Map<String, dynamic> toJson() => {
    'puzzles': puzzles.map((p) => p.toJson()).toList(),
  };
}

class PuzzleSubmitItem {
  final int puzzleId;
  final int correct;
  final int wrong;

  PuzzleSubmitItem({
    required this.puzzleId,
    required this.correct,
    required this.wrong,
  });

  Map<String, dynamic> toJson() => {
    'puzzleId': puzzleId,
    'currect': correct,
    'worng': wrong,
  };
}

class PuzzleResultModel {
  final double percentage;
  final int totalPuzzles;
  final int totalCorrect;
  final int totalWrong;
  final int totalMissed;
  final int score;
  final int totalPossibleScore;

  PuzzleResultModel({
    required this.percentage,
    required this.totalPuzzles,
    required this.totalCorrect,
    required this.totalWrong,
    required this.totalMissed,
    required this.score,
    required this.totalPossibleScore,
  });

  factory PuzzleResultModel.fromJson(Map<String, dynamic> json) =>
      PuzzleResultModel(
        percentage:         (json['percentage'] as num?)?.toDouble() ?? 0,
        totalPuzzles:       json['totalPuzzles'] as int? ?? 0,
        totalCorrect:       json['totalCorrect'] as int? ?? 0,
        totalWrong:         json['totalWrong'] as int? ?? 0,
        totalMissed:        json['totalMissed'] as int? ?? 0,
        score:              json['score'] as int? ?? 0,
        totalPossibleScore: json['totalPossibleScore'] as int? ?? 0,
      );
}