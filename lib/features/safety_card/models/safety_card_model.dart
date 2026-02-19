// features/safety_card/data/models/safety_card_model.dart
class SafetyCardModel {
  final String? cardType;
  final String? areaOfObservation;
  final List<String> hazardCategories; // Changed from String to List<String>
  final String? description;
  final String? riskSeverity;
  final String? photoPath;
  final bool actionTaken;
  final bool immediateActionRequired;
  final bool submitAnonymously;

  SafetyCardModel({
    this.cardType,
    this.areaOfObservation,
    required this.hazardCategories, // Changed to required list
    this.description,
    this.riskSeverity,
    this.photoPath,
    this.actionTaken = false,
    this.immediateActionRequired = false,
    this.submitAnonymously = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'cardType': cardType,
      'areaOfObservation': areaOfObservation,
      'hazardCategories': hazardCategories, // Now returns list
      'description': description,
      'riskSeverity': riskSeverity,
      'photoPath': photoPath,
      'actionTaken': actionTaken,
      'immediateActionRequired': immediateActionRequired,
      'submitAnonymously': submitAnonymously,
    };
  }

  factory SafetyCardModel.fromJson(Map<String, dynamic> json) {
    return SafetyCardModel(
      cardType: json['cardType'],
      areaOfObservation: json['areaOfObservation'],
      hazardCategories: List<String>.from(json['hazardCategories'] ?? []), // Parse list
      description: json['description'],
      riskSeverity: json['riskSeverity'],
      photoPath: json['photoPath'],
      actionTaken: json['actionTaken'] ?? false,
      immediateActionRequired: json['immediateActionRequired'] ?? false,
      submitAnonymously: json['submitAnonymously'] ?? false,
    );
  }
}