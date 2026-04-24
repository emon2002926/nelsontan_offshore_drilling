// ── GET /game puzzle data ─────────────────────────────────────────────────────

import 'dart:convert';

class PuzzleModel {
  final int id;
  final String image;
  final String title;
  final List<PuzzleMark> marks; // correct hazard positions from server
  final int time;

  PuzzleModel({
    required this.id,
    required this.image,
    required this.title,
    required this.marks,
    required this.time,
  });

  factory PuzzleModel.fromJson(Map<String, dynamic> json) {
    // marks comes as a JSON string — needs decoding
    final rawMarks = json['marks'];
    List<PuzzleMark> parsedMarks = [];
    if (rawMarks is String) {
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
    );
  }
}

class PuzzleMark {
  final double x; // percentage 0-100
  final double y; // percentage 0-100

  PuzzleMark({required this.x, required this.y});

  factory PuzzleMark.fromJson(Map<String, dynamic> json) => PuzzleMark(
    x: (json['x'] as num).toDouble(),
    y: (json['y'] as num).toDouble(),
  );

  Map<String, dynamic> toJson() => {'x': x, 'y': y};
}

// ── POST /game/puzzle-submit request ─────────────────────────────────────────

class PuzzleSubmitRequest {
  final List<PuzzleSubmitItem> puzzles;

  PuzzleSubmitRequest({required this.puzzles});

  Map<String, dynamic> toJson() => {
    'puzzles': puzzles.map((p) => p.toJson()).toList(),
  };
}

class PuzzleSubmitItem {
  final int puzzleId;
  final List<PuzzleMark> marks; // user's tap coordinates

  PuzzleSubmitItem({required this.puzzleId, required this.marks});

  Map<String, dynamic> toJson() => {
    'puzzleId': puzzleId,
    'marks': marks.map((m) => m.toJson()).toList(),
  };
}

// ── POST /game/puzzle-submit response (placeholder — update when API is ready) ─

class PuzzleResultModel {
  final int score;
  final int totalPuzzles;
  final String message;

  PuzzleResultModel({
    required this.score,
    required this.totalPuzzles,
    required this.message,
  });

  factory PuzzleResultModel.fromJson(Map<String, dynamic> json) =>
      PuzzleResultModel(
        score: json['score'] as int? ?? 0,
        totalPuzzles: json['totalPuzzles'] as int? ?? 0,
        message: json['message'] as String? ?? '',
      );
}