// features/home/data/models/training_game_model.dart
class TrainingGameModel {
  final String id;
  final String title;
  final String description;
  final int lastScore;
  final String? gameUrl;

  TrainingGameModel({
    required this.id,
    required this.title,
    required this.description,
    required this.lastScore,
    this.gameUrl,
  });

  factory TrainingGameModel.fromJson(Map<String, dynamic> json) {
    return TrainingGameModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      lastScore: json['last_score'] ?? 0,
      gameUrl: json['game_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'last_score': lastScore,
      'game_url': gameUrl,
    };
  }

  static TrainingGameModel dummy() {
    return TrainingGameModel(
      id: '1',
      title: 'Spot the Hazard',
      description: 'Sharpen your safety eyes! Find 5 hazards in 30 seconds.',
      lastScore: 850,
      gameUrl: null,
    );
  }
}