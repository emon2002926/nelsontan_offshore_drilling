class ActivityModel {
  final int id;
  final String name;

  ActivityModel({required this.id, required this.name});

  factory ActivityModel.fromJson(Map<String, dynamic> json) =>
      ActivityModel(id: json['id'], name: json['name']);
}

class DebriefTypeModel {
  final int id;
  final String name;

  DebriefTypeModel({required this.id, required this.name});

  factory DebriefTypeModel.fromJson(Map<String, dynamic> json) =>
      DebriefTypeModel(id: json['id'], name: json['name']);
}

class DebriefQuestionModel {
  final int id;
  final String question;
  final String placeholder;

  DebriefQuestionModel({
    required this.id,
    required this.question,
    required this.placeholder,
  });

  factory DebriefQuestionModel.fromJson(Map<String, dynamic> json) =>
      DebriefQuestionModel(
        id:          json['id'],
        question:    json['question'] ?? '',
        placeholder: json['placeholder'] ?? 'Type here...',
      );
}