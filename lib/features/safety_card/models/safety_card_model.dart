// features/safety_card/data/models/safety_card_model.dart
class SafetyCardModel {
  final String? cardType;
  final String? areaOfObservation;
  final String? hazardCategory;
  final String? description;
  final String? riskSeverity;
  final String? photoPath;
  final bool actionTaken;
  final bool immediateActionRequired;
  final bool submitAnonymously;

  SafetyCardModel({
    this.cardType,
    this.areaOfObservation,
    this.hazardCategory,
    this.description,
    this.riskSeverity,
    this.photoPath,
    this.actionTaken = false,
    this.immediateActionRequired = false,
    this.submitAnonymously = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'card_type': cardType,
      'area_of_observation': areaOfObservation,
      'hazard_category': hazardCategory,
      'description': description,
      'risk_severity': riskSeverity,
      'photo_path': photoPath,
      'action_taken': actionTaken,
      'immediate_action_required': immediateActionRequired,
      'submit_anonymously': submitAnonymously,
    };
  }
}