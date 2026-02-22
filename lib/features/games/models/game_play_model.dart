// features/game/models/game_play_model.dart

/// A single hazard spot on the rig image
class HazardSpot {
  final String id;
  final double xPercent; // 0.0 - 1.0 relative to image width
  final double yPercent; // 0.0 - 1.0 relative to image height
  final String label;
  final bool isHazard;

  HazardSpot({
    required this.id,
    required this.xPercent,
    required this.yPercent,
    required this.label,
    this.isHazard = true,
  });

  factory HazardSpot.fromJson(Map<String, dynamic> json) {
    return HazardSpot(
      id: json['id']?.toString() ?? '',
      xPercent: (json['x_percent'] ?? 0.0).toDouble(),
      yPercent: (json['y_percent'] ?? 0.0).toDouble(),
      label: json['label'] ?? '',
      isHazard: json['is_hazard'] ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'x_percent': xPercent,
    'y_percent': yPercent,
    'label': label,
    'is_hazard': isHazard,
  };
}

/// Spot-the-hazard round data
class HazardRound {
  final String id;
  final String imagePath;
  final List<HazardSpot> spots;
  final int totalHazards;

  HazardRound({
    required this.id,
    required this.imagePath,
    required this.spots,
    required this.totalHazards,
  });

  factory HazardRound.fromJson(Map<String, dynamic> json) {
    return HazardRound(
      id: json['id']?.toString() ?? '',
      imagePath: json['image_path'] ?? '',
      spots: (json['spots'] as List<dynamic>?)
          ?.map((s) => HazardSpot.fromJson(s))
          .toList() ??
          [],
      totalHazards: json['total_hazards'] ?? 0,
    );
  }

  static HazardRound dummy() {
    return HazardRound(
      id: '1',
      imagePath: 'assets/images/rig_demo.png',
      spots: [
        HazardSpot(id: '1', xPercent: 0.15, yPercent: 0.25, label: 'Loose cable', isHazard: true),
        HazardSpot(id: '2', xPercent: 0.45, yPercent: 0.35, label: 'Missing guardrail', isHazard: true),
        HazardSpot(id: '3', xPercent: 0.70, yPercent: 0.20, label: 'Crane issue', isHazard: true),
        HazardSpot(id: '4', xPercent: 0.35, yPercent: 0.55, label: 'Spill hazard', isHazard: true),
        HazardSpot(id: '5', xPercent: 0.60, yPercent: 0.60, label: 'Fire risk', isHazard: true),
        HazardSpot(id: '6', xPercent: 0.25, yPercent: 0.70, label: 'Safe area', isHazard: false),
        HazardSpot(id: '7', xPercent: 0.80, yPercent: 0.50, label: 'Normal equipment', isHazard: false),
      ],
      totalHazards: 5,
    );
  }
}

/// A single quiz option
class QuizOption {
  final String id;
  final String label;
  final String emoji;

  QuizOption({
    required this.id,
    required this.label,
    required this.emoji,
  });

  factory QuizOption.fromJson(Map<String, dynamic> json) {
    return QuizOption(
      id: json['id']?.toString() ?? '',
      label: json['label'] ?? '',
      emoji: json['emoji'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'label': label, 'emoji': emoji};
}

/// A quiz question
class QuizQuestion {
  final String id;
  final String imagePath;
  final String question;
  final List<QuizOption> options;
  final String correctOptionId;

  QuizQuestion({
    required this.id,
    required this.imagePath,
    required this.question,
    required this.options,
    required this.correctOptionId,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      id: json['id']?.toString() ?? '',
      imagePath: json['image_path'] ?? '',
      question: json['question'] ?? '',
      options: (json['options'] as List<dynamic>?)
          ?.map((o) => QuizOption.fromJson(o))
          .toList() ??
          [],
      correctOptionId: json['correct_option_id']?.toString() ?? '',
    );
  }

  static QuizQuestion dummy() {
    return QuizQuestion(
      id: '1',
      imagePath: 'assets/images/rig_demo.png',
      question: 'What mechanical component is shown in the image?',
      options: [
        QuizOption(id: 'a', label: 'Hydraulic', emoji: '🔧'),
        QuizOption(id: 'b', label: 'Motor', emoji: '⚡'),
        QuizOption(id: 'c', label: 'Gearbox', emoji: '⚙️'),
        QuizOption(id: 'd', label: 'Fan', emoji: '💨'),
      ],
      correctOptionId: 'a',
    );
  }
}

/// Round type identifier
enum RoundType { hazard, quiz }

/// A single round — either a hazard-spot or a quiz question
class GameRound {
  final String id;
  final RoundType type;
  final HazardRound? hazardRound;
  final QuizQuestion? quizQuestion;

  GameRound({
    required this.id,
    required this.type,
    this.hazardRound,
    this.quizQuestion,
  });

  factory GameRound.fromJson(Map<String, dynamic> json) {
    final type = json['type'] == 'hazard' ? RoundType.hazard : RoundType.quiz;
    return GameRound(
      id: json['id']?.toString() ?? '',
      type: type,
      hazardRound: type == RoundType.hazard && json['hazard_data'] != null
          ? HazardRound.fromJson(json['hazard_data'])
          : null,
      quizQuestion: type == RoundType.quiz && json['quiz_data'] != null
          ? QuizQuestion.fromJson(json['quiz_data'])
          : null,
    );
  }

  /// Dummy: 1 hazard round → 1 quiz round
  /// Later replaced with API response
  static List<GameRound> dummyRounds() {
    return [
      GameRound(id: '1', type: RoundType.hazard, hazardRound: HazardRound.dummy()),
      GameRound(id: '2', type: RoundType.quiz, quizQuestion: QuizQuestion.dummy()),
    ];
  }
}