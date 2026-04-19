// client_rig_model.dart

class ClientModel {
  final int id;
  final String name;
  final List<RigModel> rigs;

  ClientModel({required this.id, required this.name, required this.rigs});

  factory ClientModel.fromJson(Map<String, dynamic> json) => ClientModel(
    id:   json["id"],
    name: json["name"] ?? '',
    rigs: (json["rigs"] as List<dynamic>? ?? [])
        .map((r) => RigModel.fromJson(r))
        .toList(),
  );

  @override
  bool operator ==(Object other) => other is ClientModel && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

class RigModel {
  final int id;
  final String name;
  final String location;

  RigModel({required this.id, required this.name, required this.location});

  factory RigModel.fromJson(Map<String, dynamic> json) => RigModel(
    id:       json["id"],
    name:     json["name"] ?? '',
    location: json["location"] ?? '',
  );

  @override
  bool operator ==(Object other) => other is RigModel && other.id == id;

  @override
  int get hashCode => id.hashCode;
}