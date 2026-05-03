
class CardTypeHazardAreaModel {
  final List<AreaModel> areas;
  final List<CardTypeModel> cardTypes;
  final List<HazardModel> hazards;

  CardTypeHazardAreaModel({
    required this.areas,
    required this.cardTypes,
    required this.hazards,
  });

  factory CardTypeHazardAreaModel.fromJson(Map<String, dynamic> json) {
    return CardTypeHazardAreaModel(
      areas: (json['area'] as List<dynamic>? ?? [])
          .map((e) => AreaModel.fromJson(e))
          .toList(),
      cardTypes: (json['cardType'] as List<dynamic>? ?? [])
          .map((e) => CardTypeModel.fromJson(e))
          .toList(),
      hazards: (json['hazard'] as List<dynamic>? ?? [])
          .map((e) => HazardModel.fromJson(e))
          .toList(),
    );
  }
}

class AreaModel {
  final int id;
  final String name;
  final String? color;

  AreaModel({required this.id, required this.name, this.color});

  factory AreaModel.fromJson(Map<String, dynamic> json) => AreaModel(
    id: json['id'] as int,
    name: json['name'] as String,
    color: json['color'] as String?,
  );

  // Used by SearchableMultiSelectDropdown as display label
  @override
  String toString() => name;
}

class CardTypeModel {
  final int id;
  final String name;

  CardTypeModel({required this.id, required this.name});

  factory CardTypeModel.fromJson(Map<String, dynamic> json) => CardTypeModel(
    id: json['id'] as int,
    name: json['name'] as String,
  );

  @override
  String toString() => name;
}

class HazardModel {
  final int id;
  final String name;

  HazardModel({required this.id, required this.name});

  factory HazardModel.fromJson(Map<String, dynamic> json) => HazardModel(
    id: json['id'] as int,
    name: json['name'] as String,
  );

  @override
  String toString() => name;
}