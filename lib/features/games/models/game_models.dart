// ── GET /game response ────────────────────────────────────────────────────────

class GameScheduleModel {
  final int id;
  final String scheduledFor;
  final String gameType;
  final List<GameQuestion> questions;

  GameScheduleModel({
    required this.id,
    required this.scheduledFor,
    required this.gameType,
    required this.questions,
  });

  factory GameScheduleModel.fromJson(Map<String, dynamic> json) {
    return GameScheduleModel(
      id: json['id'] as int,
      scheduledFor: json['scheduledFor'] as String,
      gameType: json['gameType'] as String,
      questions: (json['questions'] as List<dynamic>? ?? [])
          .map((e) => GameQuestion.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class GameQuestion {
  final int id;
  final String? image;
  final String question;
  final String option1;
  final String option2;
  final String option3;
  final String option4;
  final int correctAnswer; // 1-based
  final int time;

  GameQuestion({
    required this.id,
    this.image,
    required this.question,
    required this.option1,
    required this.option2,
    required this.option3,
    required this.option4,
    required this.correctAnswer,
    required this.time,
  });

  factory GameQuestion.fromJson(Map<String, dynamic> json) => GameQuestion(
    id: json['id'] as int,
    image: json['image'] as String?,
    question: json['question'] as String,
    option1: json['option1'] as String,
    option2: json['option2'] as String,
    option3: json['option3'] as String,
    option4: json['option4'] as String,
    correctAnswer: json['correctAnswer'] as int,
    time: json['time'] as int? ?? 30,
  );

  List<String> get options => [option1, option2, option3, option4];
}

// ── POST /game/question-submit request ────────────────────────────────────────

class GameAnswerRequest {
  final List<GameAnswerItem> answers;

  GameAnswerRequest({required this.answers});

  Map<String, dynamic> toJson() => {
    'answer': answers.map((a) => a.toJson()).toList(),
  };
}

class GameAnswerItem {
  final int questionId;
  final int correctAnswer; // the option index user selected (1-based)

  GameAnswerItem({required this.questionId, required this.correctAnswer});

  Map<String, dynamic> toJson() => {
    'questionId': questionId,
    'correctAnswer': correctAnswer,
  };
}

// ── POST /game/question-submit response ───────────────────────────────────────

class GameResultModel {
  final double percentage;
  final int totalQuestions;
  final int correctAnswers;
  final int wrongAnswers;
  final int score;
  final List<GameQuestionResult> results;

  GameResultModel({
    required this.percentage,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.wrongAnswers,
    required this.score,
    required this.results,
  });

  factory GameResultModel.fromJson(Map<String, dynamic> json) {
    return GameResultModel(
      percentage: (json['percentage'] as num).toDouble(),
      totalQuestions: json['totalQuestions'] as int,
      correctAnswers: json['correctAnswers'] as int,
      wrongAnswers: json['wrongAnswers'] as int,
      score: json['score'] as int,
      results: (json['results'] as List<dynamic>? ?? [])
          .map((e) => GameQuestionResult.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class GameQuestionResult {
  final int id;
  final String question;
  final String option1;
  final String option2;
  final String option3;
  final String option4;
  final String correctAnswerText;
  final int userAnswer;
  final String userAnswerText;
  final bool isCorrect;

  GameQuestionResult({
    required this.id,
    required this.question,
    required this.option1,
    required this.option2,
    required this.option3,
    required this.option4,
    required this.correctAnswerText,
    required this.userAnswer,
    required this.userAnswerText,
    required this.isCorrect,
  });

  factory GameQuestionResult.fromJson(Map<String, dynamic> json) =>
      GameQuestionResult(
        id: json['id'] as int,
        question: json['question'] as String,
        option1: json['option1'] as String,
        option2: json['option2'] as String,
        option3: json['option3'] as String,
        option4: json['option4'] as String,
        correctAnswerText: json['correctAnswerText'] as String,
        userAnswer: json['userAnswer'] as int,
        userAnswerText: json['userAnswerText'] as String,
        isCorrect: json['isCorrect'] as bool,
      );
}